/* Read list of lines from stdin, reverse it, and write result to stdout */
/* To compile:	ZTC LISTDEMO LIST MEM					*/

#include	<stdio.h>
#include	<string.h>
#include	<stdlib.h>
#include	"list.h"

main()
{   list_t list = NULL;
    list_t le;		/* list walker				*/
    char buffer[81];	/* line buffer				*/

    mem_init();		/* list uses mem, so initialize mem	*/
    list_init();	/* and initialize list package		*/

    /* Read in list, in reverse order	*/
    while (fgets(buffer,sizeof(buffer),stdin))
    {   char *p;

	p = strdup(buffer);			/* make copy	*/
	if (!p || !list_prepend(&list,p))	/* add to front	*/
	    break;				/* no memory	*/
    }

    /* Write out list */
    for (le = list; le; le = list_next(le))
	fputs((char *) list_ptr(le),stdout);

    list_free(&list,free);	/* free list			*/

    list_term();		/* terminate list package	*/
    mem_term();			/* terminate mem package	*/
    return EXIT_SUCCESS;
}
