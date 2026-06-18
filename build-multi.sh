#!/bin/bash
export BROWSER_NAME=brave-origin
export BROWSER_VERSION=$(cat ./brave-version.txt)
# build for amd64 + arm64 platforms
docker buildx build --target=brave --build-arg BROWSER_NAME=$BROWSER_NAME --build-arg BROWSER_VERSION=$BROWSER_VERSION --platform linux/amd64,linux/arm64 --push -t webrecorder/browsertrix-browser-base:${BROWSER}-${BROWSER_VERSION} .

