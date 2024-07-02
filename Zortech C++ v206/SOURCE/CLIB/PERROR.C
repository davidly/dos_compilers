/*_ perror.c   Fri May 12 1989   Modified by: Walter Bright */
/* Copyright (C) 1985-1989 by Walter Bright	*/
/* All Rights Reserved					*/
/* Written by Walter Bright				*/

#include	<stdio.h>
#include	<errno.h>
#include	<assert.h>
#include	<string.h>
#include	<stdlib.h>

/**************************
 * Assertion failure.
 */

#ifdef Aassert

void _assert(const char *e,const char *file,unsigned line)
{
	fprintf(stderr,"Assertion failure: '%s' on line %u in file '%s'\n",
		e,line,file);
	exit(EXIT_FAILURE);
}

#endif

/**************************
 * Print error message associated with the current
 * value of errno. MS-DOS has weird error numbers, and we add in
 * a few of our own, so the numbers are not sequential.
 */

#ifdef Aperror

void perror(const char *s)
{
	fprintf(stderr,"%s: %s\n",s,strerror(errno));
}

/* Error messages indexed by error number	*/
char *sys_errlist[] =
{
	"no error",		/* 0		*/
	"invalid function",	/* 1		*/
	"no entity",		/* ENOENT	*/
	"not a directory",	/* ENOTDIR	*/
	"too many open files",	/* EMFILE	*/
	"access error",		/* EACCES	*/
	"bad file handle",	/* EBADF	*/
	"memory corrupted",	/* 7		*/
	"no memory",		/* ENOMEM	*/
};

/* Number of elements in sys_errlist[]	*/
int sys_nerr = sizeof(sys_errlist) / sizeof(sys_errlist[0]);

/*******************************
 * Map errnum into an error string.
 */

char *strerror(int errnum)
{
	static const struct ERR { char *msg; int no; } err[] =
	{
		"file exists",EEXIST,
		"too big",E2BIG,
		"can't execute",ENOEXEC,
		"domain error",EDOM,
		"range error",ERANGE,
		"no more files",18,
	};
	static char buf[8 + sizeof(errnum) * 3 + 1],*p;
	int i;

    if (errnum < sys_nerr)
	p = sys_errlist[errnum];
    else
    {   
	sprintf(buf,"errnum = %d",errnum);	/* default string	*/
	p = buf;
	for (i = 0; i < sizeof(err)/sizeof(struct ERR); i++)
		if (err[i].no == errnum)
		{	p = err[i].msg;
			break;
		}
    }
    return p;
}

#endif /* Aperror */
