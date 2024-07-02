/*_ SIGNAL.H   Wed Jun 28 1989   Modified by: Walter Bright */

#ifndef SIGNAL_H
#define SIGNAL_H	1

#if __cplusplus
extern "C" {
#endif

#ifdef __STDC__
#define __CDECL
#else
#define __CDECL cdecl
#endif

typedef volatile int sig_atomic_t;

#define SIG_DFL		(void (*)(int))	0
#define SIG_ERR		(void (*)(int))	1
#define SIG_IGN		(void (*)(int))	2

#define SIGABRT	0		/* abort			*/
#define SIGFPE	1		/* floating point error		*/
#define SIGILL	2		/* illegal instruction		*/
#define SIGINT	3		/* interrupt			*/
#define SIGSEGV	4		/* segment violation		*/
#define SIGTERM	5		/* terminate (control-break)	*/

void (*signal(int,void (*)(int)))(int);
int __CDECL raise(int);

#if __cplusplus
}
#endif

#endif /* SIGNAL_H */
