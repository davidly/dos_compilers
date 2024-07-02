/* Copyright Manx Software Systems, Inc. 1990.  All rights reserved */
#include <time.h>

#ifndef __FCNTL_H 
#define __FCNTL_H 

#ifndef _SIZE_T
#define _SIZE_T
typedef unsigned int size_t;
#endif

#define O_RDONLY	0
#define O_WRONLY	1
#define O_RDWR		2
#define O_DENYRW	0x10
#define O_DENYW		0x20
#define O_DENYR		0x30
#define O_DENYN		0x40
#define O_INHER		0x80
#define O_COMP		0x00
#define O_CREAT		0x0100
#define O_TRUNC		0x0200
#define O_EXCL		0x0400
#define O_APPEND	0x0800

#define	O_TEXT		0x1000
#define	O_ISOPEN	0x2000 /* not for use except in io library */
#define	O_CONRAW	0x4000
#define	O_ISTTY		0x8000

#define MAXCHAN	20	/* maximum number of I/O channels *jd 9/8/92 */

int 			_creat(const char *_name, int _mode);
int 			_open(const char * _name, int _mode, ...);
int 			_access(char *, int);
int 			_close(int);
size_t 			_read(int, void *, size_t);
size_t 			_write(int, void *, size_t);
long 			_lseek(int, long, int);
struct sgttyb;
int 			_ioctl(int, int, ...);
int 			_isatty(int);
int 			_unlink(char *);

int 			creat(const char *_name, int _mode);
int 			open(const char * _name, int _mode, ...);
int 			access(char *, int);
int 			close(int);
size_t 			read(int, void *, size_t);
size_t 			write(int, void *, size_t);
long 			lseek(int, long, int);
int 			ioctl(int, int, struct sgttyb *);
int 			isatty(int);
int 			unlink(char *);
int 			_csread(int _fd, char *_buff, size_t _size);
int				filelock(int _fd, int _flag, long _offset, long _len);

void 			_exit(int _code);
int 			chmod(char *_name, int _attr);

int 			chdir(char *_path);
char *			getcwd(char *_path, int _size);
int 			mkdir(char *_name);
char *			mktemp(char * _template);
int 			rmdir(char *_dir);
char *			scdir(char *_pat);

int 			wait(void);
int 			fexecl(char *_file, char *_arg0, ...);
int 			fexecv(char *_file, char **_argv);

int 			execl(char *_file, char *_arg0, ...);
int 			execv(char *_file, char **_argv);
int 			execlp(char *_file, char *arg0, ...);
int 			execvp(char *_file, char **_argv);

int				fnsplit(char *_name, char *_drive, char *_dir, 
							char *_fname, char *_ext);
int				fnmerge(char *_name, char *_drive, char *_dir, 
							char *_fname, char *_ext);

#endif

