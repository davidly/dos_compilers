/*_ limits.h   Sat May 20 1989   Modified by: Walter Bright */
/* Implementation limits			*/

#ifndef __LIMITS_H
#define __LIMITS_H	1

#define	CHAR_BIT	8		/* # of bits in a char		*/
#define	SCHAR_MAX	127
#define	SCHAR_MIN	(-127-1)
#define	UCHAR_MAX	255
#if _CHAR_UNSIGNED
#define	CHAR_MAX	UCHAR_MAX	/* max value of a char		*/
#define	CHAR_MIN	0		/* min value of a char		*/
#else
#define	CHAR_MAX	SCHAR_MAX	/* max value of a char		*/
#define	CHAR_MIN	SCHAR_MIN	/* min value of a char		*/
#endif

#define	SHRT_MAX	32767		/* max value of short		*/
#define	SHRT_MIN	(-32767-1)
#define	USHRT_MAX	0xFFFF

#define	LONG_MAX	((long)0x7FFFFFFF)
#define	LONG_MIN	((long)0x80000000)
#define	ULONG_MAX	0xFFFFFFFF

#if __I86__ <= 2 /* sizeof(int) == sizeof(short) */
#define	INT_MAX		SHRT_MAX
#define	INT_MIN		SHRT_MIN
#define	UINT_MAX	USHRT_MAX
#else
#define	INT_MAX		LONG_MAX
#define	INT_MIN		LONG_MIN
#define	UINT_MAX	ULONG_MAX
#endif

#define MB_LEN_MAX	1

#endif /* __LIMITS_H */
