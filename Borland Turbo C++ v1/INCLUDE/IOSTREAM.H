/* iostream.h -- basic stream I/O declarations

    Copyright (c) 1990 by Borland International    
	All rights reserved.

    There are some inline functions here which generate a LOT of code
    (as much as 300 bytes), but are available inline because AT&T did
    it that way.  We have also made them true functions in the library
    and conditionally deleted the inline code from this header.
    
    If you really want these big functions to be inline, #define the
    macro name _BIG_INLINE_ before including this header.

    Programs will compile and link correctly even if some modules are
    compiled with _BIG_INLINE_ and some are not.
*/

#ifndef __IOSTREAM_H
#define __IOSTREAM_H

#include <mem.h>	// to get memcpy and NULL

#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

// Definition of EOF must match the one in <stdio.h>
#define EOF (-1)

// extract a char from int i, ensuring that zapeof(EOF) != EOF
#define	zapeof(i) ((unsigned char)(i))

typedef long streampos;
typedef long streamoff;

class streambuf;
class ostream;


class ios {
public:
	// stream status bits
	enum io_state	{
		goodbit	 = 0x00,	// no bit set: all is ok
		eofbit	 = 0x01,	// at end of file
		failbit	 = 0x02,	// last I/O operation failed
		badbit	 = 0x04,	// invalid operation attempted
		hardfail = 0x80		// unrecoverable error
		};

	// stream operation mode
	enum open_mode	{
		in	 = 0x01,	    // open for reading
		out	 = 0x02,	    // open for writing
		ate	 = 0x04,	    // seek to eof upon original open
		app	 = 0x08,	    // append mode: all additions at eof
		trunc	 = 0x10,	// truncate file if already exists
		nocreate = 0x20,	// open fails if file doesn't exist
		noreplace= 0x40,	// open fails if file already exists
		binary	 = 0x80		// binary (not text) file
		};

	// stream seek direction
	enum seek_dir { beg=0, cur=1, end=2 };

	// formatting flags
	enum	{
		skipws	  = 0x0001,	// skip whitespace on input
		left	  = 0x0002,	// left-adjust output
		right	  = 0x0004,	// right-adjust output
		internal  = 0x0008,	// padding after sign or base indicator
		dec	  = 0x0010,	    // decimal conversion
		oct	  = 0x0020,	    // octal conversion
		hex	  = 0x0040,	    // hexidecimal conversion
		showbase  = 0x0080,	// use base indicator on output
		showpoint = 0x0100,	// force decimal point (floating output)
		uppercase = 0x0200,	// upper-case hex output
		showpos	  = 0x0400,	// add '+' to positive integers
		scientific= 0x0800,	// use 1.2345E2 floating notation
		fixed	  = 0x1000,	// use 123.45 floating notation
		unitbuf	  = 0x2000,	// flush all streams after insertion
		stdio	  = 0x4000	// flush stdout, stderr after insertion
		};

	// constants for second parameter of seft()
static	const long basefield;		// dec | oct | hex
static	const long adjustfield;		// left | right | internal
static	const long floatfield;		// scientific | fixed

	// constructor, destructor
		_Cdecl ios(streambuf*);
virtual	_Cdecl ~ios();

	// for reading/setting/clearing format flags
	long	_Cdecl flags();
	long	_Cdecl flags(long);
	long	_Cdecl setf(long _setbits, long _field);
	long	_Cdecl setf(long);
	long	_Cdecl unsetf(long);

	// reading/setting field width
	int	    _Cdecl width();
	int	    _Cdecl width(int);

	// reading/setting padding character
	char	_Cdecl fill();
	char	_Cdecl fill(char);

	// reading/setting digits of floating precision
	int	    _Cdecl precision(int);
	int	    _Cdecl precision();

	// reading/setting ostream tied to this stream
	ostream* _Cdecl tie(ostream*);
	ostream* _Cdecl tie();

	// find out about current stream state
	int	    _Cdecl rdstate();		// return the stream state
	int	    _Cdecl eof();			// non-zero on end of file
	int	    _Cdecl fail();			// non-zero if an operation failed
	int	    _Cdecl bad();			// non-zero if error occurred
	int	    _Cdecl good();			// non-zero if no state bits set
	void	_Cdecl clear(int = 0);	// set the stream state
		    _Cdecl operator void* ();	// zero if state failed
	int	    _Cdecl operator! ();	// non-zero if state failed

	streambuf* _Cdecl rdbuf();		// get the assigned streambuf

	// for declaring additional flag bits and user words
static long	_Cdecl bitalloc();	// acquire a new flag bit, value returned
static int	_Cdecl xalloc();	// acquire a new user word, index returned
	long  & _Cdecl iword(int);	// return the nth user word as an int
	void* & _Cdecl pword(int);	// return the nth user word as a pointer

static void	_Cdecl sync_with_stdio();

	// obsolete, for streams 1.2 compatibility
	int	    _Cdecl skip(int);

protected:
	// additional state flags for ispecial and ospecial
	enum { skipping = 0x100, tied = 0x200 };

	streambuf* bp;		    // the associated streambuf
	ostream* x_tie;		    // the tied ostream, if any
	int	    state;		    // status bits
	int	    ispecial;	    // istream status bits	***
	int	    ospecial;	    // ostream status bits	***
	long 	x_flags;	    // formatting flag bits
	int	    x_precision;	// floating-point precision on output
	int 	x_width;	    // field width on output
	int	    x_fill;		    // padding character on output
	int	    isfx_special;	// unused		***
	int	    osfx_special;	// unused		***
	int	    delbuf;		    // unused		***
	int	    assign_private;	// unused		***
/*
 * The data members marked with *** above are not documented in the AT&T
 * release of streams, so we cannot guarantee compatibility with any
 * other streams release in the use or values of these data members.
 * If you can document any expected behavior of these data members, we
 * will try to adjust our implementation accordingly.
 */

		    _Cdecl ios();		// null constructor, does not initialize
            
	void	_Cdecl init(streambuf*);	// the actual initialization

	void	_Cdecl setstate(int);	    // set all status bits

static	void _Cdecl (*stdioflush)();

private:
	// for extra flag bits and user words
static	long	nextbit;
static	int	usercount;
	union ios_user_union *userwords;
	int	    nwords;
	void	_Cdecl usersize(int);

	// these declarations prevent automatic copying of an ios
		    _Cdecl ios(ios&);		    // declared but not defined
	void	_Cdecl operator= (ios&);	// declared but not defined

};
inline streambuf* _Cdecl ios::rdbuf() { return bp; }
inline ostream* _Cdecl ios::tie() { return x_tie; }    
inline char	    _Cdecl ios::fill() { return x_fill; }
inline int	    _Cdecl ios::precision() { return x_precision; }
inline int	    _Cdecl ios::rdstate() { return state; }
inline int	    _Cdecl ios::eof() { return state & eofbit; }
inline int	    _Cdecl ios::fail() { return state & (failbit | badbit | hardfail); }
inline int	    _Cdecl ios::bad() { return state & (badbit | hardfail); }
inline int	    _Cdecl ios::good() { return state == 0; }
inline long	    _Cdecl ios::flags() { return x_flags; }
inline int	    _Cdecl ios::width() { return x_width; }
inline int	    _Cdecl ios::width(int _w) { int _i = x_width; x_width = _w; return _i; }
inline char	    _Cdecl ios::fill(char _c) { char _x = x_fill; x_fill = _c; return _x; }
inline int	    _Cdecl ios::precision(int _p) {
			            int _x = x_precision; x_precision = _p; return _x;
		                }
inline		    _Cdecl ios::operator void* () { return fail() ? 0 : this; }
inline int	    _Cdecl ios::operator! () { return fail(); }


class streambuf {
public:
	// constructors and destructors
	    _Cdecl streambuf();		        // make empty streambuf
	    _Cdecl streambuf(char*, int);	// make streambuf with given char array
virtual	_Cdecl ~streambuf();

	// use the provided char array for the buffer if possible
virtual streambuf* _Cdecl setbuf(  signed char*, int);
	// WARNING:  this function is not virtual; do not override
   	streambuf*  _Cdecl setbuf(unsigned char*, int);

	// obsolete, for streams 1.2 compatibility
	streambuf*  _Cdecl setbuf(char*, int, int);

	// getting (extracting) characters
	int	    _Cdecl sgetc();		    // peek at next char
	int	    _Cdecl snextc();		// advance to and return next char
	int	    _Cdecl sbumpc();		// return current char and advance
	void	_Cdecl stossc();		// advance to next character
	int	    _Cdecl sgetn(char*, int);	// get next n chars
virtual int	_Cdecl do_sgetn(char*, int);	// implementation of sgetn
virtual int	_Cdecl underflow();		// fill empty buffer
	int	    _Cdecl sputbackc(char);	// return char to input
virtual int	_Cdecl pbackfail(int);	// implementation of sputbackc
	int	    _Cdecl in_avail();		// number of avail chars in buffer

	// putting (inserting) characters
	int	    _Cdecl sputc(int);		    // put one char
	int	    _Cdecl sputn(const char*, int); // put n chars from string
virtual int	_Cdecl do_sputn(const char* s, int n); // implementation of sputn
virtual int	_Cdecl overflow(int = EOF);	// flush buffer and make more room
	int	    _Cdecl out_waiting();		// number of unflushed chars

	// moving around in stream
virtual streampos _Cdecl seekoff(streamoff, seek_dir, int = (ios::in | ios::out));
virtual streampos _Cdecl seekpos(streampos, int = (ios::in | ios::out));
virtual int	_Cdecl sync();

	void	_Cdecl dbp();		// for debugging streambuf implementations

protected:
	char*	_Cdecl base();		// return start of buffer area
	char*	_Cdecl ebuf();		// return end+1 of buffer area
	int	    _Cdecl blen();		// return length of buffer area
	char*	_Cdecl pbase();	    // return start of put area
	char*	_Cdecl pptr();		// return next location in put area
	char*	_Cdecl epptr();	    // return end+1 of put area
	char*	_Cdecl eback();	    // return base of putback section of get area
	char*	_Cdecl gptr();		// return next location in get area
	char*	_Cdecl egptr();	    // return end+1 of get area
	void	_Cdecl setp(char*, char*);		// initialize the put pointers
	void	_Cdecl setg(char*, char*, char*);	// initialize the get pointers
	void	_Cdecl pbump(int);	// advance the put pointer
	void	_Cdecl gbump(int);	// advance the get pointer
	void	_Cdecl setb(char*, char*, int = 0 );	// set the buffer area
	void	_Cdecl unbuffered(int);// set the buffering state
	int	    _Cdecl unbuffered();	// non-zero if not buffered
	int	    _Cdecl allocate();	// set up a buffer area
virtual int	_Cdecl doallocate();	// implementation of allocate

private:
	short	alloc_;		// non-zero if buffer should be deleted
	short	unbuf_;		// non-zero if unbuffered
	char*	base_;		// start of buffer area
	char*	ebuf_;		// end+1 of buffer area
	char*	pbase_;		// start of put area
	char*	pptr_;		// next put location
	char*	epptr_;		// end+1 of put area
	char*	eback_;		// base of putback section of get area
	char*	gptr_;		// next get location
	char*	egptr_;		// end+1 of get area

	int	    _Cdecl do_snextc();	// implementation of snextc

	// these declarations prevent copying of a streambuf
		    _Cdecl streambuf(streambuf&);	// declared but not defined
	void	_Cdecl operator= (streambuf&);	// declared but not defined
};
inline char* _Cdecl streambuf::base() { return base_; }
inline char* _Cdecl streambuf::pbase() { return pbase_; }
inline char* _Cdecl streambuf::pptr() { return pptr_; }
inline char* _Cdecl streambuf::epptr() { return epptr_; }
inline char* _Cdecl streambuf::gptr() { return gptr_; }
inline char* _Cdecl streambuf::egptr()	{ return egptr_; }
inline char* _Cdecl streambuf::eback()	{ return eback_; }
inline char* _Cdecl streambuf::ebuf()	{ return ebuf_; }
inline int	 _Cdecl streambuf::unbuffered() { return unbuf_; }
inline int	 _Cdecl streambuf::blen() { return (int)(ebuf_ - base_);}
inline streambuf* _Cdecl streambuf::setbuf(unsigned char* _p, int _len) {
			// call the virtual function
			return setbuf((signed char*)_p, _len);
		    }
inline void	_Cdecl streambuf::pbump(int _n) { pptr_ += _n; }
inline void	_Cdecl streambuf::gbump(int _n) { gptr_ += _n; }
inline void	_Cdecl streambuf::unbuffered(int _unb) { unbuf_ = (_unb != 0); }
inline int	_Cdecl streambuf::in_avail() {
			    return (egptr_ > gptr_) ? (int)(egptr_ - gptr_) : 0;
        		}
inline int	_Cdecl streambuf::out_waiting() { return pptr_ ? (int)(pptr_ - pbase_) : 0; }
inline int	_Cdecl streambuf::allocate() {
			    return (base_ || unbuf_) ? 0 : doallocate();
        		}
inline int	_Cdecl streambuf::sgetc() {
			    return (gptr_ >= egptr_) ? underflow() :
				   (unsigned char)(*gptr_);
        		}
inline int	_Cdecl streambuf::snextc() {
    			return (! gptr_ || (++gptr_ >= egptr_)) ?
    				do_snextc() :
	    			(unsigned char)(*gptr_);
	        	}
inline int	_Cdecl streambuf::sbumpc() {
		    	return (gptr_ >= egptr_ && underflow() == EOF) ?
			    	EOF :
				    (unsigned char)(*gptr_++);
        		}
inline void	_Cdecl streambuf::stossc() {
    			if( gptr_ >= egptr_ ) underflow();
	    		else ++gptr_;
		        }
inline int	_Cdecl streambuf::sputbackc(char _c) {
    			return (gptr_ > eback_) ?
	    			(unsigned char)(*--gptr_ = _c) :
		    		pbackfail(_c);
        		}
inline int	_Cdecl streambuf::sputc(int _c) {
    			return (pptr_ >= epptr_) ?
	    			overflow((unsigned char)_c) :
		    		(unsigned char)(*pptr_++ = _c);
        		}
#ifdef _BIG_INLINE_
inline int	_Cdecl streambuf::sputn(const char* _s, int _n) {
    			if( _n <= (epptr_ - pptr_) ) {
	    			memcpy(pptr_, _s, _n);
		    		pbump(_n);
			    	return _n;
    			}
	    		return do_sputn(_s, _n);
		        }
inline int	_Cdecl streambuf::sgetn(char* _s, int _n) {
    			if( _n <= (egptr_ - gptr_) ) {
	    			memcpy(_s, gptr_, _n);
		    		gbump(_n);
			    	return _n;
    			}
	    		return do_sgetn(_s, _n);
		        }
#endif


class istream : virtual public ios {
public:
	// constructor and destructor
		_Cdecl istream(streambuf*);
virtual	_Cdecl ~istream();

	// Obsolete constructors, for streams 1.2 compatibility
		// obsolete: set skip via format, tie via tie() function
		_Cdecl istream(streambuf*, int _sk, ostream* _t=0);
		// obsolete: use strstream
		_Cdecl istream(int _sz, char*, int _sk=1);
		// obsolete: use fstream
		_Cdecl istream(int _fd, int _sk=1, ostream* _t=0);

	int	_Cdecl ipfx(int = 0);		// input prefix function
	int	_Cdecl ipfx0();		// same as ipfx(0)
	int	_Cdecl ipfx1();		// same as ipfx(1)
	void _Cdecl isfx()		{ }	// unused input suffix function

	// set/read the get pointer's position
	istream& _Cdecl seekg(streampos);
	istream& _Cdecl seekg(streamoff, seek_dir);
   	streampos _Cdecl tellg();

	int	_Cdecl sync();

	/*
	 * Unformatted extraction operations
	 */
	// extract characters into an array
	istream& _Cdecl get(  signed char*, int, char = '\n');
	istream& _Cdecl get(unsigned char*, int, char = '\n');
	istream& _Cdecl read(  signed char*, int);
	istream& _Cdecl read(unsigned char*, int);

	// extract characters into an array up to termination char
	istream& _Cdecl getline(  signed char*, int, char = '\n');
	istream& _Cdecl getline(unsigned char*, int, char = '\n');

	// extract characters into a streambuf up to termination char
	istream& _Cdecl get(streambuf&, char = '\n');

	// extract a single character
	istream& _Cdecl get(unsigned char&);
	istream& _Cdecl get(  signed char&);
	int 	 _Cdecl get();
                     
	int	     _Cdecl peek();		// return next char without extraction
	int	     _Cdecl gcount();	// number of unformatted chars last extracted
	istream& _Cdecl putback(char);	// push back char into input

	// extract and discard chars but stop at delim
	istream& _Cdecl ignore(int = 1, int = EOF);

	/*
	 * Formatted extraction operations
	 */
	istream& _Cdecl operator>> (istream& (*_f)(istream&));
	istream& _Cdecl operator>> (ios& (*_f)(ios&) );
	istream& _Cdecl operator>> (  signed char*);
	istream& _Cdecl operator>> (unsigned char*);
	istream& _Cdecl operator>> (unsigned char&);
	istream& _Cdecl operator>> (  signed char&);
	istream& _Cdecl operator>> (short&);
	istream& _Cdecl operator>> (int&);
	istream& _Cdecl operator>> (long&);
	istream& _Cdecl operator>> (unsigned short&);
	istream& _Cdecl operator>> (unsigned int&);
	istream& _Cdecl operator>> (unsigned long&);
	istream& _Cdecl operator>> (float&);
	istream& _Cdecl operator>> (double&);
	istream& _Cdecl operator>> (long double&);

	// extract from this istream, insert into streambuf
	istream& _Cdecl operator>> (streambuf*);

protected:
		    _Cdecl istream();
	int	    _Cdecl do_ipfx(int);	// implementation of ipfx
	void	_Cdecl eatwhite();	    // extract consecutive whitespace

private:
	int	gcount_;	// chars extracted by last unformatted operation
	signed char _Cdecl do_get();	// implementation of get
};
inline int	_Cdecl istream::gcount() { return gcount_; }
inline int	_Cdecl istream::ipfx(int _need) {
    			if( _need ? (ispecial & ~skipping) : ispecial )
	    			return do_ipfx(_need);
		    	return 1;
        		}
inline int	_Cdecl istream::ipfx0() { return ispecial ? do_ipfx(0) : 1; }
inline int	_Cdecl istream::ipfx1() {
    			return (ispecial & ~skipping) ? do_ipfx(1) : 1;
	        	}
#ifdef _BIG_INLINE_
inline istream& _Cdecl istream::operator>> (unsigned char& _c) {
        		if( ipfx0() )
		    		_c = bp->in_avail() ? bp->sbumpc() : do_get();
			    return *this;
        		}
inline istream& _Cdecl istream::operator>> (signed char& _c) {
    			if( ipfx0() )
	    			_c = bp->in_avail() ? bp->sbumpc() : do_get();
		    	return *this;
        		}
#endif
inline istream&	_Cdecl istream::operator>> (unsigned char* _p) {
    			return *this >> (signed char *)_p;
	        	}
inline istream&	_Cdecl istream::get(unsigned char* _p, int _l, char _t) {
    			return get((signed char*)_p, _l, _t);
	        	}
inline istream&	_Cdecl istream::read(unsigned char* _p, int _l) {
    			return read((signed char*)_p, _l);
	        	}
inline istream&	_Cdecl istream::getline(unsigned char* _p, int _l, char _t) {
    			return getline((signed char*) _p, _l, _t);
	        	}
inline int	    _Cdecl istream::sync() { return bp->sync(); }
inline istream& _Cdecl istream::operator>> (istream& (*_f) (istream&)) {
    			return (*_f)(*this);
	        	}
#ifdef _BIG_INLINE_
inline istream& _Cdecl istream::get(unsigned char& _c) {
    			if( ipfx1() )
	    			if( bp->in_avail() ) {
		    			gcount_ = 1;
			    		_c = bp->sbumpc();
				    }
				else _c = do_get();
    			return *this;
	        	}
inline istream& _Cdecl istream::get(signed char& _c) {
    			if( ipfx1() )
	    			if( bp->in_avail()) {
		    			gcount_ = 1;
			    		_c = bp->sbumpc();
				    }
				else _c = do_get();
    			return *this;
	        	}
inline int 	    _Cdecl istream::get() {
    			if( ipfx1() ) {
	    			int _c = bp->sbumpc();
		    		if( _c == EOF ) setstate(eofbit);
			    	else gcount_ = 1;
				    return _c;
    			}
	    		else return EOF;
        		}
#endif
inline int	_Cdecl istream::peek() { return ipfx1() ? bp->sgetc() : EOF; }


class ostream : virtual public ios {
public:
	// constructors and destructor
		_Cdecl ostream(streambuf*);
virtual	_Cdecl ~ostream();
	// Obsolete constructors, for streams 1.2 compatibility
		_Cdecl ostream(int _fd); // obsolete, use fstream
		_Cdecl ostream(int _sz, char*); // obsolete, use strstream

	int	_Cdecl opfx();		// output prefix function
	void _Cdecl osfx();		// output suffix function
	ostream& _Cdecl flush();

	// set/read the put pointer's position
	ostream& _Cdecl seekp(streampos);
	ostream& _Cdecl seekp(streamoff, seek_dir);
 	streampos _Cdecl tellp();

	/*
	 * Unformatted insertion operations
	 */
	ostream& _Cdecl put(char);	// insert the character
	ostream& _Cdecl write(const   signed char*, int); // insert the string
	ostream& _Cdecl write(const unsigned char*, int); // insert the string

	/*
	 * Formatted insertion operations
	 */
	// insert the character
	ostream& _Cdecl operator<< (  signed char);
	ostream& _Cdecl operator<< (unsigned char);

	// for the following, insert character representation of numeric value
	ostream& _Cdecl operator<< (short);
	ostream& _Cdecl operator<< (unsigned short);
	ostream& _Cdecl operator<< (int);
	ostream& _Cdecl operator<< (unsigned int);
	ostream& _Cdecl operator<< (long);
	ostream& _Cdecl operator<< (unsigned long);
	ostream& _Cdecl operator<< (float);
	ostream& _Cdecl operator<< (double);
	ostream& _Cdecl operator<< (long double);

	// insert the null-terminated string
	ostream& _Cdecl operator<< (const   signed char*);
	ostream& _Cdecl operator<< (const unsigned char*);

	// insert character representation of the value of the pointer
	ostream& _Cdecl operator<< (void*);

	// extract from streambuf, insert into this ostream
	ostream& _Cdecl operator<< (streambuf*);

	// manipulators
	ostream& _Cdecl operator<< (ostream& (*_f)(ostream&));
	ostream& _Cdecl operator<< (ios& (*_f)(ios&));

protected:
	int	    _Cdecl do_opfx();	// implementation of opfx
	void	_Cdecl do_osfx();	// implementation of osfx
		    _Cdecl ostream();

private:
	void	_Cdecl outstr(const signed char*, const signed char*);
};
inline int	_Cdecl ostream::opfx() { return ospecial ? do_opfx() : 1; }
inline void	_Cdecl ostream::osfx() { if( x_flags & (stdio | unitbuf) ) do_osfx(); }
#ifdef _BIG_INLINE_
inline ostream& _Cdecl ostream::operator<< (signed char _c) {
    			if( opfx() )
	    			if( bp->sputc(_c) == EOF ) setstate(badbit);
		            	osfx();
    			return *this;
	        	}
#endif
inline ostream& _Cdecl ostream::operator<< (unsigned char _c) {
    			return *this << (signed char)_c;
	        	}
inline ostream& _Cdecl ostream::operator<< (const signed char* _s) {
    			outstr(_s, (const signed char*)0);
	    		return *this;
		        }
inline ostream& _Cdecl ostream::operator<< (const unsigned char* _s) {
    			outstr((const signed char*)_s, (const signed char*)0);
	    		return *this;
		        }
inline ostream& _Cdecl ostream::operator<< (short _i) { return *this << (long) _i; }
inline ostream& _Cdecl ostream::operator<< (unsigned short _i) {
    			return *this << (unsigned long) _i;
	        	}
inline ostream& _Cdecl ostream::operator<< (int _i) { return *this << (long) _i; }
inline ostream& _Cdecl ostream::operator<< (unsigned int _i) {
    			return *this << (unsigned long) _i;
	        	}
inline ostream& _Cdecl ostream::operator<< (float _f) { return *this << (long double) _f; }
inline ostream& _Cdecl ostream::operator<< (double _d) { return *this << (long double) _d; }
inline ostream& _Cdecl ostream::operator<< (ostream& (*_f)(ostream&)) {
    			return (*_f)(*this);
	        	}
inline ostream& _Cdecl ostream::write(const unsigned char* _s, int _n) {
    			return write((const signed char*)_s, _n);
	        	}
inline ostream& _Cdecl ostream::put(char _c) {
    			if( bp->sputc(_c) == EOF ) setstate(badbit);
	    		return *this;
		        }
#ifdef _BIG_INLINE_
inline ostream& _Cdecl ostream::write(const signed char* _s, int _n) {
    			if( ! fail() )
	    			if( bp->sputn((const char*)_s, _n) != _n )
		    			setstate(badbit);
			    return *this;
        		}
#endif


class iostream : public istream, public ostream {
public:
		_Cdecl iostream(streambuf*);
virtual	_Cdecl ~iostream();

protected:
		_Cdecl iostream();
};


class istream_withassign : public istream {
public:
		// does no initialization
		_Cdecl istream_withassign();

virtual	_Cdecl ~istream_withassign();

	// gets buffer from istream and does entire initialization
	istream_withassign& _Cdecl operator= (istream&);

	// associates streambuf with stream and does entire initialization
	istream_withassign& _Cdecl operator= (streambuf*);
};


class ostream_withassign : public ostream {
public:
		// does no initialization
		_Cdecl ostream_withassign();

virtual	_Cdecl ~ostream_withassign();

	// gets buffer from istream and does entire initialization
	ostream_withassign& _Cdecl operator= (ostream&);

	// associates streambuf with stream and does entire initialization
	ostream_withassign& _Cdecl operator= (streambuf*);
};


class iostream_withassign : public iostream {
public:
		// does no initialization
		_Cdecl iostream_withassign();

virtual	_Cdecl ~iostream_withassign();

	// gets buffer from stream and does entire initialization
	iostream_withassign& _Cdecl operator= (ios&);

	// associates streambuf with stream and does entire initialization
	iostream_withassign& _Cdecl operator= (streambuf*);
};


/*
 * The predefined streams
 */
extern istream_withassign _Cdecl cin;
extern ostream_withassign _Cdecl cout;
extern ostream_withassign _Cdecl cerr;
extern ostream_withassign _Cdecl clog;

/*
 * Manipulators
 */
ostream& _Cdecl endl(ostream&);	// insert newline and flush
ostream& _Cdecl ends(ostream&);	// insert null to terminate string
ostream& _Cdecl flush(ostream&);// flush the ostream
ios&	 _Cdecl dec(ios&);		// set conversion base to decimal
ios&	 _Cdecl hex(ios&);		// set conversion base to hexidecimal
ios&	 _Cdecl oct(ios&);		// set conversion base to octal
istream& _Cdecl ws(istream&);	// extract whitespace characters

#endif
