docker run --env DOWNLOAD_LIMIT=8192 --env UPLOAD_LIMIT=4096  --rm -v `pwd`:/app/ --cap-add=NET_ADMIN -dp 8000:8000 -dp 8088:8088 --expose=20000-40000 janus-network-limiting
