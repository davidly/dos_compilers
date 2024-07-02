/*_ system.c   Sun Apr 16 1989   Modified by: Walter Bright */
/* OS2 support added by Nikki Locke May 1989 */
/* Copyright (C) 1985-1989 by Northwest Software	*/
/* All Rights Reserved					*/
/* Written by Walter Bright				*/

#include	<stdio.h>
#include	<errno.h>
#include	<stdlib.h>
#include	<string.h>
#include	<process.h>
#include	<dos.h>

/* From exec2.asm	*/
#ifdef __OS2__
extern int _exec(char *command,char *commandline,char *envptr,int chain);
#else
extern int _exec(char *command,char *commandline,int envseg,int chain);
#endif

static int near pascal _forkv(int mode,char *path,char **argv,int chain);
static int near pascal _forkvp(int mode,char *cmd,char **argv,int flag);

#ifndef	__OS2__
static void near pascal flushrelease(void);
#endif

/**************************
 * Execute command line using COMMAND.COM.
 * Note that since COMMAND.COM doesn't return the exit status of the
 * program it ran, we can't either. All we can return is the exit
 * status of COMMAND.COM itself.
 * Returns:
 *	0	success
 *	-1	error
 */

int system(const char *cmdline)
{	char *comspec;

	comspec = getenv("COMSPEC");
	return spawnl(0,comspec,"COMMAND.COM","/c",cmdline,(char *) NULL);
}

/*************************
 * Here are all the spawn commands.
 * The 'p' functions bip along the PATH environment variable looking
 * for the command.
 * Input:
 *	mode		ignored
 *	path		the command name
 *			(if no ., .COM is tried first, then .EXE)
 *	arg0		also the command name (but ignored)
 *	argn...		list of pointers to args terminated with a NULL
 * Returns:
 *	-1	error (errno is set)
 *	n	exit status from spawned process
 */

int spawnl(int mode,char *path,char *arglist,...)
{
	return spawnv(mode,path,&arglist);
}

int spawnv(int mode,char *path,char **argv)
{
	return _forkv(mode,path,argv,0);
}

int spawnlp(int mode,char *path,char *arglist,...)
{
	return spawnvp(mode,path,&arglist);
}

int spawnvp(int mode,char *cmd,char **argv)
{
	return _forkvp(mode,cmd,argv,0);
}

static int near pascal _forkv(int mode,char *path,char **argv,int chain)
{	char argbuf[1 + 128 + 1],*a;
	       /*   D: path name .  ext  0	*/
	char cmdbuf[2 + 64 + 8 + 1 + 3 + 1];
	int i,status;

	/* Build argbuf[]	*/
	i = 0;
#ifdef __OS2__
	a = &argbuf[0];
	if(*argv)
	{
	    i = strlen(*argv);
	    if (i > 128 - 1)		/* leave room for \0 at end */
		goto err;
	    strcpy(a,*argv++);
	    a += strlen(a) + 1;		/* move past argument */
	}
#else
	a = &argbuf[1];
	if (*argv)
		argv++;			/* skip over arg0		*/
#endif
	*a = 0;
	while (*argv)
	{
		i += strlen(*argv);
		if (i > 128 - 1)	/* leave room for \r at end	*/
		{
		 err:	errno = E2BIG;
			return -1;
		}
		strcat(a,*argv++);
		if (*argv)		/* if more arguments		*/
		{	i++;
			if (i > 128 - 1)
				goto err;
			strcat(a," ");	/* separate with a space	*/
		}
	}
#ifndef __OS2__
	argbuf[0] = i;			/* # of bytes in command line	*/
	if (argbuf[i] != '\r')		/* if not already ending in \r	*/
		strcat(a,"\r");		/* terminate command with \r	*/
#endif

	if (!path)
		goto badpath;
	i = strlen(path);
	a = path + i;
	while (1)
	{   switch (*a)
	    {
		default:
			if (a == path)
				goto L1;
			a--;
			continue;
		case '.':		/* if already a . or extension	*/
			if (i > sizeof(cmdbuf) - 1)
				goto badpath;
			strcpy(cmdbuf,path);
			break;
		case '\\':
		case ':':
		case '/':		/* no . or extension for command */
		L1:
			if (i > sizeof(cmdbuf) - 1 - 4)
				goto badpath;
			strcpy(cmdbuf,path);
			strcat(cmdbuf,".COM");	/* try .COM extension	*/
/*printf("cmdbuf = '%s', argbuf = '%s'\n",cmdbuf,argbuf + 1);*/
			if (filesize(cmdbuf) != -1)
			{
#ifdef __OS2__
				return _exec(cmdbuf,argbuf,0,mode);
#else
				if (chain)
					flushrelease();
				return _exec(cmdbuf,argbuf,0,chain);
#endif
			}
			errno = 0;
			strcpy(&cmdbuf[i],".EXE"); /* try .EXE extension */
			break;
	    }
	    break;
	}
/*printf("cmdbuf = '%s', argbuf = '%s'\n",cmdbuf,argbuf + 1);*/
	if (filesize(cmdbuf) == -1)
	{	errno = 2;		/* file not found or path invalid */
		status = -1;
	}
	else
	{
#ifdef __OS2__
		status = _exec(cmdbuf,argbuf,0,mode);
#else
		if (chain)
			flushrelease();
		status = _exec(cmdbuf,argbuf,0,chain);
#endif
	}
	return status;

badpath:
	errno = ENOENT;
	return -1;
}

static int near pascal _forkvp(int mode,char *cmd,char **argv,int flag)
{	char *p;
	int status;
		/*  D: path name .  ext  0	*/
	char cmdbuf[2 + 64 + 8 + 1 + 3 + 1 + 1],*pc;
	/* The one extra at the end is in case we add a \ to the end	*/
	/* of the path. Hopefully, this will still cause an error in	*/
	/* spawnv().							*/

	status = _forkv(mode,cmd,argv,flag);
	if (status >= 0 || errno != ENOENT)
		return status;

	p = getenv("PATH");
	if (!p || strlen(cmd) > 8 + 1 + 3) /* if no path or cmd too long */
		return status;
	while (*p)
	{
		pc = cmdbuf;
		while (*p)
		{	if (*p == ';')		/* path separator	*/
			{	p++;
				break;
			}
			if (pc < &cmdbuf[2 + 64])
				*pc++ = *p;
			p++;
		}
		if (pc > cmdbuf && *(pc - 1) != '\\')
			*pc++ = '\\';
		*pc = 0;
		strcat(cmdbuf,cmd);	/* guaranteed not to overflow	*/
		status = _forkv(mode,cmdbuf,argv,flag);
		if (status >= 0 || errno != ENOENT)
			break;
	}
	return status;
}

/********************************
 * exec() functions work just like the spawn() ones do, except that
 * the command is not returned from unless there is an error.
 * The DOS implementation is flawed:
 *	o If there is insufficient memory to run the program,
 *	  or if the .EXE file is invalid, the parent will simply
 *	  terminate with an errorlevel of 1.
 *	o About 768 bytes is lost for each exec, so circular
 *	  execs will eventually run out of memory.
 */

int execl(char *path,char *arglist,...)
{
	return execv(path,&arglist);
}

int execv(char *path,char **argv)
{
#ifdef __OS2__
	int status;

	status = _forkv(1,path,argv,1);
	if(status == -1)
		perror("Exec format error");
	exit(0);
#else
	return _forkv(0,path,argv,1);
#endif
}

int execlp(char *path,char *arglist,...)
{
	return execvp(path,&arglist);
}

int execvp(char *cmd,char **argv)
{
#ifdef __OS2__
	int status;

	status = _forkvp(1,cmd,argv,1);
	if(status == -1)
		perror("Exec format error");
	exit(0);
#else
	return _forkvp(0,cmd,argv,1);
#endif
}

#ifndef __OS2__
/**************************
 * Flush output, and release memory for buffers outside the data segment.
 */

static void near pascal flushrelease(void)
{	FILE *fp;
	int flag;

	for (fp = &_iob[0]; fp < &_iob[_NFILE]; fp++)
	{
		flag = fp->_flag;
		if (flag & (_IOREAD | _IOWRT | _IORW))
		{	/* flush buffer	*/
			if (!(flag & _IONBF))
			{	fflush(fp);
#ifdef BIGBUF
				/* dump big buffer if there is one	*/
				if (flag & _IOBIGBUF && fp->_seg)
					dos_free(fp->_seg);
#endif
			}
		}
	}
}
#endif

