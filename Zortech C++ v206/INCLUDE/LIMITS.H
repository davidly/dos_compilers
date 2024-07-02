/*_ limits.h   Sat May 20 1989   Modified by: Walter Bright */
/* Implementation limits			*/

#ifndef __LIMITS_H
#define __LIMITS_H	1

#define	CHAR_BIT	8		/* # of bits in a char		*/
#define	CHAR_MAX	127		/* max value of a char		*/
#define	CHAR_MIN	0		/* min value of a char		*/
#define	SCHAR_MAX	127
#define	SCHAR_MIN	(-128)
#define	UCHAR_MAX	255

#define	SHRT_MAX	INT_MAX		/* max value of short		*/
#define	SHRT_MIN	INT_MIN
#define	USHRT_MAX	UINT_MAX

#define	INT_MAX		32767		/* max value of int		*/
#define	INT_MIN		(-32768)	/* min value of int		*/
#define	UINT_MAX	0xFFFF		/* max value of unsigned int	*/

#define	LONG_MAX	((long)0x7FFFFFFF)
#define	LONG_MIN	((long)0x80000000)
#define	ULONG_MAX	0xFFFFFFFF

#define MB_LEN_MAX	1

#endif /* __LIMITS_H */
