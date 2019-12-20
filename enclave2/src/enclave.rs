use sgx_types::*;
use sgx_urts::SgxEnclave;

static ENCLAVE_FILE: &'static str = "libenclave2.signed.so";

extern "C" {
    fn say_something(
        eid: sgx_enclave_id_t,
        retval: *mut sgx_status_t,
        some_string: *const u8,
        len: usize,
    ) -> sgx_status_t;
}

pub struct Enclave(SgxEnclave);

impl Enclave {
    pub fn new() -> SgxResult<Self> {
        let mut launch_token: sgx_launch_token_t = [0; 1024];
        let mut launch_token_updated: i32 = 0;
        // call sgx_create_enclave to initialize an enclave instance
        // Debug Support: set 2nd parameter to 1
        let debug = 1;
        let mut misc_attr = sgx_misc_attribute_t {
            secs_attr: sgx_attributes_t { flags: 0, xfrm: 0 },
            misc_select: 0,
        };
        SgxEnclave::create(
            ENCLAVE_FILE,
            debug,
            &mut launch_token,
            &mut launch_token_updated,
            &mut misc_attr,
        )
        .map(Enclave)
    }

    pub fn say_something(&self, input_string: String) -> sgx_status_t {
        let mut retval = sgx_status_t::SGX_SUCCESS;
        let result = unsafe {
            say_something(
                self.0.geteid(),
                &mut retval,
                input_string.as_ptr() as *const u8,
                input_string.len(),
            )
        };
        result
    }
}
