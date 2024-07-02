/*
; note: FP_OFF and FP_SEG only work in large case
*/

/*	Mode bits for chdir(). Or the bits desired.	*/

#define	CHDIR_READONLY	1
#define CHDIR_HIDDEN	2

/*	#defines for extraction offset and segment from a pointer.	*/

struct {unsigned _offset,_segment;};
#define FP_OFF(ptr)	((((char *)&ptr))->_offset)
#define FP_SEG(ptr)	((((char *)&ptr))->_segment)

/*	Codes for locking and unlocking. Used by locking().	*/

#define LOCK	0
#define UNLCK	1

/*	Open modes.	*/

#define READ		0
#define WRITE		1
#define READWRITE	2

/*	Open sharing modes. Add to above open modes.	*/

#define COMPAT	0x00	/* compatibility mode */
#define DENYRW	0x10	/* deny read/write mode */
#define DENYWR	0x20	/* deny write mode */
#define DENYRD	0x30	/* deny read mode */
#define DENYNO	0x40	/* deny none mode */

