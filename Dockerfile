FROM ubuntu:20.04 as base

ARG DAVIX_VERSION=latest
ARG DAVIX_GHPROJ=cern-fts/davix
ARG DAVIX_RELROOT=https://github.com/${DAVIX_GHPROJ}/releases
ARG DAVIX_DWROOT=${DAVIX_RELROOT}/download


ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update \
  && apt-get -y install ca-certificates wget \
  && if [ "$DAVIX_VERSION" = "latest" ]; then \
      DAVIX_VERSION=$(wget -q  -O - "$DAVIX_RELROOT" | \
                      grep "href=\"/${DAVIX_GHPROJ}/releases/tag/R_[0-9]_[0-9]*_[0-9]*\"" | \
                      grep -v no-underline | \
                      head -n 1 | \
                      cut -d '"' -f 2 | \
                      awk '{n=split($NF,a,"/");print a[n]}' | \
                      awk 'a !~ $0{print}; {a=$0}' | \
                      sed -e 's/R_//' -e 's/_/./g' ); \
     fi \
  && echo "Building for Davix v. $DAVIX_VERSION" \
  && wget -q -O /tmp/davix.tgz "${DAVIX_DWROOT}/R_$(printf %s\\n "$DAVIX_VERSION" | sed 's/\./_/g')/davix-${DAVIX_VERSION}.tar.gz" \
  && tar -C /tmp -zxf /tmp/davix.tgz \
  && apt-get --no-install-recommends -y install \
        cmake g++ build-essential python libxml2-dev libssl-dev uuid-dev \
  && mkdir "/tmp/davix-${DAVIX_VERSION#v}/build" \
  && cd "/tmp/davix-${DAVIX_VERSION#v}/build" \
  && cmake -Wno-dev -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_BUILD_WITH_INSTALL_RPATH=1 .. \
  && make \
  && make install \
  && cp ../docker/davix.sh /usr/local/bin/



FROM ubuntu:20.04

ARG DAVIX_VERSION=latest
ARG DAVIX_GHPROJ=cern-fts/davix
ARG DAVIX_RELROOT=https://github.com/${DAVIX_GHPROJ}/releases

# Metadata
LABEL MAINTAINER efrecon+github@gmail.com
LABEL org.opencontainers.image.title="davix"
LABEL org.opencontainers.image.description="High-performance file management over WebDAV / HTTP"
LABEL org.opencontainers.image.authors="Emmanuel Frécon <efrecon+github@gmail.com>"
LABEL org.opencontainers.image.url="https://github.com/efrecon/docker-davix"
LABEL org.opencontainers.image.documentation="https://github.com/efrecon/docker-davix/README.md"
LABEL org.opencontainers.image.source="https://github.com/efrecon/docker-davix/Dockerfile"

ARG DEBIAN_FRONTEND=noninteractive

COPY --from=base /usr/local/bin/davix* /usr/local/bin/
COPY --from=base /usr/local/lib64/libdavix.so /usr/local/lib/x86_64-linux-gnu/
RUN apt-get -y update \
  && apt-get --no-install-recommends -y install ca-certificates wget libxml2 openssl uuid \
  && if [ "$DAVIX_VERSION" = "latest" ]; then \
      DAVIX_VERSION=$(wget -q  -O - "$DAVIX_RELROOT" | \
                      grep "href=\"/${DAVIX_GHPROJ}/releases/tag/R_[0-9]_[0-9]*_[0-9]*\"" | \
                      grep -v no-underline | \
                      head -n 1 | \
                      cut -d '"' -f 2 | \
                      awk '{n=split($NF,a,"/");print a[n]}' | \
                      awk 'a !~ $0{print}; {a=$0}' | \
                      sed -e 's/R_//' -e 's/_/./g' ); \
     fi \
  && cd /usr/local/lib/x86_64-linux-gnu \
  && ln -sf libdavix.so "libdavix.so.${DAVIX_VERSION#v}" \
  && ln -sf libdavix.so "libdavix.so.$(printf %s\\n "${DAVIX_VERSION#v}" | cut -d. -f1)" \
  && ldconfig 

ENTRYPOINT [ "/usr/local/bin/davix.sh" ]