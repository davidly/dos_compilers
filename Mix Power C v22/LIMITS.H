/*$no list*//*$no trace <<< limits.h >>> */
/*   Copyright (c) Mix Software 1988     */

#define CHAR_BIT                8
#if '\xff' == 255
#define CHAR_MAX              255
#define CHAR_MIN                0
#else
#define CHAR_MAX              127
#define CHAR_MIN             -128
#endif
#define INT_MAX             32767
#define INT_MIN            -32768
#define LONG_MAX       2147483647
#define LONG_MIN      -2147483648
#define SCHAR_MAX             127
#define SCHAR_MIN            -128
#define SHRT_MAX            32767
#define SHRT_MIN           -32768
#define UCHAR_MAX            255U
#define UINT_MAX           65535U
#define ULONG_MAX     4294967295U
#define USHORT_MAX         65535U
#define USHRT_MAX          65535U

/*$list*//*$trace       <<< limits.h >>> */
