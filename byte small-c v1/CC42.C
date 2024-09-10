/*
** Small C - 8088/8086 version - modified by R. Grehan, BYTE Magazine
**
** add primary and secondary registers (result in primary)
*/
ffadd() {ol(" ADD BX,DX");}

/*
** subtract primary from secondary register (result in primary)
*/
ffsub() {ol(" SUB DX,BX"); ol(" MOV BX,DX");}

/*
** multiply primary and secondary registers (result in primary)
*/
ffmult() {ol(" MOV AX,DX"); ol(" IMUL BX"); ol(" MOV BX,AX");}

/*
** divide secondary by primary register
** (quotient in primary, remainder in secondary)
*/
ffdiv() {ol(" MOV AX,DX"); ol(" SUB DX,DX"); ol(" IDIV BX");
         ol(" MOV BX,AX"); }

/*
** remainder of secondary/primary
** (remainder in primary, quotient in secondary)
*/
ffmod() {ffdiv();swap();}

/*
** inclusive "or" primary and secondary registers
** (result in primary)
*/
ffor() {ol(" OR BX,DX");}

/*
** exclusive "or" the primary and secondary registers
** (result in primary)
*/
ffxor() {ol(" XOR BX,DX");}

/*
** "and" primary and secondary registers
** (result in primary)
*/
ffand() {ol(" AND BX,DX");}

/*
** logical negation of primary register
*/
lneg() {
  ol(" OR BX,BX");
  ol(" MOV BX,CX");
  ol(" JNZ $+3");
  ol(" INC BX");
}

/*
** arithmetic shift right secondary register
** number of bits given in primary register
** (result in primary)
** 8088 version: Note that I don't check BH to make
** sure there's nothing in it.  Might be a problem.--RG
*/
ffasr() {ol(" MOV CL,BL"); ol(" SAR DX,CL"); ol(" MOV BX,DX");
         ol(" XOR CX,CX"); }

/*
** arithmetic shift left secondary register
** number of bits given in primary register
** (result in primary)
*/
ffasl() {ol(" MOV CL,BL"); ol(" SAL DX,CL"); ol(" MOV BX,DX");
         ol(" XOR CX,CX"); }

/*
** two's complement primary register
*/
neg() {ol(" NEG BX");}

/*
** one's complement primary register
*/
com() {ol(" NOT BX");}

/*
** increment primary register by one object of whatever size
** 8088 version: I altered this slightly from the original
** code since it's easier to do 16-bit math on the 8088 --RG
*/
inc(n) int n; {
  if (n<=2) {
    while(1) {
     ol(" INC BX");
     if(--n < 1) break;
    }
  }
  else
  {  ot(" ADD BX,");
     outdec(n);
     nl();
  }
}

/*
** decrement primary register by one object of whatever size
** 8088 version: Same thing as inc(n) --RG
*/
dec(n) int n; {
  if (n<=2) {
    while(1) {
     ol(" DEC BX");
     if(--n < 1) break;
    }
  }
  else
  {  ot(" SUB BX,");
     outdec(n);
     nl();
  }
}
 
/*
** test for equal to
*/
ffeq()  {
  ol(" CMP DX,BX");
  ol(" MOV BX,CX");
  ol(" JNZ $+3");
  ol(" INC BX");
}

/*
** test for equal to zero
*/
eq0(label) int label; {
  ol(" OR BX,BX");
  ol(" JZ $+5");
  ot(" JMP ");
  printlabel(label);
  nl();
  }

/*
** test for not equal to
*/
ffne()  {
  ol(" CMP DX,BX");
  ol(" MOV BX,CX");
  ol(" JE $+3");
  ol(" INC BX");
}

/*
** test for not equal to zero
*/
ne0(label) int label; {
  ol(" OR BX,BX");
  ol(" JNZ $+5");
  ot(" JMP ");
  printlabel(label);
  nl();
  }

/*
** test for less than (signed)
*/
fflt()  {
  ol(" CMP DX,BX");
  ol(" MOV BX,CX");
  ol(" JGE $+3");
  ol(" INC BX");
}

/*
** test for less than zero
*/
lt0(label) int label; {
  ol(" OR BX,BX");
  ol(" JS $+5");
  ot(" JMP ");
  printlabel(label);
  nl();
  }

/*
** test for less than or equal to (signed)
*/
ffle()  {
  ol(" CMP DX,BX");
  ol(" MOV BX,CX");
  ol(" JG $+3");
  ol(" INC BX");
}

/*
** test for less than or equal to zero
*/
le0(label) int label; {
  ol(" OR BX,BX");
  ol(" JLE $+5");
  ot(" JMP ");
  printlabel(label);
  nl();
  }

/*
** test for greater than (signed)
*/
ffgt()  {
  ol(" CMP DX,BX");
  ol(" MOV BX,CX");
  ol(" JLE $+3");
  ol(" INC BX");
}

/*
** test for greater than zero
*/
gt0(label) int label; {
  ol(" OR BX,BX");
  ol(" JG $+5");
  ot(" JMP ");
  printlabel(label);
  nl();
  }

/*
** test for greater than or equal to (signed)
*/
ffge()  {
  ol(" CMP DX,BX");
  ol(" MOV BX,CX");
  ol(" JL $+3");
  ol(" INC BX");
}

/*
** test for greater than or equal to zero
*/
ge0(label) int label; {
  ol(" OR BX,BX");
  ol(" JGE $+5");
  ot(" JMP ");
  printlabel(label);
  nl();
  }

/*
** test for less than (unsigned)
*/
ult()  {
  ol(" CMP DX,BX");
  ol(" MOV BX,CX");
  ol(" JAE $+3");
  ol(" INC BX");
}

/*
** test for less than zero (unsigned)
*/
ult0(label) int label; {
  ot(" JMP ");
  printlabel(label);
  nl();
  }

/*
** test for less than or equal to (unsigned)
*/
ule()  {
  ol(" CMP DX,BX");
  ol(" MOV BX,CX");
  ol(" JA $+3");
  ol(" INC BX");
}

/*
** test for greater than (unsigned)
*/
ugt()  {
  ol(" CMP DX,BX");
  ol(" MOV BX,CX");
  ol(" JBE $+3");
  ol(" INC BX");
}

/*
** test for greater than or equal to (unsigned)
*/
uge()  {
  ol(" CMP DX,BX");
  ol(" MOV BX,CX");
  ol(" JB $+3");
  ol(" INC BX");
}

#ifdef OPTIMIZE
peephole(ptr) char *ptr; {
  while(*ptr) {
  cout(*ptr++,output);
  }
}
#endif

