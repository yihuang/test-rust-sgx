use std::env;

fn main() {
    let sgx_sdk = env::var("SGX_SDK").unwrap_or_else(|_| "/opt/sgxsdk".to_string());
    let sgx_rust = env::var("SGX_RUST").unwrap_or_else(|_| "/opt/sgx_rust".to_string());
    cc::Build::new()
        .file("src/Enclave_t.c")
        .flag("-nostdinc")
        .flag("-fvisibility=hidden")
        .flag("-fpie")
        .flag("-fstack-protector")
        .include(&format!("{}/edl", sgx_rust))
        .include(&format!("{}/common/inc", sgx_rust))
        .include(&format!("{}/include", sgx_sdk))
        .include(&format!("{}/include/tlibc", sgx_sdk))
        .include("./src")
        .compile("enclave");
}
