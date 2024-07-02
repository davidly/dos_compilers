/*_ errno.h   October 3, 1990 Modified by Joe Huffman October 3, 1990 */

#ifndef __ERRNO_H
#define __ERRNO_H	1

#ifdef __STDC__
extern volatile int errno;
#else
extern volatile int _cdecl errno;
#endif

#if M_UNIX || M_XENIX
#define EPERM		1
#define ENOENT		2
#define ESRCH		3
#define EINTR		4
#define EIO		5
#define ENXIO		6
#define E2BIG		7
#define ENOEXEC		8
#define EBADF		9
#define ECHILD		10
#define EAGAIN		11
#define ENOMEM		12
#define EACCES		13
#define EFAULT		14
#define ENOTBLK		15
#define EBUSY		16
#define EEXIST		17
#define EXDEV		18
#define ENODEV		19
#define ENOTDIR		20
#define EISDIR		21
#define EINVAL		22
#define ENFILE		23
#define EMFILE		24
#define ENOTTY		25
#define ETXTBSY		26
#define EFBIG		27
#define ENOSPC		28
#define ESPIPE		29
#define EROFS		30
#define EMLINK		31
#define EPIPE		32
#define EDOM		33
#ifndef ERANGE
#define ERANGE		34
#endif
#define ENOMSG		35
#define EIDRM		36
#define ECHRNG		37
#define EL2NSYNC	38
#define EL3HLT		39
#define EL3RST		40
#define ELNRNG		41
#define EUNATCH		42
#define ENOCSI		43
#define EL2HLT		44
#define EDEADLK		45
#define ENOLCK		46

/* XENIX error numbers */
#define EUCLEAN		135
#define ENOTNAM		137
#define ENAVAIL		138
#define EISNAM		139
#define EREMOTEIO	140
#define EREMDEV		142
#define ENOTEMPTY	145

#else
/* Values for errno corresponding to MS-DOS error numbers:    */

#define ENOENT		2
#define ENOTDIR		3
#define EMFILE		4
#define EACCES		5
#define EBADF		6
#define ENOMEM		8
#define EINVAL		22
#define EEXIST		80

/* Our own values for errno:  */
#define E2BIG		1000
#define ENOEXEC		1001
#define EDOM		1002
#ifndef ERANGE
#define ERANGE		1003
#endif
#endif /* M_UNIX || M_XENIX */

#endif /* __ERRNO_H */

