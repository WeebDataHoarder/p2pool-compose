# Partially copied from https://github.com/monero-project/monero/blob/8c3c7b81097b8e260f050b223e7fa3958c14ae66/Dockerfile

FROM alpine:3.16 AS builder

RUN apk add --no-cache \
    git \
    ca-certificates \
    cmake \
    g++ \
    make \
    pkgconfig \
    graphviz \
    doxygen \
    git \
    curl \
    libtool \
    autoconf \
    automake \
    bzip2 \
    libxslt \
    gperf \
    unzip \
    linux-headers \
    libexecinfo-dev

WORKDIR /usr/local

ENV CFLAGS='-fPIC'
ENV CXXFLAGS='-fPIC'

## Boost
ARG BOOST_VERSION=1_77_0
ARG BOOST_VERSION_DOT=1.77.0
ARG BOOST_HASH=fc9f85fc030e233142908241af7a846e60630aa7388de9a5fafb1f3a26840854
RUN set -ex \
    && curl -s -L -o  boost_${BOOST_VERSION}.tar.bz2 https://downloads.sourceforge.net/project/boost/boost/${BOOST_VERSION_DOT}/boost_${BOOST_VERSION}.tar.bz2 \
    && echo "${BOOST_HASH}  boost_${BOOST_VERSION}.tar.bz2" | sha256sum -c \
    && tar -xvf boost_${BOOST_VERSION}.tar.bz2 \
    && cd boost_${BOOST_VERSION} \
    && ./bootstrap.sh \
    && ./b2 -j $(nproc) --build-type=minimal link=static runtime-link=static --with-chrono --with-date_time --with-filesystem --with-program_options --with-regex --with-serialization --with-system --with-thread --with-locale threading=multi threadapi=pthread cflags="$CFLAGS" cxxflags="$CXXFLAGS" stage
ENV BOOST_ROOT /usr/local/boost_${BOOST_VERSION}

# OpenSSL
ARG OPENSSL_VERSION=1.1.1l
ARG OPENSSL_HASH=0b7a3e5e59c34827fe0c3a74b7ec8baef302b98fa80088d7f9153aa16fa76bd1
RUN set -ex \
    && curl -s -O https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz \
    && echo "${OPENSSL_HASH}  openssl-${OPENSSL_VERSION}.tar.gz" | sha256sum -c \
    && tar -xzf openssl-${OPENSSL_VERSION}.tar.gz \
    && cd openssl-${OPENSSL_VERSION} \
    && ./config no-shared --static "$CFLAGS" \
    && make build_generated -j$(nproc) \
    && make libcrypto.a -j$(nproc) \
    && make install
ENV OPENSSL_ROOT_DIR=/usr/local/openssl-${OPENSSL_VERSION}

# ZMQ
ARG ZMQ_VERSION=v4.3.4
ARG ZMQ_HASH=4097855ddaaa65ed7b5e8cb86d143842a594eebd
RUN set -ex \
    && git clone https://github.com/zeromq/libzmq.git -b ${ZMQ_VERSION} \
    && cd libzmq \
    && test `git rev-parse HEAD` = ${ZMQ_HASH} || exit 1 \
    && ./autogen.sh \
    && ./configure --enable-static --disable-shared \
    && make -j$(nproc) \
    && make install

# zmq.hpp
ARG CPPZMQ_VERSION=v4.8.1
ARG CPPZMQ_HASH=dd663fafd830466d34cba278c2cfd0f92eb67614
RUN set -ex \
    && git clone https://github.com/zeromq/cppzmq.git -b ${CPPZMQ_VERSION} \
    && cd cppzmq \
    && test `git rev-parse HEAD` = ${CPPZMQ_HASH} || exit 1 \
    && mv *.hpp /usr/local/include

# Readline
ARG READLINE_VERSION=8.1
ARG READLINE_HASH=f8ceb4ee131e3232226a17f51b164afc46cd0b9e6cef344be87c65962cb82b02
RUN set -ex \
    && curl -s -O https://ftp.gnu.org/gnu/readline/readline-${READLINE_VERSION}.tar.gz \
    && echo "${READLINE_HASH}  readline-${READLINE_VERSION}.tar.gz" | sha256sum -c \
    && tar -xzf readline-${READLINE_VERSION}.tar.gz \
    && cd readline-${READLINE_VERSION} \
    && ./configure \
    && make -j$(nproc) \
    && make install

# Sodium
ARG SODIUM_VERSION=1.0.18
ARG SODIUM_HASH=4f5e89fa84ce1d178a6765b8b46f2b6f91216677
RUN set -ex \
    && git clone https://github.com/jedisct1/libsodium.git -b ${SODIUM_VERSION} \
    && cd libsodium \
    && test `git rev-parse HEAD` = ${SODIUM_HASH} || exit 1 \
    && ./autogen.sh \
    && ./configure \
    && make -j$(nproc) \
    && make check \
    && make install

# Protobuf
ARG PROTOBUF_VERSION=v3.18.1
ARG PROTOBUF_HASH=0dab03ba7bc438d7ba3eac2b2c1eb39ed520f928
RUN set -ex \
    && git clone https://github.com/protocolbuffers/protobuf -b ${PROTOBUF_VERSION} \
    && cd protobuf \
    && test `git rev-parse HEAD` = ${PROTOBUF_HASH} || exit 1 \
    && git submodule update --init --recursive \
    && ./autogen.sh \
    && ./configure --enable-static --disable-shared \
    && make -j$(nproc) \
    && make install

WORKDIR /src

ARG ref=origin/master

RUN git clone --recursive https://github.com/monero-project/monero /src && \
    git reset --hard ${ref} && \
    git submodule sync && git submodule update --init --force --recursive

RUN mkdir build && cd build && \
    CFLAGS="-march=native -mtune=native -Ofast" CXXFLAGS="-march=native -mtune=native -Ofast" \
    cmake .. -D BUILD_DOCUMENTATION=OFF -D BUILD_DEBUG_UTILITIES=OFF -D BUILD_TESTS=OFF -D BUILD_GUI_DEPS=OFF -D STACK_TRACE=OFF \
    -D STATIC=ON -D ARCH="native" -D CMAKE_BUILD_TYPE=release && \
    cmake --build . --target daemon -- -j$(nproc)


FROM alpine:3.16

RUN apk add --no-cache curl ca-certificates bash

WORKDIR /var/monero

COPY --from=builder /src/build/bin/monerod /monerod

VOLUME /var/monero

EXPOSE 18080 18081 18083

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
