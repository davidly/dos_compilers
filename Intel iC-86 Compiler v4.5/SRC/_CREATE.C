/* _thread_create()  - allocate memory for struct _thread
 * _exit_create()    - allocate memory for struct _exit
 * _stdio_create()   - allocate memory for struct _stdio
 * _exit_ptr()       - get pointer to struct _exit
 * _stdio_ptr()      - get pointer to struct _stdio
 * _thread_ptr()     - get pointer to struct _thread
 * $Version: 1.25 $
 * Copyright (c) 1988 Intel Corporation, ALL RIGHTS RESERVED.
 */

#include <reent.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>


#include <_dos.h>
#include <dos.h>
#include <fileio3.h>

#pragma fixedparams(_get_misc_parms, _dq_getsize)

extern void	_get_misc_parms();
extern int	_main0();
extern int	_main2();
extern void	_main4();
extern void	_mainlast();
extern unsigned	_dq_getsize();

extern unsigned         _amblksiz;
extern char _FAR	*_argument_ptr;
extern char _FAR	*_environ_ptr;

/*
 * Allocate memory for CLIB's global data and thread context:
 */
unsigned _heapmod;
unsigned _proglen;

unsigned         _dataseg;
unsigned         _psp;
unsigned _FAR   *_pspseg;
char            **environ;

struct _io_block  *_iocb = NULL;/* File handle information structure */

int    _fileinfo;		/*  */
int    _fmode;			/* used by _stdio_create() to set _osfile[] */
int    _chbuf = EOF;		/* 1-character buffer for ungetched character */
mode_t _umask = 0;		/*  */

void _FAR *_init_ctlc = (void _FAR *)0;
void _FAR *_curr_ctlc = (void _FAR *)0;

char    cvt_buffer[350];	/* buffer used by ecvt() and fcvt() */

static struct tm      _gmtime_str;

static struct _heap   _heap_str;

static struct _locale _locale_str;

static struct _tzset  _tzset_str;

struct _exit          _exit_str;

struct _stdio         _stdio_str;

struct _thread        _thread_str;



struct _thread *_thread_create(size_t size)
{
	struct regval	regs;
	struct
	{
		unsigned	udi2dos;
		unsigned	psp;
		void		*memory;
	} misc;
	unsigned	status;
	long		data_bytes;
	void _NEAR	*near_heap;
	unsigned	near_heap_bytes;
	void _FAR	*far_heap;
	unsigned	far_heap_paras;


	/*
	 * Initialize all CLIB externally accessed data items:
	 */
	_get_misc_parms(&misc);
	_psp = misc.psp;
	_pspseg = (void _FAR *)((unsigned long)_psp << 16);

	/*
	 * Initialize the target independent CLIB global data:
	 */
	_thread_str._heap_header = &_heap_str;
	_thread_str._locale_data = &_locale_str;
	_thread_str._gmtime_buffer = &_gmtime_str;
	_init_clib_data(&_thread_str);
	
	/*
	 * Set-up the environment for the initial heap:
	 */

#if !_FAR_DATA_			/* small and medium model */
	_dataseg = (unsigned long)(void _FAR *)&_dataseg >> 16;

	near_heap = misc.memory;
	if (misc.udi2dos)
	{
		data_bytes = _dq_getsize(_dataseg, &status);
		far_heap = (_FAR *)_dosf48(1);
		_proglen = 1;
		_heapmod = FP_SEG(far_heap);
	}
	else
	{
		data_bytes = 0x10000;
		far_heap = (void _FAR *)((_dataseg + 0x1000L) << 16);
		_heapmod = _psp;
	}
	near_heap_bytes = data_bytes - (unsigned)near_heap;
	far_heap_paras = 1;
#else					/* compact and large model */
	near_heap = 0;
	near_heap_bytes = 0;
	far_heap = misc.memory;
	if (misc.udi2dos)
	{
		_heapmod = FP_SEG(far_heap);
		_proglen = far_heap_paras = _dq_getsize(_heapmod, &status) >> 4;
	}
	else
	{
		_heapmod = _psp;
		far_heap_paras = _amblksiz >> 4;
	}
#endif
	if (!misc.udi2dos)
	{
		regs.ax = 0x4a00;
		regs.es = _psp;
		regs.bx = _proglen = FP_SEG(far_heap) + far_heap_paras - _psp;
		if (sysint21(&regs, &regs) & 1)
		{
		static	char const _FAR	msg[]	= "Insufficient memory\r\n$";

			regs.ax = 0x0900;
			regs.dx = FP_OFF(msg);
			regs.ds = FP_SEG(msg);
			sysint21(&regs, &regs);
			regs.ax = 0x4c01;
		}
		_pspseg[1] = _psp + _proglen;
	}

	/*
	 * set up the initial heap:
	 */
	_main0(near_heap, near_heap_bytes, far_heap, far_heap_paras);

	/*
	 * Initialize the target dependent timezone data:
	 */
	_thread_str._tzset_data = &_tzset_str;
	if (!(_tzset_str._tzname[0] = (char *)malloc(4)))
	    return (struct _thread *)NULL;		
        if (!(_tzset_str._tzname[1] = (char *)malloc(4)))
	    return (struct _thread *)NULL;		
        strcpy(_tzset_str._tzname[0], "PST");
        strcpy(_tzset_str._tzname[1], "PDT");
	_tzset_str._timezone  = 8 * 60 * 60;
	_tzset_str._daylight  = 1;

	/*
	 * process environment variable:
	 */
	if (_main2())
	    return (struct _thread *)NULL;		

	/*
	 * process interrupts
	 */
	_main4();		

        /*
         * initialize  _fmode:  (O_TEXT by default, O_BINARY if  binmode.obj
         * is linked before the C Runtime Library);  initialize  _fileinfo: 
         * (0 by default (don't pass open file info to child), 1 if
         * fileinfo.obj  is linked before the C Runtime Library)
         */
	_fmode_init();
	_finfo_init();

	return (&_thread_str);
}



struct _exit *_exit_create(size_t size)
{
	return (&_exit_str);
}



struct _stdio *_stdio_create(size_t size)
{
    struct _io_block  *iocb;

    /*
     * Allocate memory for the  iocb  structures and initialize the iocb
     * elements for the pre-connected devices:
     */

    if ( _init_handle_count(_nfile) == -1 )    /* Initialize handle structure */
        return (struct _stdio *) NULL;

    iocb = _IOCB(0);                           /* stdin */
    iocb->osfile  = _IOASCII | _IOREAD;
    iocb->foffset = 0;
    iocb->fseekp  = 0;
    iocb->fbytes  = 0;

    iocb = _IOCB(1);                           /* stdout */
    iocb->osfile  = _IOASCII | _IOWRT;
    iocb->foffset = 0;
    iocb->fseekp  = 0;
    iocb->fbytes  = 0;

    iocb = _IOCB(2);                           /* stderr */
    iocb->osfile  = _IOASCII | _IOWRT |_IONBF;
    iocb->foffset = 0;
    iocb->fseekp  = 0;
    iocb->fbytes  = 0;

    iocb = _IOCB(3);
    iocb->osfile  = 0;

    iocb = _IOCB(4);
    iocb->osfile  = 0;

    _mainlast();			/* set up the program clock */

    return (&_stdio_str);
}



struct _exit *(_exit_ptr)(void)
{
	return (&_exit_str);
}



struct _stdio *(_stdio_ptr)(void)
{
	return (&_stdio_str);
}



struct _thread *(_thread_ptr)(void)
{
	return (&_thread_str);
}
