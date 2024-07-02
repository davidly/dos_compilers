/*_ ungetc.c   Sat Oct 17 1987   Modified by: Walter Bright */
/* Copyright (C) 1985-1987 by Walter Bright	*/
/* All Rights Reserved					*/
/* Written by Walter Bright				*/

#include	<stdio.h>
#include	<io.h>
#include	<dos.h>

/* Current position in file     */
#define CURPOS(fp)      lseek((fp)->_file,0L,1)

/**********************
 * Put char back in input stream.
 * Only 1 is allowed.
 * Returns:
 *      EOF     if failure
 *      c       if success
 */

int ungetc(c,fp)
int c;
FILE *fp;
{
	if (fp->_flag & (_IOWRT | _IOEOF | _IOERR) ||
	    c == EOF ||
#ifdef BIGBUF
	    !(fp->_base || fp->_seg)
#else
	    !fp->_base
#endif
	   )
		return EOF;
	else
	{
		if (fp->_ptr != fp->_base)      /* if buffer isn't empty */
			--fp->_ptr;
#ifdef BIGBUF
		if (fp->_flag & _IOBIGBUF)
			poke(fp->_seg,(unsigned) fp->_ptr,&c,1);
		else
#endif
			*fp->_ptr = c;
		fp->_cnt++;
		return c;
	}
	/* NOTREACHED */
}

/************************
 * Buffered version of lseek().
 *      origin  = 0     relative to beginning
 *	      = 1     relative to current position
 *	      = 2     relative to end
 * Returns:
 *      0       success
 *      -1      error
 */

int fseek(fp,offset,origin)
FILE *fp;
long offset;
int origin;
{       int cnt;

	fp->_flag &= ~(_IOERR | _IOEOF);	/* switch off these bits */
	switch (fp->_flag & (_IORW | _IOREAD | _IOWRT))
	{
	    case _IOWRT:
		fflush(fp);
		break;
	    case _IORW | _IOWRT:
	    case _IORW:
		fflush(fp);
		fp->_flag &= ~_IOWRT;   /* no longer necessarilly writing */
		fp->_ptr = fp->_base;
		break;
	    case _IOREAD:
		/* see if we can just change the position in the buffer */
		if ((fp->_flag & _IONBF) == 0 &&	/* if buffered  */
#ifdef BIGBUF
		    (fp->_base || fp->_seg) &&  /* and there is a buffer */
#else
		    fp->_base &&		/* and there is a buffer */
#endif
		    origin < 2 &&	       /* and origin is 0 or 1 */
		    (cnt = fp->_cnt) != 0)	/* and something in read buf*/
		{       long rel;

			/* calc position relative to current spot in buffer */
			if (origin == 1)	/* if rel to current pos */
				rel = offset;
			else	    /* relative to beginning	*/
				rel = offset - (CURPOS(fp) - cnt);

			/* rel can be + or -. If +, see that it isn't   */
			/* the top of the buffer. If -, see that it     */
			/* isn't past the bottom.		       */
			if (rel <= cnt && -rel <= fp->_ptr - fp->_base)
			{       fp->_cnt -= (int) rel;
				fp->_ptr += (int) rel;
				return 0;
			}
		}
		/* FALLTHROUGH */
	    case _IORW | _IOREAD:
		if (origin == 1)	/* if relative to current position */
			offset -= fp->_cnt;     /* lseek pos is offset  */
					/* note that _cnt is 0 if unbuffered*/
		fp->_ptr = fp->_base;
		break;
	    default:
	    err:
		return -1;		      /* error		*/
	}
	fp->_cnt = 0;
	if (lseek(fp->_file,offset,origin) == -1)
		goto err;
	return 0;
}

/**************************
 * Return current position in buffer.
 * Returns:
 *      -1 if error
 *      else file position
 */

long ftell(fp)
FILE *fp;
{       long curpos;

	if ((fp->_flag & (_IORW | _IOREAD | _IOWRT)) == 0)
		curpos = -1;
	else if ((curpos = CURPOS(fp)) != -1)
	{   if (fp->_flag & _IOREAD)
		curpos -= fp->_cnt;
	    else if ((fp->_flag & (_IOWRT | _IONBF)) == _IOWRT &&
		     (fp->_base
#ifdef BIGBUF
			|| fp->_seg
#endif
			       ))
		curpos += fp->_ptr - fp->_base;
	}
	return curpos;
}
