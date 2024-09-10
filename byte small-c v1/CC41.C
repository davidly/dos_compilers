/*
** Small C - 8088/8086 version - modified by R. Grehan, BYTE Magazine
**
** print all assembler info before any code is generated
*/
header()  {
  ol(" INCLUDE PROLOG.H");
  beglab=getlabel();
  }

/*
** print any assembler stuff needed at the end
*/
trailer()  {  
#ifndef LINK
  if((beglab == 1)|(beglab > 9000)) {
    /* implementation dependent trailer code goes here */
    }
#else
  char *ptr;
  cptr=STARTGLB;
  while(cptr<ENDGLB) {
    if(cptr[IDENT]==FUNCTION && cptr[CLASS]==AUTOEXT)
     { external(cptr+NAME);
      ol("NEAR");
     }
    cptr+=SYMMAX;
    }
#ifdef UPPER
  if((ptr=findglb("MAIN")) && (ptr[OFFSET]==FUNCTION))
#else
  if((ptr=findglb("main")) && (ptr[OFFSET]==FUNCTION))
#endif
{   external("Uend");	/* link to library functions */
    ol("NEAR");
}
    if(swused) { external("CCSWITCH");  /* RG */
               ol("NEAR"); }
#endif
  ol(" INCLUDE EPILOG.H");
  ol(" END");
  }

/*
** load # args before function call
*/
loadargc(val) int val; {
  if(search("NOCCARGC", macn, NAMESIZE+2, MACNEND, MACNBR, 0)==0) {
    if(val) {
      ot(" MOV AL,");
      outdec(val);
      nl();
      }
    else ol(" XOR AL,AL");
    }
  }

/*
** declare entry point
*/
entry() {

  /* Need this for 8088 -- RG */

  ot(" PUBLIC ");
  outlab(ssname);
  nl();

  outlab(ssname);
  col();

/* This code removed so MASM won't barf. --RG
**
** #ifdef LINK
**  col();
** #endif
*/

  nl();
  }

/*
** declare external reference
*/
external(name) char *name; {
#ifdef LINK
  ot(" EXTRN ");
  outlab(name);	/* Changed to ot() because MASM needs :class */
  ot(":");
#endif
  }

/*
** fetch object indirect to primary register
*/
indirect(lval) int lval[]; {
  if(lval[1]==CCHAR) {
              ol(" MOV AL,[BX]");
              ol(" CBW");
              ol(" MOV BX,AX");
  }
  else {
              ol(" MOV BX,[BX]");
  }
}

/*
** fetch a static memory cell into primary register
*/
getmem(lval)  int lval[]; {
  char *sym;
  sym=lval[0];
  if((sym[IDENT]!=POINTER)&(sym[TYPE]==CCHAR)) {
    ot(" MOV AL,");
    outlab(sym+NAME);
    nl();
    ol(" CBW");
    ol(" MOV BX,AX");
    }
  else {
    ot(" MOV BX,");
    outlab(sym+NAME);
    nl();
    }
  }

/*
** fetch addr of the specified symbol into primary register
*/
getloc(sym)  char *sym; {
  const(getint(sym+OFFSET, OFFSIZE)-csp);
  ol(" ADD BX,SP");
  }

/*
** store primary register into static cell
*/
putmem(lval)  int lval[]; {
  char *sym;
  ot(" MOV ");
  sym=lval[0];
  outlab(sym+NAME);
  if((sym[IDENT]!=POINTER)&(sym[TYPE]==CCHAR)) {
    ot(",BL");
    }
  else ot(",BX");
  nl();
  }

/*
** put on the stack the type object in primary register
*/
putstk(lval) int lval[]; {
  ol(" MOV SI,DX");
  if(lval[1]==CCHAR) {
    ol(" MOV [SI],BL");
    }
  else {
    ol(" MOV [SI],BX");
 }
}

/*
** move primary register to secondary
*/
move() {
  ol(" MOV DX,BX");
  }

/*
** swap primary and secondary registers
*/
swap() {
  ol(" XCHG BX,DX");
  }

/*
** partial instruction to get immediate value
** into the primary register
*/
immed() {
  ot(" MOV BX,");
  }

/*
** partial instruction to get immediate operand
** into secondary register
*/
immed2() {
  ot(" MOV DX,");
  }

/*
** push primary register onto stack
*/
push() {
  ol(" PUSH BX  ;");  /* Extra "  ;" makes required by unpush() */
  csp=csp-BPW;
  }

/*
** unpush or pop as required
*/
smartpop(lval, start) int lval[]; char *start; {
  if(lval[5])  pop();		/* secondary was used */
  else unpush(start);
  }

/*
** replace a push with a swap
*/
unpush(dest) char *dest; {
  int i;
  char *sour;
  sour=" XCHG DX,BX";
  while(*sour) *dest++ = *sour++;
  sour=stagenext;
  while(--sour > dest) {	/* adjust stack references */
    if(streq(sour," ADD BX,SP")) {
      --sour;
      i=BPW;
      while(isdigit(*(--sour))) {
        if((*sour = *sour-i) < '0') {
          *sour = *sour+10;
          i=1;
          }
        else i=0;
        }
      }
    }
  csp=csp+BPW;
  }

/*
** pop stack to the secondary register
*/
pop() {
  ol(" POP DX");
  csp=csp+BPW;
  }

/*
** swap primary register and stack
*/
swapstk() {
  ol(" MOV SI,SP");
  ol(" XCHG [SI],BX");
  }

/*
** process switch statement
*/
sw() {
  ffcall("CCSWITCH");

/* Following added so we know to generate an EXTRN call for */
/* CCSWITCH.  -- RG */
  swused=1;
  }

/*
** call specified subroutine name
*/
ffcall(sname)  char *sname; {
  ot(" CALL ");
  outlab(sname);  /* Changed to outlab() --RG */
  nl();
  }

/*
** return from subroutine
*/
ffret() {
  ol(" RET");
  }

/*
** perform subroutine call to value on stack
*/
callstk() {
  ol(" CALL BX");
  }

/*
** jump to internal label number
*/
jump(label)  int label; {
  ot(" JMP ");
  printlabel(label);
  nl();
  }

/*
** test primary register and jump if false
*/
testjump(label)  int label; {
  ol(" OR BX,BX");
  ol(" JNZ $+5");
  ot(" JMP ");
  printlabel(label);
  nl();
  }

/*
** test primary register against zero and jump if false
*/
zerojump(oper, label, lval) int (*oper)(), label, lval[]; {
  clearstage(lval[7], 0);	/* purge conventional code */
  (*oper)(label);
  }

/*
** define storage according to size
*/
defstorage(size) int size; {
  if(size==1) ot(" DB ");
  else        ot(" DW ");
  }

/*
** point to following object(s)
*/
point() {
  ol(" DW $+2");
  }

/*
** modify stack pointer to value given
*/
modstk(newsp, save)  int newsp, save; {
  int k;
  k=newsp-csp;
  if(k==0)return newsp;
  if(k>=0) {
      ot(" ADD SP,");
      outdec(k);
      nl();
      return newsp;
    }
  if(k<0) {
        ot(" SUB SP,");
        outdec(0-k);
        nl();
        return newsp;
   }
}
/*
** double primary register
*/
doublereg() {ol(" ADD BX,BX");}
