FROM ubuntu:18.04
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
  git=1:2.17.1-1ubuntu0.7 \
  libboost-all-dev=1.65.1.0ubuntu1 \
  wget=1.19.4-1ubuntu2.2 \
  sqlite3=3.22.0-1ubuntu0.4 \
  autoconf=2.69-11 \
  sudo=1.8.21p2-3ubuntu1.2 \
  tzdata=2020a-0ubuntu0.18.04 \
  bsdmainutils=11.1.2ubuntu1 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /root
ARG GOLANG_VERSION=1.14.7
RUN wget --quiet https://dl.google.com/go/go${GOLANG_VERSION}.linux-amd64.tar.gz && tar -xvf go${GOLANG_VERSION}.linux-amd64.tar.gz && mv go /usr/local
ENV GOROOT /usr/local/go
ENV GOPATH /go
ENV GOBIN /go/bin
ENV PATH   $GOPATH/bin:$GOROOT/bin:$PATH
ENV SRC_PARENT $GOPATH/src/github.com/algorand
RUN mkdir -p $SRC_PARENT

WORKDIR $SRC_PARENT
ARG GIT_CLONE_REPO=https://github.com/algorand/go-algorand
ARG GIT_COMMIT=b648e0d75ac89440afb435b7acbad1d6711d24ad
# ^ master as of Sept 7, 2020
ENV PROJ_NAME go-algorand
ENV SRC $SRC_PARENT/$PROJ_NAME
RUN git clone $GIT_CLONE_REPO $PROJ_NAME

WORKDIR $SRC
RUN git checkout $GIT_COMMIT && ./scripts/configure_dev.sh && make install
ENTRYPOINT ["/bin/bash"]