/**
*
* This module defines a version of _main which processes the
* command line for arguments but does not open "stdin", "stdout",
* and "stderr".  Since these files are not opened, the library
* functions "printf" and "scanf" will not work; however, the
* console functions "cprintf" and "cscanf" can be used instead.
*
**/
#include "CTYPE.H"
#define MAXARG 32		/* maximum command line arguments */

_main(line)
char *line;
{
static int argc = 0;
static char *argv[MAXARG];

while (isspace(*line)) line++;	/* find program name */
while (*line != '\0' && argc < MAXARG)
   {			/* get command line parameters */
   argv[argc++] = line;
   while (*line != '\0' && isspace(*line) == 0) line++;
   if (*line == '\0') break;
   *line++ = '\0';
   while (isspace(*line)) line++;
   }
main(argc, argv);	/* call main function */
_exit(0);
}
break;
   *line++ = '\0';
  