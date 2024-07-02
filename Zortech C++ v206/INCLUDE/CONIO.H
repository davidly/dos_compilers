/*_ CONIO.H   Wed Jun 28 1989   Modified by: Walter Bright */
/* Copyright (C) 1988-1989 by Northwest Software	*/
/* All Rights Reserved					*/
/* Written by Walter Bright				*/

#if __cplusplus
extern "C" {
#endif

int cdecl getche(void);
int cdecl getch(void);
int cdecl kbhit(void);

unsigned char	cdecl inp(unsigned);
unsigned char	cdecl outp(unsigned,char);
int		cdecl inpw(unsigned);
int		cdecl outpw(unsigned,unsigned);

#if __cplusplus
}
#endif


