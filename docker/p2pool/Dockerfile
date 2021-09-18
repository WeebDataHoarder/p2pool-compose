FROM debian:bullseye-slim AS builder

RUN DEBIAN_FRONTEND=noninteractive apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y \
    git build-essential cmake libuv1-dev libzmq3-dev libsodium-dev libpgm-dev libnorm-dev libgss-dev libtool-bin

ARG ref=origin/master
ARG repo=https://github.com/SChernykh/p2pool

RUN git clone --recursive ${repo} /src/p2pool
WORKDIR /src/p2pool
RUN git reset --hard ${ref} && git submodule sync

WORKDIR /src/p2pool/external/src/libsodium
RUN ./autogen.sh -s && \
    ./configure --enable-shared=no --enable-static=yes && \
    make -j$(nproc)

WORKDIR /src/p2pool/external/src/libzmq
RUN mkdir build && cd build && \
    cmake .. -DENABLE_WS=OFF -DENABLE_CURVE=OFF && \
    make -j$(nproc)

WORKDIR /src/p2pool/external/src/libuv
RUN mkdir build && cd build && \
    cmake .. && \
    make -j$(nproc)

WORKDIR /src/p2pool
COPY 0001-Add-dl-to-target_link_libraries.patch 0001-Add-dl-to-target_link_libraries.patch
RUN git -c user.email="bogus@example.com" -c user.name="bogus" am --3way --ignore-whitespace < 0001-Add-dl-to-target_link_libraries.patch
RUN mkdir build && cd build && \
    CFLAGS="-march=native -mtune=native -Ofast -Wno-error=unused-variable" CXXFLAGS="-march=native -mtune=native -Ofast -Wno-error=unused-variable" \
    cmake .. -DSTATIC_LINUX_BINARY=ON && \
    make -j$(nproc)

FROM debian:bullseye-slim

RUN DEBIAN_FRONTEND=noninteractive apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y \
    curl jq

RUN mkdir -p /p2pool

COPY --from=builder /src/p2pool/build/p2pool /p2pool/p2pool
COPY --from=builder /src/p2pool/config.json /p2pool/config.json

EXPOSE 3333 37889

WORKDIR /p2pool/data

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]