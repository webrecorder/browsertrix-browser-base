# Base Browser for Browsertrix Crawler

This repository contains the browser .deb files as well as a Dockerfile for platform-specific browser image for Browsertrix Crawler, based on Ubuntu 22.04.

The build uses Google Chrome for AMD64 builds and Chromium builds for ARM64

The `.deb` files are placed in platform-specific directories, `<VERSION>/linux/amd64` and `<VERSION>/linux/arm64` to support
builds for those platform.

The CI is also setup to build the image and push on release.

This image can be accessed from `webrecorder/browsertrix-browser-base:<VERSION>`.

See `build.sh` for how to build this image locally.

The releases correspond to a new version of Chrome/Chromium, and current latest release is: **101**.

