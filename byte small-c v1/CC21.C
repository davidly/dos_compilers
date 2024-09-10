/*
** Small C - 8088/8086 version - modified by R. Grehan, BYTE Magazine
*/

junk() {
  if(an(inbyte())) while(an(cch)) gch();
  else while(an(cch)==0) {
    if(cch==0) break;
    gch();
    }
  blanks();
  }

endst() {
  blanks();
  return ((streq(lptr,";")|(cch==0)));
  }

illname() {
  error("illegal symbol");
  junk();
  }
  
multidef(sname)  char *sname; {
  error("already defined");
  }

needtoken(str)  char *str; {
  if (match(str)==0) error("missing token");
  }

needlval() {
  error("must be lvalue");
  }

findglb(sname)  char *sname; {
  if(search(sname, STARTGLB, SYMMAX, ENDGLB, NUMGLBS, NAME))
    return cptr;
  return 0;
  }

findloc(sname)  char *sname;  {
  cptr = locptr - 1;		/* search backward for block locals */
  while(cptr > STARTLOC) {
    cptr = cptr - *cptr;
    if(astreq(sname, cptr, NAMEMAX)) return (cptr - NAME);
    cptr = cptr - NAME - 1;
    }
  return 0;
  }

addsym(sname, id, typ, value, lgptrptr, class)
  char *sname, id, typ;  int value, *lgptrptr, class; {
  if(lgptrptr == &glbptr) {
    if(cptr2=findglb(sname)) return cptr2;
    if(cptr==0) {
      error("global symbol table overflow");
      return 0;
      }
    }
  else {
    if(locptr > (ENDLOC-SYMMAX)) {
      error("local symbol table overflow");
      abort(ERRCODE);
      }
    cptr = *lgptrptr;
    }
  cptr[IDENT]=id;
  cptr[TYPE]=typ;
  cptr[CLASS]=class;
  putint(value, cptr+OFFSET, OFFSIZE);
  cptr3 = cptr2 = cptr + NAME;
  while(an(*sname)) *cptr2++ = *sname++;
  if(lgptrptr == &locptr) {
    *cptr2 = cptr2 - cptr3;	/* set length */
    *lgptrptr = ++cptr2;
    }
  return cptr;
  }

nextsym(entry) char *entry; {
  entry = entry + NAME;
  while(*entry++ >= ' ');	/* find length byte */
  return entry;
  }

/*
** get integer of length len from address addr
** (byte sequence set by "putint")
*/
getint(addr, len) char *addr; int len; {
  int i;
  i = *(addr + --len);		/* high order byte sign extended */
  while(len--) i = (i << 8) | *(addr+len)&255;
  return i;
  }

/*
** put integer i of length len into address addr
** (low byte first)
*/
putint(i, addr, len) char *addr; int i, len; {
  while(len--) {
    *addr++ = i;
    i = i>>8;
    }
  }

/*
** test if next input string is legal symbol name
*/
symname(sname, ucase) char *sname; int ucase; {
  int k;char c;
  blanks();
  if(alpha(cch)==0) return (*sname=0);
  k=0;
  while(an(cch)) {
#ifdef UPPER
    if(ucase)
      sname[k]=toupper(gch());
    else
#endif
      sname[k]=gch();
    if(k<NAMEMAX) ++k;
    }
  sname[k]=0;
  return 1;
  }

/*
** return next avail internal label number
*/
getlabel() {
  return(++nxtlab);
  }

/*
** post a label in the program
*/
postlabel(label) int label; {
  printlabel(label);
  col();
  nl();
  }

/*
** print specified number as a label
*/
printlabel(label)  int label; {
  outstr("_CC");
  outdec(label);
  }

/*
** test if c is alphabetic
*/
alpha(c)  char c; {
  return (isalpha(c) || c=='_');
  }

/*
** test if given character is alphanumeric
*/
an(c)  char c; {
  return (alpha(c) || isdigit(c));
  }

addwhile(ptr)  int ptr[]; {
  int k;
  ptr[WQSP]=csp;		/* and stk ptr */
  ptr[WQLOOP]=getlabel();	/* and looping label */
  ptr[WQEXIT]=getlabel();	/* and exit label */
  if (wqptr==WQMAX) {
    error("too many active loops");
    abort(ERRCODE);
    }
  k=0;
  while (k<WQSIZ) *wqptr++ = ptr[k++];
  }

delwhile() {
  if (wqptr > wq) wqptr=wqptr-WQSIZ;
  }

readwhile(ptr) int *ptr; {
  if (ptr <= wq) {
    error("out of context");
    return 0;
    }
  else return (ptr-WQSIZ);
 }

white() {
#ifdef DYNAMIC
  /* test for stack/prog overlap at deepest nesting */
  /* primary -> symname -> blanks -> white */
  avail(YES);		/* abort on stack overflow */
#endif
  return (*lptr<= ' ' && *lptr!=NULL);
  }

gch() {
  int c;
  if(c=cch) bump(1);
  return c;
  }

bump(n) int n; {
  if(n) lptr=lptr+n;
  else  lptr=line;
  if(cch=nch = *lptr) nch = *(lptr+1);
  }

kill() {
  *line=0;
  bump(0);
  }

inbyte()  {
  while(cch==0) {
    if (eof) return 0;
    preprocess();
    }
  return gch();
  }

inline() {			/* numerous revisions */
  int k,unit;
  poll(1);			/* allow operator interruption */
  if (input==EOF) openfile();
  if(eof) return;
  if((unit=input2)==EOF) unit=input;
  if(fgets(line, LINEMAX, unit)==NULL) {
    fclose(unit);
    if(input2!=EOF) input2=EOF;
    else input=EOF;
    *line=NULL;
    }
  else if(listfp) {
    if(listfp==output) cout(';', output);
    sout(line, listfp);
    }
  bump(0);
  }

