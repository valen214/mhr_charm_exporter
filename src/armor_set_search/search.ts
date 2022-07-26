// @ts-nocheck

import { DEFAULT_ARMOR } from "./data/armour";
import { DEFAULT_DECO } from "./data/deco";

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


// #endregion Util functions

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


interface IRequiredSkillUtil {
  static getId(name: string): number;
  static toRequiredSkillArray(skills: Skills): [ Array<number>, Skills ];
  static getCount(): number;
}

function getArmorCandidates(
    RequiredSkill: IRequiredSkillUtil,
    DEFAULT_ARMOR: typeof DEFAULT_ARMOR
){
  let armor_candidates = Array.from(Array(5), () => []);
  // need multiple best slots to account for 4-0-0 vs 1-1-1
  let best_slots = Array.from(Array(5), () => null);
  for(let armor of DEFAULT_ARMOR){
    try{
      let part = armor[3];
      let slots = armor[10];
      let skills = armor[11];

      let add = false;

      /*
      if(!isEmptyObject(intersection(skills, target_skills))){
        add = true;
      }
      /*/ // no diff
      for(let skill of Object.keys(skills)){
        if(RequiredSkill.getId(skill)){
          add = true;
          break;
        }
      }
      /*****/

      if(!add &&
      best_slots[part] === null ||
      betterSlots(slots, best_slots[part][10])){
        best_slots[part] = armor;
      }


      if(add){
        armor_candidates[part].push(armor);
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
    armor_candidates[i].splice(0, 0, [
      "empty", ...new Array(9).fill(0),
      [0, 0, 0],
      {}, 0, [0, 0, 0, 0, 0]
    ]);
  }

  print("total armor: ", DEFAULT_ARMOR.length);
  print("available armor parts:", armor_candidates.map(a => a.length));
  // print("armor candidates:", armor_candidates.map(a => a.map(b => b[0])));

  for(let parts of armor_candidates){
    for(let armor of parts){
      armor[11] = RequiredSkill.toRequiredSkillArray(armor[11]);
    }
  }

  return armor_candidates;
}

function getDecoCandidates(
  RequiredSkill: IRequiredSkillUtil,
  DEFAULT_DECO: typeof DEFAULT_DECO
){
  let deco_candidates = Array.from(
      Array(RequiredSkill.getCount()), () => []
  );

  for(let deco of DEFAULT_DECO){
    for(let skill of Object.keys(deco[5])){
      let skillId = RequiredSkill.getId(skill)
      if(skillId){

        deco_candidates[skillId].push(
            Object.assign([], deco, {
              5: RequiredSkill.toRequiredSkillArray(deco[5])
            })
        )
        // deco[5] = ;
        // deco_candidates.push(deco);
        break;
      }
    }
  }

  for(let [i, skill_decos] of Object.entries(deco_candidates)){
    // print(`deco candidates for skill id ${i}:`)
    // for(let deco of skill_decos){
    //   print(deco);
    // }
  }
  return deco_candidates;
}

function fillSkillsWithDeco(
  required_extra_skills: Array<number>,
  slots_pool: [ number, number, number, number ],
  deco_candidates: Array<Array<object>>
): [ boolean, Map<object, number> ]{

  let success = true;
  let usedDeco = new Map();

  for(let i = 1, n = required_extra_skills.length; i < n; ++i){
    if(required_extra_skills[i] <= 0){
      continue;
    }
    // fuck
    for(let deco of deco_candidates[i]){
      let decoLv = deco[2];

      let haveSlotLv = 0;
      for(let j = decoLv; j <= 4; ++j){
        if(slots_pool[j-1] >= 1){
          haveSlotLv = j;
          break;
        }
      }

      if(!haveSlotLv) continue;

      
      let _required_extra_skills = required_extra_skills.slice(0);
      let _slots_pool = slots_pool.slice(0);

      _required_extra_skills[i] -= deco[5][0][i];
      console.assert(deco[5][0][i] >= 1,
          "trying to slot deco with incorrect required skill"
      );
      // add a line if deco with multiple skills is introduced
      _slots_pool[haveSlotLv-1] -= 1;

      let [ _success, _usedDeco ] = fillSkillsWithDeco(
        _required_extra_skills,
        _slots_pool,
        deco_candidates
      );

      if(_success){
        let deco_name = deco[0]
        _usedDeco.set(deco_name,
          (_usedDeco.get(deco_name) || 0) + 1
        );
        return [ _success, _usedDeco ];
      }

    }

    if(required_extra_skills[i] >= 1){
      return [ false, usedDeco ];
    }
  }

  success = true;
  for(let i = 1, n = required_extra_skills.length; i < n; ++i){
    if(required_extra_skills[i] > 0){
      print("NEVER REACH");
      success = false;
      break;
    }
  }

  return [ success, usedDeco ];
}

export function doSearch(target_skills = {}){
  
  // only used internally, refresh every doSearch() call
  // might as well use iife
  class RequiredSkill
  // #region RequiredSkillUtil 
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
  // #endregion RequiredSkillUtil
  

  let [ required, _extra ] = RequiredSkill.toRequiredSkillArray(target_skills);
  console.assert(isEmptyObject(_extra),
      "error parsing required skills,",
      "required:", required, "_extra:", _extra);

  print("required skills:", target_skills);
  print("parsed rquired skills:", required);

  let armor_candidates = getArmorCandidates(RequiredSkill, DEFAULT_ARMOR);

  let deco_candidates = getDecoCandidates(RequiredSkill, DEFAULT_DECO);

  let found_set = 0;
  let list_found_set = 30
  const MAX_SET_FOUND = 200;

  console.timeLog("doSearch()");
  const TARGET_SKILLS_COUNT = RequiredSkill.getCount();
  for(let set of cartesian_gen(...armor_candidates)){
    let skill_pool = new Array(TARGET_SKILLS_COUNT).fill(0);
    let slots_pool = new Array(4).fill(0);
    for(let armor of set){
      addArrayInPlace(skill_pool, armor[11][0]);
      
      for(let slotLv of armor[10]){
        if(slotLv >= 1){
          ++slots_pool[slotLv-1];
        }
      }
    }


    let required_extra_skills = new Array(TARGET_SKILLS_COUNT).fill(0);
    for(let i = 1; i < TARGET_SKILLS_COUNT; ++i){
      required_extra_skills[i] = required[i] - skill_pool[i];
    }


    let allFullfilled = true;
    for(let i = 1; i < TARGET_SKILLS_COUNT; ++i){
      if(skill_pool[i] < required[i]){
        console.assert(required_extra_skills[i] > 0,
          "required extra skill inconsistent with result",
          required_extra_skills);
        allFullfilled = false;
        break;
      }
    }

    let fillDecoSuccess: boolean = false, usedDeco: Map = null;
    if(!allFullfilled){
      [ fillDecoSuccess, usedDeco ] = fillSkillsWithDeco(
          required_extra_skills, slots_pool, deco_candidates
      );
  
      if(found_set === 0){
        // print("required_extra_skills:", required_extra_skills);
        // print("slots_pool:", slots_pool);
      }
  
      if(fillDecoSuccess){
        allFullfilled = true;
      }
    }


    if(allFullfilled){
      ++found_set;
      if(found_set < list_found_set){
        print("set found:",
            set.map(a => a[0]),
            "[ Lv1: " + slots_pool.join(", ") + " Lv4 ]",
            "usedDeco", usedDeco
        )
        // print("set found:", set.map(a => a[11]))

      }
      
      if(found_set > MAX_SET_FOUND){
        print("terminating maximum search");
        break;
      }
    }

    // print("skill_pool of set:", skill_pool);
  }

  print("total set found:", found_set);
}


function main(){
  let target_skills = {
    "伏魔響命": 2,
    "連擊":1,
    "研磨術【銳】":1,
    "狂龍症【蝕】":1,
    "業鎧【修羅】": 1,
  };

  target_skills = {
    "\u88dd\u586b\u901f\u5ea6":1,
    "\u6ed1\u8d70\u5f37\u5316":1,
    "\u706b\u5c6c\u6027\u653b\u64ca\u5f37\u5316":1,
    "\u7206\u7834\u7570\u5e38\u72c0\u614b\u7684\u8010\u6027":1,
    "\u6703\u5fc3\u64ca\u3010\u5c6c\u6027\u3011":2,
    "\u89e3\u653e\u5f13\u7684\u84c4\u529b\u968e\u6bb5":1,
  } // 350.155ms
  // => 2.721s after implementing deco, while not using any

  target_skills = {
    "貫通彈・貫通箭強化": 2,
    "散彈・擴散箭強化": 3,
    "業鎧【修羅】": 3,
    "狂龍症【蝕】": 1,
    "會心擊【屬性】": 3,
    "解放弓的蓄力階段": 1,
  }


  console.time("doSearch()");
  doSearch(target_skills);
  console.timeEnd("doSearch()");

  print("finished");
}

main();