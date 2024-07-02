/*
                   Zortech C and C++ TSR Toolkit 
           (c)1989 Walter Bright, written by Kevin Powis.
                      Version 2.2 AUG 1989
*/
#ifdef M_I86SM

#include <dos.h>
#include <disp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <io.h>
#include <int.h>

extern void popmain();
extern char cdecl tsr_fprint[20];
extern int cdecl _datapar;
extern int cdecl _progpar;
extern int cdecl _tsrdisk;
extern unsigned char cdecl disp_inited;
extern int cdecl _tsr_bypass;
extern int cdecl _tsr_debug;
extern unsigned cdecl TSR_HOTSHIFT;
extern char     cdecl TSR_HOTSCAN;

volatile int cdecl _tsr_timeslice;
volatile int cdecl tsr_dosseg;
volatile int cdecl tsr_dosoff;
volatile int cdecl tsr_reqflag;
volatile int cdecl tsr_running;
volatile char cdecl old8[4];
volatile char cdecl old9[4];
volatile char cdecl old13[4];
volatile char cdecl old28[4];
volatile int cdecl oldpsp;

int cdecl tsr_vect_changed;
int cdecl tsr_over_graphics;


#ifdef __cplusplus
extern "C" {
#endif


void cdecl tsr_popup(void);
void cdecl tsr_no_pop(void);
void cdecl tsr_dta_on(void);
void cdecl tsr_dta_off(void);
int cdecl tsr_install ( int mode );
int cdecl tsr_uninstall ( void );
int cdecl tsr_test_vect ( unsigned vno , unsigned dataseg );
int cdecl tsr_already_in ( void );
int cdecl tsr_trap28 ( struct INT_DATA* );
int cdecl tsr_newint28 ( struct INT_DATA* );
int cdecl tsr_dosfree ( void );
int cdecl tsr_initialize ( unsigned, unsigned );
#ifdef __cplusplus
}
#endif


unsigned cdecl tsr_codeseg;

struct SREGS segregs;
union REGS regs;

tsr_install(mode)
int mode;
{
unsigned code,data,stack,extra;

     if(tsr_already_in() !=0)
        return 1;

     switch(mode)
     {
            case 0:_tsr_bypass=0;_tsr_debug=0;break;
            case 1:_tsr_bypass=1;_tsr_debug=0;break;
            case 2:_tsr_bypass=0;_tsr_debug=1;break;
            default:_tsr_bypass=1;_tsr_debug=1;break;
     }

     if(TSR_HOTSCAN>58 && TSR_HOTSCAN<69)
     {
            if(TSR_HOTSHIFT<4)
               TSR_HOTSCAN+=25;
            else
               if(TSR_HOTSHIFT<8)
                  TSR_HOTSCAN+=35;
               else
                  TSR_HOTSCAN+=45;
     }

     oldpsp=_psp;

     peek(0x0,32,&old8,4);
     peek(0x0,36,&old9,4);
     peek(0x0,76,&old13,4);
     peek(0x0,160,&old28,4);

     int_intercept(0x28,tsr_newint28,1500);
     int_intercept(0x28,tsr_trap28,150);

     tsr_initialize(tsr_dosseg,tsr_dosoff);

     regs.x.dx=_datapar;
     regs.x.dx=regs.x.dx+_progpar;
     regs.h.ah=0x31;
     intdos(&regs,&regs);
}

tsr_uninstall()
{
char near *np, far *fp;
int near *inp,far *ifp;
unsigned cseg,pid,mlen;
char mz;
unsigned tsr_ds,tsr_off;

     if(tsr_running==0)
     {
        tsr_ds=tsr_already_in();

        if(tsr_ds == 0)
           return 2;
     }
     else
        tsr_ds=getDS();

     tsr_vect_changed=0;
     tsr_test_vect(0x8,tsr_ds);
     tsr_test_vect(0x9,tsr_ds);
     tsr_test_vect(0x13,tsr_ds);
     tsr_test_vect(0x28,tsr_ds);

     if(tsr_vect_changed!=0)
        return 3;

     if(tsr_running==0)
     {
        np=&tsr_fprint[0];
        *np=0; 
        fp=MK_FP(getDS(),(unsigned) np);
        tsr_off=FP_OFF(fp);
        poke(tsr_ds,tsr_off,&tsr_fprint,1);

        int_off();
        np=&old8[0];
        fp=MK_FP(getDS(),(unsigned) np);
        tsr_off=FP_OFF(fp);
        peek(tsr_ds,tsr_off,&old8,4);
        int_on();

        np=&old9[0];
        fp=MK_FP(getDS(),(unsigned) np);
        tsr_off=FP_OFF(fp);
        peek(tsr_ds,tsr_off,&old9,4);

        np=&old13[0];
        fp=MK_FP(getDS(),(unsigned) np);
        tsr_off=FP_OFF(fp);
        peek(tsr_ds,tsr_off,&old13,4);

        np=&old28[0];
        fp=MK_FP(getDS(),(unsigned) np);
        tsr_off=FP_OFF(fp);
        peek(tsr_ds,tsr_off,&old28,4);

        inp=&oldpsp;
        ifp=MK_FP(getDS(),(unsigned) inp);
        tsr_off=FP_OFF(ifp);
        peek(tsr_ds,tsr_off,&oldpsp,2);

     }

     int_off();
     poke(0x0,32,&old8,4);
     poke(0x0,36,&old9,4);
     poke(0x0,76,&old13,4);
     poke(0x0,160,&old28,4);
     int_on();

     peek(0,0x00ba,&cseg,2);
     cseg-=1;
un1:
     peek(cseg,0,&mz,1);
     if(mz != 0x4d)
        goto un9;

     peek(cseg,1,&pid,2);
     peek(cseg,3,&mlen,2);

     cseg+=1;

     if(pid == oldpsp)
     {
         segregs.es=cseg;
         regs.h.ah=0x49;
         intdosx(&regs,&regs,&segregs);
     }

     cseg+=mlen;
     goto un1;
un9:
     return 0;
}

tsr_test_vect(vno,dataseg)
unsigned vno,dataseg;
{
unsigned lseg,loff;

     segread(&segregs);
     tsr_codeseg=dataseg-(segregs.ds-segregs.cs);
     int_getvector(vno,&loff,&lseg);

     if((lseg == tsr_codeseg) || (lseg == dataseg))
         return;
     else
         tsr_vect_changed+=1;
}

tsr_already_in()
{
int tsr_hit;
char near *np, far *fp;
char tsr_match[20];
unsigned tsr_seg,tsr_off,tsr_ds;

     tsr_hit=0;
     np=&tsr_fprint[0];
     *np=1;

     fp=MK_FP(getDS(),(unsigned) np);
     tsr_seg=FP_SEG(fp);
     tsr_off=FP_OFF(fp);

     tsr_ds=0x600;
     while((tsr_ds < tsr_seg) && tsr_hit==0)
     {
         peek(tsr_ds,tsr_off,&tsr_match,19);

         if(strcmp(tsr_fprint,tsr_match) == 0)
            tsr_hit=1;
         else
            tsr_ds+=1;
     }

     if(tsr_hit==1)
        return(tsr_ds);
     else
        return 0;
}

tsr_trap28(struct INT_DATA *p)
{
     return tsr_running;
}

tsr_newint28(struct INT_DATA *p)
{
int rf;

     if(((tsr_reqflag==0) && (_tsr_bypass==0))  || (tsr_running==1))
         return 0;

     tsr_running=1;
     rf=tsr_reqflag;

     if(rf!=0)
     {
         _tsr_timeslice=0;
         tsr_reqflag=0;
     }
     else
         _tsr_timeslice=1;

     if(tsr_dosfree() !=0)
     {
        tsr_no_pop();
        tsr_running=0;
        return 0;
     }

     tsr_dta_on();
     popmain();
     tsr_dta_off();

     tsr_running=0;
     return 0;
}

tsr_dosfree()
{
char tsr_busy_flag;
int  disp_state;

     disp_state=disp_inited;

     if(disp_inited==0)
        disp_open();

     tsr_busy_flag=disp_getmode();
     if((tsr_busy_flag > 4) && (tsr_busy_flag !=7) && (tsr_over_graphics==0))
         return 2;

     tsr_busy_flag=_tsrdisk;

     if(disp_state==0)
        disp_close();

     return(tsr_busy_flag);
}

#endif

