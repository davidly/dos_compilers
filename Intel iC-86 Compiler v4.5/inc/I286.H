/* i286.h - 80286 processor specific header file
 * $Version: 1.11 $
 * Copyright 1988, 89, 90 Intel Corporation, ALL RIGHTS RESERVED.
 */

#if !defined(_I286_)
#define _I286_

#include <i186.h>

#define FLAG_IOPL		0x3000
#define FLAG_NESTED		0x4000

/*** For additional interrupt handling ***/
#pragma _builtin_("waitforinterrupt"==24)
void    waitforinterrupt(void);

/*** For manipulation of the Task Register ***/
#pragma _builtin_("gettaskregister"==25)
selector        gettaskregister(void);

#pragma _builtin_("settaskregister"==26)
void    settaskregister(selector value);

#if _LONG64_
typedef unsigned int base_addr;
#else
typedef unsigned long base_addr;
#endif

#pragma NOALIGN("descriptor_table_reg")
struct  descriptor_table_reg
{
        unsigned short  limit;  /* 16 bits of limit */
        base_addr base;         /* physical base address */
};

/*** For manipulation of the Global Descriptor Table ***/
#pragma _builtin_("saveglobaltable"==27)
void    saveglobaltable(struct descriptor_table_reg *location);

#pragma _builtin_("restoreglobaltable"==28)
void    restoreglobaltable(struct descriptor_table_reg const *location);

/*** For manipulation of the Interrupt Descriptor Table ***/
#pragma _builtin_("saveinterrupttable"==29)
void    saveinterrupttable(struct descriptor_table_reg *location);

#pragma _builtin_("restoreinterrupttable"==30)
void    restoreinterrupttable(struct descriptor_table_reg const *location);

/*** For the manipulation of the Local Descriptor Table Register ***/
#pragma _builtin_("getlocaltable"==31)
selector        getlocaltable(void);

#pragma _builtin_("setlocaltable"==32)
void    setlocaltable(selector sel);

/*** For the manipulation of the Machine Status Register ***/
#define MSW_PROTECTION_ENABLE   0x0001
#define MSW_MONITOR_COPROCESSOR 0x0002
#define MSW_EMULATE_COPROCESSOR 0x0004
#define MSW_TASK_SWITCHED       0x0008

#pragma _builtin_("getmachinestatus"==33)
unsigned short  getmachinestatus(void);

#pragma _builtin_("setmachinestatus"==34)
void    setmachinestatus(unsigned short value);

/*** For clearing task switched flag in machine status ***/
#pragma _builtin_("cleartaskswitchedflag"==35)
void    cleartaskswitchedflag(void);

/*** For segment information ***/
#define AR_PRESENT      0x8000
#define AR_PRIV_MASK    0x6000
#define AR_PRIV_SHIFT   13
#define AR_PRIVILEGE(x) (((x) & AR_PRIV_MASK) >> AR_PRIV_SHIFT)
#define AR_SEGMENT      0x1000

#define AR_EXECUTABLE   0x0800
#define AR_EXPAND_DOWN  0x0400
#define AR_WRITABLE     0x0200
#define AR_CONFORMING   0x0400
#define AR_READABLE     0x0200
#define AR_ACCESSED     0x0100

#define AR_386_TYPE     0x0800
#define AR_GATE         0x0400
#define AR_GATE_MASK    0x0300
#define AR_GATE_TYPE(x) ((x) & AR_GATE_MASK)
#define AR_CALL_GATE    0x0000
#define AR_TASK_GATE    0x0100
#define AR_INTR_GATE    0x0200
#define AR_TRAP_GATE    0x0300
#define AR_TSS          0x0100
#define AR_BUSY         0x0200

#pragma _builtin_("getaccessrights"==36)
unsigned int    getaccessrights(selector sel);

#pragma _builtin_("getsegmentlimit"==37)
unsigned int    getsegmentlimit(selector sel);

#pragma _builtin_("segmentreadable"==38)
int     segmentreadable(selector sel);

#pragma _builtin_("segmentwritable"==39)
int     segmentwritable(selector sel);

/*** For adjusting the requested privilege level ***/
#pragma _builtin_("adjustrpl"==40)
selector        adjustrpl(selector sel);

#endif
