/*_ msmouse.h   Sat Jun  3 1989   Modified by: Walter Bright */
/* Copyright (C) 1986-1991 by Walter Bright	*/
/* All Rights Reserved				*/
/* Written by Walter Bright			*/
/* Interface to Microsoft mouse driver		*/

#ifndef __MSMOUSE_H
#define __MSMOUSE_H 1

#if __cplusplus
extern "C" {
#endif

/* signal interrupt mask constants */
#define MSM_SIGNALMOVE 1
#define MSM_SIGNALBUTTONDOWNL 2
#define MSM_SIGNALBUTTONUPL 4
#define MSM_SIGNALBUTTONDOWNR 8
#define MSM_SIGNALBUTTONUPR 16
#define MSM_SIGNALBUTTONDOWNM 32
#define MSM_SIGNALBUTTONUPM 64

/* preferred button masks, replacements for LEFT_,RIGHT_, and MIDDLE_ */
#define MSM_BUTTONL 1
#define MSM_BUTTONR 2
#define MSM_BUTTONM 4

/* old style button masks, included for compatibility only */
#define LEFT_BUTTON	1
#define RIGHT_BUTTON	2
#define MIDDLE_BUTTON	0	/* so middle button is never turned on	*/

#ifndef _WINDOWS
/* Masks for mouse buttons	*/

int	_cdecl msm_init(void);
void	_cdecl msm_term(void);
void	_cdecl msm_showcursor(void);
void	_cdecl msm_hidecursor(void);
int	_cdecl msm_getstatus(unsigned *,unsigned *);
void	_cdecl msm_setcurpos(unsigned,unsigned);
int	_cdecl msm_getpress(unsigned *,unsigned *,unsigned *);
int	_cdecl msm_getrelease(unsigned *,unsigned *,unsigned *);
void	_cdecl msm_setareax(unsigned,unsigned);
void	_cdecl msm_setareay(unsigned,unsigned);
void	_cdecl msm_setgraphcur(int,int,int *);
void	_cdecl msm_settextcur(int,int,int);
void	_cdecl msm_readcounters(int *,int *);
void	_cdecl msm_signal(unsigned,
		void (_cdecl *)(unsigned,unsigned,unsigned,unsigned),void *);
void	_cdecl msm_lightpenon(void);
void	_cdecl msm_lightpenoff(void);
void	_cdecl msm_setratio(unsigned,unsigned);
void	_cdecl msm_condoff(unsigned,unsigned,unsigned,unsigned);
void	_cdecl msm_setthreshhold(unsigned);
void    _cdecl msm_reversebuttonon(void);       /* turns reversebutton feature on, can be nested */
void    _cdecl msm_reversebuttonoff(void);      /* turns reversebutton feature off, can be nested */
int     _cdecl msm_reversebuttonis(void);       /* returns the status of the reversebutton feature, >0 is on, <=0 is off */
int     _cdecl msm_reversebutton(int);          /* used inside mouse signal handlers to reverse buttons if required */
#else

#define MSM_SCROLLUP	120
#define MSM_SCROLLDOWN	121

#define msm_setcurpos(A,B)
#define msm_setareax(A,B)
#define msm_setareay(A,B)
#define msm_setgraphcur(A,B,C)
#define msm_settextcur(A,B,C)
#define msm_setratio(A,B)
#define msm_condoff(A,B,C,D)
#define msm_setthreshhold(A)
#define msm_lightpenon()
#define msm_lightpenoff()
#define msm_showcursor()	ShowCursor(1)
#define msm_hidecursor()	ShowCursor(0)
short		_cdecl msm_init(void);
void		_cdecl msm_term(void);
unsigned short	_cdecl msm_hwndget(void);		/* returns the window handle referenced by the last mouse event */
/* msm_messagemonitor is placed in the window message handling procedure
 * and converts windows mouse message into the msm format
 * this is only valid in Windows, and must be installed for the other
 * functions to work.
 */
unsigned short  _cdecl msm_messagemonitor(unsigned short,unsigned short,unsigned short,unsigned long,short,short);
unsigned short	_cdecl msm_getstatus(unsigned short *,unsigned short *);
void		_cdecl msm_readcounters(short *,short *);
short		_cdecl msm_getpress(unsigned short *,unsigned short *,unsigned short *);
short		_cdecl msm_getrelease(unsigned short *,unsigned short *,unsigned short *);
void		_cdecl msm_signal(unsigned short,
		void (_cdecl *)(unsigned short,unsigned short,short,short),void *);
void            _cdecl msm_reversebuttonon(void);       /* turns reversebutton feature on, can be nested */
void            _cdecl msm_reversebuttonoff(void);      /* turns reversebutton feature off, can be nested */
short           _cdecl msm_reversebuttonis(void);       /* returns the status of the reversebutton feature, >0 is on, <=0 is off */
short           _cdecl msm_reversebutton(short);        /* used inside mouse signal handlers to reverse buttons if required */
#endif

#if __cplusplus
}
#endif

#endif /* __MSMOUSE_H */

