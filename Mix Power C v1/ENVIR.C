
/* Environment functions */
/*   Copyright (c) Mix Software 1988    */

char *getenvp(varname)   /* get a copy of an environment variable */
   char *varname;
{
   char *getenv();
   char *strsave();
   char *s;
   s = getenv(varname);
   if (s == NULL) return NULL;
   return strsave(s);
}  /* getenvp */

/* ------------------------------------------------------------ */

char *getenv(varname)
   char *varname;
{
   extern char *(*environ)[];
   char *_moveenv();
   int strlen(), memcmp();
   char **p;
   int len;
   if (environ == NULL) {
      if (_moveenv() == NULL) return NULL;
      }
   len = strlen(varname);
   if (*(varname+len-1) == '=') len--;
   p = *environ;
   while (*p != 0) {
      if (memcmp(*p,varname,len) == 0) {
         if (*((*p)+len) == '=') return (*p+len+1);
         }
      ++p;
      }
   return NULL;
}  /* getenv */

/* ------------------------------------------------------------ */

int *putenv(envstring)
   char *envstring;
{
   extern char **environ;
   extern int  $$ENVPX, $$ENVALT;
   char *_moveenv(), *strchr(), *malloc();
   int strlen(), memcmp();
   char **p, **q;
   char *sp;
   int len;
   if (environ == NULL) {
      if (_moveenv() == NULL) return NULL;
      }
   if ((sp = strchr(envstring,'=')) == NULL) return -1;
   sp++;    /* pass the '=' */
   $$ENVALT = 1;
   len = sp - envstring;
   p = environ;
   while (*p != 0) {
      if (memcmp(*p,envstring,len) == 0) break;
      ++p;
      }
   if (*p != 0) {  /* replace existing string */
      if (len == strlen(envstring)) { /* value is null, delete from table */
         q = p+1;
         while (*p != NULL) *p++ = *q++;
         ++$$ENVPX;
         }
      else *p = envstring;
      return 0;
      }
   if ($$ENVPX == 0) { /* no slot available in table */
      len = (p - environ);
      q = malloc(sizeof(char *)*(len + 5));
      if (q == NULL) return -1;
      memcpy(q,environ,sizeof(char *)*len);
      memset((q + len),0,5*sizeof(char *));
      free(environ);
      environ = q;
      $$ENVPX = 4;
      p = q+len;
      }
   *p = envstring;
   --$$ENVPX;
   return 0;
}  /* putenv */

/* ------------------------------------------------------------ */

unsigned _copyenv(envp)
   char **envp;
{  /* copy environment into a single block of memory on a paragraph
      boundary.  Returns a segment pointer to the block.  If the
      environment has not been altered, the environment pointer from
      the parent is returned.
      */
   extern char *(*environ)[];
   extern unsigned $$ENVIR;
   extern int      $$ENVALT;
   unsigned getdseg();
   char **p, *q, **ev;
   unsigned paragraph;
   int len = 0;
   if (envp == NULL) {
      if (environ == NULL) return $$ENVIR;
      if ($$ENVALT == 0) return $$ENVIR;
      ev = environ;
      }
   else ev = envp;
   p = ev;
   while (*p != NULL) {
      len += strlen(*p)+1;
      ++p;
      }
   q = malloc(len+16);
   if (q == NULL) return NULL;
   q = ((unsigned)q + 15) & 0xfff0;  /* paragraph boundary */
   paragraph = ((unsigned)q >> 4) + getdseg();
   p = ev;
   while (*p != NULL) {
      strcpy(q,*p);
      q += strlen(*p)+1;
      ++p;
      }
   return paragraph;
} /* _copyenv */


