# syntax=docker/dockerfile:1

FROM ubuntu:latest

# set version label
ARG BUILD_DATE
ARG VERSION
ARG SONARR_VERSION
LABEL build_version="version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="Prof"

# set environment variables
ARG DEBIAN_FRONTEND="noninteractive"
ENV XDG_CONFIG_HOME="/config/xdg"
ENV SONARR_BRANCH="main"

RUN \
apt-get update && \
apt-get install -y curl && \
 echo "**** add mediaarea repository ****" && \
  curl -L \
    "https://mediaarea.net/repo/deb/repo-mediaarea_1.0-21_all.deb" \
    -o /tmp/key.deb && \
  dpkg -i /tmp/key.deb && \
  echo "deb https://mediaarea.net/repo/deb/ubuntu jammy main" | tee /etc/apt/sources.list.d/mediaarea.list && \
  echo "**** add mono repository ****" && \
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
  echo "deb http://download.mono-project.com/repo/ubuntu stable-focal main" | tee /etc/apt/sources.list.d/mono-official.list && \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ca-certificates-mono \
    libmono-system-net-http4.0-cil \
    libmono-corlib4.5-cil \
    libmono-microsoft-csharp4.0-cil \
    libmono-posix4.0-cil \
    libmono-system-componentmodel-dataannotations4.0-cil \
    libmono-system-configuration-install4.0-cil \
    libmono-system-configuration4.0-cil \
    libmono-system-core4.0-cil \
    libmono-system-data-datasetextensions4.0-cil \
    libmono-system-data4.0-cil \
    libmono-system-identitymodel4.0-cil \
    libmono-system-io-compression4.0-cil \
    libmono-system-numerics4.0-cil \
    libmono-system-runtime-serialization4.0-cil \
    libmono-system-security4.0-cil \
    libmono-system-servicemodel4.0a-cil \
    libmono-system-serviceprocess4.0-cil \
    libmono-system-transactions4.0-cil \
    libmono-system-web4.0-cil \
    libmono-system-xml-linq4.0-cil \
    libmono-system-xml4.0-cil \
    libmono-system4.0-cil \
    mono-runtime \
    mono-vbnc \
    mediainfo \
    xmlstarlet \
    avahi-daemon \
    nginx && \    
  echo "**** install sonarr ****" && \
  mkdir -p /app/sonarr/bin && \
  if [ -z ${SONARR_VERSION+x} ]; then \
    SONARR_VERSION=$(curl -sX GET http://services.sonarr.tv/v1/releases \
    | jq -r ".[] | select(.branch==\"$SONARR_BRANCH\") | .version"); \
  fi && \
  curl -o \
    /tmp/sonarr.tar.gz -L \
    "https://download.sonarr.tv/v3/${SONARR_BRANCH}/${SONARR_VERSION}/Sonarr.${SONARR_BRANCH}.${SONARR_VERSION}.linux.tar.gz" && \
  tar xf \
    /tmp/sonarr.tar.gz -C \
    /app/sonarr/bin --strip-components=1 && \
  echo "UpdateMethod=docker\nBranch=${SONARR_BRANCH}\nPackageVersion=${VERSION}\nPackageAuthor=[linuxserver.io](https://linuxserver.io)" > /app/sonarr/package_info && \
  rm -rf /app/sonarr/bin/Sonarr.Update && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8989
VOLUME /config
