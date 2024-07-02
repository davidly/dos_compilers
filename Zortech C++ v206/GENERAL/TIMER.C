/*_ timer.c   Mon Feb 29 1988   Modified by: Walter Bright */
/* Written by Walter Bright 		*/
/* To compile (with Zortech C):		*/
/*	ZTC -mti timer			*/

#include	<stdio.h>
#include	<time.h>
#include	<process.h>
#include 	<stdlib.h>

#if __ZTC__
int _okbigbuf = 0;	/* Use as little memory as possible	*/
#endif

main(argc,argv)
int argc;
char *argv[];
{	clock_t clock(),starttime;
	int status;

	if (argc < 2)
	{	printf("Time execution of a command.\nUse:\n\ttimer command\n");
		exit(1);
	}
	argv[argc] = 0;		/* terminate with a 0 (unportable method) */
	starttime = clock();
	status = spawnvp(0,argv[1],argv + 1);
	starttime = clock() - starttime;
	if (status == -1)
	{	printf("'%s' failed to execute\n",argv[1]);
		exit(1);
	}
	printf("Elapsed time = %d.%02d seconds\n",(int) (starttime/CLK_TCK),
		(int) (starttime%CLK_TCK));
	if (status != 0)
		printf("--- errorlevel %d\n",status);
}

#if __ZTC__

/* Prevent exit() and fclose() from being linked in from library	*/
/* (to conserve the size of the output file).				*/

void exit(int exitstatus)
{
	_exit(exitstatus);
}
#endif

