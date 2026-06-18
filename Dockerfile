FROM ubuntu:noble AS base

ARG BROWSER="brave"
ENV BROWSER=$BROWSER
ARG BROWSER_VERSION="latest"
ENV BROWSER_VERSION=$BROWSER_VERSION
ARG TARGETARCH

# Accept Microsoft EULA agreement for ttf-mscorefonts-installer
RUN echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections

RUN apt-get update -y && apt-get install --no-install-recommends -qqy software-properties-common \
    && apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -qqy build-essential locales-all redis-server apt-transport-https  \
      curl git socat jq xvfb x11vnc gosu gpg gpg-agent ca-certificates libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 \
      libxkbcommon0 libxcomposite1 libxdamage1 libxrandr2 libgbm1 libpango-1.0-0 libcairo2 libasound2t64 libgtk-3-0 \
      libxtst6 xdg-utils libc-bin hicolor-icon-theme python3-pip python3-dev python3-venv \
      fonts-arphic-ukai fonts-arphic-uming fonts-freefont-ttf fonts-gfs-neohellenic fonts-indic fonts-ipafont-mincho fonts-ipafont-gothic fonts-kacst \
      fonts-liberation fonts-noto-cjk fonts-noto-color-emoji fonts-roboto fonts-stix fonts-thai-tlwg fonts-sil-padauk fonts-ubuntu fonts-unfonts-core fonts-wqy-zenhei \
      msttcorefonts libu2f-udev libvulkan1 openssh-client sshpass autossh

# Yarn: https://classic.yarnpkg.com/en/docs/install#debian-stable
# Node.js: replicates the repo setup from https://deb.nodesource.com/setup_24.x
# (deb822 .sources + apt pin) without piping the setup script to bash
RUN curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/yarnpkg-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/yarnpkg-archive-keyring.gpg] https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /usr/share/keyrings/nodesource.gpg \
    && printf 'Types: deb\nURIs: https://deb.nodesource.com/node_24.x\nSuites: nodistro\nComponents: main\nArchitectures: %s\nSigned-By: /usr/share/keyrings/nodesource.gpg\n' "$TARGETARCH" > /etc/apt/sources.list.d/nodesource.sources \
    && printf 'Package: nodejs\nPin: origin deb.nodesource.com\nPin-Priority: 600\n' > /etc/apt/preferences.d/nodejs \
    && apt-get update -y && apt-get install --no-install-recommends -qqy nodejs yarn \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------

FROM base AS brave

ARG TARGETARCH
ARG TARGETPLATFORM

# Add Brave repository so we can grab brave-keyring after installing deb
RUN curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"|tee /etc/apt/sources.list.d/brave-browser-release.list

# Select the brave-browser asset explicitly: releases also ship brave-origin
# debs, so a bare "$TARGETARCH.deb" match picks up the wrong package
RUN if [ "$BROWSER_VERSION" = "latest" ] ; \
    then \
        tagname=$(curl -fsSL "https://api.github.com/repos/brave/brave-browser/releases/latest" | jq -r '.tag_name') ; \
    else \
        tagname="v${BROWSER_VERSION}" ; \
    fi \
    && debname=$(curl -fsSL "https://api.github.com/repos/brave/brave-browser/releases/tags/${tagname}" \
        | jq -r --arg arch "$TARGETARCH" '.assets[].name | select(test("^brave-browser_.*_" + $arch + "\\.deb$"))') \
    && test -n "$debname" \
    && curl -fsSL "https://github.com/brave/brave-browser/releases/download/${tagname}/${debname}" -o brave.deb

# apt-get install (not dpkg -i; apt-get -f) so a corrupt or missing deb fails the build
RUN echo "installing Brave from $TARGETPLATFORM" \
    && apt-get update -y \
    && apt-get install --no-install-recommends -qqy ./brave.deb \
    && rm -f brave.deb \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/brave-browser /usr/bin/chromium-browser

RUN /usr/bin/brave-browser --version

# -----------------------------------------------------------------------------

FROM base AS chrome

ARG TARGETARCH
ARG TARGETPLATFORM

COPY $BROWSER_VERSION/$TARGETPLATFORM/*.deb /tmp/deb/

RUN echo "installing Chrome/Chromium from $TARGETPLATFORM" && dpkg -i /tmp/deb/*.deb && rm -rf /tmp/deb/

RUN if [ "$TARGETARCH" = "amd64" ] ; \
    then \
        /usr/bin/google-chrome --version ; \
    else \
        /usr/bin/chromium-browser --version ; \
    fi
