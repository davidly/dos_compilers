/*
 * cerror.h
 *
 * handles critical error interrupt under DOS and DOS16RM
 *
 * written by: G. Eric Engstrom
 */

#ifndef __CERROR_H
#define __CERROR_H	1

#if __cplusplus
extern "C"
  {
#endif
int _cdecl cerror_open(void);				/* installs critical error handler */
int _cdecl cerror_close(void);				/* de installs critical error handler */
int (_far _cdecl *_cerror_handler)(int *ax,int *di);	/* user supplied function goes here */
#if __cplusplus
  }
#endif

#endif
