/*_ update.c   Thu Mar  1 1990   Modified by: Walter Bright */
/* Use:
	UPDATE fromspec

 Filespec is the source file specification, including drive, path and
 wildcards. Newer files from the source directory matching this are
 copied to the destination directory.
 */

#include	<stdio.h>
#include	<stdlib.h>
#include	<time.h>
#include	"mem.h"
#include	"filespec.h"
#include	"file.h"

int numcopy;	/* # of files copied	*/

#ifdef _WINDOWS
char winc_programname[] = "UPDATEW.EXE";
char winc_programtitle[] = "UPDATE for Windows";
#endif

main(int argc,char *argv[])
{
    if (argc != 2)
	usage();
    mem_init();
    doit(argv[1]);			/* do the work			*/
    printf("        %d File(s) copied",numcopy);
    mem_term();
    return EXIT_SUCCESS;
}

/*****************
 * Do the work.
 */

doit(char *arg)
{   unsigned nfiles = 0;
    char **files = NULL;
    unsigned u;
    time_t fromtime;

    file_directory(arg,0,&files,&nfiles);
    for (u = 0; u < nfiles; u++)
    {	char *fromspec;
	char *tospec;

	fromspec = files[u];
	/*printf("fromspec   = '%s'\n",fromspec);*/
	fromtime = file_time(fromspec);
	tospec = filespecname(fromspec);
	if (!file_exists(tospec) || fromtime > file_time(tospec))
	{
	    puts(fromspec);
	    if (file_copy(fromspec,tospec))
	    {
		fputs("File I/O error",stdout);
		exit(EXIT_FAILURE);
	    }
	    file_settime(tospec,fromtime);
	    numcopy++;
	}
    }
    file_directory(NULL,0,&files,&nfiles);
}

usage()
{
    puts("\
Invalid number of parameters\n\
Use:\n\
	UPDATE fromspec\n\n\
Newer files from the source directory matching this\n\
 are copied to the default directory.\n\
V3.0r1, Written by Walter Bright");
    exit(EXIT_FAILURE);
}

