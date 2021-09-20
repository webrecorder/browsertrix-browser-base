# Base Browser for Browsertrix Crawler

This repository contains the base platform-specific deb files for Browsertrix Crawler builds.

The `.deb` files are placed in platform-specific directories, `linux/amd64` and `linux/arm64` to support
builds for those platforms. Chromium is used for ARM64 while Chrome is used for amd64 builds.

The image can be built manually via `docker buildx build --platform linux/amd64,linux/arm64 --push -t webrecorder/browsertrix-browser-base:VERSION .`

The CI is also setup to build the image and push on release.

The current browser (Chrome/Chromium) is 91.
