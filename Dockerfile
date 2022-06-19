FROM ubuntu:jammy

# Accept Microsoft EULA agreement for ttf-mscorefonts-installer
RUN echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections

RUN apt-get update -y && apt-get install --no-install-recommends -qqy software-properties-common \
    && apt-get update -y \
    && apt-get install --no-install-recommends -qqy build-essential locales-all redis-server xvfb gpg-agent curl git socat \
      gpg ca-certificates libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 \
      libxkbcommon0 libxcomposite1 libxdamage1 libxrandr2 libgbm1 libpango-1.0-0 libcairo2 libasound2 libgtk-3-0 \
      libxtst6 xdg-utils libc-bin hicolor-icon-theme python3-pip python3-dev \
      fonts-arphic-ukai fonts-arphic-uming fonts-freefont-ttf fonts-gfs-neohellenic fonts-indic fonts-ipafont-mincho fonts-ipafont-gothic fonts-kacst \
      fonts-liberation fonts-noto-cjk fonts-noto-color-emoji fonts-roboto fonts-stix fonts-thai-tlwg fonts-ubuntu fonts-unfonts-core fonts-wqy-zenhei \
      msttcorefonts

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && curl -sL https://deb.nodesource.com/setup_16.x -o /tmp/nodesource_setup.sh && bash /tmp/nodesource_setup.sh \
    && apt-get update -y && apt-get install -qqy nodejs yarn \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ARG TARGETPLATFORM
ARG VERSION=$VERSION

COPY $VERSION/$TARGETPLATFORM/*.deb /tmp/deb/

RUN echo "installing from $TARGETPLATFORM"; dpkg -i /tmp/deb/*.deb; rm -rf /tmp/deb/

