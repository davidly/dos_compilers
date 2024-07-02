/* Copyright (C) 1981,1982, 1983 by Manx Software Systems */
#include "errno.h"
#include "fcntl.h"

static char **Argv;
static int Argc;

extern int _ioflg[];

_Croot(cp, first)
register char *cp;
{
	register char **cpp;
	char *_sbrk();
#ifdef REDIR
	register int k;
	register char *fname;
#endif

	/* start the timer */

	(void)_clock(0);

	_ioflg[0] = _ioflg[1] = _ioflg[2] = O_TEXT;
	_ioflg[0] |= _isatty(0) ? O_ISTTY:0;	/* set flag for i/o routines */
	_ioflg[1] |= _isatty(1) ? O_ISTTY:0;	/* set flag for i/o routines */
	_ioflg[2] |= _isatty(2) ? O_ISTTY:0;	/* set flag for i/o routines */

	Argv = (char **)_sbrk((first+1)*sizeof(char *));
	Argv[0] = "";
	cpp = &Argv[Argc = first];
	for (;;) {
		while (*cp == ' ' || *cp == '\t')
			++cp;
		if (*cp == 0)
			break;
#ifdef REDIR
		if (*cp == '>') {		/* redirect output */
			k = 1;
			goto redirect;
		} else if (*cp == '<') {	/* redirect input */
			k = 0;
redirect:
			while (*++cp == ' ' || *cp == '\t')
				;
			fname = cp;
			while (*++cp)
				if (*cp == ' ' || *cp == '\t') {
					*cp++ = 0;
					break;
				}
			_close(k);
			if (k)
				k = _creat(fname, 0666);
			else
				k = _open(fname, O_RDONLY);
			if (k == -1)
				_redir_err(fname);
		} else 
#endif
		{
			Argc++;
			if (_sbrk(sizeof(char *)) == (char *)-1) {
				_write(2, "Too many args.", 14);
				_exit(200);
			}
			if (*cp=='"'){
				++cp;
				while (*cp == ' ' || *cp == '\t')
					++cp;
				if (*cp == 0)
					break;
				*cpp++ = cp;
				while (*++cp)
					if (*cp == '"'){
						*cp++ = 0;
						break;
					}
			} else {
				*cpp++ = cp;
				while (*++cp)
					if (*cp == ' ' || *cp == '\t') {
						*cp++ = 0;
						break;
					}
			}
		}
	}
	*cpp = 0;
	main(Argc,Argv);
	exit(0);
}

#ifdef REDIR
static _redir_err(name)
char *name;
{
	char buff[200];

	strcpy(buff, "Can't open file for redirection: ");
	strcat(buff, name);
	strcat(buff, "\n");
	_write(2, buff, strlen(buff));
	exit(10);
}
#endif
