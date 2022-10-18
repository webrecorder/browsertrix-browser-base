#!/bin/bash
export VERSION=105
# build just for local platform
docker buildx build --build-arg VERSION=$VERSION --progress simple --load -t webrecorder/browsertrix-browser-base:$VERSION .

