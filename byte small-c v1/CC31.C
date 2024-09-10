/*
** Small C - 8088/8086 version - modified by R. Grehan, BYTE Magazine
**
** lval[0] - symbol table address, else 0 for constant
** lval[1] - type of indirect obj to fetch, else 0 for static
** lval[2] - type of pointer or array, else 0 for all other
** lval[3] - true if constant expression
** lval[4] - value of constant expression (+ auxiliary uses)
** lval[5] - true if secondary register altered
** lval[6] - function address of highest/last binary operator
** lval[7] - stage address of "oper 0" code, else 0
*/

/*
** skim over terms adjoining || and && operators
*/
skim(opstr, testfunc, dropval, endval, hier, lval)
  char *opstr;
  int (*testfunc)(), dropval, endval, (*hier)(), lval[]; {
  int k, hits, droplab, endlab;
  hits=0;
  while(1) {
    k=plnge1(hier, lval);
    if(nextop(opstr)) {
      bump(opsize);
      if(hits==0) {
        hits=1;
        droplab=getlabel();
        }
      dropout(k, testfunc, droplab, lval);
      }
    else if(hits) {
      dropout(k, testfunc, droplab, lval);
      const(endval);
      jump(endlab=getlabel());
      postlabel(droplab);
      const(dropval);
      postlabel(endlab);
      lval[1]=lval[2]=lval[3]=lval[4]=lval[7]=0;
      return 0;
      }
    else return k;
    }
  }

/*
** test for early dropout from || or && evaluations
*/
dropout(k, testfunc, exit1, lval)
  int k, (*testfunc)(), exit1, lval[]; {
  if(k) rvalue(lval);
  else if(lval[3]) const(lval[4]);
  (*testfunc)(exit1);		/* jumps on false */
  }

/*
** plunge to a lower level
*/
plnge(opstr, opoff, hier, lval)
  char *opstr;
  int opoff, (*hier)(), lval[]; {
  int k, lval2[8];
  k=plnge1(hier, lval);
  if(nextop(opstr)==0) return k;
  if(k) rvalue(lval);
  while(1) {
    if(nextop(opstr)) {
      bump(opsize);
      opindex=opindex+opoff;
      plnge2(op[opindex], op2[opindex], hier, lval, lval2);
      }
    else return 0;
    }
  }

/*
** unary plunge to lower level
*/
plnge1(hier, lval) int (*hier)(), lval[]; {
  char *before, *start;
  int k;
  setstage(&before, &start);
  k=(*hier)(lval);
  if(lval[3]) clearstage(before,0);	/* load constant later */
  return k;
  }

/*
** binary plunge to lower level
*/
plnge2(oper, oper2, hier, lval, lval2)
  int (*oper)(),(*oper2)(),(*hier)(),lval[],lval2[]; {
  char *before, *start;
  setstage(&before, &start);
  lval[5]=1;		/* flag secondary register used */
  lval[7]=0;		/* flag as not "... oper 0" syntax */
  if(lval[3]) {		/* constant on left side not yet loaded */
    if(plnge1(hier, lval2)) rvalue(lval2);
    if(lval[4]==0) lval[7]=stagenext;
    const2(lval[4]<<dbltest(oper, lval2, lval));
    }
  else {		/* non-constant on left side */
    push();
    if(plnge1(hier, lval2)) rvalue(lval2);
    if(lval2[3]) {	/* constant on right side */
      if(lval2[4]==0) lval[7]=start;
      if(oper==ffadd) {	/* may test other commutative operators */
        csp=csp+2;
        clearstage(before, 0);
        const2(lval2[4]<<dbltest(oper, lval, lval2));
			/* load secondary */
        }
      else {
        const(lval2[4]<<dbltest(oper, lval, lval2));
			/* load primary */
        smartpop(lval2, start);
        }
      }
    else {		/* non-constants on both sides */
      smartpop(lval2, start);
      if(dbltest(oper, lval,lval2)) doublereg();
      if(dbltest(oper, lval2,lval)) {
        swap();
        doublereg();
        if(oper==ffsub) swap();
        }
      }
    }
  if(oper) {
    if(lval[3]=lval[3]&lval2[3]) {
      lval[4]=calc(lval[4], oper, lval2[4]);
      clearstage(before, 0);  
      lval[5]=0;
      }
    else {
      if((lval[2]==0)&(lval2[2]==0)) {
        (*oper)();
        lval[6]=oper;			/* identify the operator */
        }
      else {
        (*oper2)();
        lval[6]=oper2;			/* identify the operator */
        }
      }
    if(oper==ffsub) {
      if((lval[2]==CINT)&(lval2[2]==CINT)) {
        swap();
        const(1);
        ffasr();			/** div by 2 **/
        }
      }
    if((oper==ffsub)|(oper==ffadd)) result(lval, lval2);
    }
  }

calc(left, oper, right) int left, (*oper)(), right; {
       if(oper ==  ffor) return (left  |  right);
  else if(oper == ffxor) return (left  ^  right);
  else if(oper == ffand) return (left  &  right);
  else if(oper ==  ffeq) return (left  == right);
  else if(oper ==  ffne) return (left  != right);
  else if(oper ==  ffle) return (left  <= right);
  else if(oper ==  ffge) return (left  >= right);
  else if(oper ==  fflt) return (left  <  right);
  else if(oper ==  ffgt) return (left  >  right);
  else if(oper == ffasr) return (left  >> right);
  else if(oper == ffasl) return (left  << right);
  else if(oper == ffadd) return (left  +  right);
  else if(oper == ffsub) return (left  -  right);
  else if(oper ==ffmult) return (left  *  right);
  else if(oper == ffdiv) return (left  /  right);
  else if(oper == ffmod) return (left  %  right);
  else return 0;
  }

expression(const, val) int *const, *val;  {
  int lval[8];
  if(hier1(lval)) rvalue(lval);
  if(lval[3]) {
    *const=1;
    *val=lval[4];
    }
  else *const=0;
  }

hier1(lval)  int lval[];  {
  int k,lval2[8], lval3[2], oper;
  k=plnge1(hier3, lval);
  if(lval[3]) const(lval[4]);
       if(match("|="))  oper=ffor;
  else if(match("^="))  oper=ffxor;
  else if(match("&="))  oper=ffand;
  else if(match("+="))  oper=ffadd;
  else if(match("-="))  oper=ffsub;
  else if(match("*="))  oper=ffmult;
  else if(match("/="))  oper=ffdiv;
  else if(match("%="))  oper=ffmod;
  else if(match(">>=")) oper=ffasr;
  else if(match("<<=")) oper=ffasl;
  else if(match("="))   oper=0;
  else return k;
  if(k==0) {
    needlval();
    return 0;
    }
  lval3[0] = lval[0];
  lval3[1] = lval[1];
  if(lval[1]) {
    if(oper) {
      push();
      rvalue(lval);
      }
    plnge2(oper, oper, hier1, lval, lval2);
    if(oper) pop();
    }
  else {
    if(oper) {
      rvalue(lval);
      plnge2(oper, oper, hier1, lval, lval2);
      }
    else {
      if(hier1(lval2)) rvalue(lval2);
      lval[5]=lval2[5];
      }
    }
  store(lval3);
  return 0;
  }

hier3(lval)  int lval[]; {
  return skim("||", eq0, 1, 0, hier4, lval);
  }

hier4(lval)  int lval[]; {
  return skim("&&", ne0, 0, 1, hier5, lval);
  }

hier5(lval)  int lval[]; {
  return plnge("|", 0, hier6, lval);
  }

hier6(lval)  int lval[]; {
  return plnge("^", 1, hier7, lval);
  }

hier7(lval)  int lval[]; {
  return plnge("&", 2, hier8, lval);
  }

hier8(lval)  int lval[];  {
  return plnge("== !=", 3, hier9, lval);
  }

hier9(lval)  int lval[];  {
  return plnge("<= >= < >", 5, hier10, lval);
  }

hier10(lval)  int lval[];  {
  return plnge(">> <<", 9, hier11, lval);
  }

hier11(lval)  int lval[];  {
  return plnge("+ -", 11, hier12, lval);
  }

hier12(lval)  int lval[];  {
  return plnge("* / %", 13, hier13, lval);
  }

