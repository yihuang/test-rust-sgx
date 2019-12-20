use enclave1::Enclave;

fn main() {
    let enclave = Enclave::new().expect("create enclave");
    println!("{}", enclave.say_something("test".to_owned()));
}
