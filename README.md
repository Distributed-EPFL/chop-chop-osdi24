Chop Chop Artifact
==================

**Important** Chop Chop is publicly available under an academic
non-commercial license.
To get a copy of the source code, please fill the LICENSE.pdf document and send
it to <gauthier.voron@epfl.ch>.

This repository and the Chop Chop repository contains the artifact for the
paper: [Chop Chop: Byzantine Atomic Broadcast to the Network Limit](https://arxiv.org/pdf/2304.07081).


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

Detailed instructions about system and workload generation can be found in the
main Chop Chop repository.

The `docker-generate.sh` script automatically generates a system and some
pre-processed batches based on the setup file and experiment settings.
Under the hood, it calls the `script/control-generate` script from a Docker
container.

Feel free to inspect the `script/control-generate` to understand better how
each parameter is set or to use it for a real workd deployment.

To generate the assets for the example setup and settings:

    ./docker-generate.sh example/setup.txt example/settings.sh assets

The pre-processed batches generation is CPU intensive and time consuming.
Also, the generated files can be large for big or long experiments.
For the files in the 'example' directory, the generation can take between 5 min
and 30 min depending on your machine.


### Starting the Docker network

This step start a private Docker network as specified in the setup file.
It also imports the setup file, the experiment settings and the generated
assets if provided.

    ./docker-run.sh example/setup.txt example/settings.sh assets

Under the hood, this command starts several Docker containers plus an
additional container used as a control node.
This control node immediately executes `docker-init.sh`.
This short script configures all the nodes in the network with Silk so they
know their role and optionally send the assets to every node.
A similar process should be followed for real world deployment.

Exiting the prompt of the control node deletes the network.


### Running the experiment

To run an experiment, make sure all nodes have the appropriate assets in an
'assets' directory then run the following command:

    ./script/control-benchmark mnt/setup.txt mnt/settings.txt env.sh

The 'env.sh' file is created by `docker-init.sh`.
If you are using a real world deployment, make sure to follow the same process
as this script.
The previous command creates a directory ending with a '.result' containing the
log files for every node in the system.

This command follows the step described in the main Chop Chop repository but
in an automated way.


### Plotting the results

To plot the results obtained from the previous steps, follow the instructions
in the [dedicated repository](https://github.com/Distributed-EPFL/chop-chop-plots).
