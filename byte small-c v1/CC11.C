
/*
** Small-C, 8088/8086 version -- modified by R. Grehan, BYTE Magazine
** execution begins here
*/
main(argc, argv) int argc, *argv; {
  argcs=argc;
  argvs=argv;
  fputs("Small-C Compiler, ", stderr);
  fputs(VERSION, stderr);
  fputs(CRIGHT1, stderr);
  fputs(CRIGHT2,stderr);
#ifdef DYNAMIC
  swnext=calloc(SWTABSZ, 1);
  swend=swnext+((SWTABSZ-SWSIZ)>>1);
  stage=calloc(STAGESIZE, 1);
  stagelast=stage+STAGELIMIT;
  wq=calloc(WQTABSZ, BPW);
  litq=calloc(LITABSZ, 1);
  macn=calloc(MACNSIZE, 1);
  macq=calloc(MACQSIZE, 1);
  pline=calloc(LINESIZE, 1);
  mline=calloc(LINESIZE, 1);
#else
  swend=(swnext=swq)+SWTABSZ-SWSIZ;
  stagelast=stage+STAGELIMIT;
#endif
  swactive=		/* not in switch */
  stagenext=		/* direct output mode */
  iflevel=		/* #if... nesting level = 0 */
  skiplevel=		/* #if... not encountered */
  macptr=		/* clear the macro pool */
  csp=			/* stack ptr (relative) */
  errflag=		/* not skipping errors till ";" */
  eof=			/* not eof yet */
  ncmp=			/* not in compound statement */
  files=
  filearg=
  swused=
  quote[1]=0;
  func1=		/* first function */
  ccode=1;		/* enable preprocessing */
  wqptr=wq;		/* clear while queue */
  quote[0]='"';		/* fake a quote literal */
  input=input2=EOF;
  ask();		/* get user options */
  openfile();		/* and initial input file */
  preprocess();		/* fetch first line */
#ifdef DYNAMIC
  symtab=calloc((NUMLOCS*SYMAVG + NUMGLBS*SYMMAX), 1);
#endif
  locptr=STARTLOC;
  glbptr=STARTGLB;
  glbflag=1;
  ctext=0;
  header();		/* intro code */
  setops();		/* set values in op arrays */
  parse();		/* process ALL input */
  outside();		/* verify outside any function */
  trailer();		/* follow-up code */
  fclose(output);
  }

/*
** process all input text
**
** At this level, only static declarations,
**      defines, includes and function
**      definitions are legal...
*/
parse() {
  while (eof==0) {
    if(amatch("extern", 6))
		dodeclare(EXTERNAL);
    else if(dodeclare(STATIC))
		;
    else if(match("#asm"))
		doasm();
    else if(match("#include"))
		doinclude();
    else if(match("#define"))
		addmac();
    else
		newfunc();
    blanks();		/* force eof if pending */
    }
  }

/*
** dump the literal pool
*/
dumplits(size) int size; {
  int j, k;
  k=0;
  while (k<litptr) {
    poll(1);		/* allow program interruption */
    defstorage(size);
    j=10;
    while(j--) {
      outdec(getint(litq+k, size));
      k=k+size;
      if ((j==0)|(k>=litptr))
		{
		nl();
		break;
		}
      outbyte(',');
      }
    }
  }

/*
** dump zeroes for default initial values
*/
dumpzero(size, count) int size, count; {
  int j;
  while (count > 0) {
    poll(1);		/* allow program interruption */
    defstorage(size);
    j=30;
    while(j--) {
      outdec(0);
      if ((--count <= 0)|(j==0))
		{
		nl();
		break;
		}
      outbyte(',');
      }
    }
  }

/*
** verify compile ends outside any function
*/
outside()  {
  if (ncmp)
	error("no closing bracket");
  }

/*
** get run options
*/
ask() {
  int i;
  i=listfp=nxtlab=0;
  output=stdout;
#ifdef OPTIMIZE
  optimize=
#endif
  alarm=monitor=pause=NO;
  line=mline;
  while(getarg(++i, line, LINESIZE, argcs, argvs)!=EOF) {
    if(line[0]!='-')
		continue;
    if((toupper(line[1])=='L')&(isdigit(line[2]))&(line[3]<=' ')) {
      listfp=line[2]-'0';
      continue;
      }
    if(line[2]<=' ') {
      if(toupper(line[1])=='A') {
        alarm=YES;
        continue;
        }
      if(toupper(line[1])=='M') {
        monitor=YES;
        continue;
        }
#ifdef OPTIMIZE
      if(toupper(line[1])=='O') {
        optimize=YES;
        continue;
        }
#endif
      if(toupper(line[1])=='P') {
        pause=YES;
        continue;
        }
      }
#ifndef LINK
    if(toupper(line[1])=='B') {
      bump(0); bump(2);
      if(number(&nxtlab)) continue;
      }
#endif
    sout("usage: cc [file]... [-m] [-a] [-p] [-l#]", stderr);
#ifdef OPTIMIZE
    sout(" [-o]", stderr);
#endif
#ifndef LINK
    sout(" [-b#]", stderr);
#endif
    sout(NEWLINE, stderr);
    abort(ERRCODE);
    }
  }

/*
** input and output file opens
*/
openfile() {		/* entire function revised */
  char outfn[15];
  int i, j, ext;
  input=EOF;
  while(getarg(++filearg, pline, LINESIZE, argcs, argvs)!=EOF) {
    if(pline[0]=='-') continue;
    ext = NO;
    i = -1;
    j = 0;
    while(pline[++i]) {
      if(pline[i] == '.') {ext = YES; break;}
      if(j < 10) outfn[j++] = pline[i];
      }
    if(!ext) {
      strcpy(pline + i, ".C");
      }
    input = mustopen(pline, "r");
    if(!files && isatty(stdout)) {
      strcpy(outfn + j, ".MAC");
      output = mustopen(outfn, "w");
      }
    files=YES;
    kill();
    return;
    }
  if(files++) eof=YES;
  else input=stdin;
  kill();
  }

/*
** open a file with error checking
*/
mustopen(fn, mode) char *fn, *mode; {
  int fd;
  if(fd = fopen(fn, mode)) return fd;
  sout("open error on ", stderr);
  lout(fn, stderr);
  abort(ERRCODE);
  }

setops() {
  op2[ 0]=     op[ 0]=  ffor;		/* heir5 */
  op2[ 1]=     op[ 1]= ffxor;		/* heir6 */
  op2[ 2]=     op[ 2]= ffand;		/* heir7 */
  op2[ 3]=     op[ 3]=  ffeq;		/* heir8 */
  op2[ 4]=     op[ 4]=  ffne;
  op2[ 5]=ule; op[ 5]=  ffle;		/* heir9 */
  op2[ 6]=uge; op[ 6]=  ffge;
  op2[ 7]=ult; op[ 7]=  fflt;
  op2[ 8]=ugt; op[ 8]=  ffgt;
  op2[ 9]=     op[ 9]= ffasr;		/* heir10 */
  op2[10]=     op[10]= ffasl;
  op2[11]=     op[11]= ffadd;		/* heir11 */
  op2[12]=     op[12]= ffsub;
  op2[13]=     op[13]=ffmult;		/* heir12 */
  op2[14]=     op[14]= ffdiv;
  op2[15]=     op[15]= ffmod;
  }

