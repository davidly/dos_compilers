

/*
** CSYSLIB -- System-Level Library Functions
** Modified for MS-DOS 2 by R. Grehan
*/

#include stdio.h
#include clib.def
#define NOCCARGC    /* no argument count passing */
#define DIR         /* compile directory option */

/*
****************** System Variables ********************
*/

int

  errno,             /* Error number holding var */
  
  Ucnt=1,            /* arg count for main */
  Uvec[20],          /* arg vectors for main */

  Ustatus[MAXFILES] = {RDBIT, WRTBIT, RDBIT|WRTBIT},
                     /* status of respective file */
  Udevice[MAXFILES] = {CONSOL, CONSOL, CONSOL},
                     /* non-disk device assignments */
  Unextc[MAXFILES]  = {EOF, EOF, EOF},
                     /* pigeonhole for ungetc bytes */
  Ufd[MAXFILES] = {0, 1, 2};
                     /* Map logical fd's to physical */

char
 *Umemptr,           /* pointer to free memory. */
  Uarg1[]="*";       /* first arg for main */
/*
*************** System-Level Functions *****************
*/

/*
** -- Process Command Line, Execute main(), and Exit to CP/M
*/
Umain() {
  Uparse();
  main(Ucnt,Uvec);
  exit(0);
  }

/*
** Parse command line and setup argc and argv.
*/
Uparse() {
  char *count, *ptr;
  count = 128;  /* Reserve bytes */
  ptr = Ualloc(count+1, YES);

  count=Ugcmdtl(ptr);	/* Get command tail - null pad */

  Uvec[0]=Uarg1;				/* first arg = "*" */
  while (*ptr) {
    if(isspace(*ptr)) {++ptr; continue;}
    switch(*ptr) {
      case '<': ptr = Uredirect(ptr, "r", stdin);
                continue;
      case '>': if(*(ptr+1) == '>')
                     ptr = Uredirect(ptr+1, "a", stdout);
                else ptr = Uredirect(ptr,   "w", stdout);
                continue;
      default:  if(Ucnt < 20) Uvec[Ucnt++] = ptr;
                ptr = Ufield(ptr);
      }
    }
  }

Ugcmdtl(mypt) char *mypt; {
#asm
  MOV AH,62H  ;Get program segment prefix
  INT 21H
  MOV AX,DS   ;Get our segment
  MOV ES,AX   ;Will be destination
  MOV DS,BX   ;PSP segment is source
  MOV SI,80H  ;Offset to command tail byte count
  MOV CL,[SI] ;Get byte count
  MOV BX,CX   ;Save for return
  INC SI      ;Bump pointer
  POP AX      ;Return address
  POP DI      ;mypt
  PUSH DI     ;Restore
  PUSH AX
  CLD         ;Set direction
  REP MOVSB   ;Move it in
  MOV BYTE PTR ES:[DI],0 ;Move in Null
  MOV AX,ES   ;Restore our segment
  MOV DS,AX
  XOR CX,CX   ;Zero in CX
#endasm
}
/*

** Isolate next command-line field.
*/
Ufield(ptr) char *ptr; {
  while(*ptr) {
    if(isspace(*ptr)) {
      *ptr = NULL;
      return (++ptr);
      }
    ++ptr;
    }
  return (ptr);
  }

/*
** Redirect stdin or stdout.
*/
Uredirect(ptr, mode, std)  char *ptr, *mode; int std; {
  char *fn;
  fn = ++ptr;
  ptr = Ufield(ptr);
  if(Uopen(fn, mode, std)==ERR) exit('R');
  return (ptr);
  }

/*
** ------------ File Open
*/

/*
** Open file on specified fd.
*/
Uopen(fn, mode, fd) char *fn, *mode; int fd; {
  int pfd;
  if(!strchr("rwau", *mode)) return (ERR);
  Unextc[fd] = EOF;
  if(strcmp(fn,"CON:")==0) {
    Udevice[fd]=CONSOL; Ustatus[fd]=RDBIT|WRTBIT; return (fd);
    }
  if(strcmp(fn,"LST:")==0) {
    Udevice[fd]=PRINTR; Ustatus[fd]=WRTBIT; return (fd);
    }
  Udevice[fd] = 0;
  switch(*mode) {
    case 'r': {
      if((pfd=Umsdos(fn,0,0,OPNFIL+RACCESS))==ERR) return (ERR);
      Ustatus[fd] =  RDBIT;
      Ufd[fd]=pfd;
      break;
      }
    case 'u': {
      if((pfd=Umsdos(fn,0,0,OPNFIL+RWACCESS))==ERR)
         return (ERR);
      Ustatus[fd] = RDBIT|WRTBIT;
      Ufd[fd]=pfd;
      break;
     } 
    case 'w': {
      if((pfd=Umsdos(fn,0,0,OPNFIL+WACCESS))!=ERR) { 
              Umsdos(0,0,pfd,CLOFIL);
              Umsdos(fn,0,0,DELFIL); }
    create:
      if((pfd=Umsdos(fn,0,0,MAKFIL))==ERR) return (ERR);
      Ustatus[fd] = EOFBIT|WRTBIT;
      Ufd[fd]=pfd;
      break;
      }
    default: {      /* append mode */
      if((pfd=Umsdos(fn,0,0,OPNFIL+RWACCESS))==ERR) 
      goto create;
      Ustatus[fd] = RDBIT;
      Ufd[fd]=pfd;
      seek(fd, -1, -1, 2);
      while(fgetc(fd)!=EOF) ;
      Ustatus[fd] = EOFBIT|WRTBIT;
      }
    }
  return (fd);
  }

/*
** ------------ File Input
*/

/*
** Binary-stream input fd.
*/
Uread(buff,fd,n) int fd; char *buff, *n; {
  char *i;  /* Fake unsigned */
  char ch;
  i=n;
  switch (Umode(fd)) {
    default: Useterr(fd); return (EOF);
    case RDBIT:
    case RDBIT|WRTBIT:
    }
  if(Unextc[fd] != EOF) {
    *buff++=Unextc[fd];
    Unextc[fd] = EOF;
    if((--n)==0) return(1) ;
    }
  switch(Udevice[fd]) {
    /* PUN & LST can't occur since they are write mode */
    case CONSOL: while(n--) {
                 if((ch=Uconin())==FILEOF) return(EOF);
                 *buff++=ch;                 
                 } return(i-n);
    default:
         if((i=Umsdos(buff,n,Ufd[fd],RDFIL))==ERR)
           return(ERR);
         if(i==0) Useteof(fd);
         return(i);
    }
  }

/*
** Console character input.
*/
Uconin() {
  int ch;
  while(!(ch = Dcio(255))) ;
  switch(ch) {
    case ABORT: exit(0);
    case    LF:
    case    CR: Uconout(LF); return (Uconout(CR));
    case   DEL: ch = RUB;
       default: if(ch < 32) { Uconout('^'); Uconout(ch+64);}
                else Uconout(ch);
                return (ch);
    }
  }

/*
** Special direct keyboard input for MS-DOS
*/
Dcio(ch) int ch; {
#asm
  POP SI
  POP DX
  PUSH DX
  PUSH SI
  MOV AH,6   ;Direct I/O
  INT 21H
  JNZ  Dcio1
  XOR AL,AL  ;No char.
Dcio1:
  MOV BL,AL
  XOR BH,BH
#endasm
}


/*
** ------------ File Output
*/

/*
** Binary-Stream output to fd.
*/
Uwrite(buff, fd, n) int fd; char *buff, *n; {
  char *i;
  i=n;
  switch (Umode(fd)) {
    default: Useterr(fd); return (EOF);
    case WRTBIT:
    case WRTBIT|RDBIT:
    case WRTBIT|EOFBIT:
    case WRTBIT|EOFBIT|RDBIT:
    }
  switch(Udevice[fd]) {
    /* RDR can't occur since it is read mode */
    case CONSOL: while (n--) {
                 Dcio(*buff++);
                 } return(i-n);
    case PRINTR: while (n--) {
                 Umsdos(*buff++,0,0,PRTOUT);
                 } return (i-n);
    default:
      return(Umsdos(buff,n,Ufd[fd],WRFIL));
    }
  }

/*
** Console character output.
*/
Uconout(ch) int ch; {
  Dcio(ch);
  return (ch);
  }

/*
** ------------ Buffer Service
*/


/*
** Return fd's open mode, else NULL.
*/
Umode(fd) char *fd; {
  if(fd < MAXFILES) return (Ustatus[fd]);
  return (NULL);
  }

/*
** Set eof status for fd and
** disable future i/o unless writing is allowed.
*/
Useteof(fd) int fd; {
  Ustatus[fd] |= EOFBIT;
  }

/*
** Clear eof status for fd.
*/
Uclreof(fd) int fd; {
  Ustatus[fd] &= ~EOFBIT;
  }

/*
** Set error status for fd.
*/
Useterr(fd) int fd; {
  Ustatus[fd] |= ERRBIT;
  }

/*
** ------------ Memory Allocation
*/

/*
** Allocate n bytes of (possibly zeroed) memory.
** Entry: n = Size of the items in bytes.
**    clear = "true" if clearing is desired.
** Returns the address of the allocated block of memory
** or NULL if the requested amount of space is not available.
*/
Ualloc(n, clear) char *n; int clear; {
  char *oldptr;
  if(n < avail(YES)) {
    if(clear) pad(Umemptr, NULL, n);
    oldptr = Umemptr;
    Umemptr += n;
    return (oldptr);
    }
  return (NULL);
  }

/* MS-DOS interface
** If there's an error code, we store it in errno and
** return ERR
*/

Umsdos(dx,cx,bx,ax) int dx,cx,bx,ax; {
#asm
  POP SI  ;Return address
  POP AX  ;Load all the registers
  POP BX
  POP CX
  POP DX
  PUSH DX  ;Now restore them
  PUSH CX
  PUSH BX
  PUSH AX
  PUSH SI
  INT 21H  ;Issue the call do DOS
  JNC UMSDOS1  ;Jump if no error
  MOV _ERRNO,AX
  MOV AX,-2    ;ERR
UMSDOS1:
  MOV BX,AX
  XOR CX,CX    ;Zero in CX
#endasm
}


