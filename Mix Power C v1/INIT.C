/* Initialization functions. */
/*   Copyright (c) Mix Software 1988    */

/* _INITIO is called by the lowest level initialization
   function.  It is the first C function executed by a program.
   _INITIO opens the standard files, creates argv and argc
   and calls main.
   */


_INITIO(stdfiles)
int     stdfiles;                /*stdfiles = 1 says open standard files*/
{
    extern  char   *$$CMDPTR;
    extern  FILE   *_iob[MAXFILES];
    extern  int (*_fclose)();
    extern  char $$ARGV0[];
    register char *cmdline;
    register int count;
    static char *argv[MAXARGS];  /*pointers to command line arguments*/
    int     argc;                /*number of command line arguments*/
    int     quote;
    int     main();
    int     exit();

    cmdline = $$CMDPTR;
    count = *cmdline++;
    argv[0] = $$ARGV0;
    argc = 1;
    while (count > 0 && argc < MAXARGS) {
        while (*cmdline == ' ' && count) {
            count--;
            cmdline++;
        }
        if (count) {
            quote = 0;
            argv[argc] = cmdline;
            while (count && (*cmdline != ' ' || quote)) {
               if (*cmdline == '"') {
                  if (quote) {*cmdline = ' '; quote = 0; }
                  else if (argv[argc] == cmdline) {
                     quote = 1;
                     cmdline++, count--;
                     argv[argc] = cmdline;
                     }
                  else cmdline++, count--;
                  }
               else if (*cmdline == '\\' && quote) {
                  memcpy(cmdline,cmdline+1,count);
                  cmdline++, count--;
                  if (count) count--;
                  }
               else cmdline++, count--;   /* not " or \ */
            }
            argc++;
            *cmdline++ = '\0';
            count--;
        }
    }
    exit(main(argc,argv));
    _iob[0];   /* These statements look useless but are not. */
    _fclose;   /* They force these variables to be linked into program */
}

/* _INITIO3 is called if main requires 3 arguments.  In addition to
   the functions performed by _INITIO, it also creates the environment
   and passes envp to main.
   */

_INITIO3(stdfiles)
int     stdfiles;                /*stdfiles = 1 says open standard files*/
{
    extern  char   *$$CMDPTR;
    extern  char   *(*environ)[];
    extern  FILE    *_iob[MAXFILES];
    extern  int (*_fclose)();
    extern  char $$ARGV0[];
    register char *cmdline;
    register int count;
    char    *argv[MAXARGS];      /*pointers to command line arguments*/
    int     argc;                /*number of command line arguments*/
    int     quote;
    int     main();
    int     exit();

    cmdline = $$CMDPTR;
    count = *cmdline++;
    argv[0] = $$ARGV0;
    argc = 1;
    while (count > 0 && argc < MAXARGS) {
        while (*cmdline == ' ' && count) {
            count--;
            cmdline++;
        }
        if (count) {
            quote = 0;
            argv[argc] = cmdline;
            while (count && (*cmdline != ' ' || quote)) {
               if (*cmdline == '"') {
                  if (quote) {*cmdline = ' '; quote = 0; }
                  else if (argv[argc] == cmdline) {
                     quote = 1;
                     cmdline++, count--;
                     argv[argc] = cmdline;
                     }
                  else cmdline++, count--;
                  }
               else if (*cmdline == '\\' && quote) {
                  memcpy(cmdline,cmdline+1,count);
                  cmdline++, count--;
                  if (count) count--;
                  }
               else cmdline++, count--;   /* not " or \ */
            }
            argc++;
            *cmdline++ = '\0';
            count--;
        }
    }
    getenv("PATH=");
    exit(main(argc,argv,environ));
    _iob[0];
    _fclose;
}

/* standard files */

char _STDINB[128];
FILE    _STDFL1, _STDFL2, _STDFL3, _STDFL4, _STDFL5;

FILE    *_iob[MAXFILES] = {&_STDFL1, &_STDFL2, &_STDFL3,
                           &_STDFL4, &_STDFL5};
FILE    _STDFL1 = {{'S', '\001', 0, &_STDINB,
                    &_STDINB, 0, 128, 0,
                    'i', '\0', '\0', '\0',
                    '\0', fdfilter+fdsetbuf, '\0', '\0',
                    0, 0, '\0', "\0\0\0\0" },
                    0};
FILE    _STDFL2 = {{'S', '\001', 1, 0,
                    0, 0, 0, 0,
                    'o', '\0', '\001', '\0',
                    '\0', fdfilter+fdunbufr, '\0', '\0',
                    0, 0, '\0', "\0\0\0\0" },
                    1};
FILE    _STDFL3 = {{'S', '\001', 2, 0,
                    0, 0, 0, 0,
                    'e', '\0', '\001', '\0',
                    '\0', fdfilter+fdunbufr, '\0', '\0',
                    0, 0, '\0', "\0\0\0\0" },
                    2};
FILE    _STDFL4 = {{'S', '\001', 3, 0,
                    0, 0, 0, 0,
                    'a', '\0', '\001', '\0',
                    '\0', fdfilter+fdunbufr, '\0', '\0',
                    0, 0, '\0', "\0\0\0\0" },
                    3};
FILE    _STDFL5 = {{'S', '\001', 4, 0,
                    0, 0, 0, 0,
                    'l', '\0', '\001', '\0',
                    '\0', fdfilter+fdunbufr, '\0', '\0',
                    0, 0, '\0', "\0\0\0\0" },
                    4};

extern  int _stdclose();            /* Close function for std files only */
int     (*_fclose)() = _stdclose;

