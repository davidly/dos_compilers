/*_ flush.c   Sun Apr 16 1989   Modified by: Walter Bright */
/* Copyright (C) 1985-1989 by Walter Bright	*/
/* All Rights Reserved					*/

#include	<stdio.h>
#include	<stdlib.h>
#include	<io.h>
#include	<dos.h>

extern int _okbigbuf;		/* flag if ok to use big buffers	*/

void pascal _freebuf(FILE *fp);

/*****************************
 * Flush all output to line buffered output channels.
 */

void _flushterm()
{	FILE *fp2;

	for (fp2 = &_iob[0]; fp2 < &_iob[_NFILE]; fp2++)
	{
		if (fp2->_flag & (_IOREAD | _IOWRT | _IORW) &&
		    fp2->_flag & _IOLBF)
			fflush(fp2);
	}
}

/************************************
 * Shortcut buffer setting function.
 */

void setbuf(FILE *stream,char *buf)
{
	setvbuf(stream,buf,(buf ? _IOFBF : _IONBF),BUFSIZ);
}

/****************************
 * Set buffer for file stream.
 * Input:
 *	_okbigbuf	For S and M models with buf == NULL,
 *		this determines if the buffer
 *		is located outside of the data segment (1) or not (0).
 *		If _okbigbuf is 1, then setvbuf() first attempts to allocate
 *		a buffer outside of the data segment. If that fails, and
 *		size <= BUFSIZ, then setvbuf() tries again within the
 *		data segment.
 *		If _okbigbuf is 0, setvbuf() always tries to allocate
 *		a buffer within the data segment.
 *		A buffer located outside the data segment is indicated
 *		by _IOBIGBUF being set in fp->_flags.
 *		A buffer malloc'd or dos_alloc'd by setvbuf() is flagged
 *		with _IOMYBUF in fp->_flags.
 *	fp	Opened stream pointer (but before anything is read or
 *		written to the file)
 *	buf	Pointer to buffer, or NULL. If NULL, then setvbuf()
 *		uses malloc() or dos_alloc() to try to allocate a buffer
 *		of size bytes.
 *	mode	One of:
 *		_IONBF	No buffering. buf and size are ignored
 *		_IOLBF	Do line buffering
 *		_IOFBF	Full buffering
 *	size	Size of buffer. If buf is not NULL, then size must be
 *		the size of the buffer that buf points to.
 * Output:
 *	If success, the various fields that fp points to are updated
 *	to show the buffer.
 * Returns:
 *	0	success
 *	!=0	failure (out of memory, or mode is invalid)
 */

int setvbuf(FILE *fp,char *buf,int mode,size_t size)
{
	static char nbfbuf[_NFILE];	/* buffers for _IONBF devices	*/

	_freebuf(fp);			/* free any existing buffer	*/
	if (mode == _IONBF)		/* if unbuffered input desired	*/
	{   /* Ignore buf and size, use our own 1 character buffer	*/
	    fp->_base = &nbfbuf[fp - &_iob[0]];
	    size = 1;
	}
	else if (mode == _IOLBF || mode == _IOFBF)
	{
	    fp->_base = buf;
	    if (buf == NULL)		/* need to allocate a buffer	*/
	    {
#ifdef BIGBUF
		if (_okbigbuf)
		{	fp->_seg = dos_alloc((size + 15) >> 4);
			if (fp->_seg == 0)	/* failed		*/
			{	if (size > BUFSIZ)
					goto err;
			}
			else
			{	fp->_flag |= _IOBIGBUF;
				goto gotbuf;
			}
		}
#endif
		fp->_base = malloc(size);
		if (fp->_base == NULL)
			goto err;
	    gotbuf:
		fp->_flag |= _IOMYBUF;
	    }
	}
	else 				/* invalid mode		*/
	{
	    err:
		return EOF;
	}
#ifdef BIGBUF
	/* If buffer is near data, make sure that _seg has DS in it	*/
	if(!(fp->_flag & _IOBIGBUF))
	    fp->_seg = getDS();
#endif
	fp->_ptr = fp->_base;
	fp->_flag = (fp->_flag & ~(_IONBF | _IOLBF | _IOFBF)) | mode;
	fp->_bufsiz = size;
	return 0;			/* success		*/

}

/***********************
 * Free buffer if setvbuf() malloc'ed it.
 */

void pascal _freebuf(FILE *fp)
{
	if (fp->_flag & _IOMYBUF)
	{
		if (fp->_base)
			free(fp->_base);
#ifdef BIGBUF
		else if (fp->_seg)
		{	dos_free(fp->_seg);
			fp->_flag &= ~(_IOMYBUF | _IOBIGBUF);
		}
#else
		fp->_flag &= ~_IOMYBUF;
#endif
	}
	fp->_ptr = 0;
	fp->_base = 0;
	fp->_cnt = fp->_bufsiz = 0;
#ifdef BIGBUF
	fp->_seg = 0;
#endif
}

/************************
 * Put char in output buffer.
 * Allocate buffer if there isn't one.
 * Returns:
 *	c on success
 *	EOF on failure
 */

int _flushbu(int c,FILE *fp)
{
	if (fp->_flag & _IORW)
		fp->_flag = (fp->_flag & ~_IOREAD) | _IOWRT;

	if ((fp->_flag & (_IOWRT | _IOERR | _IOEOF)) != _IOWRT)
		goto L2;

	if (fp->_flag & _IONBF)		/* if unbuffered		*/
	{
	  L3:	if (write(fp->_file,&c,1) != 1)
			goto L4;
		fp->_cnt = 0;
		return c & 0xFF;
	}

	/* Make sure we have a buffer	*/
	if (!(fp->_base
#ifdef BIGBUF
		|| fp->_seg
#endif
	   ))
	{	int mode;
		size_t size;

		mode = fp->_flag & (_IOFBF | _IOLBF | _IONBF);
		if (mode == 0)
			mode = _IOFBF;
		size = BUFSIZ;
		if (isatty(fp->_file))
			mode = _IOLBF;
#ifdef BIGBUF
		else
			size = BIGBUF;
		if (setvbuf(fp,NULL,mode,size) != 0)
#endif
		{   if (setvbuf(fp,NULL,mode,BUFSIZ) != 0)
		    {	setvbuf(fp,NULL,_IONBF,1);
			goto L3;
		    }
		}
	}
	else /* Do the write	*/
	{	int n;

		n = fp->_ptr - fp->_base;	/* # of chars in buffer	*/
#ifdef BIGBUF
		if (n && n != _writex(fp->_file,fp->_base,n,fp->_seg))
				goto L4;
#else
		if (n && n != write(fp->_file,fp->_base,n))
				goto L4;
#endif
	}
	fp->_ptr = fp->_base;
#ifdef BIGBUF
	poke(fp->_seg,(unsigned) fp->_ptr,&c,1);
#else
	*fp->_ptr = c;
#endif
	fp->_ptr++;
	fp->_cnt = fp->_bufsiz - 1; /* # of chars left in buffer	*/
	return c & 0xFF;

L4:	fp->_flag |= _IOERR;
L2:	fp->_cnt = 0;
	return EOF;
}

/**********************
 * Fill input buffer from stream.
 * Returns 0 if successful, EOF if error.
 */

int _fillbuf(FILE *fp)
{
	if (fp->_flag & _IORW)		/* if read/write	*/
		fp->_flag = (fp->_flag & ~_IOWRT) |  _IOREAD; /*set read bit */

	if ((fp->_flag & (_IOREAD | _IOERR | _IOEOF)) != _IOREAD)
		goto L2;		/* something is wrong here */

	/* Make sure we have a buffer	*/
	if (!(fp->_base
#ifdef BIGBUF
		|| fp->_seg
#endif
	   ))
	{	int mode;

		mode = fp->_flag & (_IOFBF | _IOLBF | _IONBF);
		if (mode == 0)
			mode = _IOFBF;
		if (mode & _IONBF)
		    L3:
			setvbuf(fp,NULL,_IONBF,1);
		else
		{
			if (isatty(fp->_file))
			    mode = _IOLBF;	/* line buffer terminals */
#ifdef BIGBUF
			if (mode == _IOLBF || setvbuf(fp,NULL,mode,BIGBUF) != 0)
#endif
			{   if (setvbuf(fp,NULL,mode,BUFSIZ) != 0)
				goto L3;
			}
		}
	}

	/* Flush all terminal output before expecting terminal input	*/
	if (fp->_flag & (_IOLBF | _IONBF))
	    _flushterm();

	/* Reset counters	*/
	fp->_ptr = fp->_base;

	/* Fill buffer		*/
#ifdef BIGBUF
	fp->_cnt = _readx(fileno(fp),fp->_ptr,fp->_bufsiz,fp->_seg);
#else
    	fp->_cnt = read(fileno(fp),fp->_ptr,fp->_bufsiz);
#endif

	if (fp->_cnt <= 0)		/* if unsuccessful read	*/
	{	if (fp->_cnt == 0)	/* if end of file	*/
		{	fp->_flag |= _IOEOF;
			if (fp->_flag & _IORW)
				fp->_flag &= ~_IOERR;
		}
		else
			fp->_flag |= _IOERR;

	    L2:	fp->_cnt = 0;	/* force no chars left in buffer */
		return EOF;
	}
	return 0;
}
