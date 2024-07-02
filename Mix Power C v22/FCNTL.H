/*$no list*//*$no trace <<< fcntl.h >>> */
/*   Copyright (c) Mix Software 1988    */

#define O_RDONLY    0x0000
#define O_WRONLY    0x0001
#define O_RDWR      0x0002
#define O_APPEND    0x0008
#define O_CREAT     0x0100
#define O_TRUNC     0x0200
#define O_EXCL      0x0400
#define O_TEXT      0x4000
#define O_BINARY    0x8000
#define O_MODEMASK  0x00F3

#define O_DENYALL   0x0010
#define O_DENYNONE  0x0040
#define O_DENYREAD  0x0030
#define O_DENYWRITE 0x0020
#define O_NOINHERIT 0x0080

/*$list*//*$trace       <<< fcntl.h >>> */
