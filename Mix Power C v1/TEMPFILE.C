/* Temporary file functions */
/*   Copyright (c) Mix Software 1988    */

char *mktemp(template)
   char *template;
{
   static int pr = 0;
   static char pid[5];
   char *p, *q;
   char id = 'a';
   int i, j;
   if (pr == 0) {
      j = pr = getpid();
      p = &pid[4];
      for (i = 0; i < 5; ++i) {
         *p-- = (j % 10) + 48;
         j /= 10;
         }
      }
   if ((j = strlen(template)) < 6) return NULL;
   p = template + j - 1;
   q = &pid[4];
   for (i = 0; i < 5; ++i) {
      if (*p != 'X') return NULL;
      *p-- = *q--;
      }
   *p = '0';
   do {
      if (_sys_acd(0x4300,0,template,&j) != 0) return template;
      *p = id;
      } while (++id < 'z');
   return NULL;
}

int rmtmp()
{
   int i;
   int n = 0;
   FILE *fp;
   for (i=0; i < MAXFILES; ++i) {
      fp = _iob[i];
      if (fp != NULL) {
         if (fp->file.flag2 & fd2temp) { close(fp->fd); ++n; }
         }
      }
   return n;
}

FILE *tmpfile()
{
   FILE *fp;
   char name[L_tmpnam];
   if (tmpnam(name) == NULL) return NULL;
   fp = fopen(name,"w+");
   if (fp) fp->file.flag2 |= fd2temp;
   return fp;
}

char *tmpnam(string)
   char *string;
{
   extern unsigned _tmpoff;
   char value[8];
   if (_tmpoff == 0) return NULL;
   if (string == NULL) {
      if ((string = malloc(L_tmpnam)) == NULL) return NULL;
      }
   strcpy(string,P_tmpdir);
   value[0] = '\\';
   utoa(_tmpoff,&value[1],10);
   strcat(string,value);
   ++_tmpoff;
   return string;
}

char *tempnam(dir,prefix)
   char *dir;
   char *prefix;
{
   extern unsigned _tmpoff;
   char *pf, *s;
   char *_isdir();
   char value[8];
   pf = getenv("TMP");
   if (pf != NULL) pf = _isdir(pf);
   if (pf == NULL) pf = _isdir(dir);
   if (pf == NULL) pf = _isdir(P_tmpdir);
   if (pf == NULL) pf = "\tmp";
   s = malloc(strlen(pf)+strlen(prefix)+8);
   if (s == NULL) return NULL;
   strcpy(s,pf);
   if (strlen(pf) != 2 || *(pf+1) != ':') strcat(s,"\\");
   strcat(s,prefix);
   utoa(_tmpoff,value,10);
   strcat(s,value);
   ++_tmpoff;
   return s;
}

unsigned _tmpoff = 1;

char *_isdir(dirname)
   char *dirname;
{
   int flags;
   char dr;
   if (*(dirname+1) == ':') {
      if (strlen(dirname) == 2) {
         dr = toupper(*dirname);
         if (dr >= 'A' && dr <= 'P') return dirname;
         }
      }
   if (_sysacdc(0x4300, 0, dirname, &flags) != 0) return 0;
   if ((flags & 0x0010) == 0) return 0;
   return dirname;
}

creattemp(filename,attrib)
   char *filename;
   int attrib;
{
   static unsigned tmpindex = 0;
   unsigned startindex;
   int fd;
   int namelen;
   startindex = tmpindex;
   namelen = strlen(filename);
   do {
      utoa(++tmpindex,(filename+namelen),10);
      fd = creatnew(filename,attrib);
      } while (fd == -1 && tmpindex != startindex);
   return fd;
   }

