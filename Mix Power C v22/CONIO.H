/*$no list*//*$no trace	<<< conio.h >>>	*/
/*   Copyright (c) Mix Software	1988	*/

char   *cgets(char string[]);
int	cprintf(char *format, ...);
void	cputs(char *string);
int	cscanf(char *format, ...);
int	getch(void);
int	getche(void);
int	getkey(void);
char   *getpass(char *prompt);
int	inp(unsigned port);
int	inport(int port);
int	inportb(int port);
int	kbhit(void);
int	outp(unsigned port, int	c);
void	outport(unsigned port, int word);
void	outportb(int port, char	c);
void	putch(int c);
int	ungetch(int c);

/*$list*//*$trace	<<< conio.h >>>	*/
