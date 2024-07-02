/*_ process.h   Sat Jun  3 1989   Modified by: Walter Bright */
/* OS2 support added by Nikki Locke May 1989 */
/* Copyright (C) 1988-1989 by Northwest Software	*/
/* All Rights Reserved					*/
/* Written by Walter Bright				*/

#if __cplusplus
extern "C" {
#endif

void cdecl _exit(int);
void cdecl _dodtors(void);

int cdecl spawnl(int,char *,char *,...);
int cdecl spawnv(int,char *,char **);
int cdecl spawnlp(int,char *,char *,...);
int cdecl spawnvp(int,char *,char **);

/* mode values for spawn?? */
#define P_WAIT 0
#define P_NOWAIT 1
#define P_SAVEEXIT 2
#define P_DETACHED 4

int cdecl execl(char *,char *,...);
int cdecl execv(char *,char **);
int cdecl execlp(char *,char *,...);
int cdecl execvp(char *,char **);

/* action codes used with cwait() */

#define WAIT_CHILD 0
#define WAIT_GRANDCHILD 1

int cdecl cwait(int *,int,int);
int cdecl wait(int *);

#if __cplusplus
}
#endif
