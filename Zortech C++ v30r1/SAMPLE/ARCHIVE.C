/*_ archive.c   Thu Mar  1 1990   Modified by: Walter Bright */
/* Use:
	ARCHIVE filespec

 Filespec is the target file specification, including drive, path and
 wildcards. Newer files from the default directory matching this are
 copied to the target directory.
 */

#include	<stdio.h>
#include	<stdlib.h>
#include	<time.h>
#include	"mem.h"
#include	"filespec.h"
#include	"file.h"

#ifdef _WINDOWS
char winc_programname[] = "ARCHIVEW.EXE";
char winc_programtitle[] = "ARCHIVE for Windows";
#endif

int numcopy;    /* # of files copied    */


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
    char *fromspec;
    time_t totime;
    time_t fromtime;

    file_directory(arg,0,&files,&nfiles);
    for (u = 0; u < nfiles; u++)
    {	char *tospec;

	tospec = files[u];
	/*printf("tospec   = '%s'\n",tospec);*/
	fromspec = filespecname(tospec);
	if (file_exists(fromspec))
	{
	    fromtime = file_time(fromspec);
	    totime = file_time(tospec);
	    if (fromtime > totime)
	    {
		printf("%s\n",fromspec);
		if (file_copy(fromspec,tospec))
		{
		    printf("File I/O error");
		    exit(EXIT_FAILURE);
		}
		file_settime(tospec,fromtime);
		numcopy++;
	    }
	}
    }
    file_directory(NULL,0,&files,&nfiles);
}

usage()
{
    printf("\
Invalid number of parameters\n\
Use:\n\
	ARCHIVE filespec\n\n\
Newer files from the default directory matching this\n\
 are copied to filespec.\n\
V3.0r1, Written by Walter Bright\n");
    exit(EXIT_FAILURE);
}

