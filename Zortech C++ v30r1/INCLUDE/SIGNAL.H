/*_ signal.h   Mon Dec 25 1989	 Modified by: Walter Bright */

#ifndef __SIGNAL_H
#define __SIGNAL_H	1

#if __cplusplus
extern "C" {
#endif

#ifdef __STDC__
#define __CDECL
#else
#define __CDECL _cdecl
#endif

typedef volatile int sig_atomic_t;

void (__CDECL *signal(int,void (__CDECL *)(int)))(int);

#if M_UNIX || M_XENIX
#define SIGHUP	 1
#define SIGINT	 2
#define SIGQUIT	 3
#define SIGILL	 4
#define SIGTRAP	 5
#define SIGIOT	 6
#define SIGABRT	 6
#define SIGEMT	 7
#define SIGFPE	 8
#define SIGKILL	 9
#define SIGBUS	 10
#define SIGSEGV	 11
#define SIGSYS	 12
#define SIGPIPE	 13
#define SIGALRM	 14
#define SIGTERM	 15
#define SIGUSR1	 16
#define SIGUSR2	 17
#define SIGCLD	 18
#define SIGPWR	 19
#define SIGWINCH 20

#if M_XOUT
#define SIGPOLL 20
#else
#define SIGPOLL 22
#endif

#define SIGCHLD SIGCLD	/* compatibility   */

#if M_UNIX
#define SIGSTOP 23
#define SIGTSTP 24
#define SIGCONT 25
#define SIGTTIN 26
#define SIGTTOU 27

#define SIGALL (~(sigset_t)0L) /* All signals.	  */
#endif /* M_UNIX */

typedef long	sigset_t;

#define sigbit(n)	(1L << ((n) - 1))
#define sigemptyset(s)	*(s) = ~SIGALL
#define sigfillset(s)	*(s) = SIGALL
#define sigaddset(s,n)	*(s) |= sigbit(n)
#define sigdelset(s,n)	*(s) &= ~sigbit(n)
#define sigismember(set,n) ((*(set) & sigbit(n)) == sigbit(n))

/*
 * Signal vector "template" used in sigaction call.
 */
struct	sigaction {
	void	(*sa_handler)();	/* signal handler		*/
	sigset_t sa_mask;		/* signal mask to apply		*/
	int	sa_flags;		/* see signal options below	*/
};
#define SA_NOCLDSTOP	1		/* ignore SIGCHLD		*/

#define SIG_ERR	 (void(*)(int))-1
#define SIG_DFL	 (void(*)(int))0
#define SIG_IGN	 (void(*)(int))1
#define SIG_HOLD (void(*)(int))2

extern int __CDECL kill(int,int), __CDECL getpid(void);
extern int __CDECL pause(void);
extern unsigned int __CDECL alarm(unsigned int seconds);
#define raise(s) kill(getpid(),s)

#else /* M_UNIX || M_XENIX */

#define SIGABRT 0		/* abort			*/
#define SIGFPE	1		/* floating point error		*/
#define SIGILL	2		/* illegal instruction		*/
#define SIGINT	3		/* interrupt			*/
#define SIGSEGV 4		/* segment violation		*/
#define SIGTERM 5		/* terminate			*/
#define SIGBREAK 6		/* ctrl-break			*/

int __CDECL raise(int);

#define SIG_DFL		(void (__CDECL *)(int)) 0
#define SIG_ERR		(void (__CDECL *)(int)) 1
#define SIG_IGN		(void (__CDECL *)(int)) 2

#endif

#if __cplusplus
}
#endif

#endif /* __SIGNAL_H */

