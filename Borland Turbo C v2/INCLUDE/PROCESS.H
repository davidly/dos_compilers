/*	process.h

	Symbols and structures for process management.

	Copyright (c) Borland International 1987,1988
	All Rights Reserved.
*/
#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

/*  Modes available as first argument to the spawnxx functions. */

#define P_WAIT	  0	/* child runs separately, parent waits until exit */
#define P_NOWAIT  1	/* both concurrent -- not implemented */
#define P_OVERLAY 2	/* child replaces parent, parent no longer exists */


/*  MSDOS does not have any abstract identifier for a process, but the
    process Program Segment Prefix location provides a similar token.
*/

#ifndef _psp
extern	unsigned _Cdecl _psp;	 /* provided unconditionally in dos.h */
#endif

#define  getpid()   (_psp)

void	_Cdecl abort(void);
int	_Cdecl execl(char *path, char *arg0, ...);
int	_Cdecl execle(char *path, char *arg0, ...);
int	_Cdecl execlp(char *path, char *arg0, ...);
int	_Cdecl execlpe(char *path, char *arg0, ...);
int	_Cdecl execv(char *path, char *argv[]);
int	_Cdecl execve(char *path, char *argv[], char **env);
int	_Cdecl execvp(char *path, char *argv[]);
int	_Cdecl execvpe(char *path, char *argv[], char **env);
void	_Cdecl exit(int status);
void	_Cdecl _exit(int status);
int	_Cdecl spawnl(int mode, char *path, char *arg0, ...);
int	_Cdecl spawnle(int mode, char *path, char *arg0, ...);
int	_Cdecl spawnlp(int mode, char *path, char *arg0, ...);
int	_Cdecl spawnlpe(int mode, char *path, char *arg0, ...);
int	_Cdecl spawnv(int mode, char *path, char *argv[]);
int	_Cdecl spawnve(int mode, char *path, char *argv[], char **env);
int	_Cdecl spawnvp(int mode, char *path, char *argv[]);
int	_Cdecl spawnvpe(int mode, char *path, char *argv[], char **env);
int	_Cdecl system(const char *command);

