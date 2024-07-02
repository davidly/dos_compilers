extern int _attrib;

static cputc(chr)
register int chr;
{
	scr_putc(chr);
	
	if (chr == '\n')
		scr_putc('\r');
}

scr_puts(str)
register char *str;
{
	while(*str)
		cputc(*str++);

	cputc('\n');
}

scr_printf(fmt,args)
register char *fmt; 
unsigned args;
{
	format(cputc,fmt,&args);
}

scr_setatr(back,frg,intens,blink)
register int back, frg;
register int intens, blink;
{
	register char tmp;
	
	tmp = _attrib;
	_attrib = (back << 4) | frg;
	
	if (blink)
		_attrib |= 128;
	else
		_attrib &= 127;

	if (intens)
		_attrib |= 8;
	else
		_attrib &= 247;
	
	_attrib &= 255;
	return(tmp);
}

scr_getatr()
{
	return(_attrib);
}

scr_resatr(atr)
register int atr;
{
	register char tmp;
	
	tmp = _attrib;
	_attrib = atr;
	return(tmp);
}
