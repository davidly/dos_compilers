/* Copyright 1987 Manx Software Systems, Inc */

#define	_U	0x01	/* Upper case */
#define	_L	0x02	/* Lower case */
#define	_D	0x04	/* Decimal digit */
#define	_X	0x08	/* heXadecimal digit */
#define	_S	0x10	/* Spacing character */
#define	_C	0x20	/* Control character */
#define	_P	0x40	/* Punctuation */
#define	_B	0x80	/* Blank */

char _ctype[1+256] = {
	0,								/*	EOF */
	_C,		_C,		_C,		_C,		/*	nul	soh	stx	etx	*/
	_C,		_C,		_C,		_C,		/*	eot	enq	ack	bel	*/
	_C,		_C|_S,	_C|_S,	_C|_S,	/*	bs	ht	nl	vt	*/
	_C|_S,	_C|_S,	_C,		_C,		/*	ff	cr	so	si	*/
	_C,		_C,		_C,		_C,		/*	dle	dc1	dc2	dc3	*/
	_C,		_C,		_C,		_C,		/*	dc4	nak	syn	etb	*/
	_C,		_C,		_C,		_C,		/*	can	em	sub	esc	*/
	_C,		_C,		_C,		_C,		/*	fs	gs	rs	us	*/
	_B|_S,	_P,		_P,		_P,		/*	sp	!	"	#	*/
	_P,		_P,		_P,		_P,		/*	$	%	&	'	*/
	_P,		_P,		_P,		_P,		/*	(	)	*	+	*/
	_P,		_P,		_P,		_P,		/*	,	-	.	/	*/
	_D|_X,	_D|_X,	_D|_X,	_D|_X,	/*	0	1	2	3	*/
	_D|_X,	_D|_X,	_D|_X,	_D|_X,	/*	4	5	6	7	*/
	_D|_X,	_D|_X,	_P,		_P,		/*	8	9	:	;	*/
	_P,		_P,		_P,		_P,		/*	<	=	>	?	*/
	_P,		_U|_X,	_U|_X,	_U|_X,	/*	@	A	B	C	*/
	_U|_X,	_U|_X,	_U|_X,	_U,		/*	D	E	F	G	*/
	_U,		_U,		_U,		_U,		/*	H	I	J	K	*/
	_U,		_U,		_U,		_U,		/*	L	M	N	O	*/
	_U,		_U,		_U,		_U,		/*	P	Q	R	S	*/
	_U,		_U,		_U,		_U,		/*	T	U	V	W	*/
	_U,		_U,		_U,		_P,		/*	X	Y	Z	[	*/
	_P,		_P,		_P,		_P,		/*	\	]	^	_	*/
	_P,		_L|_X,	_L|_X,	_L|_X,	/*	`	a	b	c	*/
	_L|_X,	_L|_X,	_L|_X,	_L,		/*	d	e	f	g	*/
	_L,		_L,		_L,		_L,		/*	h	i	j	k	*/
	_L,		_L,		_L,		_L,		/*	l	m	n	o	*/
	_L,		_L,		_L,		_L,		/*	p	q	r	s	*/
	_L,		_L,		_L,		_L,		/*	t	u	v	w	*/
	_L,		_L,		_L,		_P,		/*	x	y	z	{	*/
	_P,		_P,		_P,		_C,		/*	|	}	~	del	*/
} ;
