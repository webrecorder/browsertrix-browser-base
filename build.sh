#!/bin/bash
export BROWSER=brave
export BROWSER_VERSION=$(cat ./brave-version.txt)
# build just for local platform
docker buildx build --target=$BROWSER --build-arg BROWSER=$BROWSER --build-arg BROWSER_VERSION=$BROWSER_VERSION --progress plain --load -t webrecorder/browsertrix-browser-base:${BROWSER}-${BROWSER_VERSION} .

