/*$no list*//*$no trace	<<< process.h >>> */
/*   Copyright (c) Mix Software	1988	  */

extern	int	  _p_overlay;

#define	P_WAIT	  0
#define	P_NOWAIT  1
#define	P_OVERLAY _p_overlay

void	abort(void);
int	execl(char *filename, char *arg0, ...);
int	execle(char *filename, char *arg0, ...);
int	execlp(char *filename, char *arg0, ...);
int	execlpe(char *filename,	char *arg0, ...);
int	execv(char *filename, char *argv[]);
int	execve(char *filename, char *argv[], char *envp[]);
int	execvp(char *filename, char *argv[]);
int	execvpe(char *filename,	char *argv[], char *envp[]);
void	exit(int status);
void   _exit(int status);
int	getpid(void);
int	spawnl(int mode, char *filename, char *arg0, ...);
int	spawnle(int mode, char *filename, char *arg0, ...);
int	spawnlp(int mode, char *filename, char *arg0, ...);
int	spawnlpe(int mode, char	*filename, char	*arg0, ...);
int	spawnv(int mode, char *filename, char *argv[]);
int	spawnve(int mode, char *filename, char *argv[],	char *envp[]);
int	spawnvp(int mode, char *filename, char *argv[]);
int	spawnvpe(int mode, char	*filename, char	*argv[], char *envp[]);
int	system(char *cmdstring);

/*$list*//*$trace	<<< process.h >>> */
