/*   Copyright (c) Mix Software 1988    */

void ctrlbrk(fptr)
   int (*fptr)();
{
   _signal_(SIGINT,fptr);
   }

void fnmerge(path, drive, dir, name, ext)
   char *path;       /* buffer to constuct file name */
   char *drive;      /* disk drive name */
   char *dir;        /* directory name */
   char *name;       /* file name */
   char *ext;        /* file extension */
{
   if (drive != NULL) strcpy(path,drive);
   else *path = '\0';
   if (dir != NULL) strcat(path,dir);
   if (name != NULL) strcat(path,name);
   if (ext != NULL) strcat(path,ext);
   }

/* flags for fnsplit */
#define WILDCARDS 0x0001
#define EXTENSION 0x0002
#define FILENAME  0x0004
#define DIRECTORY 0x0008
#define DRIVE     0x0010

void fnsplit(path, drive, dir, name, ext)
   char *path;       /* buffer containing file name */
   char *drive;      /* disk drive name (with ':') */
   char *dir;        /* directory name (with '\') */
   char *name;       /* file name */
   char *ext;        /* file extension (with '.') */
{
   char *p, *q;
   int result = 0;
   p = strchr(path,':');
   if (p != NULL) {
      if (drive != NULL) memcpy(drive,path,(++p)-path);
      result += DRIVE;
      }
   else p = path;
   if (drive != NULL) *(drive+(p-path)) = '\0';
   q = strrchr(path,'\\');
   if (q != NULL) {
      if (dir != NULL) {
         memcpy(dir,p,q-p+1);
         *(dir+(q-p)+1) = '\0';
         }
      p = q+1;
      result += DIRECTORY;
      }
   else if (dir != NULL) *dir = '\0';
   q = strchr(p,'.');
   if (q != NULL) {
      if (ext != NULL) strcpy(ext,q);
      if (name != NULL) {
         memcpy(name,p,q-p);
         *(name+(q-p)) = '\0';
         if (p != q) result += FILENAME;
         }
      result += EXTENSION;
      }
   else {
      if (ext != NULL) *ext = '\0';
      if (name != NULL) strcpy(name,p);
      if (*p != '\0') result += FILENAME;
      }
   if (strchr(path,'*')) result += WILDCARD;
   else if (strchr(path,'?')) result += WILDCARD;
   return result;
   }

char *getpass(prompt)
   char *prompt;
{
   static char password[9];
   int count = 0;
   int c;
   while (*prompt != '\0') putch(*prompt++);
   do {
      c = getch();
      if (c == '\b') {
         if (count > 0) --count;
         }
      else if (!iscntrl(c)) password[count++] = c;
      } while ((c != '\r') && (c != '\l') && (count < 8));
   password[count] = '\0';
   return &password;
   }

char *searchpath(filename)
   char *filename;   /* name of file */
{
   void _searchenv();
   static char fname[80];
   _searchenv(filename,"PATH=",fname);
   if (fname[0] != '\0') return fname; else return NULL;
}  /* searchpath */

void _searchenv(name, env_var, path)
   char *name;       /* name to search for */
   char *env_var;    /* name of environment variable */
   char *path;       /* buffer to hold result */
{
   char *getenv();
   char *envptr, *p;
   int status;
   strcpy(path,name);
   /* check default directory */
   if (_sys_acd(0x4300,0,path,&status) == 0) return;
   envptr = getenv(env_var);
   if (envptr == NULL) {*path = '\0'; return; }
   do {  /* try all directorys in envptr */
      p = path;
      while ((*envptr != ';') && (*envptr != '\0')) *p++ = *envptr++;
      if (*envptr == ';') ++envptr;
      if (p != path) if (*(p-1) != '\\') *p++ = '\\';
      *p = '\0';
      strcat(p,name);
      if (_sys_acd(0x4300,0,path,&status) == 0) return;
      }  while (*envptr != '\0');
   *path = '\0';
   return;      /* not found */
}  /* searchenv */

