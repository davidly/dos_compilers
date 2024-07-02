#include "model.h"

#define SETDMA	26
#define SRCHFIR	0x4e
#define SRCHNXT	0x4f


char *
scdir(pat)
char *pat;
{
	register char *cp, *np;
	char *index();
	static int code = SRCHFIR;
	static char nambuf[64], *tail;
	static struct {
		char reserve[21];
		char attr;
		long mtime;
		long fsize;
		char name[13];
	} srchbuf;

	if (!pat){	/* NULL pat means begin new search *jd 9/21/92 */
		code = SRCHFIR;
		return (char *)0;
	}
	if (code == SRCHFIR) {
		if (index(pat, '*') == 0 && index(pat, '?') == 0) {

/*	This code was taken out and new code put in to handle the case of
	scdir("hello.c") where hello.c does not exist. 3/10/88
*/
#if 0
			code = 0;
			return pat;
#endif
			if (access(pat, 0) == -1) {
				code = SRCHFIR;
				return (char *)0;
			} else {
				code = 0;
				return pat;
			}
		}
		strncpy(nambuf, pat, 64);
		for (cp = tail = nambuf ; cp < &nambuf[64] && *cp ; ++cp)
			if ((tail == nambuf && *cp == ':') || *cp == '/' || *cp == '\\')
				tail = cp+1;
	}

#ifdef _LARGEDATA
	bdosx(SETDMA, &srchbuf);
	if (code == 0 || dosx(code, 0, -1, pat) == -1) {
#else
	bdos(SETDMA, &srchbuf);
	if (code == 0 || dos(code, 0, -1, pat) == -1) {
#endif
		code = SRCHFIR;
		return (char *)0;
	}
	code = SRCHNXT;

	np = tail;
	cp = srchbuf.name;
	while (*np++ = tolower(*cp++))
		;
	return nambuf;
}



