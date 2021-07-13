FROM ubuntu:20.10

ENV DOWNLOAD_LIMIT=8192
ENV UPLOAD_LIMIT=4096

ARG JANUS_BRANCH=master
ARG JANUS_REPO=https://github.com/meetecho/janus-gateway.git

WORKDIR /app

# Import scripts
COPY . .

# Install docker specific dependencies
RUN apt-get update && apt-get install -y sudo
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata
RUN apt-get install -y php wondershaper

# Install Janus
RUN sh janus-setup-linux.sh

# Make ports available to the world outside this container
EXPOSE 8000
EXPOSE 8088
EXPOSE 8188
EXPOSE 20000-40000

# Run Janus when the container launches
CMD sh cmd.sh
