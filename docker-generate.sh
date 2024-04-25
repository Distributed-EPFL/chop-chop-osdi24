#!/bin/bash
#
#
#

set -e


IMAGE_NAME='chop-chop'


setup_path="$1" ; shift

settings_path="$1" ; shift

output_path="$1" ; shift


mkdir "${output_path}"


tmpdir="$(mktemp -d --suffix='.d' "${0##*/}.XXXXXX")"
trap "rm -rf '${tmpdir}'" 'EXIT'


cp "${setup_path}" "${tmpdir}/setup.txt"

cp "${settings_path}" "${tmpdir}/settings.sh"

cat > "${tmpdir}/generate.sh" <<EOF
#!/bin/bash

./tools/control-generate './mnt/setup.txt' './mnt/settings.sh' \\
    './mnt/passepartout.db' \\
    './mnt/membership.db' \\
    './mnt/directory.db' \\
    './mnt/flows'
EOF

chmod 755 "${tmpdir}/generate.sh"


sudo docker run \
     -it \
     --rm \
     --mount type=bind,source="${PWD}/${tmpdir}",target='/home/ubuntu/mnt' \
     --mount type=bind,source="${PWD}/script",target='/home/ubuntu/tools' \
     --entrypoint='/home/ubuntu/mnt/generate.sh' \
     "${IMAGE_NAME}"


mv "${tmpdir}/passepartout.db" "${output_path}"
mv "${tmpdir}/membership.db" "${output_path}"
mv "${tmpdir}/directory.db" "${output_path}"
mv "${tmpdir}/flows" "${output_path}"
