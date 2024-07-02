/* signal.h - signal handling header file
 * $Version: 1.20 $
 * Copyright (c) 1988-91 Intel Corporation, ALL RIGHTS RESERVED.
 */

#ifndef _signalh
#define _signalh
/*lint -library */

#pragma fixedparams("_sig_abrt_dfl",  "_sig_alloc_dfl", "_sig_break_dfl")
#pragma fixedparams("_sig_fpe_dfl",   "_sig_free_dfl",  "_sig_ill_dfl")
#pragma fixedparams("_sig_int_dfl",   "_sig_read_dfl",  "_sig_segv_dfl")
#pragma fixedparams("_sig_term_dfl",  "_sig_write_dfl", "_sig_null")
#pragma fixedparams("_sig_err_dummy", "_sig_dfl_dummy", "_sig_ign_dummy")
#pragma fixedparams("_sig_dfl",       "raise",          "signal")

typedef char sig_atomic_t;

/*
 * Signal definitions:
 */
#define SIGILL    1   /* illegal instruction signal */
#define SIGINT    2   /* interactive attention signal */
#define SIGALLOC  3   /* dynamic memory allocation failure signal */
#define SIGFREE   4   /* bad free pointer signal */
#define SIGTERM   5   /* terminate signal */
#define SIGREAD   6   /* read error signal */
#define SIGWRITE  7   /* write error signal */
#define SIGFPE    8   /* floating point exception signal */
#define SIGSEGV   9   /* segment violation signal */
#define SIGABRT  10   /* abnormal termination signal */
#define SIGBREAK 11   /* Ctrl_break sequence */
#define SIGUSR1  12   /* User-defined signal 1 */
#define SIGUSR2  13   /* User-defined signal 2 */
#define SIGUSR3  14   /* User-defined signal 3 */

#define SIGSIZE  15                     /* Number of defined signals         */

extern void _sig_ill_dfl(void);
extern void _sig_int_dfl(void);
extern void _sig_alloc_dfl(void);
extern void _sig_free_dfl(void);
extern void _sig_term_dfl(void);
extern void _sig_read_dfl(void);
extern void _sig_write_dfl(void);
extern void _sig_fpe_dfl(void);
extern void _sig_segv_dfl(void);
extern void _sig_abrt_dfl(void);
extern void _sig_break_dfl(void);
extern void _sig_null(void);
extern void _sig_err_dummy(int);
extern void _sig_dfl_dummy(int);
extern void _sig_ign_dummy(int);

/*
 * Signal vector arrays
 */
extern void (*_sig_eval[SIGSIZE])();
extern void (*_sig_dfl[SIGSIZE])();

/*
 * Signal processing macros
 */
#define  SIG_DFL  (&_sig_dfl_dummy)
#define  SIG_ERR  (&_sig_err_dummy)
#define  SIG_IGN  (&_sig_ign_dummy)

/*
 * Function prototypes:
 */
void (*signal (int, void (*)(int)))(int);
int raise(int);

#endif /* _signalh */

