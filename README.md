# Janus Bandwidth Throttling

A [Janus](https://github.com/meetecho/janus-gateway) setup that allows testing scenarios with limited network bandwidth (aka traffic shaping / network conditioning).
This is achieved by using [Docker](https://www.docker.com/) and the [wondershaper](http://manpages.ubuntu.com/manpages/trusty/man8/wondershaper.8.html) commandline utility. All components (server and browser) can run directly on your development machine for more control.

## Pre Requirements

You need to have [Docker or Docker Desktop](https://docs.docker.com/get-docker/) installed on your machine (available for Mac, Windows and Linux).

## Build Container

Checkout this repo and enter its directory. Then run:
```
docker build -t janus-network-limiting .
```
If you want to test a specific Janus version (git tag oder branch) you can specify as follows:
```
docker build --build-arg JANUS_BRANCH=<YOUR-GIT-TAG-OF-CHOICE> -t janus-network-limiting .
```

## Run
Start the container as follows. The `DOWNLOAD_LIMIT` and `UPLOAD_LIMIT` parameters can have any value you like.
```
docker run --env DOWNLOAD_LIMIT=8192 --env UPLOAD_LIMIT=4096  --rm --cap-add=NET_ADMIN -dp 8000:8000 -dp 8088:8088 --expose=20000-40000 janus-network-limiting
```

After that, navigate to http://localhost:8000/ and test any Janus Demo you'd like.

## Change the limit at runtime

You can change the limits for upload and download at any time: 

1. Find the ID of the running docker container: `docker ps`
2. Open a bash shell in the running docker container:
`
docker exec -i -t <CONTAINER ID> /bin/bash
`
   
3. Set the new limit: `wondershaper eth0 <DOWNLOAD_LIMIT> <UPLOAD_LIMIT>`

## Hints + Troubleshooting

- Keep in mind, that we limit the server side here. The browser or _user perspective_ is the other way round.
- Limiting the servers **upload** means that the maximum download-speed for clients gets limited.
- When multiple peers join a video session, the limited bandwith must be shared between all peers.
- In the local video element, select *'Bandwidth: No limit'* to make sure no additional limits from the demo come into play.
- When running the container, you may be tempted to use *host networking* instead defining all the port forwarding. But be aware, that the *host network* mode is not fully supported on all platforms (eg. macOS). 

## How to limit one peer only?

The setup above limits bandwidth at server side and therefore always effects all peers. If you want to limit only one specific peer instead, you will need to modify the setup. 

What you can do is:
- Setup a virtual ubuntu machine for the peer to be limited.
- Install wondershaper on vm: `sudo apt-get install wondershaper`
- Set a limit in the vm: `wondershaper <INTERFACE> <DOWNLOAD_LIMIT> <UPLOAD_LIMIT>`
- Start chromium with the local Janus IP whitelisted: `chromium --unsafely-treat-incure-origin-as-secure="http://<HOST-IP>:8000"`
