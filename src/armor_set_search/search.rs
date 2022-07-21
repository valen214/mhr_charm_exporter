
pub struct Armor {
  pub name: &'static str,
  pub slots: (u8, u8, u8),
  pub skills: HashMap<&'static str, u8>
}

/*
https://rust-lang-nursery.github.io/rust-cookbook/mem/global_static.html

*/
use std::collections::HashMap;
extern crate phf;
use phf::phf_map;
pub static DEFAULT_ARMOR: [ Armor; 2 ] = [
  Armor {
    name: "AAAA",
    slots: (4, 0, 0),
    skills: phf_map! {
      "loop" => 2
    }
  },
  Armor {
    name: "AAAA",
    slots: (4, 0, 0),
    skills: phf_map! {
      "loop" => 2
    }
  }
];

fn do_search(target: HashMap<&str, u8>) -> Vec<Armor> {
  let mut output: Vec<Armor> = Vec::new();

  

  let a = &DEFAULT_ARMOR[0];


  return output;
}


fn main(){
  do_search(HashMap::from([
      ("Attack", 4),
      ("Critical Boost", 3),
      ("Critical Eye", 5),
      ("Weakness Exploit", 3),
  ]));
  print!("HI");
}