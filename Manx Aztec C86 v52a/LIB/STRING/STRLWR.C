#include <ctype.h>

unsigned char *
strlwr(string)
unsigned char *string;
{
	register unsigned char *place;
	place = string;
	while ( *place ) {
		*place = tolower(*place);
		place ++;
	}
	return string;
}

