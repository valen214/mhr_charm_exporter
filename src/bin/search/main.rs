
use std::collections::HashMap;
use strum::{ EnumIter, IntoEnumIterator, IntoStaticStr };

use itertools::{ iproduct };

type Skills = HashMap<&'static str, u8>;
fn reduce_skills(pool: &mut Skills, subtract: &Skills){
  for skill in pool.clone().keys() {
    if !subtract.contains_key(skill){ continue; }

    let lv = pool.get(skill).unwrap() - subtract.get(skill).unwrap();
    if lv > 0 {
      pool.insert(skill, lv);
    } else{
      pool.remove(skill);
    }
  }
}
fn add_skills(pool: &mut Skills, addition: &Skills){
  for (skill, lv) in addition {
    if pool.contains_key(skill){
      pool.insert(skill, pool.get(skill).unwrap() + lv);
    } else{
      pool.insert(skill, *lv);
    }
  }
}

#[derive(IntoStaticStr, EnumIter, Debug, PartialEq, Eq, Hash, Clone)]
pub enum ArmorPart {
  Head, Chest, Gloves, Belt, Boots
}
#[derive(Debug, Clone)]
pub struct Armor {
  pub part: ArmorPart,
  pub name: &'static str,
  pub slots: (u8, u8, u8),
  pub skills: Skills
}
#[derive(Debug, Clone)]
pub struct Charm {
  pub skills: Skills,
  pub slots: (u8, u8, u8),
}
pub struct ArmorSet {
  pub head: Option<Armor>,
  pub chest: Option<Armor>,
  pub gloves: Option<Armor>,
  pub belt: Option<Armor>,
  pub boots: Option<Armor>,
  pub charm: Option<Charm>
}

/*
https://rust-lang-nursery.github.io/rust-cookbook/mem/global_static.html

*/
use lazy_static::lazy_static;
lazy_static! {
  #[derive(Copy, Clone)]
  static ref DEFAULT_ARMOR: Vec<Armor> = vec![
    Armor {
      part: ArmorPart::Head,
      name: "AAAA",
      slots: (4, 0, 0),
      skills: HashMap::from([
        ("Attack", 2)
      ])
    },
    Armor {
      part: ArmorPart::Chest,
      name: "AAAB",
      slots: (4, 0, 0),
      skills: HashMap::from([
        ("Attack", 3)
      ])
    }
  ];
}

use std::str;
fn do_search(target: Skills) -> Vec<ArmorSet> {
  let output: Vec<ArmorSet> = Vec::new();

  // https://www.reddit.com/r/rust/comments/38oa85/
  let mut armors: HashMap<ArmorPart, Vec<Option<Armor>>> =
      HashMap::new();
  for part in ArmorPart::iter() {
    armors.insert(part, Vec::from([ None ]));
  }

  let mut charms: Vec<Option<Charm>> = Vec::from([ None ]); 

  for armor in DEFAULT_ARMOR.iter() {
    armors.get_mut(&armor.part).unwrap().push(Some(armor.clone()));
  }
  
  // let current_set = ArmorSet{ 
  //   head: None,
  //   chest: None,
  //   gloves: None,
  //   belt: None,
  //   boots: None,
  //   charm: None
  // };
  // let current_skills: Skills = HashMap::new();

  /*
  brute force, just 100 ^ 5 * 1500 no big deal
  */
  let mut skill_pool: Skills = HashMap::from([]);
  for whole_set in iproduct!(
    armors.get(&ArmorPart::Head).unwrap(),
    armors.get(&ArmorPart::Chest).unwrap(),
    armors.get(&ArmorPart::Gloves).unwrap(),
    armors.get(&ArmorPart::Belt).unwrap(),
    armors.get(&ArmorPart::Boots).unwrap(),
    charms
  ){
    let (
      head, chest, gloves, belt, boots, charm
    ) = whole_set;
    for a in [head, chest, gloves, belt, boots] {
      if !a.is_none() {
        add_skills(&mut skill_pool, &a.as_ref().unwrap().skills);
      }
    }
    add_skills(&mut skill_pool, &charm.as_ref().unwrap().skills);


    println!(
      "set: {:?} {:?} {:?} {:?} {:?} {:?}",
      head.as_ref().unwrap(),
      chest.as_ref().unwrap(),
      gloves.as_ref().unwrap(),
      belt.as_ref().unwrap(),
      boots.as_ref().unwrap(),
      charm
    );
  }
  

  for (skill, lv) in &target {
    println!("{skill}: {lv}");
  }

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