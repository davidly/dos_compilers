/*_ file.h   Wed Mar 22 1989   Modified by: Walter Bright */
/* $Header: file.h,v 1.9 88/07/22 15:36:04 bright Exp $ */
/* Written by Walter Bright				*/

#ifndef FILE_H
#define FILE_H	1

#ifndef _1
#include	"toolkit.h"
#endif

#ifndef LIST_H
#include	"list.h"
#endif

#if MSC
#include	<sys\types.h>
#endif

#if BSDUNIX
#include	<sys/types.h>
#endif

#if VAX11C
#include	<types.h>
#endif

#ifdef SUN 
#ifndef _TIME_
#include	<sys/time.h>
#endif _TIME_
#else
#include	<time.h>
#endif

/********************************
 * Determine size of file.
 * Returns:
 *	-1L	if file doesn't exist
 */

unsigned long file_size(_1(char *));

/********************************
 * Return != 0 if file exists, else 0.
 */

#if DLC || __ZTC__
extern long filesize(char *);
#define file_exists(f)	(filesize(f) != -1L)
#else
int file_exists(_1(char *));
#endif

/********************************
 * Rename file. Return != 0 if success, 0 if failure.
 */

int file_rename(_2(char *,char *));

/********************************
 * Copy file from to to.
 * Use low-level file I/O routines for speed.
 * Returns:
 *	0:	success
 *	!= 0:	failure
 */                

int file_copy(_2(char *,char *));

/********************************
 * Append file from to onto to.
 * Use low-level file I/O routines for speed.
 * Returns:
 *	0:	success
 *	!= 0:	failure
 */                

int file_append(_2(char *,char *));

/********************************
 * Set time of file.
 * Returns:
 *	0:	success
 *	!= 0:	failure
 */                

int file_settime(_2(char *,time_t));

/********************************
 * Return time that operating system associates with a file. The
 * format is system dependent.
 */

time_t file_time(_1(char *));

/*****************************
 * Return a pointer to an array of pointers
 * to strings that are filenames that are
 * the files that match filespec. filespec
 * may contain wild cards.
 * Input:
 *    Filespec is:
 *	NULL		Free the data in *Files_ppp and *Nfiles_p. The
 *			data must have been created by a previous call
 *			to this function. Always returns 1 in this case.
 *	""		All files in default directory
 *    for MSDOS:
 *	*.*		All files in default directory
 *	\		All files in root directory
 *	d:		All files in default directory on drive d
 *	\bin\*.exe	All .exe files in \bin
 *	\bin		All files in \bin
 *	\bin\		All files in \bin
 *    for BSDUNIX:
 *	*		All files in default directory
 *	.		All files in default directory
 *	/		All files in root directory
 *	/bin/ *.c	All .c files in /bin
 *	/bin		All files in /bin
 *	/bin/		All files in /bin
 *	? and [] type wild carding works, but {} and ~ does not.
 *
 *    Attr is:
 *	0		All normal files (other values not supported yet)
 *
 *    *Nfiles_p
 *    *Files_ppp	Previous results, which are free'd
 * Output:
 *	*Nfiles_p	Number of files that matched
 *	*Files_ppp	Pointer to array of strings (which needs to
 *			eventually be free'd by file_directory())
 * Returns:
 *	!= 0		success
 *	0		failure (out of memory), *Files_ppp is NULL,
 *			*Nfiles_p is 0
 */

int file_directory(
/*    _4(char *Filespec,int Attr,char ***Files_ppp,unsigned *Nfiles_p));*/
    _4(char *,int,char ***,unsigned *));

/***********************************
 * Search for a file along a path.
 * Input:
 *	filename	Name of file to look for. If the filename contains a
 *			complete path specification, only that is looked at.
 *	path		Path to search. Individual paths are separated by
 *			' ' or ';'. If path is NULL, then the current
 *			directory is searched.
 * Returns:
 *	string	mem_malloc'd string containing the complete file spec if
 *		the file is found
 *	NULL	file not found or out of memory
 */

/* char *file_searchpath(_2(char *path,char *filename)); */
char *file_searchpath(_2(char *,char *));

/**********************************
 * Determine if filespec1 and filespec2 refer to the same file.
 * This works even if the file doesn't exist yet.
 * Returns:
 *	0	not the same file
 *	!=0	the same file
 */

int file_same(_2(char *,char *));

/**********************************
 * Read a simple ascii text file and break it up into a list
 * of lines. Each line is a 0 terminated string, with the trailing \n
 * removed.
 * Ascii 0s in the file are ignored.
 * Input:
 *	name	File name to read
 * Returns:
 *	list	Linked list of strings
 * BUGS:
 *	Out of memory errors results in assertion failures.
 *	File read errors results in a shortened list coming back.
 */

list_t file_read(_1(char *));

/***********************************
 * Write a list of 0-terminated strings out as a file.
 * A \n is added to the end of each string.
 * Input:
 *	name	Name of file
 *	lines	Linked list of strings which are the lines in the file
 * Returns:
 *	0	success
 *	!=0	failure
 */

int file_write(_2(char *,list_t));

/******************************
 * Create directory, including any intervening directories in the path.
 * Returns:
 *	0	Success
 *	!=0	Failure
 */

int file_mkdir(_1(char *dir));

#endif /* FILE_H */
