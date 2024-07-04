/* reent.h - iC86 header file for reentrancy hooks
 * $Version: 1.22 $
 * Copyright (c) 1988-91 Intel Corporation, ALL RIGHTS RESERVED.
 */

#ifndef _reenth
#define _reenth
/*lint -library */

#pragma fixedparams("_exit_init", "_stdio_init", "_thread_init")
#pragma fixedparams("_init_clib_data")
#pragma fixedparams("_exit_create", "_stdio_create", "_thread_create")
#pragma fixedparams("_exit_ptr", "_stdio_ptr", "_thread_ptr", "_tzset_ptr")
#pragma fixedparams("_semaphore_delete", "_semaphore_init")
#pragma fixedparams("_semaphore_signal", "_semaphore_wait")

#ifndef NULL
#define NULL ((void *)0)
#endif

#ifndef _size_t
#define _size_t
typedef unsigned size_t;
#endif

#ifndef _localeh
#include <locale.h>
#endif

#ifndef _free_list_item_t
#define _free_list_item_t
#pragma align (free_list_item)
struct free_list_item {
    struct free_list_item *next;
    unsigned               length;
};
#endif

#pragma align (_heap)
struct _heap {
    void                    *_malloc_sem;
    struct free_list_item   *_primary_free_list;
    struct free_list_item   *_secondary_free_list;
    int                      _secondary_list_count;
    struct free_list_item   *_allocated_list;
    int                      _allocated_list_count;
    unsigned int             _last_fill;         /* Last fill value used */
    unsigned char            _fill_set;          /* Has _heapset been called */
};

#pragma align (_locale)
struct _locale {
    struct lconv  _locale_conv;
    char         *_locale_array[LC_MAX+1];
};

#pragma align (_tzset)
struct _tzset {
    char  *_tzname[2];
    long   _timezone;
    int    _daylight;
};

#define INIT_OK              0
#define THREAD_INIT_ERROR    2

#pragma align (_exit)
struct _exit {
    void    *open_stream_sem;
    struct  _iobuf    *open_stream_list;    /* list is maintained as a stack */
    void    *exit_handler_sem;
    int      exit_handler_count;
    void   (*exit_handler_list[32])();
};

#pragma align (_thread)
struct _thread
{
    int             _errno;
    char           *_strtok_buffer;
    struct tm      *_gmtime_buffer;
    unsigned long   _rand_seed;
    struct _heap   *_heap_header;
    struct _locale *_locale_data;
    struct _tzset  *_tzset_data;
    char            _asctime_buffer[26];
    int             __doserrno;
};

/*
 * Function prototypes:
 */
int             _exit_init(void);
int             _stdio_init(void);
int             _thread_init(void);
void            _init_clib_data(struct _thread *);
struct _exit   *_exit_create(size_t);
struct _stdio  *_stdio_create(size_t);
struct _thread *_thread_create(size_t);
struct _exit   *_exit_ptr(void);
struct _stdio  *_stdio_ptr(void);
struct _thread *_thread_ptr(void);
struct _tzset  *_tzset_ptr(void);
void            _semaphore_delete(void **);
void            _semaphore_init(void **);
void            _semaphore_signal(void **);
void            _semaphore_wait(void **);


#define _EXIT_PTR   _exit_ptr()
#define _STDIO_PTR  _stdio_ptr()
#define _THREAD_PTR _thread_ptr()

#endif /* _reenth */

#ifndef _stdio_stream

#ifdef _stdioh
#define _stdio_stream
struct _stdio {
    FILE    _stdin;         /* stdin stream */
    FILE    _stdout;        /* stdout stream */
    FILE    _stderr;        /* stderr stream */
};
#endif /* _stdioh */
#endif /* _stdio_stream */
