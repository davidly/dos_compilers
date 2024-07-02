/* Copyright (C) 1984 by Manx Software Systems */

char *sys_errlist[] = {
	/* MsDos error codes */
	"No error",
	"Invalid function number",
	"File not found",
	"Path not found",
	"Too many open files",
	"Access denied",
	"Bad file handle",
	"Memory control blocks destroyed",
	"Insufficient memory",
	"Invalid memory block address",
	"Invalid environment",
	"Invalid format",
	"Invalid access code",
	"Invalid data",
	"",
	"Invalid drive",
	"Attempt to remove the current directory",
	"Not same device",
	"No more files",

	/* additional codes for Aztec C */
	"File exists",
	"Not a console device",
	/* math library */
	"Result too large",
	"Argument out of domain"
};

int sys_nerr =  sizeof (sys_errlist) / sizeof (char *);
