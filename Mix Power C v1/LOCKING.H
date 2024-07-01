/*$no list*//*$no trace	<<< locking.h >>> */
/*   Copyright (c) Mix Software	1988	  */

#define	LK_UNLCK    0	/* unlock the file region */
#define	LK_LOCK	    1	/* lock	the file region	(10 attempts) */
#define	LK_NBLCK    2	/* lock	the file region	  (1 attempt) */
#define	LK_RLCK	    3	/* same	as LK_LOCK  */
#define	LK_NBRLCK   4	/* same	as LK_NBLCK */

/*$list*//*$trace	<<< locking.h >>> */
