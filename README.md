# Base Browser for Browsertrix Crawler

This repository contains a Dockerfile for platform-specific browser images for Browsertrix Crawler, based on Ubuntu 22.04, using Brave Browser or Chrome/Chromium depending on the `--target` passed to `docker buildx build`. Valid values: `brave`, `chrome`.

Brave is set as the default in the build scripts included in this repository, which set the `--target` based on the value of the `BROWSER` environment variable.

The CI is setup to build the images for each browser and platform, create draft releases on GitHub if a matching one does not already exist, and publish the images to DockerHub on each push to the `main` branch.

This image can be accessed from `webrecorder/browsertrix-browser-base:<BROWSER>-<BROWSER_VERSION>`.

See `build.sh` for how to build this image locally using `docker buildx`.

## Brave

With `--target=brave`, the build uses Brave Browser for both AMD64 and ARM64 builds.

The `.deb` files are retrieved from releases the Brave Browser GitHub repository, based on the `BROWSER_VERSION` build-arg supplied. If `BROWSER_VERSION` is set to `latest`, the `.deb` files from the latest stable release on GitHub will be used.

## Chrome

With `--target=chrome`, the build uses Google Chrome for AMD64 builds and Chromium builds for ARM64.

The `.deb` files are placed in platform-specific directories, `<BROWSER_VERSION>/linux/amd64` and `<BROWSER_VERSION>/linux/arm64` to support builds for those platform.


