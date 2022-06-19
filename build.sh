#!/bin/bash
export VERSION=101
# build just for local platform
docker buildx build --build-arg VERSION=$VERSION --load -t webrecorder/browsertrix-browser-base:$VERSION .

