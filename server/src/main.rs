use enclave1::Enclave as Enclave1;
use enclave2::Enclave as Enclave2;
fn main() {
    let enclave1 = Enclave1::new().expect("create enclave1");
    println!("{}", enclave1.say_something("test".to_owned()));
    let enclave2 = Enclave2::new().expect("create enclave2");
    println!("{}", enclave2.say_something("test".to_owned()));
}
