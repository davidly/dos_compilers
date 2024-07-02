/*_ host.h   Fri Oct 14 1988   Modified by: bright */
/* $Header: /proj/products/merlin/port/RCS/host.h,v 1.13 89/05/19 16:00:21 bright Exp $ */
/* Variations between host machines are defined here.		*/
/* This file attempts to identify which compiler is running	*/
/* in order to select the correct #include file for it.		*/

#ifndef HOST_H
#define HOST_H

/* Select one of the following:	*/

#if __ZTC__
#ifdef __DATE__
#include	"ztc.h"		/* IBM AT, MS-DOS, Zortech C		*/
#else
#include	"dlc.h"		/* IBM AT, MS-DOS, Datalight C		*/
#endif
#else
#if DLC
#include	"dlc.h"		/* IBM AT, MS-DOS, Datalight C		*/
#else
#if M_I86
#include	"msc.h"		/* IBM AT, MS-DOS, Microsoft C 5.0	*/
#endif
#endif
#endif

#if __TURBOC__			/* IBM AT, MS-DOS, Turbo C		*/
#include	"turboc.h"
#endif

#if unix
#if m68k
#include	"macaux.h"	/* Mac running A/UX			*/
#else
#if mc68000
#include	"sun.h"		/* Sun running BSD Unix			*/
#else
#if sun386
#include        "sun386.h"	/* 386 running Sun-Os                   */
#else
#if sparc
#include        "sunsparc.h"	/* Sun-4 with sparc CPU			*/
#else
#include	"vaxbsd.h"	/* Vax running BSD Unix			*/
#endif /* sparc */
#endif /* sun386 */
#endif /* mc68000 */
#endif /* m68k */
#endif /* unix */

#if vms
#include        "vaxvms.h"      /* Vax running VMS 4.4                  */
#endif

#if _daisy
#include 	"mwc.h"		/* Mark William C86			*/
#endif

#ifdef hc386
#include        "highc.h"      /* IBM PC - MSDOS - highc 386 */
#endif

#ifndef HOST
	error! error! error!
#endif

#endif /* HOST_H */

