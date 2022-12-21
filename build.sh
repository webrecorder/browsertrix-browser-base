#!/bin/bash
export BROWSER=brave
export BROWSER_VERSION=latest
# build just for local platform
docker buildx build --target=$BROWSER --build-arg BROWSER=$BROWSER --build-arg BROWSER_VERSION=$BROWSER_VERSION --progress simple --load -t webrecorder/browsertrix-browser-base:${BROWSER}-${BROWSER_VERSION} .

