/**
*
* The following symbols are used for the "open" and "creat" functions.
*
**/
#define O_RDONLY 0	/* Read-only value (right byte of mode word) */
#define O_WRONLY 1	/* Write-only value */
#define O_RDWR 2	/* Read-write value */

#define O_NDELAY 4	/* Non-blocking I/O flag */
#define O_APPEND 8	/* Append mode flag */
#define O_CREAT 0x0100	/* File creation flag */
#define O_TRUNC 0x200	/* File truncation flag */
#define O_EXCL 0x400	/* Exclusive access flag */

#define O_RAW 0x8000	/* Raw I/O flag (Lattice feature) */

/**
*
* The following symbols are used for the "fcntl" function.
*
*/
#define F_DUPFD 0	/* Duplicate file descriptor */
#define F_GETFD 1	/* Get file descriptor flags */
#define F_SETFD 2	/* Set file descriptor flags */
#define F_GETFL 3	/* Get file flags */
#define F_SETFL 4	/* Set file flags */
