/*$no list*//*$no trace <<< float.h >>> */
/*   Copyright (c) Mix Software 1988    */

#define DBL_DIG                             15
#define DBL_EPSILON     2.2204460492503131E-16
#define DBL_MANT_DIG                        53
#define DBL_MAX        1.7976931348623158E+308
#define DBL_MAX_10_EXP                    +308
#define DBL_MAX_EXP                      +1024
#define DBL_MIN        2.2250738585072014E-308
#define DBL_MIN_10_EXP                    -307
#define DBL_MIN_EXP                      -1021
#define FLT_DIG                              6
#define FLT_EPSILON            1.192092896E-07
#define FLT_MANT_DIG                        24
#define FLT_MAX                3.402823466E+38
#define FLT_MAX_10_EXP                     +38
#define FLT_MAX_EXP                       +128
#define FLT_MIN                1.175494351E-38
#define FLT_MIN_10_EXP                     -37
#define FLT_MIN_EXP                       -125
#define LDBL_DIG                       DBL_DIG
#define LDBL_EPSILON               DBL_EPSILON
#define LDBL_MANT_DIG             DBL_MANT_DIG
#define LDBL_MAX                       DBL_MAX
#define LDBL_MAX_10_EXP         DBL_MAX_10_EXP
#define LDBL_MAX_EXP               DBL_MAX_EXP
#define LDBL_MIN                       DBL_MIN
#define LDBL_MIN_10_EXP         DBL_MIN_10_EXP
#define LDBL_MIN_EXP               DBL_MIN_EXP

#if !defined(ANSI)
#define FLT_GUARD      1
#define FLT_RADIX      2
#define DBL_RADIX      2
#define LDBL_RADIX     2
#define FLT_NORMALIZE  1
#define FLT_ROUNDS     1
#define DBL_ROUNDS     1
#define LDBL_ROUNDS    1

unsigned _clear87(void);
unsigned _control87(unsigned cw, unsigned mask);
void     _fpreset(void);
unsigned _status87(void);

/* 8087/80287 Status Word format   */

#define SW_INVALID              0x0001  /* Invalid operation            */
#define SW_DENORMAL             0x0002  /* Denormalized operand         */
#define SW_ZERODIVIDE           0x0004  /* Zero divide                  */
#define SW_OVERFLOW             0x0008  /* Overflow                     */
#define SW_UNDERFLOW            0x0010  /* Underflow                    */
#define SW_INEXACT              0x0020  /* Precision (Inexact result)   */

/* 8087/80287 Control Word format */

#define MCW_EM                  0x003f  /* interrupt Exception Masks    */
#define     EM_INVALID          0x0001  /*   invalid                    */
#define     EM_DENORMAL         0x0002  /*   denormal                   */
#define     EM_ZERODIVIDE       0x0004  /*   zero divide                */
#define     EM_OVERFLOW         0x0008  /*   overflow                   */
#define     EM_UNDERFLOW        0x0010  /*   underflow                  */
#define     EM_INEXACT          0x0020  /*   inexact (precision)        */

#define MCW_IC                  0x1000  /* Infinity Control             */
#define     IC_AFFINE           0x1000  /*   affine                     */
#define     IC_PROJECTIVE       0x0000  /*   projective                 */

#define MCW_RC                  0x0c00  /* Rounding Control             */
#define     RC_CHOP             0x0c00  /*   chop                       */
#define     RC_UP               0x0800  /*   up                         */
#define     RC_DOWN             0x0400  /*   down                       */
#define     RC_NEAR             0x0000  /*   near                       */

#define MCW_PC                  0x0300  /* Precision Control            */
#define     PC_24               0x0000  /*    24 bits                   */
#define     PC_53               0x0200  /*    53 bits                   */
#define     PC_64               0x0300  /*    64 bits                   */
#endif /* ANSI */

#define CW_DEFAULT IC_AFFINE|RC_NEAR|PC_64|EM_DENORMAL|EM_UNDERFLOW|EM_INEXACT

/*$list*//*$trace       <<< float.h >>> */
