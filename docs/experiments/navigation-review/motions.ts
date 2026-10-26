import N from "../../../src/core/navigation.bend";

// Review-only probe of the observed runtime View representation. This is not
// an additional public API or a declaration of the opaque TypeScript shape.
let seed = 48271;
function rand(n: number) { seed = (seed * 48271) % 2147483647; return seed % n; }
function expected(text: string, p: number, command: string, n: number) {
  const row = Math.floor(p / 40), col = p % 40;
  const index = (r: number, c: number) => r * 40 + c;
  const indent = (r: number) => { for(let c=0;c<40;c++) if(text[index(r,c)] !== ' ') return index(r,c); return index(r,0); };
  if(command === 'h') return index(row,Math.max(0,col-n));
  if(command === 'l') return index(row,Math.min(39,col+n));
  if(command === 'j') return index(Math.min(19,row+n),col);
  if(command === 'k') return index(Math.max(0,row-n),col);
  if(command === '0') return index(row,0);
  if(command === '^') return indent(row);
  if(command === '$') return index(Math.min(19,row+n-1),39);
  if(command === 'gg' || command === 'G') return indent(n ? Math.min(19,n-1) : command === 'gg' ? 0 : 19);
  if(command.startsWith('f') || command.startsWith('F')) {
    const delta=command[0] === 'f' ? 1 : -1;
    let left=n;
    for(let c=col+delta;c>=0 && c<40;c+=delta) if(text[index(row,c)]===command[1] && --left===0) return index(row,c);
    return p;
  }
  const big=command === command.toUpperCase();
  const cls=(c: string) => c===' ' ? 0 : big ? 1 : /[a-zA-Z0-9_]/.test(c) ? 2 : 1;
  const candidates=[];
  for(let i=0;i<800;i++) {
    if(cls(text[i])===0) continue;
    const end=command.toLowerCase()==='e';
    if(end ? i%40===39 || cls(text[i+1])!==cls(text[i]) : i%40===0 || cls(text[i-1])!==cls(text[i])) candidates.push(i);
  }
  for(let k=0;k<n;k++) p=command.toLowerCase()==='b' ? candidates.findLast(q=>q<p) ?? 0 : candidates.find(q=>q>p) ?? 799;
  return p;
}
let checks=0;
for(let f=0;f<4;f++) {
  const alphabet=' abZ9_+.#';
  const text=f===0 ? ' '.repeat(800) : Array.from({length:800},()=>alphabet[rand(alphabet.length)]).join('');
  for(const p of [0,39,40,rand(800),799]) {
    for(const command of ['h','j','k','l','w','b','e','W','B','E','0','^','$','gg','G','fa','Fa','f ','F#']) {
      const n=command==='0' ? 1 : 1+rand(3);
      let state:any={$:'View',field:text,position:p,mode:{$:'Normal',count:0}};
      for(const key of (command==='0' ? '0' : `${n}${command}`)) state=N.step(state,N.input_character(key,false));
      const want=expected(text,p,command,n), got=N.position(state);
      if(got!==want) throw Error(JSON.stringify({f,p,command,n,want,got}));
      if(N.contents(state)!==text || !N.valid(state)) throw Error('state invariant');
      checks++;
    }
  }
}
console.log(`${checks} independent arbitrary-field motion checks passed`);
