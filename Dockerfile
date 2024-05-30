FROM ubuntu:noble AS base

ARG BROWSER="brave"
ENV BROWSER=$BROWSER
ARG BROWSER_VERSION="latest"
ENV BROWSER_VERSION=$BROWSER_VERSION

# Accept Microsoft EULA agreement for ttf-mscorefonts-installer
RUN echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections

RUN apt-get update -y && apt-get install --no-install-recommends -qqy software-properties-common \
    && apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -qqy build-essential locales-all redis-server apt-transport-https  \
      curl git socat jq xvfb x11vnc gosu gpg gpg-agent ca-certificates libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 \
      libxkbcommon0 libxcomposite1 libxdamage1 libxrandr2 libgbm1 libpango-1.0-0 libcairo2 libasound2t64 libgtk-3-0 \
      libxtst6 xdg-utils libc-bin hicolor-icon-theme python3-pip python3-dev python3-venv \
      fonts-arphic-ukai fonts-arphic-uming fonts-freefont-ttf fonts-gfs-neohellenic fonts-indic fonts-ipafont-mincho fonts-ipafont-gothic fonts-kacst \
      fonts-liberation fonts-noto-cjk fonts-noto-color-emoji fonts-roboto fonts-stix fonts-thai-tlwg fonts-ubuntu fonts-unfonts-core fonts-wqy-zenhei \
      msttcorefonts libu2f-udev libvulkan1 openssh-client sshpass

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && curl -sL https://deb.nodesource.com/setup_20.x -o /tmp/nodesource_setup.sh && bash /tmp/nodesource_setup.sh \
    && apt-get update -y && apt-get install -qqy nodejs yarn \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------

FROM base AS brave

ARG TARGETARCH
ARG TARGETPLATFORM

# Add Brave repository so we can grab brave-keyring after installing deb
RUN curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"|tee /etc/apt/sources.list.d/brave-browser-release.list \
    && apt-get update

RUN if [ "$BROWSER_VERSION" = "latest" ] ; \
    then \
        debname=$(curl -sL "https://api.github.com/repos/brave/brave-browser/releases/latest" \
            | grep "$TARGETARCH.deb\",$" \
            | cut -d : -f 2,3 \
            | tr -d \",\,,\[:space:]) \
        && tagname=$(curl -sL "https://api.github.com/repos/brave/brave-browser/releases/latest" \
            | grep "tag_name" \
            | cut -d : -f 2,3 \
            | tr -d \",\,,\[:space:]) \
        && curl -sL "https://github.com/brave/brave-browser/releases/download/$tagname/$debname" -o brave.deb ; \
    else \
        debname=$(curl -sL "https://api.github.com/repos/brave/brave-browser/releases/tags/v${BROWSER_VERSION}" \
            | grep "$TARGETARCH.deb\",$" \
            | cut -d : -f 2,3 \
            | tr -d \",\,,\[:space:]) \
        && curl -sL "https://github.com/brave/brave-browser/releases/download/v${BROWSER_VERSION}/$debname" -o brave.deb ; \
    fi

RUN echo "installing Brave from $TARGETPLATFORM"; dpkg -i brave.deb; apt-get -f install -y; rm -f brave.deb

RUN ln -s /usr/bin/brave-browser /usr/bin/chromium-browser

RUN /usr/bin/brave-browser --version

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------

FROM base AS chrome

ARG TARGETARCH
ARG TARGETPLATFORM

COPY $BROWSER_VERSION/$TARGETPLATFORM/*.deb /tmp/deb/

RUN echo "installing Chrome/Chromium from $TARGETPLATFORM"; dpkg -i /tmp/deb/*.deb; rm -rf /tmp/deb/

RUN if [ "$TARGETARCH" = "amd64" ] ; \
    then \
        /usr/bin/google-chrome --version ; \
    else \
        /usr/bin/chromium-browser --version ; \
    fi
