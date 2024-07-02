/*_ okbigbuf.c	31-Aug-85	*/

/* If this flag is TRUE, 64k is allocated to the data segment for	*/
/* S and P model programs, and BIGBUF disk buffers are enabled.		*/
/* The only time you wouldn't want to use this is if you were		*/
/* using system() or spawn() function calls. In that case, use		*/
/* the global declaration						*/
/*	int _okbigbuf = 0;						*/
/* in one of your program files.					*/

int _okbigbuf = 1;		/* TRUE				*/
