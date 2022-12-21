#!/bin/bash
export BROWSER=brave
export BROWSER_VERSION=latest
# build for amd64 + arm64 platforms
docker buildx build --target=$BROWSER --build-arg BROWSER=$BROWSER --build-arg BROWSER_VERSION=$BROWSER_VERSION --platform linux/amd64,linux/arm64 --push -t webrecorder/browsertrix-browser-base:${BROWSER}-${BROWSER_VERSION} .

