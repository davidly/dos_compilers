/*$no list*//*$no trace <<< ctype.h >>> */
/*   Copyright (c) Mix Software 1988    */

int isalnum(int c);
int isalpha(int c);
int iscntrl(int c);
int isdigit(int c);
int isgraph(int c);
int islower(int c);
int isprint(int c);
int ispunct(int c);
int isspace(int c);
int isupper(int c);
int isxdigit(int c);
int tolower(int c);
int toupper(int c);

#if !defined(ANSI)
int  isascii(int c);
int  isatty(int fd);
int  toascii(int c);
int _tolower(int c);
int _toupper(int c);
#endif

/*$list*//*$trace        <<< ctype.h >>> */
