/*
 * udi.h - iRMX (reg. TM) UDI System Call interface functions
 * $Version: 1.3 $
 * Copyright (C) 1989, 90 Intel Corporation, ALL RIGHTS RESERVED
 */

#ifndef _udih
#define _udih

#include <i86.h>
#include <time.h>

#ifndef _plmtypes
#define _plmtypes
#if _ARCHITECTURE_ < 386
#define NATIVE_WORD     unsigned short    /* 16-bit machine */
#else
#define NATIVE_WORD     unsigned long     /* 32-bit machine */
#endif

#define BYTE        unsigned char
#define STRING      char
#define BOOLEAN     unsigned char
#define WORD        unsigned short
#define DWORD       unsigned long
#define TOKEN       selector
#define SELECTOR    selector
#endif

/* -------------------------------------------------------------------- */

/*
 * iRMX UDI interface functions
 */

#pragma fixedparams("dqallocate","dqattach","dqchangeaccess")
#pragma fixedparams("dqchangeextension","dqclose","dqcreate")
#pragma fixedparams("dqdecodeexception","dqdecodetime","dqdelete")
#pragma fixedparams("dqdetach","dqexit","dqfileinfo","dqfree")
#pragma fixedparams("dqgetargument","dqgetconnectionstatus")
#pragma fixedparams("dqgetexceptionhandler","dqgetmsize","dqgetsize")
#pragma fixedparams("dqgetsystemid","dqgettime","dqmallocate","dqmfree")
#pragma fixedparams("dqopen","dqread","dqrename")
#pragma fixedparams("dqreserveiomemory","dqseek","dqspecial")
#pragma fixedparams("dqswitchbuffer","dqtrapcc","dqtrapexception")
#pragma fixedparams("dqtruncate","dqwrite")

/* iRMX UDI structure usage:
 *
 * CONNSTATUSSTRUCT - dqgetconnectionstatus
 * DATETIMESTRUCT - dqdecodetime
 * FILEINFOSTRUCT - dqfileinfo
 * HANDLERPTRSTRUCT - dqgetexceptionhandler, dqtrapcc, dqtrapexception
 */

#pragma noalign (connstatusstruct)
typedef struct connstatusstruct {
     BYTE                   open;
     BYTE                   access;
     BYTE                   seek;
     DWORD                  fileptr;
} CONNSTATUSSTRUCT;

#pragma noalign (datetimestruct)
typedef struct datetimestruct {
     time_t                 systemtime;
     BYTE                   date[8];
     BYTE                   time[8];
} DATETIMESTRUCT;

#pragma noalign (fileinfostruct)
typedef struct fileinfostruct {
     BYTE                   owner[15];
     DWORD                  length;
     BYTE                   type;
     BYTE                   owneraccess;
     BYTE                   worldaccess;
     time_t                 creationtime;
     time_t                 modifytime;
     BYTE                   groupaccess;
     BYTE                   reserved[19];
} FILEINFOSTRUCT;

#pragma noalign (handlerptrstruct)
typedef struct handlerptrstruct {
     NATIVE_WORD            offset;
     SELECTOR               base;
} HANDLERPTRSTRUCT;

extern TOKEN    dqallocate(NATIVE_WORD,
                            WORD far *);

extern TOKEN    dqattach(STRING far *,
                            WORD far *);

extern void dqchangeaccess(STRING far *,
                            BYTE,
                            BYTE,
                            WORD far *);

extern void dqchangeextension(STRING far *,
                            STRING far *,
                            WORD far *);

extern void dqclose(TOKEN,
                            WORD far *);

extern TOKEN    dqcreate(STRING far *,
                            WORD far *);

extern void dqdecodeexception(WORD,
                            STRING far *,
                            WORD far *);

extern void dqdecodetime(DATETIMESTRUCT far *,
                            WORD far *);

extern void dqdelete(STRING far *,
                            WORD far *);

extern void dqdetach(TOKEN,
                            WORD far *);

extern void dqexit(WORD);

extern void dqfileinfo(TOKEN,
                            BYTE,
                            FILEINFOSTRUCT far *,
                            WORD far *);

extern void dqfree(TOKEN,
                            WORD far *);

extern BYTE dqgetargument(STRING far *,
                            WORD far *);

extern void dqgetconnectionstatus(TOKEN,
                            CONNSTATUSSTRUCT far *,
                            WORD far *);

extern void dqgetexceptionhandler(
                            HANDLERPTRSTRUCT far *,
                            WORD far *);

extern NATIVE_WORD dqgetsize(TOKEN,
                            WORD far *);

extern void dqgetsystemid(BYTE far * id,
                            WORD far *);

extern void dqgettime(BYTE far *,
                            WORD far *);

extern BYTE far *    dqmallocate(DWORD,
                            WORD far *);

extern void dqmfree(BYTE far *,
                            WORD far *);

extern DWORD    dqgetmsize(BYTE far *,
                            WORD far *);

extern void dqopen(TOKEN,
                            BYTE,
                            BYTE,
                            WORD far *);

#if _ARCHITECTURE_ < 386
#pragma fixedparams("dqoverlay")
extern void dqoverlay(STRING far *,
                            WORD far *);
#endif

extern NATIVE_WORD dqread(TOKEN,
                            BYTE far *,
                            NATIVE_WORD,
                            WORD far *);

extern void dqrename(STRING far *,
                            STRING far *,
                            WORD far *);

extern void dqreserveiomemory(WORD,
                            WORD,
                            WORD far *);

extern void dqseek(TOKEN,
                            BYTE,
                            DWORD,
                            WORD far *);

extern void dqspecial(BYTE,
                            void far *,
                            WORD far *);

extern WORD dqswitchbuffer(BYTE far *,
                            WORD far *);

extern void dqtrapcc(HANDLERPTRSTRUCT far *,
                            WORD far *);

extern void dqtrapexception(HANDLERPTRSTRUCT far *,
                            WORD far *);

extern void dqtruncate(TOKEN,
                            WORD far *);

extern void dqwrite(TOKEN,
                            BYTE far *,
                            NATIVE_WORD,
                            WORD far *);

#endif /* _udih */
