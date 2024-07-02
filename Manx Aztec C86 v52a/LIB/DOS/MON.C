
#include <stdio.h>

#if __VERSION > 500
#define WRITEBINARY "wb"
#else
#define WRITEBINARY "w"
#endif

extern short _mon_off;
extern unsigned  _speed; 
extern long _ticks;
extern int errno;
extern int _Corg(), _Cend();

#define high(x)  ((unsigned long)(x))
#define low(x)  ((unsigned long)(x) & 0x0000ffffl)
#define canon(x) (int (*)())(((high(x) >> 12)&0x000fffffl) + low(x))

long _ptrdiff();

static struct {
	short	pockets;
	short	byte_pock;
	long	 lowpc;
	long	 highpc;
	int  speed;
	long	time;
} mon_head;

void _profil();

short _monitor (lowpc, highpc, buffer, pockets, nfunc)
int (*lowpc)(), (*highpc)();
unsigned int *buffer;
int pockets, nfunc;
{
	register int i;
	static short pro_flag; 
	static unsigned int *buff_add, oldsig;
	unsigned long  tot_bytes, left_over, org;
	unsigned int bytes, scale;
	int exit();
	FILE *fopen(), *fp;
	int (*slowpc)();

/* 
 *	offset = lowpc;
 * 	tot_bytes = highpc - lowpc
 *	range mod pockets = bytes left over
 *	if (bytes left over)
 *		pockets * (bytes in range +1) > range
 */

	if (pro_flag)
	{

		/*check to see if profiling was turned off by overflow*/

		if (_mon_off)  {
			printf ("Bucket number %d  overflowed\n", _mon_off);
			_mon_off = 0;
		}  
		else
			_clkrest();

		pro_flag = 0;
		mon_head.time = _ticks;
		if ((fp = fopen ("mon.out", WRITEBINARY)) == NULL)
			return (errno);
		if ((fwrite (&mon_head, sizeof(mon_head), 1, fp)) != 1)  {
			printf("\nfunction monitor: error trying to write header data\n");
			fclose (fp);
			return(errno);
		}
		for (i=0; i<mon_head.pockets; ++i)  {
			if ((fwrite (&buff_add[i], sizeof(short), 1, fp)) != 1)  {
				printf("\nfunction monitor: error trying to write data\n");
				fclose (fp);
				return(errno); 
			}
		}
		fclose (fp);

		return(0);
	}  /* end if */  

	if (pockets == 0 || buffer == 0) /* check for valid array and pockets */
		return -1;

	for (i=0; i<pockets; ++i) 		/* clear the users array of junk  */
		buffer[i] = 0;

	pro_flag = 1;

    /* are we running in large code model ? */

	slowpc = lowpc;
	if (sizeof(int (*)()) == 4)
		slowpc  = canon(lowpc);
	tot_bytes = _ptrdiff((unsigned long)highpc,(unsigned long)slowpc);  

	if ((bytes = tot_bytes/pockets) == 0)
		bytes = 1; /* must have at least one byte per pocket */

	if (tot_bytes < pockets || ((tot_bytes % pockets) == 0))
		;
	else  {
		while ( (left_over = (long)pockets * (bytes + 1)) < tot_bytes) 
			bytes = left_over / pockets;
	}

	/* mon_head.speed is set in intr_sp to the number of intrps. per sec */

	mon_head.pockets = pockets;
	mon_head.byte_pock = bytes;
	org = 0;
	if (sizeof(int (*)()) == 4)
		org = canon(_Corg);
	mon_head.lowpc = (unsigned long)slowpc-org;
	mon_head.highpc = (unsigned long)highpc-org;
	buff_add = buffer;


	_profil (buffer, pockets, lowpc, bytes);

}



void _profil (buff, bufsiz, offset, scale)
char *buff;
int bufsiz;
int (*offset)();
int scale;
{

	_clkinit(buff, bufsiz, offset, scale);

	return;
}
/*
;divsor for 121 Hz clock is 9861 dec.
;hex value 0x4DE0 will give exactly 60 inters. per second
*/

#define DIVSOR 1193180L

_intr_sp (sp)
int sp;
{
	if (sp > 121)  {
		_speed = 9861;
		mon_head.speed = 121;
	}  else if (sp <= 0)  {
		_speed = 0;
		mon_head.speed = 18;
	}  else  {
		_speed = DIVSOR / sp;
		mon_head.speed = sp;
	}
}
