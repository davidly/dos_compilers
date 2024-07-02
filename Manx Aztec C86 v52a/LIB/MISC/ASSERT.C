#include <stdio.h>
#include <stdlib.h>

void _assert(char *expr, const char *filename, unsigned int linenumber)
{
	fprintf(stderr, "Assert(%s) failed at line %u in file %s.\n",
		expr, linenumber, filename);
	abort();
}
