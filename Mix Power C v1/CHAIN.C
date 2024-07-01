

/*******************  Program chaining functions ********************/
/*   Copyright (c) Mix Software 1988    */

system(cmd)
   char *cmd;
{
   extern int errno;
   static char option[] = "/C";
   char cmdline[130];
   char *comspec;
   int  _spawn();
   int  len;
   comspec = getenv("COMSPEC=");
   if (comspec == NULL) { errno = ENOENT; return -1; }
   if ((cmd == NULL) || (*cmd == '\0')) strcpy(cmdline,"\x00\x0d");
   else {
      len = strlen(cmd);
      if (len > 124) {errno = E2BIG; return -1; }
      strcpy(cmdline," /C ");
      strcat(cmdline,cmd);
      cmdline[0] = len+3;
      cmdline[len+4] = '\x0d';
      }
   return _spawn(comspec,cmdline,_copyenv(NULL));
}  /* system */

int execl(pathname, arg0)
   char *pathname;
   char *arg0;
{
   return _spawn1(P_OVERLAY,pathname,&arg0,NULL,0);
   }

int execle(pathname, arg0)
   char *pathname;
   char *arg0;
{
   char **argptr = &arg0;
   while (*argptr != NULL) ++argptr;
   return _spawn1(P_OVERLAY,pathname,&arg0,*++argptr,0);
   }

int execlp(pathname, arg0)
   char *pathname;
   char *arg0;
{
   return _spawn1(P_OVERLAY,pathname,&arg0,NULL,1);
   }

int execlpe(pathname, arg0)
   char *pathname;
   char *arg0;
{
   char **argptr = &arg0;
   while (*argptr != NULL) ++argptr;
   return _spawn1(P_OVERLAY,pathname,&arg0,*++argptr,1);
   }

int execv(pathname, argv)
   char *pathname;
   char **argv;
{
   return _spawn1(P_OVERLAY,pathname,argv,NULL,0);
   }

int execve(pathname, argv, envp)
   char *pathname;
   char *argv[];
   char *envp[];
{
   return _spawn1(P_OVERLAY,pathname,argv,envp,0);
   }

int execvp(pathname, argv)
   char *pathname;
   char *argv[];
{
   return _spawn1(P_OVERLAY,pathname,argv,NULL,1);
   }

int execvpe(pathname, argv, envp)
   char *pathname;
   char *argv[];
   char *envp[];
{
   return _spawn1(P_OVERLAY,pathname,argv,envp,1);
   }

int spawnl(modeflag, pathname, arg0)
   int modeflag;
   char *pathname;
   char *arg0;
{
   return _spawn1(modeflag,pathname,&arg0,NULL,0);
   }

int spawnle(modeflag, pathname, arg0)
   int modeflag;
   char *pathname;
   char *arg0;
{
   char **argptr = &arg0;
   while (*argptr != NULL) ++argptr;
   return _spawn1(modeflag,pathname,&arg0,*++argptr,0);
   }

int spawnlp(modeflag, pathname, arg0)
   int modeflag;
   char *pathname;
   char *arg0;
{
   return _spawn1(modeflag,pathname,&arg0,NULL,1);
   }

int spawnlpe(modeflag, pathname, arg0)
   int modeflag;
   char *pathname;
   char *arg0;
{
   char **argptr = &arg0;
   while (*argptr != NULL) ++argptr;
   return _spawn1(modeflag,pathname,&arg0,*++argptr,1);
   }

int spawnv(modeflag, pathname, argv)
   int modeflag;
   char *pathname;
   char *argv[];
{
   return _spawn1(modeflag,pathname,argv,NULL,0);
   }

int spawnve(modeflag, pathname, argv, envp)
   int modeflag;
   char *pathname;
   char *argv[];
   char *envp[];
{
   return _spawn1(modeflag,pathname,argv,envp,0);
   }

int spawnvp(modeflag, pathname, argv)
   int modeflag;
   char *pathname;
   char *argv[];
{
   return _spawn1(modeflag,pathname,argv,NULL,1);
   }

int spawnvpe(modeflag, pathname, argv, envp)
   int modeflag;
   char *pathname;
   char *argv[];
   char *envp[];
{
   return _spawn1(modeflag,pathname,argv,envp,1);
   }

/*
   spawn and exec driver.
   */

int _spawn1(modeflag, pathname, argv, envp, pathflag)
   int modeflag;     /* P_WAIT, P_NOWAIT or P_OVERLAY */
   char *pathname;   /* name of command or exe file */
   char *argv[];     /* list of arguments */
   char *envp[];     /* pointer to environment */
   int pathflag;     /* search path environment string */
{
   extern int $$ENVALT;
   extern unsigned $$ENVIR;
   extern char **environ;
   extern int errno;
   extern int (*_p_chain)();
   extern int (*_p_chenv)();
   char cmdline[128], path[128];
   char *p;
   char *pathenv;
   int  len, handle, status;
   if (modeflag == P_NOWAIT) { errno = EINVAL; return -1;}
   if (envp == NULL) {  /* no environment, use current program's */
      if ($$ENVALT != 0) envp = environ;
      }
   else if (envp == environ) {   /* caller has passed current environment */
      if ($$ENVALT == 0) envp = NULL;
      }
   /* envp is null if the original environment will be passed */
   if (argv != NULL) { /* make command line from argument list */
      if (*argv != NULL) {
         *cmdline = ' ';
         p = &cmdline[1];
         *p = '\0';
         len = 1;
         while (*++argv != NULL) {
            len += strlen(*argv)+1;
            if (len > 127) { errno = E2BIG; return -1; }
            strcat(cmdline,*argv);
            strcat(cmdline," ");
            }
         cmdline[0] = len-1;
         if (len < 127) cmdline[len] = 0x0d;
         }
      }
   /* search for the command or exe file */
   if (pathflag != 0) pathenv = getenv("PATH="); else pathenv = 0;
   handle = _openfind(pathname,pathenv,".COM;.EXE",0,1,path);
   if (handle == -1) { errno = ENOENT; return -1; }
   /* execute task */
   if (modeflag == P_WAIT) {  /* execute and wait for completion */
      _sys_ab(0x3e00,handle,&status);
      if (envp == NULL) envp = $$ENVIR; else envp = _copyenv(envp);
      status = _spawn(path,cmdline,envp);
      if (envp != $$ENVIR) free(envp);
      return(status);
      }
   else {  /* overlay current program */
      if (_p_chain == NULL) {errno = EINVAL; return -1; }
      if (envp == NULL) status = (*_p_chain)(handle,cmdline);
      else {
         envp = _copyenv(envp);
         _sys_ab(0x3e00,handle,&status);
         status = (*_p_chenv)(path,cmdline,envp);
         if (envp != $$ENVIR) free(envp);
         }
      return status;
      }
   }  /* _spawn1 */

/*   Open a file by searching.  Name is the basic file name, envir is
     a list of possible prefixes and extlist is a list of possible
     extensions.  Extensions are tried only if the file does not
     already have an extension.  If the file is succesfully opened,
     a file handle is returned, otherwise -1 is returned.
     Extensions are tried first, followed by directories.
     */
int _openfind(name, envir, extlist, pathfirst, nonull, newname)
   int  pathfirst;   /* search environment before default directory */
   int  nonull;      /* do not try file without extension */
   char *extlist; /* list of extensions to try (if none supplied) */
   char *envir;   /* list of prefixes to search for file */
   char *name;    /* base name of file */
   char *newname; /* return buffer for name found by the search */
{
   int status;
   char *p, *q;
   char *extptr, *extloc, *final;
   char nul = '\0';
   int tryit;
   strcpy(newname,name);
   if (extlist == NULL) extlist = &nul;
   else {
      p = name+strlen(name);
      do {                       /* search for extension */
         if (*p == '.') break;   /*     found */
         if (*p == '\\') break;  /*     stop on directory name */
         if (*p == ':') break;   /*     stop on disk name */
         --p;
         } while (p != name);
      if (*p == '.') extlist = &nul;  /* extension supplied */
      }
   if (pathfirst == 0) {
      if ((nonull == 0) || (extlist == &nul)) {
         if (_sys_acd(0x3d00,0,newname,&status) == 0) return status;
         }
      final = &nul;
      }
   else final = ";";       /* to try default directory last */

   if (envir == NULL) q = &nul; else q = envir;
   if (pathfirst == 0) extptr = extlist; else extptr = &nul;
   extloc = newname+strlen(newname);
   do {  /* try all combinations */
      if (*extptr != '\0') {  /* try next extension */
         p = extloc;
         while ((*extptr != ';') && (*extptr != '\0')) *p++ = *extptr++;
         *p = '\0';
         if (*extptr == ';') ++extptr;
         tryit = 1;
         }
      else {   /* try next prefix */
         p = newname;
         while ((*q != ';') && (*q != '\0')) *p++ = *q++;
         if (*q == ';') ++q;
         if (p != newname) if (*(p-1) != '\\') *p++ = '\\';
         *p = '\0';
         strcat(p,name);
         extptr = extlist;
         extloc = newname+strlen(newname);
         if ((nonull == 0) || (extlist == &nul)) tryit = 1; else tryit = 0;
         }
      if (tryit) {   /* try to open file with this path */
         if (_sys_acd(0x3d00,0,newname,&status) == 0) return status;
         }
      if (*q == '\0') { /* try default directory (if not tried already) */
         q = final;
         final = &nul;
         }
      }  while ((*q != '\0') || (*extptr != '\0'));

   return -1;   /* not found */
}  /* _openfind */

