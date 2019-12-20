#[cfg(feature = "enclave")]
mod enclave;
#[cfg(feature = "enclave")]
pub use enclave::Enclave;

#[cfg(not(feature = "enclave"))]
mod mock;
#[cfg(not(feature = "enclave"))]
pub use mock::Enclave;
