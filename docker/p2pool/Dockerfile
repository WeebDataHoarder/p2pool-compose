FROM debian:bullseye-slim AS builder

RUN DEBIAN_FRONTEND=noninteractive apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y \
    git build-essential cmake libuv1-dev libzmq3-dev libsodium-dev libpgm-dev libnorm-dev libgss-dev

ARG ref=origin/master

RUN git clone --recursive https://github.com/SChernykh/p2pool /src/p2pool && \
    cd /src/p2pool && git reset --hard ${ref} && git submodule sync && \
    mkdir build && cd build && \
    CFLAGS="-march=native -mtune=native -Ofast -Wno-error=unused-variable" CXXFLAGS="-march=native -mtune=native -Ofast -Wno-error=unused-variable" \
    cmake .. && \
    make -j$(nproc)

FROM debian:bullseye-slim

RUN DEBIAN_FRONTEND=noninteractive apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y \
    libuv1 libzmq5 libsodium23 libpgm-5.3-0 libnorm1 libgss3 \
    curl jq

RUN mkdir -p /p2pool

COPY --from=builder /src/p2pool/build/p2pool /p2pool/p2pool
COPY --from=builder /src/p2pool/config.json /p2pool/config.json

EXPOSE 3333 37889

WORKDIR /p2pool/data

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]