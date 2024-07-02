/*_ process.h   Tue May 29 1990   Modified by: Walter Bright */
/* OS2 support added by Nikki Locke May 1989 */
/* Copyright (C) 1988-1990 by Walter Bright	*/
/* All Rights Reserved					*/
/* Written by Walter Bright				*/

#if __cplusplus
extern "C" {
#endif

#ifdef _WINDOWS
          void _cdecl exec_showset(unsigned short style); /* set client window SHOW style used be spawn, system, etc. */
          void _cdecl exec_showreset(void);		 /* reset SHOW style to default (SW_SHOW) */
unsigned short _cdecl exec_showget(void);		 /* get current SHOW style setting */
#endif

void _cdecl _exit(int);
void _cdecl _dodtors(void);

int _cdecl spawnl(int,char *,char *,...);
int _cdecl spawnv(int,char *,char **);
int _cdecl spawnlp(int,char *,char *,...);
int _cdecl spawnvp(int,char *,char **);

/* mode values for spawn?? */
#define P_WAIT 0
#define P_NOWAIT 1
#define P_SAVEEXIT 2
#define P_DETACHED 4

int _cdecl execl(const char *,const char *,...);
int _cdecl execv(const char *,const char **);
int _cdecl execlp(const char *,const char *,...);
int _cdecl execvp(const char *,const char **);

#if defined(M_UNIX) || defined(M_XENIX)
int _cdecl getpid(void);
int _cdecl fork(void);
int _cdecl execle(const char *path,const char *arg1,...);
int _cdecl execve(const char *command, const char *command_line[],
                  const char *environment[]);
#endif

/* action codes used with cwait() */

#define WAIT_CHILD 0
#define WAIT_GRANDCHILD 1

int _cdecl cwait(int *,int,int);
int _cdecl wait(int *);

#ifdef __cplusplus
  }
#endif


