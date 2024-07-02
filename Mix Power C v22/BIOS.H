/*$no list*//*$no trace <<< bios.h >>> */
/*   Copyright (c) Mix Software 1988   */

int     bioscom(int operation, char data, int comport);
int     biosdisk(int operation, char drive, int head,
                 int cylinder, int sector, int nsects, void *buffer);
int     biosequip(void);
int     bioskey(int operation);
int     biosmemory(void);
int     biosprint(int operation, int data, int prnport);
long    biostime(int operation, long newtime);
void    clrscrn(void);
void    clrscrn2(int attr);
void    cursblk(void);
void    curslin(void);
int     curscol(void);
int     cursrow(void);
void    cursoff(void);
void    curson(void);
int     getvmode(void);
void    poscurs(int row, int col);
int     readattr(void);
int     readch(void);
int     readdot(int row, int col);
void    setcolor(int background, int palette);
int     setvmode(int mode);
void    sound(int freq, int duration);
void    writech(int c);
void    writechs(int c, int attr, int n);
void    writedot(int row, int col, int pixel);

/*$list*//*$trace       <<< bios.h >>> */
