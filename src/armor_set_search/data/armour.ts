

export type Armor = [
  Name: string,
  ...Data: [ number, number, number, number, number, number, number, number, number ],
  Slots: [ number, number, number ],
  Skills: object, // skills
  Defense: number, // defense
  Resistances: [ number, number, number, number, number ]
];

export const DEFAULT_ARMOR: readonly Armor[]  = Object.freeze([
  ["AAAA",3,3,1,15,99,0,8,0,1,[3,0,0],{"BBBB":1,"CCCC":1,"DDDD":2},130,[2,1,3,-5,2]]
])

let a = DEFAULT_ARMOR[0][10];