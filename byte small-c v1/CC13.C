/*
** Small C - 8088/8086 version - modified by R. Grehan, BYTE Magazine
**
** statement parser
**
** called whenever syntax requires a statement
**  this routine performs that statement
**  and returns a number telling which one
*/
statement() {
  if ((cch==0) & (eof)) return;
  else if(amatch("char",4))  {declloc(CCHAR);ns();}
  else if(amatch("int",3))   {declloc(CINT);ns();}
  else {
    if(declared >= 0) {
#ifdef STGOTO
      if(ncmp > 1) nogo=declared;	/* disable goto if any */
#endif
      csp=modstk(csp - declared, NO);
      declared = -1;
      }
    if(match("{"))                compound();
    else if(amatch("if",2))       {doif();		lastst=STIF;}
    else if(amatch("while",5))    {dowhile();		lastst=STWHILE;}
#ifdef STDO
    else if(amatch("do",2))       {dodo();		lastst=STDO;}
#endif
#ifdef STFOR
    else if(amatch("for",3))	  {dofor();		lastst=STFOR;}
#endif
#ifdef STSWITCH
    else if(amatch("switch",6))	  {doswitch();		lastst=STSWITCH;}
    else if(amatch("case",4))	  {docase();		lastst=STCASE;}
    else if(amatch("default",7))  {dodefault();		lastst=STDEF;}
#endif
#ifdef STGOTO
    else if(amatch("goto", 4))	  {dogoto();		lastst=STGOTO;}
    else if(dolabel())					lastst=STLABEL;
#endif
    else if(amatch("return",6))	  {doreturn();ns();	lastst=STRETURN;}
    else if(amatch("break",5))	  {dobreak();ns();	lastst=STBREAK;}
    else if(amatch("continue",8)) {docont();ns();	lastst=STCONT;}
    else if(match(";"))		  errflag=0;
    else if(match("#asm"))	  {doasm();		lastst=STASM;}
    else			  {doexpr();ns();	lastst=STEXPR;}
    }
  return lastst;
  }

/*
** semicolon enforcer
**
** called whenever syntax requires a semicolon
*/
ns()  {
  if(match(";")==0) error("no semicolon");
  else errflag=0;
  }

compound()  {
  int savcsp;
  char *savloc;
  savcsp=csp;
  savloc=locptr;
  declared=0;			/* may now declare local variables */
  ++ncmp;			/* new level open */
  while (match("}")==0)
    if(eof) {
      error("no final }");
      break;
      }
    else statement();		/* do one */
  --ncmp;			/* close current level */
/*55*/
#ifdef STGOTO
  if(lastst != STRETURN && lastst != STGOTO)
#else
  if(lastst != STRETURN)
#endif
    modstk(savcsp, NO);		/* delete local variable space */
  csp=savcsp;
/*55*/
#ifdef STGOTO
  cptr=savloc;			/* retain labels */
  while(cptr < locptr) {
    cptr2=nextsym(cptr);
    if(cptr[IDENT] == LABEL) {
      while(cptr < cptr2) *savloc++ = *cptr++;
      }
    else cptr=cptr2;
    }
#endif
  locptr=savloc;		/* delete local symbols */
  declared = -1;		/* may not declare variables */
  }

doif()  {
  int flab1,flab2;
  flab1=getlabel();		/* get label for false branch */
  test(flab1, YES);		/* get expression, and branch false */
  statement();			/* if true, do a statement */
  if (amatch("else",4)==0) {	/* if...else ? */
    /* simple "if"...print false label */
    postlabel(flab1);
    return;			/* and exit */
    }
  flab2=getlabel();
#ifdef STGOTO
  if((lastst != STRETURN)&(lastst != STGOTO)) jump(flab2);
#else
  if(lastst != STRETURN) jump(flab2);
#endif
  postlabel(flab1);		/* print false label */
  statement();			/* and do "else" clause */
  postlabel(flab2);		/* print true label */
  }

doexpr() {
  int const, val;
  char *before, *start;
  while(1) {
    setstage(&before, &start);
    expression(&const, &val);
    clearstage(before, start);
    if(cch != ',') break;
    bump(1);
    }
  }

dowhile()  {
  int wq[4];			/* allocate local queue */
  addwhile(wq);			/* add entry to queue for "break" */
  postlabel(wq[WQLOOP]);	/* loop label */
  test(wq[WQEXIT], YES);	/* see if true */
  statement();			/* if so, do a statement */
  jump(wq[WQLOOP]);		/* loop to label */
  postlabel(wq[WQEXIT]);	/* exit label */
  delwhile();			/* delete queue entry */
  }

#ifdef STDO
dodo() {
  int wq[4], top;
  addwhile(wq);
  postlabel(top=getlabel());
  statement();
  needtoken("while");
  postlabel(wq[WQLOOP]);
  test(wq[WQEXIT], YES);
  jump(top);
  postlabel(wq[WQEXIT]);
  delwhile();
  ns();
  }
#endif

#ifdef STFOR
dofor() {
  int wq[4], lab1, lab2;
  addwhile(wq);
  lab1=getlabel();
  lab2=getlabel();
  needtoken("(");
  if(match(";")==0) {
    doexpr();			/* expr 1 */
    ns();
    }
  postlabel(lab1);
  if(match(";")==0) {
    test(wq[WQEXIT], NO);	/* expr 2 */
    ns();
    }
  jump(lab2);
  postlabel(wq[WQLOOP]);
  if(match(")")==0) {
    doexpr();			/* expr 3 */
    needtoken(")");
    }
  jump(lab1);
  postlabel(lab2);
  statement();
  jump(wq[WQLOOP]);
  postlabel(wq[WQEXIT]);
  delwhile();
  }
#endif

#ifdef STSWITCH
doswitch() {
  int wq[4], endlab, swact, swdef, *swnex, *swptr;
  swact=swactive;
  swdef=swdefault;
  swnex=swptr=swnext;
  addwhile(wq);
  *(wqptr + WQLOOP - WQSIZ) = 0;
  needtoken("(");
  doexpr();			/* evaluate switch expression */
  needtoken(")");
  swdefault=0;
  swactive=1;
  jump(endlab=getlabel());
  statement();			/* cases, etc. */
  jump(wq[WQEXIT]);
  postlabel(endlab);
  sw();				/* match cases */
  while(swptr < swnext) {
    defstorage(CINT>>2);
    printlabel(*swptr++);	/* case label */
    outbyte(',');
    outdec(*swptr++);		/* case value */
    nl();
    }
  defstorage(CINT>>2);
  outdec(0);
  nl();
  if(swdefault) jump(swdefault);
  postlabel(wq[WQEXIT]);
  delwhile();
  swnext=swnex;
  swdefault=swdef;
  swactive=swact;
  }

docase() {
  if(swactive==0) error("not in switch");
  if(swnext > swend) {
    error("too many cases");
    return;
    }
  postlabel(*swnext++ = getlabel());
  constexpr(swnext++);
  needtoken(":");
  }

dodefault() {
  if(swactive) {
    if(swdefault) error("multiple defaults");
    }
  else error("not in switch");
  needtoken(":");
  postlabel(swdefault=getlabel());
  }
#endif

#ifdef STGOTO
dogoto() {
  if(nogo > 0) error("not allowed with block-locals");
  else noloc = 1;
  if(symname(ssname, YES)) jump(addlabel());
  else error("bad label");
  ns();
  }

dolabel() {
  char *savelptr;
  blanks();
  savelptr=lptr;
  if(symname(ssname, YES)) {
    if(gch()==':') {
      postlabel(addlabel());
      return 1;
      }
    else bump(savelptr-lptr);
    }
  return 0;
  }

addlabel()  {
  if(cptr=findloc(ssname)) {
    if(cptr[IDENT]!=LABEL) error("not a label");
    }
  else cptr=addsym(ssname, LABEL, LABEL, getlabel(), &locptr, LABEL);
  return (getint(cptr+OFFSET, OFFSIZE));
  }
#endif

doreturn()  {
  if(endst()==0) {
    doexpr();
    modstk(0, YES);
    }
  else modstk(0, NO);
  ffret();
  }

dobreak()  {
  int *ptr;
  if ((ptr=readwhile(wqptr))==0) return;
  modstk((ptr[WQSP]), NO);
  jump(ptr[WQEXIT]);
  }

docont()  {
  int *ptr;
  ptr = wqptr;
  while (1) {
    if ((ptr=readwhile(ptr))==0) return;
    if (ptr[WQLOOP]) break;
    }
  modstk((ptr[WQSP]), NO);
  jump(ptr[WQLOOP]);
  }

doasm()  {
  ccode=0;			/* mark mode as "asm" */
  while (1) {
    inline();
    if (match("#endasm")) break;
    if(eof)break;
    sout(line, output);
    }
  kill();
  ccode=1;
  }

