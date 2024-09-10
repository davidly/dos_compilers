/*
** Small C - 8088/8086 version - modified by R. Grehan, BYTE Magazine
** open an include file
*/
doinclude()  {
  char *cp;
  blanks();			/* skip over to name */
  switch (*lptr) {
    case '"': case '<': cp = ++lptr;
    while(*cp) {
      switch(*cp) {case '"': case '>': *cp=NULL;}
      ++cp;
      }
    }
  if((input2=fopen(lptr,"r"))==NULL) {
    input2=EOF;
    error("open failure on include file");
    }
  kill();			/* clear rest of line */
				/* so next read will come from */
				/* new file (if open) */
  }

/*
** test for global declarations
*/
dodeclare(class) int class; {
  if(amatch("char",4)) {
    declglb(CCHAR, class);
    ns();
    return 1;
    }
  else if((amatch("int",3))|(class==EXTERNAL)) {
    declglb(CINT, class);
    ns();
    return 1;
    }
  return 0;
  }

/*
** delcare a static variable
*/
declglb(type, class)  int type, class; {
  int k, j;
  while(1) {
    if(endst()) return;			/* do line */
    if(match("(*")|match("*")) {
      j=POINTER;
      k=0;
      }
    else {
      j=VARIABLE;
      k=1;
      }
    if (symname(ssname, YES)==0) illname();
    if(findglb(ssname)) multidef(ssname);
    if(match(")")) ;
    if(match("()")) j=FUNCTION;
    else if (match("[")) {
      paerror(j);
      k=needsub();			/* get size */
      j=ARRAY;				/* !0=array */
      }
/* Following changed for MASM */
    if(class==EXTERNAL) { external(ssname);
     if(j==FUNCTION) { if(k!=0) ol("NEAR"); else ol("WORD"); }
      else
      if ((type==CCHAR)&(k!=0)) ol("BYTE"); else ol("WORD");
    }
    else if(j!=FUNCTION) j=initials(type>>2, j, k);
    addsym(ssname, j, type, k, &glbptr, class);
    if (match(",")==0) return;		/* more? */
    }
  }

/*
** declare local variables
*/
declloc(typ)  int typ;  {
  int k,j;
  if(swactive) error("not allowed in switch");
#ifdef STGOTO
  if(noloc) error("not allowed with goto");
#endif
  if(declared < 0) error("must declare first in block");
  while(1) {
    while(1) {
      if(endst()) return;
      if(match("*")) j=POINTER;
      else           j=VARIABLE;
      if (symname(ssname, YES)==0) illname();
      /* no multidef check, block-locals are together */
      k=BPW;
      if (match("[")) {
        paerror(j);
        if(k=needsub()) {
          j=ARRAY;
          if(typ==CINT)k=k<<LBPW;
          }
        else {j=POINTER; k=BPW;}
        }
      else if((typ==CCHAR)&(j==VARIABLE)) k=SBPC;
      declared = declared + k;
      addsym(ssname, j, typ, csp - declared, &locptr, AUTOMATIC);
      break;
      }
    if (match(",")==0) return;
    }
  }

/*
** test for pointer array (unsupported)
*/
paerror(j) int j; {
  if(j==POINTER) error("no pointer arrays");
  }

/*
** initialize global objects
*/
initials(size, ident, dim) int size, ident, dim; {
  int savedim;
  litptr=0;
  if(dim==0) dim = -1;
  savedim=dim;

/*  Had to change entry(); to following stuff to keep
** MASM happy.  It doesn't like colons preceding DW and
** DB.  Sheesh.  --RG
**  entry();
*/
  ot(" PUBLIC ");
  outlab(ssname);
  nl();
  outlab(ssname);
  
  if(match("=")) {
    if(match("{")) {
      while(dim) {
        init(size, ident, &dim);
        if(match(",")==0) break;
        }
      needtoken("}");
      }
    else init(size, ident, &dim);
    }
  if((dim == -1)&(dim==savedim)) {
     stowlit(0, size=BPW);
    ident=POINTER;
    }
  dumplits(size);
  dumpzero(size, dim);
  return ident;
  }

/*
** evaluate one initializer
*/
init(size, ident, dim) int size, ident, *dim; {
  int value;
  if(qstr(&value)) {
    if((ident==VARIABLE)|(size!=1))
      error("must assign to char pointer or array");
    *dim = *dim - (litptr - value);
    if(ident==POINTER) point();
    }
  else if(constexpr(&value)) {
    if(ident==POINTER) error("cannot assign to pointer");
    stowlit(value, size);
    *dim = *dim - 1;
    }
  }

/*
** get required array size
*/
needsub()  {
  int val;
  if(match("]")) return 0;	/* null size */
  if (constexpr(&val)==0) val=1;
  if (val<0) {
    error("negative size illegal");
    val = -val;
    }
  needtoken("]");		/* force single dimension */
  return val;			/* and return size */
  }

/*
** begin a function
**
** called from "parse" and tries to make a function
** out of the following text
**
*/
newfunc()  {
  char *ptr;
#ifdef STGOTO
  nogo  =			/* enable goto statements */
  noloc = 0;			/* enable block-local declarations */
#endif
  lastst=			/* no statement yet */
  litptr=0;			/* clear lit pool */
  litlab=getlabel();		/* label next lit pool */
  locptr=STARTLOC;		/* clear local variables */
  if(monitor) lout(line, stderr);
  if (symname(ssname, YES)==0) {
    error("illegal function or declaration");
    kill();			/* invalidate line */
    return;
    }
  if(func1) {
    postlabel(beglab);
    func1=0;
    }
  if(ptr=findglb(ssname)) {	/* already in symbol table ? */
    if(ptr[IDENT]!=FUNCTION)       multidef(ssname);
    else if(ptr[OFFSET]==FUNCTION) multidef(ssname);
    else {
      /* earlier assumed to be a function */
      ptr[OFFSET]=FUNCTION;
      ptr[CLASS]=STATIC;
      }
    }
  else
    addsym(ssname, FUNCTION, CINT, FUNCTION, &glbptr, STATIC);
  if(match("(")==0) error("no open paren");
  entry();
  locptr=STARTLOC;
  argstk=0;			/* init arg count */
  while(match(")")==0) {	/* then count args */
    /* any legal name bumps arg count */
    if(symname(ssname, YES)) {
      if(findloc(ssname)) multidef(ssname);
      else {
        addsym(ssname, 0, 0, argstk, &locptr, AUTOMATIC);
        argstk=argstk+BPW;
        }
      }
    else {error("illegal argument name");junk();}
    blanks();
    /* if not closing paren, should be comma */
    if(streq(lptr,")")==0) {
      if(match(",")==0) error("no comma");
      }
    if(endst()) break;
    }
  csp=0;			/* preset stack ptr */
  argtop=argstk;
  while(argstk) {
    /* now let user declare what types of things */
    /*      those arguments were */
    if(amatch("char",4))     {doargs(CCHAR);ns();}
    else if(amatch("int",3)) {doargs(CINT);ns();}
    else {error("wrong number of arguments");break;}
    }
  statement();
#ifdef STGOTO
  if(lastst != STRETURN && lastst != STGOTO) ffret();
#else
  if(lastst != STRETURN) ffret();
#endif
  if(litptr) {
    printlabel(litlab);
    col();
    dumplits(1);		/* dump literals */
    }
  }

/*
** declare argument types
**
** called from "newfunc" this routine adds an entry in the
** local symbol table for each named argument
*/
doargs(t) int t; {
  int j, legalname;
  char c, *argptr;
  while(1) {
    if(argstk==0) return;	/* no arguments */
    if(match("(*")|match("*")) j=POINTER;  else j=VARIABLE;
    if((legalname=symname(ssname, YES))==0) illname();
    if(match(")")) ;
    if(match("()")) ;
    if(match("[")) {
      paerror(j);
      while(inbyte()!=']') if(endst()) break;	/* skip "[...]" */
      j=POINTER;		/* add entry as pointer */
      }
    if(legalname) {
      if(argptr=findloc(ssname)) {
        /* add details of type and address */
        argptr[IDENT]=j;
        argptr[TYPE]=t;
        putint(argtop-getint(argptr+OFFSET, OFFSIZE), argptr+OFFSET, OFFSIZE);
        }
      else error("not an argument");
      }
    argstk=argstk-BPW;		/* cnt down */
    if(endst())return;
    if(match(",")==0) error("no comma");
    }
  }

