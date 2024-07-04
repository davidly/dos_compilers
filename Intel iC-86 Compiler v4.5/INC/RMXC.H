/*
 * rmxc.h - iRMX (reg. TM) System Call interface functions
 * $Version: 1.2 $
 * Copyright (C) 1989, 90 Intel Corporation, ALL RIGHTS RESERVED
 */

#ifndef _rmxch
#define _rmxch

#include <udi.h>
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
 * iRMX structure declarations
 */

#pragma noalign (accessstruct)
typedef struct accessstruct {
     BYTE                   access;
     BYTE                   reserved;
} ACCESSSTRUCT;

#pragma noalign (connectioninfostruct)
typedef struct connectioninfostruct {
     BYTE                   filedriver;
     BYTE                   flags;
     BYTE                   openmode;
     BYTE                   sharemode;
     DWORD                  fileptr;
     BYTE                   access;
     BYTE                   numberbuffers;
     WORD                   buffersize;
     BOOLEAN                seek;
} CONNECTIONINFOSTRUCT;

#ifndef _udih
#pragma noalign (datetimestruct)
typedef struct datetimestruct {
     time_t                 systemtime;
     BYTE                   date[8];
     BYTE                   time[8];
} DATETIMESTRUCT;
#endif

#pragma noalign (devinfostruct)
typedef struct devinfostruct {
     BYTE                   devicename[15];
     BYTE                   filedriver;
     WORD                   numconns;
     WORD                   ownerid;
} DEVINFOSTRUCT;

#pragma noalign (epoolattribstruct)
typedef struct epoolattribstruct {
     TOKEN                  targetjob;
     TOKEN                  parentjob;
     DWORD                  poolmax;
     DWORD                  poolmin;
     DWORD                  initialsize;
     DWORD                  allocated;
     DWORD                  available;
     DWORD                  borrowed;
} EPOOLATTRIBSTRUCT;

#pragma noalign (exceptionstruct)
typedef struct exceptionstruct {
     NATIVE_WORD            offset;
     SELECTOR               base;
     BYTE                   exceptionmode;
} EXCEPTIONSTRUCT;

#pragma noalign (extdatastruct)
typedef struct extdatastruct {
     BYTE                   count;
     BYTE                   info[2];    /* adjust # of info bytes! */
} EXTDATASTRUCT;

#pragma noalign (getportattribstruct)
typedef struct getportattribstruct {
     WORD                   portid;
     BYTE                   type;
     BYTE                   reserveda;
     WORD                   numtrans;
     WORD                   reserved[2];
     TOKEN                  sinkport;
     DWORD                  defaultremotesocket;
     TOKEN                  bufferpool;
     WORD                   flags;
     BYTE                   reservedb;
} GETPORTATTRIBSTRUCT;

#ifndef _udih
#pragma noalign (handlerptrstruct)
typedef struct handlerptrstruct {
     NATIVE_WORD            offset;
     SELECTOR               base;
} HANDLERPTRSTRUCT;
#endif

#pragma noalign (idsstruct)
typedef struct idsstruct {
     WORD                   length;
     WORD                   count;
     WORD                   ids[2]; /* adjust # of ids words! */
} IDSSTRUCT;

#pragma noalign (iorsstruct)
typedef struct iorsstruct {
     NATIVE_WORD            actual;
#if _ARCHITECTURE_ < 386
     WORD                   actualfill;
#endif
     WORD                   device;
     BYTE                   unit;
     BYTE                   funct;
     WORD                   subfunct;
     DWORD                  deviceloc;
     BYTE far *             buff;
     NATIVE_WORD            count;
#if _ARCHITECTURE_ < 386
     WORD                   countfill;
#endif
     void far *             aux;
} IORSSTRUCT;

#pragma noalign (offspringstruct)
typedef struct offspringstruct {
     WORD                   maxnum;
     WORD                   actual;
     TOKEN                  children[2];    /* adjust # of children! */
} OFFSPRINGSTRUCT;

#pragma noalign (plmstringstruct)
typedef struct plmstringstruct {
     BYTE                   count;
     BYTE                   string[2];  /* adjust # of BYTEs in string! */
} PLMSTRINGSTRUCT;

#pragma noalign (poolattribstruct)
typedef struct poolattribstruct {
     DWORD                  poolmax;
     DWORD                  poolmin;
     DWORD                  initialsize;
     DWORD                  allocated;
     DWORD                  available;
} POOLATTRIBSTRUCT;

#pragma noalign (receiveinfostruct)
typedef struct receiveinfostruct {
     WORD                   flags;
     WORD                   status;
     WORD                   transid;
     DWORD                  datalength;
     TOKEN                  forwardingport;
     DWORD                  remotesocket;
     BYTE                   controlmsg[20];
     BYTE                   reserved[4];
} RECEIVEINFOSTRUCT;

#pragma noalign (replyinfostruct)
typedef struct replyinfostruct {
     WORD                   flags;
     WORD                   status;
     WORD                   transid;
     DWORD                  datalength;
     TOKEN                  forwardingport;
     DWORD                  remotesocket;
     BYTE                   controlmsg[20];
     BYTE                   reserved;
} REPLYINFOSTRUCT;

#pragma noalign (settimestruct)
typedef struct settimestruct {
     BYTE                   seconds;
     BYTE                   minutes;
     BYTE                   hours;
     BYTE                   days;
     BYTE                   months;
     WORD                   years;
} SETTIMESTRUCT;

#pragma noalign (sfilestatusstruct)
typedef struct sfilestatusstruct {
     WORD                   deviceshare;
     WORD                   numberconnections;
     WORD                   numberreaders;
     WORD                   numberwriters;
     BYTE                   share;
     BYTE                   namedfile;
     BYTE                   devicename[14];
     WORD                   filedrivers;
     BYTE                   functions;
     BYTE                   flags;
     WORD                   devicegranularity;
     DWORD                  devicesize;
     WORD                   deviceconnections;
     WORD                   fileid;
     BYTE                   filetype;
     BYTE                   filegranularity;
     WORD                   ownerid;
     time_t                 creationtime;
     time_t                 accesstime;
     time_t                 modifytime;
     DWORD                  filesize;
     DWORD                  fileblocks;
     BYTE                   volumename[6];
     WORD                   volumegranularity;
     DWORD                  volumesize;
     WORD                   accessorcount;
     BYTE                   owneraccess;
} SFILESTATUSSTRUCT;

#pragma noalign (stringtablestruct)
typedef struct stringtablestruct {
     BYTE                   numentry;
     PLMSTRINGSTRUCT		strings[2];
} STRINGTABLESTRUCT;

#pragma noalign (tokenliststruct)
typedef struct tokenliststruct {
     WORD                   numslots;
     WORD                   numused;
     TOKEN                  tokens[2];  /* adjust # of tokens! */
} TOKENLISTSTRUCT;

/* -------------------------------------------------------------------- */

/*
 * iRMX asynchronous structure declarations
 */

#pragma noalign (termattribstruct)
typedef struct termattribstruct {
     WORD                   numwords;
     WORD                   numused;
     WORD                   connectionflags;
     WORD                   terminalflags;
     NATIVE_WORD            inbaudrate;
     NATIVE_WORD            outbaudrate;
     WORD                   scrolllines;
     BYTE                   pagewidth;
     BYTE                   pagelength;
     BYTE                   cursoroffset;
     BYTE                   overflowoffset;
     WORD                   specialmodes;
     WORD                   highwatermark;
     WORD                   lowwatermark;
     WORD                   fconchar;
     WORD                   fcoffchar;
     WORD                   linkparameter;
     WORD                   spchiwatermark;
     BYTE                   specialchar[4];
} TERMATTRIBSTRUCT;     

/* -------------------------------------------------------------------- */

/*
 * iRMX utility functions
 */

#pragma fixedparams("_get_rmx_conn", "_put_rmx_conn")

extern TOKEN _get_rmx_conn (int fd);
extern int _put_rmx_conn (TOKEN connection);

/* -------------------------------------------------------------------- */

/*
 * iRMX Nucleus interface functions
 */

#pragma fixedparams("rqcreatejob","rqecreatejob","rqdeletejob")
#pragma fixedparams("rqoffspring","rqeoffspring","rqcreatetask")
#pragma fixedparams("rqdeletetask","rqgetpriority","rqgettasktokens")
#pragma fixedparams("rqresumetask","rqsetpriority","rqsleep")
#pragma fixedparams("rqsuspendtask","rqcreatemailbox","rqdeletemailbox")
#pragma fixedparams("rqreceivedata","rqreceivemessage","rqsenddata")
#pragma fixedparams("rqsendmessage","rqcreatesemaphore","rqdeletesemaphore")
#pragma fixedparams("rqreceiveunits","rqsendunits","rqcreatesegment")
#pragma fixedparams("rqdeletesegment","rqgetpoolattrib","rqegetpoolattrib")
#pragma fixedparams("rqgetsize","rqsetpoolmin","rqcreatebufferpool")
#pragma fixedparams("rqdeletebufferpool","rqreleasebuffer","rqrequestbuffer")
#pragma fixedparams("rqechangedescriptor","rqecreatedescriptor")
#pragma fixedparams("rqedeletedescriptor","rqcatalogobject")
#pragma fixedparams("rqechangeobjectaccess","rqegetaddress")
#pragma fixedparams("rqegetobjectaccess","rqgettype","rqlookupobject")
#pragma fixedparams("rquncatalogobject","rqgetexceptionhandler")
#pragma fixedparams("rqsetexceptionhandler","rqdisable","rqenable")
#pragma fixedparams("rqendinittask","rqenterinterrupt","rqexitinterrupt")
#pragma fixedparams("rqgetlevel","rqresetinterrupt","rqsetinterrupt")
#pragma fixedparams("rqsignalinterrupt","rqetimedinterrupt")
#pragma fixedparams("rqwaitinterrupt","rqaltercomposite","rqcreatecomposite")
#pragma fixedparams("rqdeletecomposite","rqinspectcomposite")
#pragma fixedparams("rqcreateextension","rqdeleteextension")
#pragma fixedparams("rqdisabledeletion","rqenabledeletion","rqforcedelete")
#pragma fixedparams("rqesetosextension","rqsignalexception","rqacceptcontrol")
#pragma fixedparams("rqcreateregion","rqdeleteregion","rqreceivecontrol")
#pragma fixedparams("rqsendcontrol","rqattachbufferpool","rqattachport")
#pragma fixedparams("rqbroadcast","rqcancel","rqconnect","rqcreateport")
#pragma fixedparams("rqdeleteport","rqdetachbufferpool","rqdetachport")
#pragma fixedparams("rqgethostid","rqgetportattributes","rqreceive")
#pragma fixedparams("rqreceivefragment","rqreceivereply","rqreceivesignal")
#pragma fixedparams("rqsend","rqsendrsvp","rqsendreply","rqsendsignal")
#pragma fixedparams("rqgetinterconnect","rqsetinterconnect")

/* iRMX Nucleus structure usage:
 *
 * ACCESSSTRUCT - rqegetobjectaccess
 * EPOOLATTRIBSTRUCT - rqegetpoolattrib
 * EXCEPTIONSTRUCT - rqcreatejob, rqecreatejob, rqgetexceptionhandler,
 *                   rqsetexceptionhandler
 * GETPORTATTRIBSTRUCT - rqgetportattributes
 * OFFSPRINGSTRUCT - rqeoffspring
 * POOLATTRIBSTRUCT - rqgetpoolattrib
 * RECEIVEINFOSTRUCT - rqreceive
 * REPLYINFOSTRUCT - rqreceivereply
 * TOKENLISTSTRUCT - rqcreatecomposite, rqinspectcomposite
 *
 */

extern TOKEN    rqcreatejob(WORD,
                            TOKEN,
                            NATIVE_WORD,
                            NATIVE_WORD,
                            WORD,
                            WORD,
                            BYTE,
                            EXCEPTIONSTRUCT far *,
                            WORD,
                            BYTE,
                            void (far *)(void),
                            TOKEN,
                            WORD far *,
                            NATIVE_WORD,
                            WORD,
                            WORD far *);

extern TOKEN    rqecreatejob(WORD,
                            TOKEN,
                            DWORD,
                            DWORD,
                            WORD,
                            WORD,
                            BYTE,
                            EXCEPTIONSTRUCT far *,
                            WORD,
                            BYTE,
                            void (far *)(void),
                            TOKEN,
                            WORD far *,
                            NATIVE_WORD,
                            WORD,
                            WORD far *);

extern void rqdeletejob(TOKEN,
                            WORD far *);

extern TOKEN    rqoffspring(TOKEN,
                            WORD far *);

extern void rqeoffspring(TOKEN,
                            OFFSPRINGSTRUCT far *,
                            WORD far *);

extern TOKEN    rqcreatetask(BYTE,
                            void (far *)(void),
                            TOKEN,
                            WORD far *,
                            NATIVE_WORD,
                            WORD,
                            WORD far *);

extern void rqdeletetask(TOKEN,
                            WORD far *);

extern BYTE rqgetpriority(TOKEN,
                            WORD far *);

extern TOKEN    rqgettasktokens(BYTE,
                            WORD far *);

extern void rqresumetask(TOKEN,
                            WORD far *);

extern void rqsetpriority(TOKEN,
                            BYTE,
                            WORD far *);

extern void rqsleep(WORD,
                            WORD far *);

extern void rqsuspendtask(TOKEN,
                            WORD far *);

extern TOKEN    rqcreatemailbox(WORD,
                            WORD far *);

extern void rqdeletemailbox(TOKEN,
                            WORD far *);

extern WORD rqreceivedata(TOKEN,
                            STRING far *,
                            WORD,
                            WORD far *);

extern TOKEN    rqreceivemessage(TOKEN,
                            WORD,
                            TOKEN far *,
                            WORD far *);

extern void rqsenddata(TOKEN,
                            STRING far *,
                            WORD,
                            WORD far *);

extern void rqsendmessage(TOKEN,
                            TOKEN,
                            TOKEN,
                            WORD far *);

extern TOKEN    rqcreatesemaphore(WORD,
                            WORD,
                            WORD,
                            WORD far *);

extern void rqdeletesemaphore(TOKEN,
                            WORD far *);

extern WORD rqreceiveunits(TOKEN,
                            WORD,
                            WORD,
                            WORD far *);

extern void rqsendunits(TOKEN,
                            WORD,
                            WORD far *);

extern TOKEN    rqcreatesegment(NATIVE_WORD,
                            WORD far *);

extern void rqdeletesegment(TOKEN,
                            WORD far *);

extern void rqgetpoolattrib(POOLATTRIBSTRUCT far *,
                            WORD far *);

extern void rqegetpoolattrib(EPOOLATTRIBSTRUCT far *,
                            WORD far *);

extern NATIVE_WORD rqgetsize(TOKEN,
                            WORD far *);

extern void rqsetpoolmin(WORD,
                            WORD far *);

extern TOKEN    rqcreatebufferpool(WORD,
                            WORD,
                            WORD far *);

extern void rqdeletebufferpool(TOKEN,
                            WORD far *);

extern void rqreleasebuffer(TOKEN,
                            TOKEN,
                            WORD,
                            WORD far *);

extern TOKEN    rqrequestbuffer(TOKEN,
                            DWORD,
                            WORD far *);

extern void rqechangedescriptor(TOKEN,
                            DWORD,
                            WORD,
                            WORD far *);

extern TOKEN    rqecreatedescriptor(DWORD,
                            WORD,
                            WORD far *);

extern void rqedeletedescriptor(TOKEN,
                            WORD far *);

extern void rqcatalogobject(TOKEN,
                            TOKEN,
                            STRING far *,
                            WORD far *);

extern void rqechangeobjectaccess(TOKEN,
                            BYTE,
                            BYTE,
                            WORD far *);

extern DWORD    rqegetaddress(void far *,
                            WORD far *);

extern void rqegetobjectaccess(TOKEN,
                            ACCESSSTRUCT far *,
                            WORD far *);

extern WORD rqgettype(TOKEN,
                            WORD far *);

extern TOKEN    rqlookupobject(TOKEN,
                            STRING far *,
                            WORD,
                            WORD far *);

extern void rquncatalogobject(TOKEN,
                            STRING far *,
                            WORD far *);

extern void rqgetexceptionhandler(EXCEPTIONSTRUCT far *,
                            WORD far *);

extern void rqsetexceptionhandler(EXCEPTIONSTRUCT far *,
                            WORD far *);

extern void rqdisable(WORD,
                            WORD far *);

extern void rqenable(WORD,
                            WORD far *);

extern void rqendinittask(void);

extern void rqenterinterrupt(WORD,
                            WORD far *);

extern void rqexitinterrupt(WORD,
                            WORD far *);

extern WORD rqgetlevel(WORD far *);

extern void rqresetinterrupt(WORD,
                            WORD far *);

extern void rqsetinterrupt(WORD,
                            BYTE,
                            void (far *)(void),
                            TOKEN,
                            WORD far *);

extern void rqsignalinterrupt(WORD,
                            WORD far *);

extern void rqetimedinterrupt(WORD,
                            WORD,
                            WORD far *);

extern void rqwaitinterrupt(WORD,
                            WORD far *);

extern void rqaltercomposite(TOKEN,
                            TOKEN,
                            WORD,
                            TOKEN,
                            WORD far *);

extern TOKEN    rqcreatecomposite(TOKEN,
                            TOKENLISTSTRUCT far *,
                            WORD far *);

extern void rqdeletecomposite(TOKEN,
                            TOKEN,
                            WORD far *);

extern void rqinspectcomposite(TOKEN,
                            TOKEN,
                            TOKENLISTSTRUCT far *,
                            WORD far *);

extern TOKEN    rqcreateextension(WORD,
                            TOKEN,
                            WORD far *);

extern void rqdeleteextension(TOKEN,
                            WORD far *);

extern void rqdisabledeletion(TOKEN,
                            WORD far *);

extern void rqenabledeletion(TOKEN,
                            WORD far *);

extern void rqforcedelete(TOKEN,
                            TOKEN,
                            WORD far *);

extern void rqesetosextension(WORD,
                            void (far *)(void),
                            WORD far *);

extern void rqsignalexception(WORD,
                            BYTE,
                            WORD,
                            WORD,
                            WORD,
                            WORD far *);

extern void rqacceptcontrol(TOKEN,
                            WORD far *);

extern TOKEN    rqcreateregion(WORD,
                            WORD far *);

extern void rqdeleteregion(TOKEN,
                            WORD far *);

extern void rqreceivecontrol(TOKEN,
                            WORD far *);

extern void rqsendcontrol(WORD far *);


extern void rqattachbufferpool(TOKEN,
                            TOKEN,
                            WORD far *);

extern void rqattachport(TOKEN,
                            TOKEN,
                            WORD far *);

extern void rqbroadcast(TOKEN,
                            DWORD,
                            BYTE far *,
                            WORD far *);

extern void rqcancel(TOKEN,
                            WORD,
                            WORD far *);

extern void rqconnect(TOKEN,
                            DWORD,
                            WORD far *);

extern TOKEN    rqcreateport(WORD,
                            void far *,
                            WORD far *);

extern void rqdeleteport(TOKEN,
                            WORD far *);

extern TOKEN    rqdetachbufferpool(TOKEN,
                            WORD far *);

extern void rqdetachport(TOKEN,
                            WORD far *);

extern WORD rqgethostid(WORD far *);


extern void rqgetportattributes(TOKEN,
                            GETPORTATTRIBSTRUCT far *,
                            WORD far *);

extern BYTE far *   rqreceive(TOKEN port,
                            WORD,
                            RECEIVEINFOSTRUCT far *,
                            WORD far *);

extern void rqreceivefragment(TOKEN,
                            DWORD,
                            WORD,
                            BYTE far *,
                            DWORD,
                            WORD,
                            WORD far *);

extern BYTE far *   rqreceivereply(TOKEN,
                            WORD,
                            WORD,
                            REPLYINFOSTRUCT far *,
                            WORD far *);

extern void rqreceivesignal(TOKEN,
                            WORD,
                            WORD far *);

extern WORD rqsend(TOKEN,
                            DWORD,
                            BYTE far *,
                            BYTE far *,
                            DWORD,
                            WORD,
                            WORD far *);

extern WORD rqsendrsvp(TOKEN,
                            DWORD,
                            BYTE far *,
                            BYTE far *,
                            DWORD,
                            BYTE far *,
                            DWORD,
                            WORD,
                            WORD far *);

extern WORD rqsendreply(TOKEN,
                            DWORD,
                            WORD,
                            BYTE far *,
                            BYTE far *,
                            DWORD,
                            WORD,
                            WORD far *);

extern void rqsendsignal(TOKEN,
                            WORD far *);

extern BYTE rqgetinterconnect(BYTE,
                            WORD,
                            WORD far *);

extern void rqsetinterconnect(BYTE,
                            BYTE,
                            WORD,
                            WORD far *);

/* -------------------------------------------------------------------- */

/*
 * iRMX BIOS interface functions
 */

#pragma fixedparams("rqaattachfile","rqachangeaccess","rqaclose")
#pragma fixedparams("rqacreatedirectory","rqacreatefile")
#pragma fixedparams("rqadeleteconnection","rqadeletefile")
#pragma fixedparams("rqagetconnectionstatus","rqagetdirectoryentry")
#pragma fixedparams("rqagetextensiondata","rqagetfilestatus")
#pragma fixedparams("rqagetpathcomponent","rqaopen","rqaphysicalattachdevice")
#pragma fixedparams("rqaphysicaldetachdevice","rqaread","rqarenamefile")
#pragma fixedparams("rqaseek","rqasetextensiondata","rqaspecial")
#pragma fixedparams("rqatruncate","rqaupdate","rqawrite","rqcreateuser")
#pragma fixedparams("rqdeleteuser","rqencrypt","rqgetdefaultprefix")
#pragma fixedparams("rqgetdefaultuser","rqgetglobaltime","rqgettime")
#pragma fixedparams("rqinspectuser","rqsetdefaultprefix","rqsetdefaultuser")
#pragma fixedparams("rqsetglobaltime","rqsettime","rqwaitio")

/* iRMX BIOS structure usage:
 *
 * EXTDATASTRUCT - rqasetextensiondata
 * IDSSTRUCT - rqcreateuser, rqinspectuser
 * SETTIMESTRUCT - rqgetglobaltime, rqsetglobaltime
 */

extern void rqaattachfile(TOKEN,
                            TOKEN,
                            STRING far *,
                            TOKEN,
                            WORD far *);

extern void rqachangeaccess(TOKEN,
                            TOKEN,
                            STRING far *,
                            WORD,
                            BYTE,
                            TOKEN,
                            WORD far *);

extern void rqaclose(TOKEN,
                            TOKEN,
                            WORD far *);

extern void rqacreatedirectory(TOKEN,
                            TOKEN,
                            STRING far *,
                            BYTE,
                            TOKEN,
                            WORD far *);

extern void rqacreatefile(TOKEN,
                            TOKEN,
                            STRING far *,
                            BYTE,
                            WORD,
                            DWORD,
                            BYTE,
                            TOKEN,
                            WORD far *);

extern void rqadeleteconnection(TOKEN,
                            TOKEN,
                            WORD far *);

extern void rqadeletefile(TOKEN,
                            TOKEN,
                            STRING far *,
                            TOKEN,
                            WORD far *);

extern void rqagetconnectionstatus(TOKEN,
                            TOKEN,
                            WORD far *);

extern void rqagetdirectoryentry(TOKEN,
                            WORD,
                            TOKEN,
                            WORD far *);

extern void rqagetextensiondata(TOKEN,
                            TOKEN,
                            WORD far *);

extern void rqagetfilestatus(TOKEN,
                            TOKEN,
                            WORD far *);

extern void rqagetpathcomponent(TOKEN,
                            TOKEN,
                            WORD far *);

extern void rqaopen(TOKEN,
                            BYTE,
                            BYTE,
                            TOKEN,
                            WORD far *);

extern void rqaphysicalattachdevice(STRING far *,
                            BYTE,
                            TOKEN,
                            WORD far *);

extern void rqaphysicaldetachdevice(TOKEN,
                            BYTE,
                            TOKEN,
                            WORD far *);

extern void rqaread(TOKEN,
                            BYTE far *,
                            NATIVE_WORD,
                            TOKEN,
                            WORD far *);

extern void rqarenamefile(TOKEN,
                            TOKEN,
                            TOKEN,
                            STRING far *,
                            TOKEN,
                            WORD far *);

extern void rqaseek(TOKEN,
                            BYTE,
                            DWORD,
                            TOKEN,
                            WORD far *);

extern void rqasetextensiondata(TOKEN,
                            EXTDATASTRUCT far *,
                            TOKEN,
                            WORD far *);

extern void rqaspecial(TOKEN,
                            WORD,
                            void far *,
                            TOKEN,
                            WORD far *);

extern void rqatruncate(TOKEN,
                            TOKEN,
                            WORD far *);

extern void rqaupdate(TOKEN,
                            TOKEN,
                            WORD far *);

extern void rqawrite(TOKEN,
                            BYTE far *,
                            NATIVE_WORD,
                            TOKEN,
                            WORD far *);

extern TOKEN    rqcreateuser(IDSSTRUCT far *,
                            WORD far *);

extern void rqdeleteuser(TOKEN,
                            WORD far *);

extern void rqencrypt(STRING far *,
                            STRING far *,
                            STRING far *,
                            WORD far *);

extern TOKEN    rqgetdefaultprefix(TOKEN,
                            WORD far *);

extern TOKEN    rqgetdefaultuser(TOKEN,
                            WORD far *);

extern void rqgetglobaltime(SETTIMESTRUCT far *,
                            WORD far *);

extern time_t   rqgettime(WORD far *);

extern void rqinspectuser(TOKEN,
                            IDSSTRUCT far *,
                            WORD far *);

extern void rqsetdefaultprefix(TOKEN,
                            TOKEN,
                            WORD far *);

extern void rqsetdefaultuser(TOKEN,
                            TOKEN,
                            WORD far *);

extern void rqsetglobaltime(SETTIMESTRUCT far *,
                            WORD far *);

extern void rqsettime(time_t datetime,
                            WORD far *);

extern NATIVE_WORD rqwaitio(TOKEN,
                            TOKEN,
                            WORD,
                            WORD far *);

/* -------------------------------------------------------------------- */

/*
 * iRMX EIOS interface functions
 */

#pragma fixedparams("rqcreateiojob","rqecreateiojob","rqexitiojob")
#pragma fixedparams("rqgetlogicaldevicestatus","rqgetuserids")
#pragma fixedparams("rqhybriddetachdevice","rqlogicalattachdevice")
#pragma fixedparams("rqlogicaldetachdevice","rqstartiojob","rqsattachfile")
#pragma fixedparams("rqscatalogconnection","rqschangeaccess","rqsclose")
#pragma fixedparams("rqscreatedirectory","rqscreatefile")
#pragma fixedparams("rqsdeleteconnection","rqsdeletefile")
#pragma fixedparams("rqsgetconnectionstatus","rqsgetdirectoryentry")
#pragma fixedparams("rqsgetfilestatus","rqsgetpathcomponent")
#pragma fixedparams("rqslookupconnection","rqsopen","rqsreadmove")
#pragma fixedparams("rqsrenamefile","rqsseek","rqsspecial","rqstruncatefile")
#pragma fixedparams("rqsuncatalogconnection","rqswritemove","rqverifyuser")

/* iRMX EIOS structure usage:
 *
 * CONNECTIONINFOSTRUCT - rqsgetconnectionstatus
 * DEVINFOSTRUCT - rqgetlogicaldevicestatus
 * HANDLERPTRSTRUCT - (used by EXCEPTIONSTRUCT)
 * EXCEPTIONSTRUCT - rqcreateiojob, rqecreateiojob
 * IDSSTRUCT - rqgetuserids
 * IORSSTRUCT - rqsspecial
 * SFILESTATUSSTRUCT - rqsgetfilestatus
 */

extern TOKEN    rqcreateiojob(NATIVE_WORD,
                            NATIVE_WORD,
                            EXCEPTIONSTRUCT far *,
                            WORD,
                            BYTE,
                            void (far *)(void),
                            TOKEN,
                            WORD far *,
                            NATIVE_WORD,
                            WORD,
                            TOKEN,
                            WORD far *);

extern TOKEN    rqecreateiojob(DWORD,
                            DWORD,
                            EXCEPTIONSTRUCT far *,
                            WORD,
                            BYTE,
                            void (far *)(void),
                            TOKEN,
                            WORD far *,
                            NATIVE_WORD,
                            WORD,
                            TOKEN,
                            WORD far *);

extern void rqexitiojob(WORD,
                            STRING far *,
                            WORD far *);

extern void rqgetlogicaldevicestatus(STRING far *,
                            DEVINFOSTRUCT far *,
                            WORD far *);

extern void rqgetuserids(STRING far *,
                            IDSSTRUCT far *,
                            WORD far *);

extern void rqhybriddetachdevice(STRING far *,
                            WORD far *);

extern void rqlogicalattachdevice(STRING far *,
                            STRING far *,
                            BYTE,
                            WORD far *);

extern void rqlogicaldetachdevice(STRING far *,
                            WORD far *);

extern void rqstartiojob(TOKEN,
                            WORD far *);

extern TOKEN    rqsattachfile(STRING far *,
                            WORD far *);

extern void rqscatalogconnection(TOKEN,
                            TOKEN,
                            STRING far *,
                            WORD far *);

extern void rqschangeaccess(STRING far *,
                            WORD,
                            BYTE,
                            WORD far *);

extern void rqsclose(TOKEN,
                            WORD far *);

extern TOKEN    rqscreatedirectory(STRING far *,
                            WORD far *);

extern TOKEN    rqscreatefile(STRING far *,
                            WORD far *);

extern void rqsdeleteconnection(TOKEN,
                            WORD far *);

extern void rqsdeletefile(STRING far *,
                            WORD far *);

extern void rqsgetconnectionstatus(TOKEN,
                            CONNECTIONINFOSTRUCT far *,
                            WORD far *);

extern void rqsgetdirectoryentry(STRING far *,
                            WORD,
                            STRING far *,
                            WORD far *);

extern void rqsgetfilestatus(STRING far *,
                            SFILESTATUSSTRUCT far *,
                            WORD far *);

extern void rqsgetpathcomponent(TOKEN,
                            STRING far *,
                            WORD far *);

extern TOKEN    rqslookupconnection(STRING far *,
                            WORD far *);

extern void rqsopen(TOKEN,
                            BYTE,
                            BYTE,
                            WORD far *);

extern NATIVE_WORD rqsreadmove(TOKEN,
                            BYTE far *,
                            NATIVE_WORD,
                            WORD far *);


extern void rqsrenamefile(STRING far *,
                            STRING far *,
                            WORD far *);

extern void rqsseek(TOKEN,
                            BYTE,
                            DWORD,
                            WORD far *);

extern void rqsspecial(TOKEN,
                            WORD,
                            void far *,
                            IORSSTRUCT far *,
                            WORD far *);

extern void rqstruncatefile(TOKEN,
                            WORD far *);

extern void rqsuncatalogconnection(TOKEN,
                            STRING far *,
                            WORD far *);

extern NATIVE_WORD rqswritemove(TOKEN,
                            BYTE far *,
                            NATIVE_WORD,
                            WORD far *);

extern void rqverifyuser(TOKEN,
                            STRING far *,
                            STRING far *,
                            WORD far *);

/* -------------------------------------------------------------------- */

/*
 * iRMX Application Loader interface functions
 */

#pragma fixedparams("rqaload","rqaloadiojob","rqealoadiojob")
#pragma fixedparams("rqesloadiojob","rqsloadiojob","rqsoverlay")

/* iRMX Application Loader structure usage:
 *
 * HANDLERPTRSTRUCT - (used by EXCEPTIONSTRUCT)
 * EXCEPTIONSTRUCT - rqaloadiojob, rqealoadiojob, rqesloadiojob,
 *                   rqsloadiojob
 */

extern void rqaload(TOKEN,
                            TOKEN,
                            WORD far *);

extern TOKEN    rqaloadiojob(TOKEN,
                            NATIVE_WORD,
                            NATIVE_WORD,
                            EXCEPTIONSTRUCT far *,
                            WORD,
                            BYTE,
                            WORD,
                            TOKEN,
                            WORD far *);

extern TOKEN    rqealoadiojob(TOKEN,
                            DWORD,
                            DWORD,
                            EXCEPTIONSTRUCT far *,
                            WORD,
                            BYTE,
                            WORD,
                            TOKEN,
                            WORD far *);

extern TOKEN    rqesloadiojob(STRING far *,
                            DWORD,
                            DWORD,
                            EXCEPTIONSTRUCT far *,
                            WORD,
                            BYTE,
                            WORD,
                            TOKEN,
                            WORD far *);

extern TOKEN    rqsloadiojob(STRING far *,
                            NATIVE_WORD,
                            NATIVE_WORD,
                            EXCEPTIONSTRUCT far *,
                            WORD,
                            BYTE,
                            WORD,
                            TOKEN,
                            WORD far *);

extern void rqsoverlay(STRING far *,
                            WORD far *);

/* -------------------------------------------------------------------- */

/*
 * iRMX Human Interface interface functions
 */

#pragma fixedparams("rqcbackupchar","rqccreatecommandconnection")
#pragma fixedparams("rqcdeletecommandconnection","rqcformatexception")
#pragma fixedparams("rqcgetchar","rqcgetcommandname","rqcgetinputconnection")
#pragma fixedparams("rqcgetinputpathname","rqcgetinputpathnamenowc")
#pragma fixedparams("rqcgetoutputconnection","rqcgetoutputpathname")
#pragma fixedparams("rqcgetparameter","rqcsendcommand","rqcsendcoresponse")
#pragma fixedparams("rqcsendeoresponse","rqcsetcontrolc","rqcsetparsebuffer")

/* iRMX Human Interface structure usage:
 *
 * PLMSTRINGSTRUCT - (used by STRINGTABLESTRUCT)
 * STRINGTABLESTRUCT - rqcgetparameter
 */

extern void rqcbackupchar(WORD far *);


extern TOKEN    rqccreatecommandconnection(TOKEN,
                            TOKEN,
                            WORD,
                            WORD far *);

extern void rqcdeletecommandconnection(TOKEN,
                            WORD far *);

extern void rqcformatexception(STRING far *,
                            WORD,
                            WORD,
                            BYTE,
                            WORD far *);

extern STRING rqcgetchar(WORD far *);

extern void rqcgetcommandname(STRING far *,
                            WORD,
                            WORD far *);

extern TOKEN    rqcgetinputconnection(STRING far *,
                            WORD far *);

extern void rqcgetinputpathname(STRING far *,
                            WORD,
                            WORD far *);

extern void rqcgetinputpathnamenowc(STRING far *,
                            WORD,
                            WORD far *);

extern TOKEN    rqcgetoutputconnection(STRING far *,
                            BYTE,
                            WORD far *);

extern BYTE rqcgetoutputpathname(STRING far *,
                            WORD,
                            STRING far *,
                            WORD far *);

extern BYTE rqcgetparameter(STRING far *,
                            WORD,
                            STRINGTABLESTRUCT far *,
                            WORD,
                            BYTE far *,
                            STRINGTABLESTRUCT far *,
                            WORD far *);

extern void rqcsendcommand(TOKEN,
                            STRING far *,
                            WORD far *,
                            WORD far *);

extern void rqcsendcoresponse(STRING far *,
                            WORD,
                            STRING far *,
                            WORD far *);

extern void rqcsendeoresponse(STRING far *,
                            WORD,
                            STRING far *,
                            WORD far *);

extern void rqcsetcontrolc(TOKEN,
                            WORD far *);

extern WORD rqcsetparsebuffer(STRING far *,
                            WORD,
                            WORD far *);

#endif  /* rmxch */
