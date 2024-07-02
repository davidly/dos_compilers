/* stdiostream.h -- class stdiobuf and stdiostream declarations

    Copyright (c) 1990 by Borland International    
	All rights reserved

  NOTE: These are inefficient and obsolete.  Use the standard classes and
	functions in <fstream.h> instead.
*/

#ifndef __STDSTREAM_H
#define __STDSTREAM_H

#include <iostream.h>
#include <stdio.h>

#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

class stdiobuf : public streambuf {
public:
		_Cdecl stdiobuf(FILE*);
	FILE*	_Cdecl stdiofile();
		_Cdecl ~stdiobuf();

virtual	int	_Cdecl overflow(int=EOF);
virtual	int	_Cdecl pbackfail(int);
virtual	int	_Cdecl sync();
virtual	streampos _Cdecl seekoff(streamoff, seek_dir, int);
virtual	int	_Cdecl underflow();

private:
	FILE*	sio;			
	char	lahead[2];
};
inline	FILE*	_Cdecl stdiobuf::stdiofile() { return sio; }


class stdiostream : public ios {
public:
		_Cdecl stdiostream(FILE*);
		_Cdecl ~stdiostream();
	stdiobuf* _Cdecl rdbuf();

private:
	stdiobuf buf;
};
inline	stdiobuf* _Cdecl stdiostream::rdbuf() { return &buf; }

#endif
