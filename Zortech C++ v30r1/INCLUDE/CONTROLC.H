/*
 * controlc.h
 *
 * handles control C/Break under DOS and DOS16RM
 * and OS/2 and DOS386
 *
 * written by: G. Eric Engstrom
 */

#ifndef __CONTROLC_H
#define __CONTROLC_H	1

#if __cplusplus
extern "C"
  {
#endif
int _cdecl controlc_open(void);			/* installs controlC/Break handler */
int _cdecl controlc_close(void);		/* de installs controlC/Break handler */

void (_cdecl *_controlc_handler)(void);		/* user supplied function goes here */
#if __cplusplus
  }
#endif

#endif
