#!/bin/bash
#
#   run-local.sh - run a local docker network for small scale experiments
#
#   Syntax: ./run-local.sh
#


set -e


IMAGE_NAME='chop-chop'

NETWORK_NAME='chop-chop-network'

ROLES=(
    'rendezvous'
    'server'
    'load-broker' 'honest-broker'
    'load-client' 'honest-client'
)


setup_path="$1" ; shift

settings_path="$1" ; shift

assets="$1"


tmpdir=


# Cleanup phase
#
# The cleanup routine is implemented in a subroutine which is called when the
# script exits.
#
atexit() {
    set +e

    echo ":: Cleanup" >&2

    echo "==> Kill nodes" >&2
    sudo docker inspect --format='{{ range $key, $value := .Containers }}{{ printf "%s\n" $key}}{{ end }}' "$(cat "${tmpdir}/network")" \
	| while read container
    do
	if [ "x${container}" = 'x' ] ; then
	    continue
	fi
	printf '  -> ' >&2
	sudo docker container kill "${container}"
    done

    echo "==> Remove network '${NETWORK_NAME}'" >&2
    printf '  -> ' >&2
    sudo docker network rm "$(cat "${tmpdir}/network")" >&2

    echo "==> Delete temporary working directory: '${tmpdir}'" >&2
    if [ "x${tmpdir}" != 'x' ] ; then
	rm -rf "${tmpdir}"
    fi
}

trap atexit 'EXIT'


# Setup phase -----------------------------------------------------------------
#
# Create the virtual network with all the nodes specified in the setup file.
#
echo ":: Setup" >&2


# Create a temp directory where to put all the working files during the
# execution of the script.
# It is cleaned up automatically at the script exit.
#
printf '==> Create temporary working directory: ' >&2
tmpdir="$(mktemp -d --suffix='.d' "${0##*/}.XXXXXX")"
echo "'${tmpdir}'" >&2


# Create a Docker virtual network where the future Docker containers will
# attach to form a test environment.
# The subnet is specified in the setup file with a line:
#
#   network  <ip>/<mask>
#
# The Docker id of the network is stored in the temp directory. 
#
grep '^network' "${setup_path}" | while read _ ip ; do
    echo "==> Create network '${NETWORK_NAME}'" >&2

    sudo docker network create \
	 --attachable \
	 --subnet="${ip}" \
	 "${NETWORK_NAME}" \
	 > "${tmpdir}/network"

    echo "  -> $(cat "${tmpdir}/network")" >&2
done


# Create the Docker contrainers which run the nodes.
# For each container, boot it with the default entry point which is a Silk
# server then invoke a script command (in another container for convenience)
# to set 5 properties as key/values:
#
#     role          role of the node in the setup, e.g. server, etc...
#     id            id of the node within its role, starting from 0
#     ip            ip address of the node
#     silk_port     tcp port where Silk listens
#     target        for clients, the IP of the broker to connect to
#

echo "==> Create nodes" >&2
while read role ip _ ; do
    # Do not consider the line indicating the network or empty lines
    #
    if [ "x${role}" = 'x' -o "x${role}" = 'xnetwork' ] ; then
	continue
    fi

    # Boot the container.
    #
    printf "  -> " >&2
    sudo docker run \
	 --detach \
	 --rm \
	 --network="${NETWORK_NAME}" \
	 --ip="${ip}" \
	 --mount type=bind,source="${PWD}/script",target='/home/ubuntu/script' \
	 "${IMAGE_NAME}" \
	 >&2
done < "${setup_path}"


# Create the control node.
#
# This Docker container starts in interactive mode.
# You should use this node to start experiments with the script included.
#
# When you exit the interactive shell of this container, it shuts down and the
# cleanup phase starts.
#
echo "==> Create control node" >&2

if [ -e "${tmpdir}/mnt" ] ; then
    rm -rf "${tmpdir}/mnt"
fi
mkdir "${tmpdir}/mnt"

cp "${setup_path}" "${tmpdir}/mnt/setup.txt"
cp "${settings_path}" "${tmpdir}/mnt/settings.txt"

if [ "x${assets}" != 'x' ] ; then
    cp -R --link "${assets}" "${tmpdir}/mnt/assets"
fi

sudo docker run \
     -it \
     --rm \
     --mount type=bind,source="${PWD}/${tmpdir}/mnt",target='/home/ubuntu/mnt' \
     --mount type=bind,source="${PWD}/script",target='/home/ubuntu/script' \
     --mount type=bind,source="${PWD}/docker-init.sh",target='/home/ubuntu/init.sh' \
     --network="${NETWORK_NAME}" \
     --entrypoint='/home/ubuntu/init.sh' \
     "${IMAGE_NAME}"
