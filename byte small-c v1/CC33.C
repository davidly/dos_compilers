/*
** Small C - 8088/8086 version - modified by R. Grehan, BYTE Magazine
**
** true if val1 -> int pointer or int array and val2 not ptr or array
*/
dbltest(oper, val1, val2) int (*oper)(), val1[], val2[]; {
  if((oper!=ffadd) && (oper!=ffsub)) return 0;
  if(val1[2]!=CINT) return 0;
  if(val2[2]) return 0;
  return 1;
  }

/*
** determine type of binary operation
*/
result(lval, lval2) int lval[], lval2[]; {
  if((lval[2]!=0)&(lval2[2]!=0)) {
    lval[2]=0;
    }
  else if(lval2[2]) {
    lval[0]=lval2[0];
    lval[1]=lval2[1];
    lval[2]=lval2[2];
    }
  }

step(oper, lval) int (*oper)(), lval[]; {
  if(lval[1]) {
    if(lval[5]) {
      push();
      rvalue(lval);
      (*oper)(lval[2]>>2);
      pop();
      store(lval);
      return;
      }
    else {
      move();
      lval[5]=1;
      }
    }
  rvalue(lval);
  (*oper)(lval[2]>>2);
  store(lval);
  }

store(lval)  int lval[]; {
  if(lval[1]) putstk(lval);
  else        putmem(lval);
  }

rvalue(lval) int lval[]; {
  if ((lval[0]!=0)&(lval[1]==0)) getmem(lval);
  else                         indirect(lval);
  }

test(label, parens)  int label, parens;  {
  int lval[8];
  char *before, *start;
  if(parens) needtoken("(");
  while(1) {
    setstage(&before, &start);
    if(hier1(lval)) rvalue(lval);
    if(match(",")) clearstage(before, start);
    else break;
    }
  if(parens) needtoken(")");
  if(lval[3]) {			/* constant expression */
    clearstage(before, 0);
    if(lval[4]) return;
    jump(label);
    return;
    }
  if(lval[7]) {			/* stage address of "oper 0" code */
    oper=lval[6];		/* operator function address */
         if((oper==ffeq)|
            (oper==ule)) zerojump(eq0, label, lval);
    else if((oper==ffne)|
            (oper==ugt)) zerojump(ne0, label, lval);
    else if (oper==ffgt) zerojump(gt0, label, lval);
    else if (oper==ffge) zerojump(ge0, label, lval);
    else if (oper==uge)  clearstage(lval[7],0);
    else if (oper==fflt) zerojump(lt0, label, lval);
    else if (oper==ult)  zerojump(ult0, label, lval);
    else if (oper==ffle) zerojump(le0, label, lval);
    else                 testjump(label);
    }
  else testjump(label);
  clearstage(before, start);
  }

constexpr(val) int *val; {
  int const;
  char *before, *start;
  setstage(&before, &start);
  expression(&const, val);
  clearstage(before, 0);	/* scratch generated code */
  if(const==0) error("must be constant expression");
  return const;
  }

const(val) int val; {
  immed();
  outdec(val);
  nl();
  }

const2(val) int val; {
  immed2();
  outdec(val);
  nl();
  }

constant(lval)  int lval[]; {
  lval=lval+3;
  *lval=1;			/* assume it will be a constant */
  if (number(++lval)) immed();
  else if (pstr(lval)) immed();
  else if (qstr(lval)) {
    *(lval-1)=0;		/* nope, it's a string address */
    immed();
    ot("OFFSET ");             /* For MASM -- RG */
    printlabel(litlab);
    outbyte('+');
    }
  else return 0;
  outdec(*lval);
  nl();
  return 1;
  }

number(val)  int val[]; {
  int k, minus;
  k=minus=0;
  while(1) {
    if(match("+")) ;
    else if(match("-")) minus=1;
    else break;
    }
  if(isdigit(cch)==0)return 0;
  while (isdigit(cch)) k=k*10+(inbyte()-'0');
  if (minus) k=(-k);
  val[0]=k;
  return 1;
  }

address(ptr) char *ptr; {
  immed();
  ot("OFFSET ");       /* For MASM -- RG */ 
  outlab(ptr+NAME);    /* Append underscore -- RG */
  nl();
  }

pstr(val)  int val[]; {
  int k;
  k=0;
  if (match("'")==0) return 0;
  while(cch!=39)    k=(k&255)*256 + (litchar()&255);
  gch();
  val[0]=k;
  return 1;
  }

qstr(val)  int val[]; {
  char c;
  if (match(quote)==0) return 0;
  val[0]=litptr;
  while (cch!='"') {
    if(cch==0) break;
    stowlit(litchar(), 1);
    }
  gch();
  litq[litptr++]=0;
  return 1;
  }

stowlit(value, size) int value, size; {
  if((litptr+size) >= LITMAX) {
    error("literal queue overflow"); abort(ERRCODE);
    }
  putint(value, litq+litptr, size);
  litptr=litptr+size;
  }

/*
** return current literal char & bump lptr
*/
litchar() {
  int i, oct;
  if((cch!=92)|(nch==0)) return gch();
  gch();
  if(cch=='n') {gch(); return NEWLINE;}
  if(cch=='t') {gch(); return  9;} /* HT */
  if(cch=='b') {gch(); return  8;} /* BS */
  if(cch=='f') {gch(); return 12;} /* FF */
  i=3; oct=0;
  while(((i--)>0)&(cch>='0')&(cch<='7')) oct=(oct<<3)+gch()-'0';
  if(i==2) return gch(); else return oct;
  }

