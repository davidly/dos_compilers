/*
 * float.h
 *
 * contains defines for a number of implementation dependent values which are
 * commonly used by sophisticated numerical (floating point) programs.
 *
 * Copyright (C) Microsoft Corporation, 1985, 1986
 *
 */

#define DBL_DIG 15
#define DBL_MAX_EXP 306
#define DBL_MIN_EXP -306
#define DBL_RADIX 2
#define DBL_ROUNDS 0
#define FLT_DIG 7
#define FLT_GUARD 0
#define FLT_MAX_EXP 38
#define FLT_MIN_EXP -38
#define FLT_NORMALIZE 0
#define FLT_RADIX 2
#define FLT_ROUNDS 0
#define LDBL_DIG 15
#define LDBL_MAX_EXP 306
#define LDBL_MIN_EXP -306
#define LDBL_RADIX 2
#define LDBL_ROUNDS 0


/*
 *	8087/80287 math control information
 */

/*  User Control Word Mask and Bit Definitions	*/
/*  These definitions match the 8087/80287 */

#define MCW_EM			0x003f		/* interrupt Exception Masks */
#define     EM_INVALID		0x0001		/*   invalid */
#define     EM_DENORMAL 	0x0002		/*   denormal */
#define     EM_ZERODIVIDE	0x0004		/*   zero divide */
#define     EM_OVERFLOW 	0x0008		/*   overflow */
#define     EM_UNDERFLOW	0x0010		/*   underflow */
#define     EM_INEXACT		0x0020		/*   inexact (precision) */

#define MCW_IC			0x1000		/* Infinity Control */
#define     IC_AFFINE		0x1000		/*   affine */
#define     IC_PROJECTIVE	0x0000		/*   projective */

#define MCW_RC			0x0c00		/* Rounding Control */
#define     RC_CHOP		0x0c00		/*   chop */
#define     RC_UP		0x0800		/*   up */
#define     RC_DOWN		0x0400		/*   down */
#define     RC_NEAR		0x0000		/*   near */

#define MCW_PC			0x0300		/* Precision Control */
#define     PC_24		0x0000		/*    24 bits */
#define     PC_53		0x0200		/*    53 bits */
#define     PC_64		0x0300		/*    64 bits */

#define CW_DEFAULT ( IC_AFFINE + RC_NEAR + PC_64 + EM_DENORMAL + EM_UNDERFLOW + EM_INEXACT )  /* initial control word */


/*  User Status Word Bit Definitions  */

#define SW_INVALID		0x0001		/*   invalid */
#define SW_DENORMAL		0x0002		/*   denormal */
#define SW_ZERODIVIDE		0x0004		/*   zero divide */
#define SW_OVERFLOW		0x0008		/*   overflow */
#define SW_UNDERFLOW		0x0010		/*   underflow */
#define SW_INEXACT		0x0020		/*   inexact (precision) */

/*    invalid subconditions (SW_INVALID also set) */

#define SW_UNEMULATED		0x0040		/* unemulated instruction */
#define SW_SQRTNEG		0x0080		/* square root of a neg number */
#define SW_STACKOVERFLOW	0x0200		/* FP stack overflow */
#define SW_STACKUNDERFLOW	0x0400		/* FP stack underflow */


/*  Floating point error signals and return codes */

#define FPE_INVALID		0x81
#define FPE_DENORMAL		0x82
#define FPE_ZERODIVIDE		0x83
#define FPE_OVERFLOW		0x84
#define FPE_UNDERFLOW		0x85
#define FPE_INEXACT		0x86

#define FPE_UNEMULATED		0x87
#define FPE_SQRTNEG		0x88
#define FPE_STACKOVERFLOW	0x8a
#define FPE_STACKUNDERFLOW	0x8b


#ifdef LINT_ARGS	/* argument checking enabled */

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
unsigned int cdecl _clear87(void);
unsigned int cdecl _control87(unsigned int,unsigned int);
void cdecl _fpreset(void);
unsigned int cdecl _status87(void);
#else			/* extended keywords not enabled */
unsigned int _clear87(void);
unsigned int _control87(unsigned int,unsigned int);
void _fpreset(void);
unsigned int _status87(void);
#endif	/* NO_EXT_KEYS */

#else			/* argument checking not enabled */

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
unsigned int cdecl _clear87();
unsigned int cdecl _control87();
void cdecl _fpreset();
unsigned int cdecl _status87();
#else			/* extended keywords not enabled */
unsigned int _clear87();
unsigned int _control87();
void _fpreset();
unsigned int _status87();
#endif	/* NO_EXT_KEYS */

#endif	/* LINT_ARGS */
