#ifdef DOS11
#include <fcntl.h>
#endif

char *
mktemp(template)
char *template;
{
	register char *cp;
	register unsigned val;
	extern unsigned _dsval;
#ifdef DOS11
	int file;
#endif

	cp = template;
	cp += strlen(cp);
	for (val = _dsval ; ; )
		if (*--cp == 'X') {
			*cp = val%10 + '0';
			val /= 10;
		} else if (*cp != '.')
			break;

	if (*++cp == '.')	/* allow for "abcd.XXX" type file names */
		++cp;
	if (*cp != 0) {
		*cp = 'A';
#ifdef DOS11
		while ((file = open(template, O_RDONLY)) >= 0) {
			close(file);
#else
		while (access(template, 0) == 0) {
#endif
			if (*cp == 'Z') {
				*template = 0;
				break;
			}
			++*cp;
		}
	} else {
#ifdef DOS11
		if ((file = open(template, O_RDONLY)) >= 0) {
			close(file);
#else
		if (access(template, 0) == 0) {
#endif
			*template = 0;
		}
	}
	return template;
}
