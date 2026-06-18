#!/bin/bash
export BROWSER_NAME=brave-origin
export BROWSER_VERSION=$(cat ./brave-version.txt)
# build just for local platform
docker buildx build --target=brave --build-arg BROWSER_NAME=$BROWSER_NAME --build-arg BROWSER_VERSION=$BROWSER_VERSION --progress plain --load -t webrecorder/browsertrix-browser-base:brave-${BROWSER_VERSION} .

