#!/bin/bash

# Error Handling
clean_up() {
  echo "Cleaning Up..."
  kill -TERM "$webserverprocess" 2>/dev/null
  kill -TERM "$janusprocess" 2>/dev/null
	exit
}

trap clean_up SIGHUP SIGINT SIGTERM TERM SIGKILL KILL

# Network limiting
echo "Limiting download speed to $DOWNLOAD_LIMIT and upload speed to $UPLOAD_LIMIT"
wondershaper eth0 $DOWNLOAD_LIMIT $UPLOAD_LIMIT

# Start Webserver (serve HTML files)
cd /opt/janus/share/janus/demos
php -S 0.0.0.0:8000 &
webserverprocess=$!

# Start Janus
/opt/janus/bin/janus --libnice-debug --rtp-port-range=20000-40000 --debug-level=5 &
janusprocess=$!
wait "$janusprocess"
