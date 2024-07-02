/* Copyright 1992 Manx Software Systems, Inc. All rights reserved */

#ifndef __DOS_H
#define	__DOS_H

int bdos(int _func, int _dx, int _cx);
int bdosx(int _func, far void *_dsdx, int _cx);
int dos(int _func, int _bx, int _cx, int _dx, int _di, int _si);
int dosx(int _func, int _bx, int _cx, void *_dsdx, int _di, int _si);
int dup(int _oldfd);
int fcbinit(char *_name, void *_fcb);
int fdup(int _oldfd, int _newfd);

#endif	/* __DOS_H */
