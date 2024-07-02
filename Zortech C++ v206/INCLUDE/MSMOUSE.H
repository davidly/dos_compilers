/*_ msmouse.h   Sat Jun  3 1989   Modified by: Walter Bright */
/* Copyright (C) 1986-1989 by Northwest Software	*/
/* All Rights Reserved					*/
/* Written by Walter Bright				*/
/* Interface to Microsoft mouse driver	*/

#ifndef __MSMOUSE_H
#define __MSMOUSE_H 1

#if __cplusplus
extern "C" {
#endif

/* Masks for mouse buttons	*/
#define LEFT_BUTTON	1
#define RIGHT_BUTTON	2
#define MIDDLE_BUTTON	0	/* so middle button is never turned on	*/

int	cdecl msm_init(void);
void	cdecl msm_term(void);
void	cdecl msm_showcursor(void);
void	cdecl msm_hidecursor(void);
int	cdecl msm_getstatus(unsigned *,unsigned *);
void	cdecl msm_setcurpos(unsigned,unsigned);
int	cdecl msm_getpress(unsigned *,unsigned *,unsigned *);
int	cdecl msm_getrelease(unsigned *,unsigned *,unsigned *);
void	cdecl msm_setareax(unsigned,unsigned);
void	cdecl msm_setareay(unsigned,unsigned);
void	cdecl msm_setgraphcur(int,int,int *);
void	cdecl msm_settextcur(int,int,int);
void	cdecl msm_readcounters(int *,int *);
void	cdecl msm_signal(unsigned,
		void (cdecl *)(unsigned,unsigned,unsigned,unsigned),void *);
void	cdecl msm_lightpenon(void);
void	cdecl msm_lightpenoff(void);
void	cdecl msm_setratio(unsigned,unsigned);
void	cdecl msm_condoff(unsigned,unsigned,unsigned,unsigned);
void	cdecl msm_setthreshhold(unsigned);

#if __cplusplus
}
#endif

#endif /* __MSMOUSE_H */

