/*_ fread.c   Sun Apr 16 1989   Modified by: Walter Bright */
/* Copyright (C) 1985-1989 by Walter Bright	*/
/* All Rights Reserved					*/
/* Written by Walter Bright				*/

#include	<stdio.h>
#include	<string.h>
#include	<dos.h>

int _fillbuf(FILE *fp);
int _flushbu(int c,FILE *fp);

#if Afread

/***************************
 * Read data from stream.
 * Returns:
 *	# of complete items read
 */

size_t fread(void *pi,size_t bytesper,size_t numitems,FILE *fp)
{	char *p;
	unsigned bytesleft;
	unsigned u;

	p = (char *) pi;
	bytesleft = bytesper * numitems;
	while (bytesleft != 0)
	{	u = fp->_cnt;		/* # of characters left in buffer */
		if (u == 0)
		{	if (_fillbuf(fp) == EOF)
			    return (p - (char *) pi) / bytesper;
			continue;
		}
		if (u > bytesleft)
			u = bytesleft;
#ifdef BIGBUF
		if (fp->_flag & _IOBIGBUF)
			peek(fp->_seg,(unsigned) fp->_ptr,p,u);
		else
#endif
			memcpy(p,fp->_ptr,u);
		fp->_ptr += u;
		fp->_cnt -= u;
		p += u;
		bytesleft -= u;
	}
	return numitems;
}

#endif /* Afread */

#if Afwrite

/*************************
 * Write data to stream.
 * Returns:
 *	# of complete items written
 */

size_t fwrite(const void *pi,size_t bytesper,size_t numitems,FILE *fp)
{	unsigned bytesleft;
	unsigned u;
	const char *p = pi;

	bytesleft = bytesper * numitems;
	while (bytesleft != 0)
	{
		u = fp->_cnt;
		if (u == 0)
		{
			if (_flushbu(*p,fp) == EOF)
				return (p - (const char *) pi) / bytesper;
			bytesleft--;
			p++;
			continue;
		}
		if (u > bytesleft)
			u = bytesleft;
#ifdef BIGBUF
		if (fp->_flag & _IOBIGBUF)
			poke(fp->_seg,(unsigned) fp->_ptr,p,u);
		else
#endif
			memcpy(fp->_ptr,p,u);
		fp->_ptr += u;
		fp->_cnt -= u;
		bytesleft -= u;
		p += u;
	}
	return numitems;
}

#endif /* Afwrite */

#if Aputs

/*****************************
 * Write string to stdout, followed by a newline.
 * Returns:
 *	0 if successful
 *	non-zero if not
 */

int puts(const char *p)
{
	while (*p)
	{	if (putchar(*p) == EOF)
			return 1;
		p++;
	}
	return putchar('\n') == EOF;
}

#endif /* Aputs */

#if Agets

/****************************
 * Read string from stdin.
 */

char *gets(char *s)
{	unsigned c;
	char *sstart = s;

	c = getchar();
	if (c == EOF)
		return (char *) NULL;
	while (c != EOF && c != '\n')
	{	*s++ = c;
		c = getchar();
	}
	*s++ = 0;			/* terminate the string		*/
	return (ferror(stdin)) ? (char *) NULL : sstart;
}

#endif /* Agets */

#if Afgets

/*************************
 * Read string from stream.
 * Returns:
 *	NULL no chars read or read error
 *	else s
 */

char *fgets(char *s,int n,FILE *fp)
{	unsigned c;
	char *sstart = s;

	while (--n > 0)
	{	c = fgetc(fp);
		if (c == EOF)
		{	if (s == sstart)	/* if no chars read	*/
				return (char *) NULL;
			else
				break;
		}
		*s++ = c;
		if (c == '\n')
			break;
	}
	*s++ = 0;			/* terminate the string		*/
	return (ferror(fp)) ? (char *) NULL : sstart;
}

#endif /* Afgets */

#if Afputs

/**************************
 * Write string to stream.
 * Returns:
 *	non-zero if error
 */

int fputs(const char *s,FILE *fp)
{
	while (*s)
	{	if (fputc(*s,fp) == EOF)
			return EOF;
		s++;
	}
	return 0;
}

#endif /* Afputs */
