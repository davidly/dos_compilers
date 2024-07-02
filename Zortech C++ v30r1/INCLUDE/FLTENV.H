/*_ fltenv.h   Sat Mar 30 1991   Modified by: Walter Bright */

#ifndef __FLTENV_H
#define __FLTENV_H	1

#if __cplusplus
extern "C" {
#endif

#ifdef __STDC__
#define __CDECL
#else
#define __CDECL _cdecl
#endif

/* floating point environment	*/
typedef struct __fenv_t
{   /* mimic 8087 status	*/
    unsigned short status;
    unsigned short control;
    unsigned short round;	/* copy of just the rounding bits	*/
    unsigned short reserved[2];	/* for future expansion			*/
} fenv_t;

typedef int fexcept_t;		/* exception flag		*/

/* Exceptions		*/
#define FE_INVALID	1
#define FE_DENORMAL	2
#define FE_DIVBYZERO	4
#define FE_OVERFLOW	8
#define FE_UNDERFLOW	0x10
#define FE_INEXACT	0x20
#define FE_ALL_EXCEPT	0x3F	/* OR of all exceptions		*/

/* Rounding directions	*/
#define FE_TONEAREST	0
#define FE_UPWARD	0x800
#define FE_DOWNWARD	0x400
#define FE_TOWARDZERO	0xC00

extern fenv_t __CDECL FE_DFL_ENV;	/* default floating point environment	*/

/* Rounding precision	*/
#define FE_FLTPREC	0
#define FE_DBLPREC	0x200
#define FE_LDBLPREC	0x300

int  __CDECL fetestexcept(int excepts);
int  __CDECL feraiseexcept(int excepts);
int  __CDECL feclearexcept(int excepts);
int  __CDECL fegetexcept(fexcept_t *flagp,int except);
int  __CDECL fesetexcept(const fexcept_t *flagp,int except);
int  __CDECL fegetround(void);
int  __CDECL fesetround(int round);
int  __CDECL fegetprec(void);
int  __CDECL fesetprec(int prec);
void __CDECL fegetenv(fenv_t *envp);
void __CDECL fesetenv(const fenv_t *envp);
void __CDECL feprocentry(fenv_t *envp);
void __CDECL feprocexit(const fenv_t *envp);

#if __cplusplus
}
#endif

#endif /* __FLTENV_H */


