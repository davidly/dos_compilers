
/* Exit from program */
/*   Copyright (c) Mix Software 1988    */

void abort()
{
   raise(SIGABRT);
   _errmsg("Abnormal program terminations\x0d\x0a");
   _exit(3);
   }

/* ------------------------------------------------------------ */

exit(status)
int status;
{
   int  i;
   int  _exit();
   extern int (*_fclose)();
   extern onexit_t _on_exit_tbl[32];
   extern int _on_index;

   while (_on_index--) (*(_on_exit_tbl[_on_index]))();

   i = 0;
   while (i < MAXFILES) {
      if (_iob[i] != NULL) (*_fclose)(_iob[i]);
      i++;
   }
   _exit(status);
}

/* ------------------------------------------------------------ */

onexit_t onexit(func)
   onexit_t func;
{
   extern int _on_index;
   extern onexit_t _on_exit_tbl[32];
   if (_on_index > 31) return NULL;
   _on_exit_tbl[_on_index] = func;
   _on_index++;
   return func;
}

/* ------------------------------------------------------------ */

atexit_t atexit(func)
   atexit_t func;
{
   extern int _on_index;
   extern onexit_t _on_exit_tbl[32];
   if (_on_index > 31) return NULL;
   _on_exit_tbl[_on_index] = func;
   _on_index++;
   return func;
}

/* ------------------------------------------------------------ */

_exit(status)
    int status;
{
    extern int $$EXSTAT;
    extern void (*$$EXITPT)();
    $$EXSTAT = status;
    (*$$EXITPT)();
    }

onexit_t _on_exit_tbl[32];
int _on_index = 0;

