#!/bin/sh
. /root/.cargo/env
. /opt/sgxsdk/environment

echo 'Building libenclave1.signed.so ...'
make -C enclaves/enclave1 all SGX_DEBUG=1

echo 'Building libenclave2.signed.so ...'
make -C enclaves/enclave2 all SGX_DEBUG=1

echo 'Building server...'
cd server
cargo build --features enclave

cd ..
cp enclaves/enclave1/target/debug/libenclave1.signed.so target/debug
cp enclaves/enclave2/target/debug/libenclave2.signed.so target/debug
