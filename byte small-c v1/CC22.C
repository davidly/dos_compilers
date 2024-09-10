/*
** Small C - 8088/8086 version - modified by R. Grehan, BYTE Magazine
*/

ifline() {
  while(1) {
    inline();
    if(eof) return;
    if(match("#ifdef")) {
      ++iflevel;
      if(skiplevel) continue;
      symname(msname, NO);
      if(search(msname, macn, NAMESIZE+2, MACNEND, MACNBR, 0)==0)
        skiplevel=iflevel;
      continue;
      }
    if(match("#ifndef")) {
      ++iflevel;
      if(skiplevel) continue;
      symname(msname, NO);
      if(search(msname, macn, NAMESIZE+2, MACNEND, MACNBR, 0))
        skiplevel=iflevel;
      continue;
      }
    if(match("#else")) {
      if(iflevel) {
        if(skiplevel==iflevel) skiplevel=0;
        else if(skiplevel==0)  skiplevel=iflevel;
        }
      else noiferr();
      continue;
      }
    if(match("#endif")) {
      if(iflevel) {
        if(skiplevel==iflevel) skiplevel=0;
        --iflevel;
        }
      else noiferr();
      continue;
      }
    if(skiplevel) continue;
    if(cch==0) continue;
    break;
    }
  }

keepch(c)  char c; {
  if(pptr<LINEMAX) pline[++pptr]=c;
  }

preprocess() {
  int k;
  char c;
  if(ccode) {
    line=mline;
    ifline();
    if(eof) return;
    }
  else {
    line=pline;
    inline();
    return;
    }
  pptr = -1;
  while(cch != NEWLINE && cch) {
    if(white()) {
      keepch(' ');
      while(white()) gch();
      }
    else if(cch=='"') {
      keepch(cch);
      gch();
      while((cch!='"')|((*(lptr-1)==92)&(*(lptr-2)!=92))) {
        if(cch==0) {
          error("no quote");
          break;
          }
        keepch(gch());
        }
      gch();
      keepch('"');
      }
    else if(cch==39) {
      keepch(39);
      gch();
      while((cch!=39)|((*(lptr-1)==92)&(*(lptr-2)!=92))) {
        if(cch==0) {
          error("no apostrophe");
          break;
          }
        keepch(gch());
        }
      gch();
      keepch(39);
      }
    else if((cch=='/')&(nch=='*')) {
      bump(2);
      while(((cch=='*')&(nch=='/'))==0) {
        if(cch) bump(1);
        else {
          ifline();
          if(eof) break;
          }
        }
      bump(2);
      }
    else if(an(cch)) {
      k=0;
      while((an(cch)) & (k<NAMEMAX)) {
        msname[k++]=cch;
        gch();
        }
      msname[k]=0;
      if(search(msname, macn, NAMESIZE+2, MACNEND, MACNBR, 0)) {
        k=getint(cptr+NAMESIZE, 2);
        while(c=macq[k++]) keepch(c);
        while(an(cch)) gch();
        }
      else {
        k=0;
        while(c=msname[k++]) keepch(c);
        }
      }
    else keepch(gch());
    }
  if(pptr>=LINEMAX) error("line too long");
  keepch(0);
  line=pline;
  bump(0);
  }

noiferr() {
  error("no matching #if...");
  errflag=0;
  }

addmac() {
  int k;
  if(symname(msname, NO)==0) {
    illname();
    kill();
    return;
    }
  k=0;
  if(search(msname, macn, NAMESIZE+2, MACNEND, MACNBR, 0)==0) {
    if(cptr2=cptr) while(*cptr2++ = msname[k++]);
    else {
      error("macro name table full");
      return;
      }
    }
  putint(macptr, cptr+NAMESIZE, 2);
  while(white()) gch();
  while(putmac(gch()));
  if(macptr>=MACMAX) {
    error("macro string queue full"); abort(ERRCODE);
    }
  }

putmac(c)  char c; {
  macq[macptr]=c;
  if(macptr<MACMAX) ++macptr;
  return c;
  }

/*
** search for symbol match
** on return cptr points to slot found or empty slot
*/
search(sname, buf, len, end, max, off)
  char *sname, *buf, *end;  int len, max, off; {
  cptr=cptr2=buf+((hash(sname)%(max-1))*len);
  while(*cptr != 0) {
    if(astreq(sname, cptr+off, NAMEMAX)) return 1;
    if((cptr=cptr+len) >= end) cptr=buf;
    if(cptr == cptr2) return (cptr=0);
    }
  return 0;
  }

hash(sname) char *sname; {
  int i, c;
  i=0;
  while(c = *sname++) i=(i<<1)+c;
  return i;
  }

setstage(before, start) int *before, *start; {
  if((*before=stagenext)==0) stagenext=stage;
  *start=stagenext;
  }

clearstage(before, start) char *before, *start; {
  *stagenext=0;
  if(stagenext=before) return;
  if(start) {
#ifdef OPTIMIZE
    peephole(start);
#else
    sout(start, output);
#endif
    }
  }

outdec(number)  int number; {
  int k,zs;
  char c, *q, *r;
  zs = 0;
  k=10000;
  if (number<0) {
    number=(-number);
    outbyte('-');
    }
  while (k>=1) {
    q=0; r=number;
    while(r >= k) {++q; r -= k;}
    c = q + '0';
    if ((c!='0')|(k==1)|(zs)) {
      zs=1;
      outbyte(c);
      }
    number=r;
    k=k/10;
    }
  }

ol(ptr)  char ptr[];  {
  ot(ptr);
  nl();
  }

ot(ptr) char ptr[]; {
  outstr(ptr);
  }

/* Act like a real C compiler...append all labels */
/* with underscores.       */

outlab(ptr) char ptr[]; {
 ot("_");
 outstr(ptr);
}

outstr(ptr) char ptr[]; {
  poll(1); /* allow program interruption */
  /* must work with symbol table names terminated by length */
  while(*ptr >= ' ') outbyte(*ptr++);
  }

outbyte(c) char c; {
  if(stagenext) {
    if(stagenext==stagelast) {
      error("staging buffer overflow");
      return 0;
      }
    else *stagenext++ = c;
    }
  else cout(c,output);
  return c;
  }

cout(c, fd) char c; int fd; {
	if(fputc(c,fd)==EOF) xout();
 }

sout(string, fd) char *string; int fd; {
  while(*string)
	cout(*string++,fd);
  }

lout(line, fd) char *line; int fd; {
  sout(line, fd);
  cout(NEWLINE, fd);
  }

xout() {
  fputs("output error", stderr);
  abort(ERRCODE);
  }

nl() {
  outbyte(NEWLINE);
  }

col() {
#ifdef COL
  outbyte(':');
#endif
  }

error(msg) char msg[]; {
  if(errflag) return; else errflag=1;
  lout(line, stderr);
  errout(msg, stderr);
  if(alarm) fputc(7, stderr);
  if(pause) while(fgetc(stderr)!=NEWLINE);
  if(listfp>0) errout(msg, listfp);
  }

errout(msg, fp) char msg[]; int fp; {
  int k; k=line+2;
  while(k++ <= lptr) cout(' ', fp);
  lout("/\\", fp);
  sout("**** ", fp); lout(msg, fp);
  }

streq(str1,str2)  char str1[],str2[]; {
  int k;
  k=0;
  while (str2[k]) {
    if ((str1[k])!=(str2[k])) return 0;
    ++k;
    }
  return k;
 }

astreq(str1,str2,len)  char str1[],str2[];int len; {
  int k;
  k=0;
  while (k<len) {
    if ((str1[k])!=(str2[k]))break;
    /*
    ** must detect end of symbol table names terminated by
    ** symbol length in binary
    */
    if(str1[k] < ' ') break;
    if(str2[k] < ' ') break;
    ++k;
    }
  if (an(str1[k]))return 0;
  if (an(str2[k]))return 0;
  return k;
 }

match(lit)  char *lit; {
  int k;
  blanks();
  if (k=streq(lptr,lit)) {
    bump(k);
    return 1;
    }
  return 0;
  }

amatch(lit,len)  char *lit;int len; {
  int k;
  blanks();
  if (k=astreq(lptr,lit,len)) {
    bump(k);
    while(an(cch)) inbyte();
    return 1;
    }
  return 0;
 }

nextop(list) char *list; {
  char op[4];
  opindex=0;
  blanks();
  while(1) {
    opsize=0;
    while(*list > ' ') op[opsize++] = *list++;
    op[opsize]=0;
    if(opsize=streq(lptr, op))
      if((*(lptr+opsize) != '=')&
         (*(lptr+opsize) != *(lptr+opsize-1)))
         return 1;
    if(*list) {
      ++list;
      ++opindex;
      }
    else return 0;
    }
  }

blanks() {
  while(1) {
    while(cch) {
      if(white()) gch();
      else return;
      }
    if(line==mline) return;
    preprocess();
    if(eof)break;
    }
  }

