export type Tx = {id:string; memberId:string; kind:'earn'|'redeem'; points:number; amountSen:number; detail:string; at:string; receipt:string};
export type Member = {id:string; name:string; email:string; joined:string; points:number; token:string};
export type Reward = {id:string; name:string; description:string; cost:number; emoji:string};
export type DemoData = {members:Member[]; transactions:Tx[]; rewards:Reward[]};
const date=(days:number)=>new Date(Date.now()-days*86400000).toISOString();
export const seed:DemoData={
 members:[
  {id:'RR-000128',name:'Alex Tan',email:'alex@example.com',joined:date(105),points:245,token:'demo-member-RR-000128'},
  {id:'RR-000129',name:'Samantha Lee',email:'samantha@example.com',joined:date(45),points:87,token:'demo-member-RR-000129'},
  {id:'RR-000130',name:'Daniel Wong',email:'daniel@example.com',joined:date(21),points:165,token:'demo-member-RR-000130'}
 ],
 transactions:[
  {id:'TX-001',memberId:'RR-000128',kind:'earn',points:18,amountSen:1890,detail:'Coffee & pastry',at:date(1),receipt:'INV-1001'},
  {id:'TX-002',memberId:'RR-000128',kind:'earn',points:24,amountSen:2400,detail:'In-store purchase',at:date(4),receipt:'INV-1000'},
  {id:'TX-003',memberId:'RR-000128',kind:'redeem',points:-100,amountSen:0,detail:'Free regular coffee',at:date(9),receipt:'RWD-1001'},
  {id:'TX-004',memberId:'RR-000129',kind:'earn',points:15,amountSen:1590,detail:'In-store purchase',at:date(2),receipt:'INV-1002'},
  {id:'TX-005',memberId:'RR-000130',kind:'earn',points:35,amountSen:3500,detail:'In-store purchase',at:date(3),receipt:'INV-1003'}
 ],
 rewards:[
  {id:'coffee',name:'Regular Coffee',description:'One regular hot or iced coffee',cost:100,emoji:'☕'},
  {id:'pastry',name:'Fresh Pastry',description:'Choose one pastry from the counter',cost:150,emoji:'🥐'},
  {id:'combo',name:'Coffee + Pastry',description:'Your favourite afternoon pairing',cost:220,emoji:'✨'}
 ]
};
const KEY='roast-ritual-demo-v1';
export function load():DemoData {try {const s=localStorage.getItem(KEY);if(s){const d=JSON.parse(s);if(d.members&&d.transactions&&d.rewards)return d;}}catch{}return structuredClone(seed)}
export function save(data:DemoData){localStorage.setItem(KEY,JSON.stringify(data))}
export function reset(){localStorage.removeItem(KEY)}
export function money(sen:number){return new Intl.NumberFormat('en-MY',{style:'currency',currency:'MYR'}).format(sen/100)}
export function formatDate(v:string){return new Date(v).toLocaleDateString('en-MY',{month:'short',day:'numeric',year:'numeric'})}
