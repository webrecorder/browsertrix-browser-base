#!/bin/bash
export VERSION=101
# build for amd64 + arm64 platforms
docker buildx build --build-arg VERSION=$VERSION --platform linux/amd64,linux/arm64 --push -t webrecorder/browsertrix-browser-base:$VERSION .

