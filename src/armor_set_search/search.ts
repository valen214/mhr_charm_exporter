// @ts-nocheck

import { DEFAULT_ARMOR } from "./data/armour";

// #region Util functions

// https://stackoverflow.com/questions/12303989#answer-43053803
const f = (a, b) => [].concat(...a.map(d => b.map(e => [].concat(d, e))));
const cartesian = (...a) => a && (
  a[1] ? cartesian(f(a[0], a[1]), ...a.slice(2)) : a[0]
);

// https://stackoverflow.com/a/34392937/3142238
function intersection(o1, o2) {
  return Object.keys(o1).filter({}.hasOwnProperty.bind(o2));
}

// https://stackoverflow.com/a/59787784/3142238
const isEmptyObject = o => { for(let k in o) return false; return true; }

function *cartesian_gen(...a: any){
  const N = a.length;
  let hard_cap = 10000000000;

  let counters = Array.from(Array(a.length), (_, i) => a[i].length-1);
  let lengths = counters.slice(0);
  let total = counters.reduce((l, r) => l * (r + 1), 1);

  print("cartesian product total: ", total);

  while(--hard_cap >= 0 && --total >= 0){
    // yield counters.map((count, i) => a[i][count]);
    let out = Array(N);
    for(let i = 0; i < N; ++i){ out[i] = a[i][counters[i]]; }
    yield out;


    let index = N-1;
    while(index >= 0){
      if(counters[index] === 0){
        counters[index] = lengths[index];
        --index;
      } else{
        counters[index] -= 1;
        break;
      }
    }
  }
  if(hard_cap < 0){
    print(`hard cap reached, cartesian gen abort`);
  }
}

//@ts-ignore
function print(...args){
  //@ts-ignore
  console.log(...args);
}

function addArrayInPlace(source: number[], arr: number[]){
  for(let i = 0; i < source.length; ++i){
    source[i] += arr[i];
  }
}
function minusArrayInPlace(source: number[], arr: number[]){
  for(let i = 0; i < source.length; ++i){
    source[i] -= arr[i];
  }
}


// #endregion

export type Skills = { [skill: string]: number };
/*
I think it is probably fair to say 2-2-2 is better than 4-4-1 in current patch

return true if a is 'better' than b
*/
function betterSlots(a: [number, number, number], b: [number, number, number]): boolean {
  for(let i of [2, 1, 0]){
    if(a[i] > b[i]){
      return true;
    } else if(a[i] < b[i]){
      return false;
    }
  }
  return false;
}
betterSlots.test = function(){
  print(betterSlots([2, 1, 0], [4, 4, 4])); // true
  print(betterSlots([2, 1, 0], [4, 2, 1])); // true
  print(betterSlots([2, 1, 0], [3, 2, 1])); // true
  print(betterSlots([4, 0, 0], [3, 2, 0])); // false
}



export function doSearch(target_skills = {}){
  
  let armor_candidates = Array.from(Array(5), () => []);
  // need multiple best slots to account for 4-0-0 vs 1-1-1
  let best_slots = Array.from(Array(5), () => null);
  for(let armor of DEFAULT_ARMOR){
    try{
      let part = armor[3];
      let slots = armor[10];
      let skills = armor[11];

      let add = false;

      if(!isEmptyObject(intersection(skills, target_skills))){
        add = true;
      }

      if(!add &&
      best_slots[part] === null ||
      betterSlots(slots, best_slots[part][10])){
        best_slots[part] = armor;
      }


      if(add){
        //@ts-ignore
        armor_candidates[armor[3]].push(armor);
      }
    } catch(e){
      console.log(e);
    }
  }

  best_slots.forEach((armor, part) => {
    if(!armor_candidates[part].includes(armor)){
      armor_candidates[part].push(armor);
    }
  });
  // print("best slots:", best_slots.map(a => a[0]));
  for(let i = 0; i < 5; ++i){
    armor_candidates[i].push([
      "empty", ...new Array(8).fill(0),
      [0, 0, 0],
      {}, 0, [0, 0, 0, 0, 0]
    ]);
  }

  // only used internally, refresh every doSearch() call
  // might as well use iife
  class RequiredSkill
  {
    private static count = 1;
    private static storedId = new Map<string, number> ();
    
    private RequiredSkill(){
      throw Exception("don't invoke this constructor");
    }

    static{
      for(let skill_name of Object.keys(target_skills)){
        RequiredSkill.storedId.set(skill_name, RequiredSkill.count);
        ++RequiredSkill.count;
      }
    }

    static getId(name: string): number {
      let skillId = RequiredSkill.storedId.get(name);
      if(skillId) return skillId;
      
      return 0;
    }

    static toRequiredSkillArray(skills: Skills): [ Array<number>, Skills ] {
      let out = new Array(RequiredSkill.count).fill(0);
      let extra = { ...skills };

      for(let skill of Object.keys(skills)){
        let id = RequiredSkill.getId(skill);
        if(id){
          out[id] = skills[skill];
          delete extra[skill];
        }
      }

      return [ out, extra ];
    }

    static getCount(){
      return RequiredSkill.count;
    }
  }

  print("total armor: ", DEFAULT_ARMOR.length);
  print("available armor parts:", armor_candidates.map(a => a.length));
  // print("armor candidates:", armor_candidates.map(a => a.map(b => b[0])));

  for(let parts of armor_candidates){
    for(let armor of parts){
      armor[11] = RequiredSkill.toRequiredSkillArray(armor[11]);
    }
  }


  let [ required, _extra ] = RequiredSkill.toRequiredSkillArray(target_skills);
  console.assert(isEmptyObject(_extra),
      "error parsing required skills,",
      "required:", required, "_extra:", _extra);

  print("required skills:", target_skills);
  print("parsed rquired skills:", required);

  let found_set = 0;
  const MAX_SET_FOUND = 10;

  console.timeLog("doSearch()");
  const TARGET_SKILLS_COUNT = RequiredSkill.getCount();
  for(let set of cartesian_gen(...armor_candidates)){
    let skill_pool = new Array(TARGET_SKILLS_COUNT).fill(0);
    for(let armor of set){
      addArrayInPlace(skill_pool, armor[11][0]);
    }

    let allFullfilled = true;
    for(let i = 1; i < TARGET_SKILLS_COUNT; ++i){
      if(skill_pool[i] < required[i]){
        allFullfilled = false;
        break;
      }
    }
    if(allFullfilled){
      print("set found:", set.map(a => a[0]))
      if(++found_set < MAX_SET_FOUND){
        // print("set found:", set.map(a => a[11]))

      } else{
        // break;
      }
    }

    // print("skill_pool of set:", skill_pool);
  }

  print("total set found:", found_set);
}


function main(){
  console.time("doSearch()");
  doSearch({
    "伏魔響命": 2,
    "連擊":1,
    "研磨術【銳】":1,
    "狂龍症【蝕】":1,
    "業鎧【修羅】": 1,
  });
  console.timeEnd("doSearch()");

  print("finished");
}

main();