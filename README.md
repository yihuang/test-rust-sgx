# A demo of integrating rust sgx enclave into larger project

## Build mock mode on mac

```
$ cargo build
```

## Build SW mode on linux docker

```
$ docker build -t test-enclave-sw --build-arg SGX_MODE=SW .
```


## Build HW mode on linux docker

```
$ docker build -t test-enclave .
```
