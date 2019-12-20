use std::env;

fn main() {
    if let Ok(_) = env::var("CARGO_FEATURE_ENCLAVE") {
        let sgx_sdk = env::var("SGX_SDK").unwrap_or_else(|_| "/opt/sgxsdk".to_string());
        let sgx_rust = env::var("SGX_RUST").unwrap_or_else(|_| "/opt/sgx_rust".to_string());
        cc::Build::new()
            .file("src/Enclave_u.c")
            .include(&format!("{}/include", sgx_sdk))
            .include(&format!("{}/edl", sgx_rust))
            .compile("enclave.a");
        println!("cargo:rustc-link-search=native={}/lib64", sgx_sdk);
        match env::var("SGX_MODE").as_ref() {
            Ok(s) if s == "SW" => {
                println!("cargo:rustc-link-lib=dylib=sgx_urts_sim");
            }
            _ => {
                println!("cargo:rustc-link-lib=dylib=sgx_urts");
            }
        }
    }
}
