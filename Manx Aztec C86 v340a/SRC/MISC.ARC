atoi.c
/* Copyright (C) 1981,1982 by Manx Software Systems */
#include <ctype.h>

atoi(cp)
register char *cp;
{
	register unsigned i;
	register sign;

	while (*cp == ' ' || *cp == '\t')
		++cp;
	sign = 0;
	if ( *cp == '-' ) {
		sign = 1;
		++cp;
	} else if ( *cp == '+' )
		++cp;

	for ( i = 0 ; isdigit(*cp) ; )
		i = i*10 + *cp++ - '0';
	return sign ? -i : i;
}
atol.c
/* Copyright (C) 1982 by Manx Software Systems */
#include <ctype.h>

long
atol(cp)
register char *cp;
{
	long n;
	register sign;

	while (*cp == ' ' || *cp == '\t')
		++cp;
	sign = 0;
	if ( *cp == '-' ) {
		sign = 1;
		++cp;
	} else if ( *cp == '+' )
		++cp;

	for ( n = 0 ; isdigit(*cp) ; )
		n = n*10 + *cp++ - '0';
	return sign ? -n : n;
}
calloc.c
/* Copyright (C) 1984 by Manx Software Systems */

char *calloc(nelem, size)
unsigned nelem, size;
{
	register unsigned i = nelem*size;
	register char *cp, *malloc();

	if ((cp = malloc(i)) != (char *)0)
		setmem(cp, i, 0);
	return cp;
}
ctype.c
/* Copyright (C) 1984 by Manx Software Systems */

char ctp_[129] = {
	0,								/*	EOF */
	0x20,	0x20,	0x20,	0x20,	/*	nul	soh	stx	etx	*/
	0x20,	0x20,	0x20,	0x20,	/*	eot	enq	ack	bel	*/
	0x20,	0x30,	0x30,	0x30,	/*	bs	ht	nl	vt	*/
	0x30,	0x30,	0x20,	0x20,	/*	ff	cr	so	si	*/
	0x20,	0x20,	0x20,	0x20,	/*	dle	dc1	dc2	dc3	*/
	0x20,	0x20,	0x20,	0x20,	/*	dc4	nak	syn	etb	*/
	0x20,	0x20,	0x20,	0x20,	/*	can	em	sub	esc	*/
	0x20,	0x20,	0x20,	0x20,	/*	fs	gs	rs	us	*/
	0x90,	0x40,	0x40,	0x40,	/*	sp	!	"	#	*/
	0x40,	0x40,	0x40,	0x40,	/*	$	%	&	'	*/
	0x40,	0x40,	0x40,	0x40,	/*	(	)	*	+	*/
	0x40,	0x40,	0x40,	0x40,	/*	,	-	.	/	*/
	0x0C,	0x0C,	0x0C,	0x0C,	/*	0	1	2	3	*/
	0x0C,	0x0C,	0x0C,	0x0C,	/*	4	5	6	7	*/
	0x0C,	0x0C,	0x40,	0x40,	/*	8	9	:	;	*/
	0x40,	0x40,	0x40,	0x40,	/*	<	=	>	?	*/
	0x40,	0x09,	0x09,	0x09,	/*	@	A	B	C	*/
	0x09,	0x09,	0x09,	0x01,	/*	D	E	F	G	*/
	0x01,	0x01,	0x01,	0x01,	/*	H	I	J	K	*/
	0x01,	0x01,	0x01,	0x01,	/*	L	M	N	O	*/
	0x01,	0x01,	0x01,	0x01,	/*	P	Q	R	S	*/
	0x01,	0x01,	0x01,	0x01,	/*	T	U	V	W	*/
	0x01,	0x01,	0x01,	0x40,	/*	X	Y	Z	[	*/
	0x40,	0x40,	0x40,	0x40,	/*	\	]	^	_	*/
	0x40,	0x0A,	0x0A,	0x0A,	/*	`	a	b	c	*/
	0x0A,	0x0A,	0x0A,	0x02,	/*	d	e	f	g	*/
	0x02,	0x02,	0x02,	0x02,	/*	h	i	j	k	*/
	0x02,	0x02,	0x02,	0x02,	/*	l	m	n	o	*/
	0x02,	0x02,	0x02,	0x02,	/*	p	q	r	s	*/
	0x02,	0x02,	0x02,	0x02,	/*	t	u	v	w	*/
	0x02,	0x02,	0x02,	0x40,	/*	x	y	z	{	*/
	0x40,	0x40,	0x40,	0x20,	/*	|	}	~	del	*/
} ;
format.c
/* Copyright (C) 1981,1982,1983 by Manx Software Systems */
#include <ctype.h>

#if MPU8080 || MPUZ80
char *_fmtcvt();
#else

static char *
_fmtcvt(ap, base, cp, len)
int *ap; register char *cp;
{
	register unsigned long val;
	static char digits[]="0123456789abcdef";

	if (len == sizeof(long))
		val = *(long *)ap;
	else if (base > 0)
		val = *(unsigned *)ap;
	else
		val = *ap;

	len = 0;
	if (base < 0) {
		base = -base;
		if ((long)val < 0) {
			val = -val;
			len = 1;
		}
	}

	do {
		*--cp = digits[(int)(val%base)];
	} while ((val /= base) != 0);
	if (len)
		*--cp = '-';
	return cp;
}
#endif

format(putsub, fmt, argp)
register int (*putsub)(); register char *fmt; char *argp;
{
	register int c;
	union {
		int *ip;
		char *cp;
		char **cpp;
#ifdef FLOAT
		double *dp;
#endif
	} args; 
	int charcount;
	int rj, fillc;
	int maxwidth, width;
	int i, k;
	char *cp;
	auto char s[200];

	charcount = 0;
	args.cp = argp;
	while ( c = *fmt++ ) {
		if ( c == '%' ) {
			s[14] = 0;
			rj = 1;
			fillc = ' ';
			maxwidth = 10000;
			if ((c = *fmt++) == '-') {
				rj = 0;
				c = *fmt++;
			}
			if (c == '0') {
				fillc = '0';
				c = *fmt++;
			}
			if (c == '*') {
				width = *args.ip++;
				c = *fmt++;
			} else {
				for (width = 0 ; isdigit(c) ; c = *fmt++)
					width = width*10 + c - '0';
			}
			if ( c == '.' ) {
				if ((c = *fmt++) == '*') {
					maxwidth = *args.ip++;
					c = *fmt++;
				} else {
					for (maxwidth = 0 ; isdigit(c) ; c = *fmt++)
						maxwidth = maxwidth*10 + c - '0';
				}
			}
			i = sizeof(int);
			if (c == 'l') {
				c = *fmt++;
				i = sizeof(long);
			} else if (c == 'h')
				c = *fmt++;

			switch ( c ) {
			case 'o':
				k = 8;
				goto do_conversion;
			case 'u':
				k = 10;
				goto do_conversion;
			case 'x':
				k = 16;
				goto do_conversion;

			case 'd':
				k = -10;
	do_conversion:
				cp = _fmtcvt(args.cp, k, s+14, i);
				args.cp += i;
				break;

			case 's':
				i = strlen(cp = *args.cpp++);
				goto havelen;
#ifdef FLOAT
			case 'e':
			case 'f':
			case 'g':
				ftoa(*args.dp++, s, maxwidth==10000?6:maxwidth, c-'e');
				i = strlen(cp = s);
				maxwidth = 200;
				goto havelen;
#endif

			case 'c':
				c = *args.ip++;
			default:
				*(cp = s+13) = c;
				break;
			}

			i = (s+14) - cp;
		havelen:
			if ( i > maxwidth )
				i = maxwidth;
			
			if ( rj ) {
				if ((*cp == '-' || *cp == '+') && fillc == '0') {
					--width;
					if ((*putsub)(*cp++) == -1)
						return -1;
				}
				for (; width-- > i ; ++charcount)
					if ((*putsub)(fillc) == -1)
						return -1;
			}
			for ( k = 0 ; *cp && k < maxwidth ; ++k )
				if ((*putsub)(*cp++) == -1)
					return -1;
			charcount += k;
			
			if ( !rj ) {
				for (; width-- > i ; ++charcount)
					if ((*putsub)(' ') == -1)
						return -1;
			}
		} else {
			if ((*putsub)(c) == -1)
				return -1;
			++charcount;
		}
	}
	return charcount;
}

malloc.c
/* Copyright (C) 1985 by Manx Software Systems, Inc. */

#ifdef __LDATA
typedef long size_t;
char *_ptradd();
long _ptrdiff();
#define bump(p,i) ((l_t *)_ptradd((p),(long)(i)))
#define ptrdiff(p1,p2) _ptrdiff(p1,p2)
#else
typedef unsigned size_t;
#define bump(p,i) ((l_t *)((char *)(p)+(i)))
#define ptrdiff(p1,p2) (unsigned)((char *)(p1)-(char *)(p2))
#endif

typedef struct list {
	struct list *next;
} l_t;
static l_t first, *current;
static l_t *endmarker = &first, *restart = &first;
static size_t keep;

#define INUSE	1
#define inuse(p) (*(size_t *)(p)&INUSE)
#define markblk(p) (*(size_t *)(p) |= INUSE)
#define unmark(p) (*(size_t *)(p) &= ~INUSE)
#define chain(p)	((l_t *)(*(size_t *)(p) & ~INUSE))

#define BLOCK	(512*sizeof(l_t))	/* # of bytes to ask sbrk for */

char *
realloc(area, size)
register char *area; unsigned size;
{
	register char *cp, *end;
	size_t osize;
	char *malloc();

	end = (char *)chain((l_t *)area-1);
	if ((osize = ptrdiff(end, area)) > size) {
		osize = size;
		end = (char *)bump(area, osize);
	}
	free(area);
	if ((cp = malloc(size)) != 0 && cp != area) {
		movmem(area, cp, osize);
		if ((char *)current >= area && (char *)current < end)
			*(size_t *)bump(cp, ptrdiff(current,area)) = keep;
	}
	return cp;
}

char *
malloc(size)
unsigned size;
{
	register l_t *ptr, *temp, *lastfree;
	register size_t len;
	int times;
	char *sbrk();

	size = ((size+sizeof(l_t)*2-1)/sizeof(l_t))*sizeof(l_t);
	if (current == 0) {
		first.next = &first;
		markblk(&first);
		current = &first;
	}
	for (times = 0, lastfree = ptr = current ; ; ptr = chain(ptr)) {
		if (ptr == endmarker) {
			if (++times > 1) {
				len = BLOCK;
				if ((temp = (l_t *)sbrk((int)len)) == (l_t *)-1)
					return 0;
				if (temp != bump(ptr,sizeof(l_t))) {
					/* non-contiguous allocation */
					ptr->next = temp;
					markblk(ptr);
					len -= sizeof(l_t);
					ptr = temp;
				}
				temp = bump(ptr, len);
				ptr->next = temp;
				temp->next = &first;	/* new end marker */
				markblk(temp);
				endmarker = temp;
				if (chain(lastfree) == ptr)
					ptr = lastfree;
			}
		}
		if (inuse(ptr))
			continue;
		lastfree = ptr;
		while (!inuse(temp = chain(ptr)))
			ptr->next = temp->next;
		len = ptrdiff(temp,ptr);
		if (len >= size) {
			if (len > size) {
				ptr->next = bump(ptr, size);
				keep = *(size_t *)ptr->next;
				ptr->next->next = temp;
			}
			current = ptr->next;
			markblk(ptr);
			return (char *)(ptr+1);
		}
	}
}

free(p)
char *p;
{
	register l_t *ptr;

	ptr = (l_t *)p - 1;
	if (!inuse(ptr))
		return -1;
	unmark(ptr);
	current = ptr;
	return 0;
}
qsort.c
/* Copyright (C) 1984 by Manx Software Systems */

qsort(base, nel, size, compar)
char *base; unsigned nel, size; int (*compar)();
{
	register char *i,*j,*x,*r;
	auto struct stk {
		char *l, *r;
	} stack[16];
	struct stk *sp;

	sp = stack;
	r = base + (nel-1)*size;
	for (;;) {
		do {
			x = base + (r-base)/size/2 * size;
			i = base;
			j = r;
			do {
				while ((*compar)(i,x) < 0)
					i += size;
				while ((*compar)(x,j) < 0)
					j -= size;
				if (i < j) {
					swapmem(i, j, size);
					if (i == x)
						x = j;
					else if (j == x)
						x = i;
				}
				if (i <= j) {
					i += size;
					j -= size;
				}
			} while (i <= j);
			if (j-base < r-i) {
				if (i < r) {	/* stack request for right partition */
					sp->l = i;
					sp->r = r;
					++sp;
				}
				r = j;			/* continue sorting left partition */
			} else {
				if (base < j) {	/* stack request for left partition */
					sp->l = base;
					sp->r = j;
					++sp;
				}
				base = i;		/* continue sorting right partition */
			}
		} while (base < r);

		if (sp <= stack)
			break;
		--sp;
		base = sp->l;
		r = sp->r;
	}
}
scan.c
/* Copyright (C) 1982, 1984 by Manx Software Systems */
#include <ctype.h>

#define EOF	-1

static int maxwidth;
static int (*gsub)();
static getnum();
char *strchr();

scanfmt(getsub, fmt, args)
int (*getsub)(); register char *fmt; register int **args;
{
#ifdef FLOAT
	double atof();
#endif
	long lv;
	register int c, count, base, cc;
	char suppress, lflag, widflg;
	char *cp;
	auto char tlist[130];
	static char list[] = "ABCDEFabcdef9876543210";
	static char vals[] = {
			10,11,12,13,14,15,10,11,12,13,14,15,9,8,7,6,5,4,3,2,1,0
	};

	count = 0;
	gsub = getsub;
	while (c = *fmt++) {
		if (c == '%') {
			widflg = lflag = suppress = 0;
			maxwidth = 127;
			if (*fmt == '*') {
				++fmt;
				suppress = 1;
			}
			if (isdigit(*fmt)) {
				maxwidth = 0;
				do {
					maxwidth = maxwidth*10 + *fmt - '0';
				} while (isdigit(*++fmt));
				widflg = 1;
			}
			if (*fmt == 'l') {
				lflag = 1;
				++fmt;
			}
	
			switch (cc = *fmt++) {
			case '%':
				c = '%';
				goto matchit;
			case 'h':			/* specify short (for compatibility) */
				lflag = 0;
				goto decimal;
			case 'D':
				lflag = 1;
			case 'u':
			case 'd':
	decimal:
				c = 12;
				base = 10;
				goto getval;

			case 'X':
				lflag = 1;
			case 'x':
				c = 0;
				base = 16;
				goto getval;

			case 'O':
				lflag = 1;
			case 'o':
				c = 14;
				base = 8;
	getval:
				if (skipblank())
					goto stopscan;
				if (getnum(&list[c], &vals[c], base, &lv) == 0)
					goto stopscan;
				if (!suppress) {
					if (lflag)
						*(long *)(*args++) = lv;
					else
						**args++ = lv;
					++count;
				}
				break;

#ifdef FLOAT
			case 'E':
			case 'F':
				lflag = 1;
			case 'e':
			case 'f':
				if (skipblank())
					goto stopscan;
				if (getflt(tlist))
					goto stopscan;
				if (!suppress) {
					if (lflag)
						*(double *)(*args++) = atof(tlist);
					else
						*(float *)(*args++) = atof(tlist);
					++count;
				}
				break;
#endif
			case '[':
				lflag = 0;
				if (*fmt == '^' || *fmt == '~') {
					++fmt;
					lflag = 1;
				}
				for (cp = tlist ; (c = *fmt++) != ']' ; )
					*cp++ = c;
				*cp = 0;
				goto string;
			case 's':
				lflag = 1;
				tlist[0] = ' ';
				tlist[1] = '\t';
				tlist[2] = '\n';
				tlist[3] = 0;
	string:
				if (skipblank())
					goto stopscan;
	charstring:
				if (!suppress)
					cp = (char *)*args++;
				widflg = 0;
				while (maxwidth--) {
					if ((c = (*gsub)(0)) == EOF)
						break;
					if (lflag ? (strchr(tlist,c)!=0) : (strchr(tlist,c)==0)) {
						(*gsub)(1);	/* unget last character */
						break;
					}
					if (!suppress)
						*cp++ = c;
					widflg = 1;
				}
				if (!widflg)
					goto stopscan;
				if (!suppress) {
					if (cc != 'c')
						*cp = 0;
					++count;
				}
				break;

			case 'c':
				if (!widflg)
					maxwidth = 1;
				tlist[0] = 0;
				lflag = 1;
				goto charstring;
			}
		} else if (isspace(c)) {
			if (skipblank())
				goto stopscan;
		} else {
matchit:
			if ((*gsub)(0) != c) {
				(*gsub)(1);
				goto stopscan;
			}
		}
	}

stopscan:
	if (count == 0) {
		if ((*gsub)(0) == EOF)
			return EOF;
		(*gsub)(1);
	}
	return count;
}

skipblank()
{
	while (isspace((*gsub)(0)))
		;
	if ((*gsub)(1) == EOF)
		return EOF;
	return 0;
}

#ifdef FLOAT
getflt(buffer)
char *buffer;
{
	register char *cp;
	register int c;
	char decpt, sign, exp;

	sign = exp = decpt = 0;

	for (cp = buffer ; maxwidth-- ; *cp++ = c) {
		c = (*gsub)(0);
		if (!isdigit(c)) {
			if (!decpt && c == '.')
				decpt = 1;
			else if (!exp && (c == 'e' || c == 'E') && cp != buffer) {
				sign = 0;
				exp = decpt = 1;
				continue;
			} else if (sign || (c != '-' && c != '+')) {
				(*gsub)(1);
				break;
			}
		}
		sign = 1;
	}
	*cp = 0;
	return cp==buffer;
}
#endif

static
getnum(list, values, base, valp)
char *list; char *values; long *valp;
{
	register char *cp;
	register int c, cnt;
	long val;
	int sign;

	if (maxwidth <= 0)
		return 0L;
	val = cnt = sign = 0;
	if ((c = (*gsub)(0)) == '-') {
		sign = 1;
		++cnt;
	} else if (c == '+')
		++cnt;
	else
		(*gsub)(1);

	for ( ; cnt < maxwidth ; ++cnt) {
		if ((cp = strchr(list, c = (*gsub)(0))) == 0) {
			if (base == 16 && val == 0 && (c=='x' || c=='X'))
				continue;
			(*gsub)(1);
			break;
		}
		val *= base;
		val += values[cp-list];
	}
	if (sign)
		*valp = -val;
	else
		*valp = val;
	return cnt;
}

sprintf.c
/* Copyright (C) 1982 by Manx Software Systems */
static char *buff;

sprintf(str,fmt,args)
char *str, *fmt; unsigned args;
{
	int spsub();
	register int i;

	buff = str;
	i = format(spsub,fmt,&args);
	*buff = 0;
	return i;
}

static
spsub(c)
{
	return (*buff++ = c)&0xff;
}

sscanf.c
/* Copyright (C) 1983 by Manx Software Systems */
static char *scnstr;
static char quit;

sscanf(string, fmt, arg)
char *string, *fmt; int *arg;
{
	int sgetc();

	scnstr = string;
	quit = 0;
	return scanfmt(sgetc, fmt, &arg);
}

static
sgetc(what)
{
	if (what == 0) {
		if (*scnstr)
			return *scnstr++ & 255;
		quit = 1;
	} else {
		if (!quit)
			return *--scnstr & 255;
	}
	return -1;
}
