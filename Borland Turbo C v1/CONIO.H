/*	conio.h

	Direct MSDOS console input/output.

	Copyright (c) Borland International 1987
	All Rights Reserved.
*/
#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

char	*_Cdecl cgets(char *str);
void	 _Cdecl cputs(char *str);
int	 _Cdecl cprintf(char *format, ...);
int	 _Cdecl cscanf(char *format, ...);
int	 _Cdecl getch(void);
int	 _Cdecl getche(void);
char	*_Cdecl getpass(char *prompt);
int	 _Cdecl kbhit(void);
int	 _Cdecl putch(int ch);
int	 _Cdecl ungetch(unsigned ch);
