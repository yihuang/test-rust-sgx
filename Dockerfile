FROM baiduxlab/sgx-rust as builder

RUN git clone https://github.com/apache/incubator-teaclave-sgx-sdk.git /opt/sgx_rust
ENV SGX_RUST=/opt/sgx_rust

RUN . /root/.cargo/env && rustup toolchain install nightly-2019-11-25

WORKDIR /src
ARG SGX_MODE=HW
COPY . /src
RUN ./build.sh

FROM ubuntu:18.04
RUN apt update -y && apt install --no-install-recommends -y libssl-dev && rm -rf /var/lib/apt/lists/*
WORKDIR /root
COPY --from=builder \
     /src/target/debug/server \
     /src/target/debug/libenclave1.signed.so \
     /src/target/debug/libenclave2.signed.so \
     /root/
COPY --from=builder \
     /opt/sgxsdk/lib64/libsgx_urts.so \
     /opt/sgxsdk/lib64/libsgx_urts_sim.so \
     /opt/sgxsdk/lib64/libsgx_uae_service.so \
     /opt/sgxsdk/lib64/libsgx_uae_service_sim.so \
    /usr/lib/
CMD ["./server"]
