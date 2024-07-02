/*	strstream.h -- class strstream declarations

    Copyright (c) 1990 by Borland International    
	All rights reserved
*/

#ifndef __STRSTREAM_H
#define __STRSTREAM_H

#include <iostream.h>

#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

class strstreambuf : public streambuf {
public:
		_Cdecl strstreambuf();
		_Cdecl strstreambuf(int n);
		_Cdecl strstreambuf(void* (*a)(long), void (*f)(void*));
		_Cdecl strstreambuf(  signed char* _s, int,   signed char* _strt=0);
		_Cdecl strstreambuf(unsigned char* _s, int, unsigned char* _strt=0);
		_Cdecl ~strstreambuf();

	void	_Cdecl freeze(int = 1);
	char*	_Cdecl str();
virtual int	_Cdecl doallocate();
virtual int	_Cdecl overflow(int);
virtual int	_Cdecl underflow();
virtual streambuf* _Cdecl setbuf(char*, int);
virtual streampos  _Cdecl seekoff(streamoff, seek_dir, int);

private:
	void*	_Cdecl (*allocf)(long);
	void	_Cdecl (*freef)(void*);
	short	ssbflags;
	enum	{ dynamic = 1, frozen = 2, unlimited = 4 };
	int	next_alloc;

	void	_Cdecl init(signed char*, int, signed char*);
};


class strstreambase : public virtual ios {
public:
	strstreambuf* _Cdecl rdbuf();

protected:
		_Cdecl strstreambase(char*, int, char*);
		_Cdecl strstreambase();
		_Cdecl ~strstreambase();
private:
    	strstreambuf buf;
};
inline strstreambuf* _Cdecl strstreambase::rdbuf() { return &this->buf; }


class istrstream : public strstreambase, public istream {
public:
		_Cdecl istrstream(char*);
		_Cdecl istrstream(char*, int);
		_Cdecl ~istrstream();
};


class ostrstream : public strstreambase, public ostream {
public:
		_Cdecl ostrstream(char*, int, int = ios::out);
		_Cdecl ostrstream();
		_Cdecl ~ostrstream();

	char*	_Cdecl str();
	int	    _Cdecl pcount();
};
inline char* _Cdecl ostrstream::str() { return strstreambase::rdbuf()->str(); }
inline int  _Cdecl ostrstream::pcount() {
        			return strstreambase::rdbuf()->out_waiting();
            		}


class strstream : public strstreambase, public iostream {
public:
		_Cdecl strstream();
		_Cdecl strstream(char*, int _sz, int _m);
		_Cdecl ~strstream();

	char*	_Cdecl str();
};
inline char* _Cdecl strstream::str() { return strstreambase::rdbuf()->str(); }

#endif
