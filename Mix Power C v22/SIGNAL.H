/*$no list*//*$no trace <<< signal.h >>> */
/*   Copyright (c) Mix Software 1988     */

#if !Defined(sig_atomic_t)
   typedef int sig_atomic_t;
#endif
#define SIG_DFL (void (*)(int))0
#define SIG_IGN (void (*)(int))1
#define SIG_ERR (void (*)(int))-1
#define SIGABRT 1
#define SIGINT  2
#define SIGILL  3
#define SIGSEGV 6
#define SIGTERM 7
#define SIGFPE  8

void (*signal(int sig, void (*sighandler)(int)))(int);
int raise(int sig);

/*$list*//*$trace       <<< signal.h >>> */
