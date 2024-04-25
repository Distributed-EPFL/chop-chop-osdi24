#!/bin/bash
#
#   install.sh - install a Chop Chop node (any type)
#
#   Install Chop Chop and its dependencies assuming the 'chop-chop' directory
#   is present and contains the source code.
#


set -e


# Install Silk ----------------------------------------------------------------
#

sudo apt install -yy 'git' 'golang-1.18' 'make'

sudo ln -s '/usr/lib/go-1.18/bin/go' '/usr/bin/go'

git clone 'https://github.com/Blockchain-Benchmarking/silk.git' 'silk'
(
    cd 'silk'

    make all

    sudo make install prefix='/usr'
)


# Install Chop Chop -----------------------------------------------------------
#

sudo apt install -y 'build-essential' 'curl' 'git'
curl --proto '=https' --tlsv1.2 -sSf 'https://sh.rustup.rs' | sh -s -- -y
. "$HOME/.cargo/env"
rustup default 1.77.0

(
    cd 'chop-chop'

    export CHOP_CHOP_MESSAGE_SIZE=8

    cargo build --release --all-features
)


# Install Bft-SMaRt (Chop Chop tobcast version) -------------------------------
#

sudo apt install -yy 'git' 'openjdk-16-jdk'
sudo update-java-alternatives --set '/usr/lib/jvm/java-1.16.0-openjdk-amd64'

git clone 'https://github.com/gauthier-voron/bftsmart-tobcast.git' 'bftsmart'
(
    cd 'bftsmart'

    ./gradlew installDist

    gradle_pid=$(ps -eo pid,cmd | grep gradle | grep -v grep \
		     | awk '{$1=$1};1' | cut -d' ' -f1)

    if [ "x${gradle_pid}" != 'x' ] ; then
	kill ${gradle_pid}
    fi
)

sed -ri -e \
    "s/^system\.totalordermulticast\.timeout.*/system.totalordermulticast.timeout = 1000000000/" \
    'bftsmart/build/install/library/config/system.config'


# Install HotStuff (Chop Chop tobcast version) --------------------------------
#

sudo apt install -y 'autoconf' 'cmake' 'g++' 'gcc' 'git' 'libboost-all-dev' \
     'libssl-dev' 'libtool' 'libuv1-dev' 'make' 'python3'

git clone 'https://github.com/gauthier-voron/hotstuff-tobcast.git' 'hotstuff'
(
    cd 'hotstuff'

    git checkout 'tobcast'
    git submodule update --init --recursive

    cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED=ON \
          -DHOTSTUFF_DEBUG_LOG=ON

    make -j$(( $(grep '^processor' '/proc/cpuinfo' | wc -l) * 2 ))
)


# The following commands are intended for real distributed development but are
# useless for a local Docker deployment.
# These are the settings used in the Chop Chop paper.

# Enable Linux Transparent Huge Pages.
# This is required to execute the application over huge memory areas without
# causing too many TLB misses.
#
#echo 'always' | sudo tee /sys/kernel/mm/transparent_hugepage/enabled

# Increase the memory size for network buffers.
# This is a common optimization for distributed systems deployed worldwide and
# required to deal with huge round-trip times of these setups.
#
#sudo sysctl net.core.rmem_default=67108864
#sudo sysctl net.core.wmem_default=67108864
#sudo sysctl net.core.rmem_max=67108864
#sudo sysctl net.core.wmem_max=67108864
#sudo sysctl net.ipv4.tcp_rmem='67108864 67108864 67108864'
#sudo sysctl net.ipv4.tcp_wmem='67108864 67108864 67108864'
#
#sudo sysctl net.ipv4.tcp_slow_start_after_idle=0
#
#sudo sysctl -w net.core.rmem_default=10485760
#sudo sysctl -w net.core.wmem_default=10485760

# Rise up number of file descriptor per process.
# Large scale consensus systems have a tendency to open sockets.
#
#echo 'ulimit -n 65535' >> '.profile'
