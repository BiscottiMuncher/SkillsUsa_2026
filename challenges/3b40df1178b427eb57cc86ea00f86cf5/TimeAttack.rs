use core::time;
use std::{cmp::Ordering, f32::consts::E, fs, os::unix::raw::time_t, path::StripPrefixError, process::Output, str::Bytes, env, process, time::{SystemTime, UNIX_EPOCH}};

enum DOW { 
    MON,
    TUE, 
    WED,
    THUR,
    FRI,
    SAT,
    SUN     
}

fn main() {
  write_out(pudding());

} 

fn get_u_time() -> u128{
    let now = SystemTime::now();
    let since = now.duration_since(UNIX_EPOCH).expect("OUT OF TIME"); 
    return since.as_micros()
}

fn write_out(s:String){ 
    fs::write("ENCRYPTED.txt", &s); 
}

fn prng_eng() -> u32{
    let seed = get_u_time();
    let high = seed & 0x000FFFFFF;
    let mut low = seed & 0x00000FFF; 
    if low == 0 {
        low = 1;
    }
    let mut div = high * low;
    if div == 0 {
        div = 1; 
    }
    let shift:u128 = (&div * &low); 
    let unreal = &seed * &shift; 
    return unreal as u32;
}

fn pudding() -> String{
    let args: Vec<_> = env::args().collect();
    let curr_dow = DOW::MON; 
    let seed = prng_eng() as u32; 
    let byte_mask: u32 = 0x3F;
    let rolling:[u8; 4] = [((&seed >> 5) & byte_mask) as u8 + 1, ((&seed >> 9) & byte_mask) as u8  + 1, ((&seed >> 15) & byte_mask) as u8  + 1, ((&seed >> 26) & byte_mask) as u8 + 1];
        if args.len() < 2 {
        println!("Please Enter A Password...\n \t Example: ./timeattack PassWord123!");
        process::exit(1);
        
    }
    let input: &str = &args[1];
    let len: usize = input.len(); 
    let mut i: usize = 0;
    let mut out:Vec<char> = Vec::with_capacity(len);
    while i < len {
        let o_byte = input.as_bytes().get(i).cloned().unwrap_or(0); 
        let m_byte = o_byte ^ rolling[i%4];
        out.push(m_byte as char);

        i+=1;
        
    }
    let res: String = out.iter().collect(); 
    println!("Password Encrypted!");
    return res;
}