#include <stdio.h>
#include "ed.h"

#if TERMCAP

#define NROW	24
#define NCOL	80
#define BEL	0x07
#define ESC	0x1B

extern int	ttopen();
extern int	ttgetc();
extern int	ttputc();
extern int	ttflush();
extern int 	ttclose();
extern int 	tcapmove();
extern int 	tcapeeol();
extern int	tcapeeop();
extern int	tcapbeep();
extern int	tcapopen();
extern int	tput();
extern char	*tgoto();

#define TCAPSLEN 315

char tcapbuf[TCAPSLEN];
char	PC,
	*CM,
	*CL,
	*CE,
	*UP,
	*CD;


TERM term = {
	NROW-1,
	NCOL,
	&tcapopen,
	&ttclose,
	&ttgetc,
	&ttputc,
	&ttflush,
	&tcapmove,
	&tcapeeol,
	&tcapeeop,
	&tcapbeep
};

tcapopen()

{
	char *getenv();
	char *t, *p, *tgetstr();
	char tcbuf[1024];
	char *tv_stype;
	char err_str[72];

	if ((tv_stype = getenv("TERM")) == NULL)
	{
		puts("Environment variable TERM not defined!");
		exit(1);
	}

	if((tgetent(tcbuf, tv_stype)) != 1)
	{
		sprintf(err_str, "Unknown terminal type %s!", tv_stype);
		puts(err_str);
		exit(1);
	}

	p = tcapbuf;
	t = tgetstr("pc", &p);
	if(t)
		PC = *t;

	CD = tgetstr("cd", &p);
	CM = tgetstr("cm", &p);
	CE = tgetstr("ce", &p);
	UP = tgetstr("up", &p);

	if(CD == NULL || CM == NULL || CE == NULL || UP == NULL)
	{
		puts("Incomplete termcap entry\n");
		exit(1);
	}

	if (p >= &tcapbuf[TCAPSLEN])
	{
		puts("Terminal description too big!\n");
		exit(1);
	}
	ttopen();
}
tcapmove(row, col)
register int row, col;
{
	putpad(tgoto(CM, col, row));
}

tcapeeol()
{
	putpad(CE);
}

tcapeeop()
{
	putpad(CD);
}

tcapbeep()
{
	ttputc(BEL);
}

putpad(str)
char	*str;
{
	tputs(str, 1, ttputc);
}

putnpad(str, n)
char	*str;
{
	tputs(str, n, ttputc);
}
#endif TERMCAP
