use core::result;
use sgx_types::{sgx_status_t, SgxResult};

pub struct Enclave;

impl Enclave {
    pub fn new() -> SgxResult<Enclave> {
        result::Result::Ok(Enclave)
    }

    pub fn say_something(&self, input_string: String) -> sgx_status_t {
        sgx_status_t::SGX_SUCCESS
    }
}
