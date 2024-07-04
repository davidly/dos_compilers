/* utime.h - basic struct for utime()
 * $Version: 1.15 $
 * Copyright (c) 1988-91 Intel Corporation, ALL RIGHTS RESERVED.
 */

#ifndef _utimeh
#define _utimeh
/*lint -library */

#ifndef _time_t
typedef long time_t;
#define _time_t
#endif

#pragma fixedparams("utime")

#pragma align (utimbuf)
struct utimbuf {
  time_t actime;  	/* time of last access - not available under DOS */
  time_t modtime; 	/* time of last modification */
};

/*
 * Function prototypes:
 */
int utime(const char *, struct utimbuf *);

#endif /* _utimeh */

