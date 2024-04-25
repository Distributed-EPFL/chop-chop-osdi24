FROM ubuntu:20.04

# Install `sudo` and create a 'ubuntu' user.
# Further operations are done by this 'ubuntu' user.
# This make the Docker setup similar to an AWS EC2 instance.
#
RUN apt update
RUN apt install -yy sudo
RUN useradd --groups sudo --create-home --user-group --shell /bin/bash ubuntu
RUN passwd --delete ubuntu

RUN DEBIAN_FRONTEND=noninteractive apt install -yy tzdata

# Copy the source code of Chop Chop inside the container and give access to the
# 'ubuntu' user.
#
COPY chop-chop /home/ubuntu/chop-chop
RUN chown -R ubuntu:ubuntu /home/ubuntu/chop-chop

# As user 'ubuntu', run the 'install.sh' script.
# This downloads the TOBcast systems used by Chop Chop and the Silk utility and
# compile them as well as Chop Chop
#
USER ubuntu
WORKDIR /home/ubuntu
COPY install.sh /tmp/install.sh
RUN /tmp/install.sh

# Expose Silk port
EXPOSE 3200
# Export TOBcast ports (BFT-SMaRt and HotStuff)
EXPOSE 7000 9000
# Export Chop Chop ports (server and broker)
EXPOSE 1234 9500

# By default, a container boots by running a Silk server.
# Remote containers can then use Silk to command this container.
#
ENV SHELL="/bin/bash"
CMD ["/usr/bin/silk", "server", "--tcp=3200", "--verbose=trace", "--log=/home/ubuntu/silk.log"]
