Chop Chop Artifact
==================

**Important** Chop Chop is publicly available under an academic
non-commercial license.
To get a copy of the source code, please fill the LICENSE.pdf document and send
it to <gauthier.voron@epfl.ch>.


Quick start
-----------

Follow the instructions in the Chop Chop repository, available after filling
and sending the LICENSE.pdf document.


Distributed deployment
----------------------

This repository contains the scripts to proceed to a distributed deployment.
Although these scripts would work in a realistic deployment, a local virtual
network is more convenient and less expensive for testing.
To this purpose, this repository also contains the scripts necessary to deploy
a local Docker network and run Chop Chop inside of it.


### Defining the setup

The scripts of this repository use two files to define the experimental setup,
i.e. the IP and role of each machine and the experiment settings, i.e. the
throughput, etc...
The 'example' directory contain an example of each.

The setup file is a text file where each non-empty line defines either the
Docker network or a system node.

The Docker network line is used by the Docker specific scripts to create an
appropriate Docker network and are ignored by the other scripts.
It has the following form:

    network  <subnet>/<mask>

The node lines describe what nodes are present in the system and what role they
have.
They have the following form:

    <role>  <ip>  [broker=<ip>]

where role is one of `rendezvous`, `server`, `load-broker`, `honest-broker`,
`load-client` or `honest-client`, the ip is a valid IP address within the
network.
Client nodes (load or honest) also need to know what broker to connect to.
For these nodes, this information is specified with the `broker=<ip>` part.

The settings file describes the experiment parameters.
See the main Chop Chop repository README for detailed explanation about these
parameters.


### Installing the binaries

First make sure that you have Docker installed and the docker daemon running.
Also make sure that you have enough disk space to build the image. It typically
takes 6 GiB.

Make sure that you have a 'chop-chop' directory that contains the Chop Chop
source code (see at the top of this README) and run the following command.

    docker build -t chop-chop .

This compiles all the binaries required to run Chop Chop.
It essentially consists in running the 'install.sh' script which can also be
used to install the binaries on machines in a real world deployment.
It can take some time, between 5 min and 30 min depending on your machine.


### Generating the system and workload



    ./docker-generate.sh example/setup.txt example/settings.sh assets

    ./docker-run.sh example/setup.txt example/settings.sh assets

    ./script/control-benchmark mnt/setup.txt mnt/settings.txt env.sh