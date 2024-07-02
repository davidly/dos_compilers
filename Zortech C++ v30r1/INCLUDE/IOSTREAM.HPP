#ifndef __IOSTREAM_HPP
#define __IOSTREAM_HPP

// Iostreams Package
// Bruce Perens, July-August 1990
//
// Modified Steve Teale April 1991
// Copyright Zortech 1990-1991. All Rights Reserved.

#include <stddef.h>

#define seek_dir relative_to

#ifndef EOF
// EOF is #defined in stdio.h
const int EOF = -1;
#endif
const int _ios_default_decimal_precision = 6;
const int _ios_n_extended_format_words = 10;
// This is the number of extended format state words reserved for use
// by derived classes and user inserters. This value should be reasonably
// small, as it inflates the size of each instance of ios.

class streampos {
friend class streamoff;
public:
    streampos(long elems, size_t elemsize = 1) : ne(elems), es(elemsize) {}
    operator long() { return (ne == -1)? EOF: ne*es; }
private:
    long ne;
    size_t es;
};

class streamoff {
public:
    streamoff(long elems, size_t elemsize = 1) : ne(elems), es(elemsize) {}
    streamoff(streampos &a) : ne(a.ne), es(a.es) {}
    size_t stepsize() { return es; }
    long steps() { return ne == -1? 0: ne; }
private:
    long ne;
    size_t es;
};

class streambuf;
class ostream;
class istream;


class ios {

// This is the base class for istream and ostream, and all of their
// derivations.

friend ostream &endl(ostream &);

public:
    enum io_state {
        goodbit=0,
// No errors - everything hunky dory!
        eofbit=1,
// Normally set when underflow failed because there was no more file.
        failbit=2,
// An error has ocurred, but it is probably recoverable, and the
// stream is still in a useable state
        badbit=4
// A fatal error has ocurred
    };

// This is called seek_dir in the AT & T version, which is misleading.
// A define is included above for compatibility. These enumerators are
// used to specify relative seeks in streams.
    enum relative_to {
        beg,
// For seek operations relative to the beginning of the stream (file),

        cur,
// relative to the current position in the stream (file),

        end
// and relative to the end of the stream (file)
    };

// The following enumeration applies to file related derivatives.
    enum open_mode {
        in=0x1,
// Input allowed

        out=0x2,
// Output allowed

        ate=0x4,
// A seek to the end of the file to be performed during open.

        app=0x8,
// All writes are to the end of the file - implies out

        trunc=0x10,
// Existing contents of the file to be discarded. Implies out
// unless ate or app specified as well.

        nocreate=0x20,
// Open will fail if the file does not already exist

        noreplace=0x40,
// Open will fail if the file does already exist

        translated = 0x80
// CR/LF pairs to be translated to newline characters on input
// and newline characters to be translated to CR/LF pairs on
// output (the normal behaviour for DOS)
    };

// The formatting state is a bit-mask used to control some of the
// inserters and extractors. All of the bits of the format state
// can be manipulated by flags(), setf(), and unsetf(). Some
// specialized parts of the formatting state can be manipulated
// by fill(), width(), and precision() . Here are the meanings
// of the various bits:

    enum format_mode {
        skipws = 0x1,
// Skip past leading white space when extracting.
// Since zero-width fields are considered an
// error by the numeric extractors, attempting
// to extract white-space into a number without
// this bit set will set an error flag.

        left = 0x2,
// Left-adjust values when inserting (fill on the right).

        right = 0x4,
// Right-adjust values when inserting (fill on the left).

        internal = 0x8,
// When inserting, fill _between_ the numeric sign or
// base indicator and the value.

        dec = 0x10, oct = 0x20, hex = 0x40,
// Default radix for integers. If neither dec, octal,
// or hex is set, integer inserters use base 10, and
// integer extractors interpret numbers according to the
// C++ lexical convention: "0x" precedes a base-16 number,
// and a number with a leading zero is base-8.

        showbase = 0x80,
// If this is set, base-16 numbers will be inserted with a
// leading "0x", and base-8 numbers will have a leading zero.

        showpoint = 0x100,
// If this is set, the floating-point inserters will print a
// decimal point and trailing zeroes, even when the trailing
// places are not significant.

        uppercase = 0x200,
// If this is set, "E" instead of "e" will be used to indicate
// the exponent of a floating point number, and "A" through "F"
// will be used to represent base-16 numerals instead of "a"
// through "f".
//
// If uppercase and showbase are both set, the string "0X"
// instead of "0x" will be used to indicate a base-16 number.

        showpos = 0x400,
// If this is set, positive numbers will be inserted with a
// leading "+".

        scientific = 0x800,
// If this is set, the floating-point inserters will print a
// number with one digit before the decimal point, and the
// number of digits after the decimal point equal to the
// value of precision(). The character "e" will introduce the
// exponent.

        fixed = 0x1000,
// If this is set, the floating-point inserters will use
// precision() to determine the number of digits after the
// decimal point.
//
// If neither scientific or fixed is set, numbers with
// exponents smaller than -4 or greater than precision() will
// be printed as if scientific were set. Other numbers will
// be printed using zeroes to explicitly show the decimal place.

        unitbuf = 0x2000,
// When this is set, a flush is performed after each insertion
// (by ostream::osfx()). This is more efficient than using
// unbuffered output, but provides most of the same advantages.

        stdio = 0x4000,
// When this is set, streams using stdiobufs will flush stdout and
// stderr after each insertion.

// Note that it is not possible to use bit 0x8000 in this way,
// as this evaluates to an enumerator with a negative value and
// lots of bits set.
    };   // end enum format_mode

    static const long stickywidth;
    static const long spacing;

    enum format_mode_mask {
        defaults = right|skipws,
        basefield = dec|oct|hex,
        adjustfield = left|right|internal,
        floatfield = scientific|fixed
    };

public: // just a reminder!

    ios(streambuf *buffer);
// Construct an ios associated with the argument streambuf.
// "buffer" should not be null.

    virtual ~ios();

/////////////////////////////////////////////////////////////
//
// Functions to interrogate/set the error state

    int good() const { return error_state == 0; };
// If there are no error bits set, this returns non-zero, otherwise
// it returns zero.

    int eof() const { return error_state & eofbit; };
// If eofbit is set in the error state, this return non-zero, otherwise
// it returns zero. This indicates that end-of-file has been reached
// while reading the character stream.

    int fail() { return error_state & (badbit | failbit); }
// If badbit or failbit is set in the error state, return non-zero.
// Otherwise, return zero. Failbit generally indicates that some
// extraction has failed, but the stream may still be used once
// failbit has been cleared.

    int bad() const { return error_state & badbit; }
// Returns non-zero if badbit is set in the error state. This
// indicates some unrecoverable error, generally an I/O error.

    int operator!() const
    {
        return error_state & (badbit|failbit);
    }
// Return non-zero if badbit or failbit is set in the error state,
// which allows expressions of the form:
//  if ( !cout )

    operator void*()
    {
        return (error_state & (badbit|failbit))?
            0: this;
    }
// Convert an ios to a value that can be compared to zero, but can
// not be easily used accidentally. The return value is a void pointer
// that will be zero if failbit or badbit is set in the error state,
// and non-zero otherwise. This allows an iostream to be used
// in conditional expressions that test its state, as in:
// if ( cin ) and if ( cin >> variable )

    int rdstate() const { return error_state; };
// Returns the current error state.

    void clear(int new_state = 0) { error_state = new_state; }
// Stores "new_state" as the error state.
//
// To set a bit without clearing others requires something like
// clear(bits_to_set | rdstate()) .

//////////////////////////////////////////////////////////////////
//
// Functions to set/interrogate various options

    char fill(char new_value)
    {
        char old_value = padding_character;
        padding_character = new_value;
        return old_value;
    }
// Sets the fill character, and returns the old value. This is the
// character used to pad output when the left, right, or internal
// adjustments are in effect.

    char fill() const { return padding_character; }
// Returns the fill character.

    int precision(int new_value)
    {
        int old_value = decimal_precision;
        decimal_precision = new_value >= 0?
            new_value: _ios_default_decimal_precision;
        return old_value;
    }
// Sets the decimal precision, and returns the old value.
// This controls the number of digits inserted after the decimal
// point by the floating-point inserter.

    int precision() const { return decimal_precision; }
// Returns the current decimal precision.

    ostream *tie(ostream * new_value)
    {
        ostream *old_value = tied_ostream;
        tied_ostream = new_value;
        return old_value;
    };
// Facilitate automatic flushing of iostreams.
// Associate this ios to an ostream such that the ostream will be
// flushed before this ios makes a request for characters, or flushes
// output characters. These ties exist by default:
//  cin.tie(cout);
//  cout.tie(cerr);
//  cout.tie(clog);
//
// For other instances of ios, the tie is set to zero by default.
//
// This returns the old value.

    long flags() const { return format_state; }
// Return the format state flags.

    long flags(long new_value)
    {
        long old_value = format_state;
        format_state = new_value;
        return old_value;
    }
// Sets the format state flags, returning the old values.

    long setf(long bits_to_set, long mask = 0)
    {
        long old_value = format_state;
        format_state = (format_state & ~mask)
                | bits_to_set;
        return old_value;
    }
// Clears the bits corresponding to mask in the format state, and
// then sets only those bits from the value of bits_to_set.

    long unsetf(long bits_to_clear)
    {
        long old_value = format_state;
        format_state &= ~bits_to_clear;
        return old_value;
    };
// Clears flags in the format state.

    ostream *tie() const { return tied_ostream; };
// Return the current "tied" ostream.

    int width(int new_value);
// Sets the field width used by inserters.
// When the width is zero, inserters will use only as many characters
// as necessary to represent a value. When the width is non-zero,
// inserters will insert at least that many characters, using the
// fill character to pad out the field. Inserters will never truncate,
// so they may output more characters than the current width.

    int width() const { return field_width; };
// Returns the current width.

////////////////////////////////////////////////////////////////
//
// Other utilities

    streambuf *rdbuf() { return buf; }
// Returns a pointer to the streambuf associated with this ios.

    static void sync_with_stdio();
// Use this when mixing C and C++ in the same program.
// It resets cin, cout, cerr, and clog to use stdiobufs, and
// thus makes I/O to these streams compatible with the C stdio.
// Invoking this degrades performance.

////////////////////////////////////////////////////////////////
//
// Functions to manipulate user defined format flags and control
// words.

    static int bitalloc();
// Returns an int with one previously-unallocated bit set.
// This allows users who need an additional format flag to
// get one. Note that this allocation is global for class ios,
// not local to any instance of class ios.

    static int xalloc();
// Returns a previously-unused index into an array of words usable
// as format-state variables by derived classes.

    long &iword(int index)
    {
        return extended_format_words[index].l;
    }
// Returns a reference to one of the auxillary format state words
// reserved for use by derived classes and user inserters, where
// index is a value returned by xalloc().

    void* &pword(int index)
    {
        return extended_format_words[index].vp;
    };

// Returns a reference to a pointer to one of the auxillary format
// state words reserved for use by derived classes and user
// inserters, where index is a value returned by xalloc().

protected:
    void set_buffer(streambuf *b) { buf = b; }

private:
    streambuf   *buf;
    ostream     *tied_ostream;
    long        format_state;
    char        error_state;
    char        padding_character;
    short       decimal_precision;
    short       field_width;
    union {
        void *vp;
        long l;
    } extended_format_words[_ios_n_extended_format_words];

    ios(const ios&);
    ios &operator=(const ios&);
// These copying functions are private so that the compiler
// will complain about an attempt to assign an ios. It is not
// actually defined. Instead of copying an ios, assign a pointer
// to it.

};

////////////////////////////////////////////////////////////////
//
// Manipulator functions

ios &dec(ios&);
// Set the default integer radix to 10.
// Invoke this (and the other manipulators) this way:
// stream >> dec;
// stream << dec;

ios &hex(ios&);
ios &oct(ios&);
ios &defaults(ios&);

class streambuf {
// Streambuf abstracts the operations used to perform I/O on a character
// stream such as a computer terminal, a file or a string.
//
// The two basic operations are "get", which fetches characters from the
// stream, and "put", which places characters on the stream. Some streambufs
// are unidirectional, in which case they support the "get" operation but
// not "put", or vice-versa.
//
// Some streambufs are bi-directional, with the "get" and "put" offsets
// at different locations in the stream. Some streambufs may implement
// a circular buffer between the "get" and "put" offsets, as in a FIFO.
// Some streambufs lock the "get" and "put" offset together, as in a UNIX file.
// Some streambufs provide buffered I/O on the underlying character streams
// for efficiency.
//
// Streambufs contain a buffer, a get area, and a put area. Usually, the
// get area and put area overlap the buffer, but do not overlap each other.

public:

    streambuf();
// The default constructor.

    streambuf(char *memory, int length);
// Constructs a streambuf, possibly using the argument buffer.
    virtual ~streambuf();

    void dbp();
// Write debugging information about the streambuf on file
// descriptor 1. Nothing about the form of that information
// is specified.

    int in_avail() const { return _egptr - _gptr; }
// Return the number of characters that can be read immediately
// with a guarantee that no errors will be reported.

    int out_waiting() const { return _pptr - _pbase; }
// Return the number of characters that have not
// been flushed away, or EOF if there are no characters.

    virtual streambuf *setbuf(char *memory, int length);
// Requests that this streambuf use the argument memory buffer.
// Special case: a null memory argument, or a length argument that is
// zero or negative, is taken as a request that this streambuf be
// unbuffered.
//
// If the request to set the buffer is honored, return "this",
// otherwise return 0.
//
// * Use of this interface, except by a derived class of streambuf,
// is discouraged. It is not protected for compatibility with the
// original stream package in Stroustrup.
//
// The default version of this member will honor the request if no
// buffer has been allocated.

    virtual streampos  seekpos(streampos position,
                                    int which=ios::in|ios::out);
// Performs an absolute seek of the get or put pointers, or both, to
// "position". Position is an implementation-dependent value which
// should not have arithmetic performed on it. "which" signifies what
// pointer is to be affected: ios::in signifies the get pointer, and
// ios::out signifies the put pointer. The two "which" values may be
// or-ed together, in which case the operation affects both pointers.
//
// * The default version of this member returns
//       seekoff(position, ios::beg, which)
// thus is is only necessary for a derived class to define
// seekoff(), and use the inherited seekpos().

    virtual streampos seekoff(streamoff offset, relative_to pos,
                                    int which=ios::in|ios::out);
// Performs a relative seek of the get or put pointers, or both, by
// "offset". Position is a byte offset, and may be negative.
// "pos" may be ios::beg, which signifies a seek relative to
// the beginning of the stream; ios::cur, which signifies a seek
// relative to the current position in the stream; and ios::end, which
// signifies a seek relative to the end of the stream.
// "which" signifies what pointer is to be affected: ios::in
// signifies the get pointer, and ios::out signifies the put pointer.
// The two "which" values may be or-ed together, in which case the
// operation affects both pointers.
//     * The default version of this member always returns EOF.

    int sgetc()
    {
        return _gptr < _egptr?
                    (unsigned char) *_gptr: underflow();
    }
// Returns the character at the get pointer, without moving the get
// pointer.

    int sbumpc()
    {
        return _gptr < _egptr?
                    (unsigned char) *_gptr++: sbumpc_special();
    }
// Moves the get pointer forward one character, and return the
// character it moved past.

    int sgetn(char *buffer, int count);
// Fetch the "count" characters following the get pointer, and
// stores them in "buffer". If there are less than "count" characters,
// the number remaining are fetched. The get pointer is repositioned
// after the fetched characters, and the number of characters fetched
// is returned.

    int snextc()
    {
        return _gptr+1 < _egptr?
                    (unsigned char) *_gptr: underflow();
    }

// Skip past the character at the get pointer, and return the
// character after that, or EOF.

    int sputbackc(char c)
    {
        return _gptr > _gbase?
                    (*(--_gptr) = c, 0): pbackfail(c);
    }
// Move the get pointer back one character. If c is not the last
// character retrieved, the effect is undefined. In this implementation
// it should work

    int sputc(int c)
    {
        return _pptr < _epptr?
                    (*_pptr++ = c, 0): overflow(c);
    }
// Store c on the character stream, advancing the "put" pointer.
// Return EOF when an error occurs.

    int sputn(const char *string, int length);
// Store "n" characters on the character stream, advancing the "put"
// pointer past the stored characters. Return the number of characters
// stored, which may be less than "n" if there is an error.

    void stossc()
    {
        if (_gptr < _egptr) ++_gptr;
    }
// Skip the "get" pointer forward, wasting one character of input.
// If the get pointer is already at the end of the sequence
// this has no effect.

    virtual int sync();
// Make the external character stream and the streambuf consistent
// with each other. This usually means:
// 1. If there are characters in the get area, return them to the
//    stream, or throw them away. Re-position the stream so that
//    it appears that the characters that had been in the get area
//    had never been taken from the stream.
// 2. If there are characters in the put area, store them to the
//    stream. Re-position the stream immediately after the characters
//    just stored.
// 3. Return EOF if there's an error, otherwise return some other
//    value.
//     * The default version of this member will return 0 if the get area
// is empty, otherwise it returns EOF.

    virtual int overflow(int c = EOF);
// This is called to store characters in the character stream, usually
// when the put area is full. It generally stores all of the characters
// that are in the put area, stores c if it is not EOF, and calls
// setp() to establish a new put area. It should return EOF if it
// has an error, otherwise return some other value.

    virtual int underflow();
// This is called to read characters from the character stream,
// usually when the get area is empty. It should read one or more
// characters, and place them in the get area. It should return the
// first character in the get area, without incrementing the get
// pointer. It should return EOF if there's a problem.

protected:

// Buffer base and one past the end
    char *base() const { return _base; }
    char *ebuf() const { return _ebuf; }
// Get pointer, pushback limit, and one past end of put area
    char *gptr() const { return _gptr; }
    char *eback() const { return _gbase; }
    char *egptr() const { return _egptr; }
// Put pointer, and one past end of put area
    char *pbase() const { return _pbase; }
    char *pptr() const { return _pptr; }
    char *epptr() const { return _epptr; }

    int blen() const { return _ebuf-_base; }
// Return the size in characters of the buffer.

    int allocate();
// Try to set up the buffer. If one already exists or unbuffered() is
// non-zero, return 0 without doing anything. If something goes wrong,
// return EOF. Otherwise, return 1. This function is only called by
// virtual members of the base class streambuf, thus you can override
// everything that uses it.

    virtual int doallocate();
// This is called when allocate() determines that space is needed.
// This function must call setb() to set up the buffer, and return
// a non-eof value, or return EOF if it can not get space.
// This function is only called if unbuffered() is zero, and base()
// is zero.
//
// * The default version allocates a buffer using operator new.

    virtual int pbackfail(int c);
// This is called by sputbackc() when the get pointer is equal to
// the base of the get area, and there is thus no space to put back
// characters. It may try to re-arrange the buffer so that it is
// possible to put back characters, and then put back c. If it
// succeeds it should return c, otherwise it should return EOF.
//     * The default version of this member always returns EOF.

    void setg(char *base, char *get, char *end)
    {
        _gbase = base;
        _gptr = get;
        _egptr = end;
    }
// Sets the base of the get area, the get pointer, and the end of
// the get area.

    void setp(char *base, char *end)
    {
        _pbase = _pptr = base;
        _epptr = end;
    }
// Sets the base of the put area, the put pointer, and the end of
// the put area.

    void setb(char *base, char *end, int own = 0);
// Sets the base and end of the buffer. If own is true, then this
// streambuf will delete base in its destructor or if setb() is called
// again.

    void gbump(int n) { _gptr += n; }
    void pbump(int n) { _pptr += n; }

    int unbuffered() const { return _unbuffered; }
    void unbuffered(int u) { _unbuffered = u; }


private:
    char *_base;
    char *_ebuf;
    char *_gbase;
    char *_gptr;
    char *_egptr;
    char *_pbase;
    char *_pptr;
    char *_epptr;
    char _unbuffered;
    char _owned;

    char unbuf[2];
// This is big enough to deal with the translated case when unbuffered

    int     sbumpc_special();
// Called by sbumpc() when get_pointer == get_area_end.
// Simply calls overflow(), increments the get pointer, and
// returns the value returned by overflow(). It's here so that
// the special-case code does not have to be inlined.
};

class ostream : virtual public ios {

// This is the class used for formatted character output.
// The various "operator << (...)" members are called "inserters", because
// they insert information into the character stream.
//
// Unless otherwise noted, all of the functions here that do output set
// the error state on failure.
//
// Where the inserters perform conversions of numbers to a readable string, 
// the conversion is affected by the format state flags in ios::flags() .

public:
    ostream(streambuf * buffer);
// Construct an ostream associated with the argument streambuf.

    virtual ~ostream();

    ostream &flush();
// Flush any characters queued for output.

    int opfx();
// Perform output-prefix operations.
// If the error state is non-zero, return zero immediately.
// If there is a tied ostream (see ios::tie()), flush it.
// Return non-zero. If you define your own inserter that directly
// manipulates the streambuf instead of calling other inserters,
// it should call this when it starts.

    void osfx();
// Perform output-suffix operations.
// If ios::unitbuf is set in the format state, flush output.
// If ios::stdio is set, flush stdio and stderr.
// If you define your own inserter that directly manipulates the
// streambuf, it should call this just before returning.
// All of the inserters in ostream call this.
// The binary put() and write() functions do not call this.

    ostream &put(char c);
// Inserts a character

    ostream &seekp(streampos position);
// Absolute seeks the output stream to "position".

    ostream &seekp(streamoff offset, seek_dir direction);
// Relative seeks the output stream. See streambuf::seekoff()

    streampos tellp();
// Returns the current position in the output stream.

    ostream &write(const void *data, size_t size);
    size_t pcount() { return write_count; }
// Inserts the block of "size" bytes starting at "data". Does not
// perform any formatting. The number of characters successfully
// output can be determined by a following call to ostream::pcount().

    ostream &operator<<(const char *string);
    ostream &operator<<(const signed char *string)
        { return operator<<((const char *) string); }
    ostream &operator<<(const unsigned char *string)
        { return operator<<((const char *) string); }
// Insert a null-terminated string.

    ostream &operator<<(char c);
// Insert a single character.

    ostream &operator<<(signed char c)
        { return operator<<((long) c); }
    ostream &operator<<(unsigned char c)
        { return operator<<((long) c); }
// Insert char values in the sense of byte wide integers, i.e. as
// possibly shorter ints than short int.

    ostream &operator<<(short v) { return operator<<((long) v); }
    ostream &operator<<(int v) { return operator<<((long) v); }
    ostream &operator<<(long);

    ostream &operator<<(float v) { return operator<<((double) v); }
    ostream &operator<<(double);

    ostream &operator<<(unsigned short v)
        { return operator<<((unsigned long) v); }
    ostream &operator<<(unsigned int v)
        { return operator<<((unsigned long) v); }
    ostream &operator<<(unsigned long);
// The above all convert numbers to human-readable character
// strings, and insert them in the output stream. The rules
// of the conversion follow the format state flags in ios::flags() .

    ostream &operator<<(void *);
// Convert a pointer to a hex integer, and insert.

    ostream &operator<<(streambuf *source);
// Insert all of the characters that can be fetched from the streambuf.

    ostream &operator<<(ostream &(*manipulator)(ostream &))
        { return (*manipulator)(*this); }
// Parameterless manipulators are implemented by providing an
// inserter for the type pointer to function taking an ostream reference
// argument and returning an ostream reference.  The specified function
// is simple executed for the current ostream.

    ostream &operator<<(ios &(*manipulator)(ios &))
    {
        (*manipulator)(*this);
        return *this;
    }
// Similar facility to insert a pointer to function taking an ios
// reference argument.

protected:
    ostream();  // ios will be initialized by derived class
private:
    size_t write_count;
// Records number of bytes actually put out by a write()

    void eof_fail();;
// Internal. Set error flags after an I/O EOF error.

    ostream &convert_unsigned(unsigned long, int);
// Internal. Scalar inserter.

    const char *unsigned_to_string(unsigned long, int, int&);
// Internal. Convert long to string, interpreting the format
// control flags.

    int fixed_point(double, char *, int &);
// Internal. Convert double to fixed-point string.

    int sci_notation(double, char *, int &, int &);
// Internal. Convert double to scientific-notation string.

    int adjust(int bit_to_test, int field_width);
// Manages padding
    void flush_stdio();
// Called by osfx() if ios::stdio is set.  This function is in a
// separate module to prevent the stdio stuff from being pulled
// in when it is not required.
};

// The following functions provide parameterless inserters of the
// type noted above. They have to be real functions because we
// need to take their address.

ostream &ends(ostream&);
// Ends a string by inserting a null character. Use this on strstreams
// before you call ostrstream::freeze() .
//
// stream << "whatever" << ends;

ostream &flush(ostream&);
// Flushes output on an ostream.
//
// stream << "whatever" << flush

ostream &endl(ostream &);
// Inserts the appropriate new-line character(s) for the system, and flushes
// output. On Unix the new-line character is inserted. On DOS, the
// carriage-return and new-line characters are inserted. Thus, using endl
// instead of '\n' or "\r\n" is more portable.
//
// stream << "whatever" << endl;

ostream &stickywidth(ostream &);
// Sets the state so that width is not reset after each insertion
// unlatch this by a call to width() or use setw manipulator.

ostream &spacing(ostream &);
ostream &nospacing(ostream &);
// Sets the state so that a space is output after any item which
// makes a call to osfx() except the endl manipulator.

ostream &fixed(ostream &);
ostream &scientific(ostream &);
ostream &showpoint(ostream &);
ostream &floating(ostream &);
// Manipulate the floating point format, floating sets the default
// state.

ostream &leftjust(ostream &);
ostream &rightjust(ostream &);
ostream &internal(ostream &);
ostream &showbase(ostream &);
// Set a justify mode

class istream : virtual public ios {

// This is the class used for character input.
// The various "operator>>(...)" members are called "extractors", because
// they extract information from the character stream.
//  * Where the extractors perform conversions of a string to a number,
// the conversion is affected by the format state flags in ios::flags() .
// Each of the extractors calls ipfx() first, and returns immediately if
// ipfx returns zero. Extractors indicate errors by setting bits of the
// error state. ios::failbit means the input characters weren't a
// representation of the required type. ios::badbit means that the I/O
// system failed to get the required characters.
//  * The unformatted extractors (get(), getline()) will set ios::failbit
// only if they are not able to extract at least one character.
//  * Caveat: The ATT version ignores overflow. This version attempts to set
// the error flags on overflow.

public:
    static int is_white_space(char c);
// Internal. Return 1 if the argument character is white-space,
// otherwise return 0.

    istream(streambuf *buffer);
// Construct a new istream associated with the argument streambuf.

    virtual ~istream();

    size_t gcount() { return read_count; }
// Return the number of characters extracted by the last unformatted
// input function. Other input functions may call the unformatted
// input functions, so this counter is only accurate immediately
// after a call to an unformatted input function.

    istream &get(char *data, int length, char delimiter = '\n');
    istream &get(signed char *data, int length, char delimiter = '\n');
    istream &get(unsigned char *data, int length, char delimiter = '\n');
// Both of these extract up to "length" characters, storing them in
// "data". If a character equal to "delimiter" is seen, it is pushed
// back on the input stream and extraction stops.

    istream &get(char &destination);
    istream &get(signed char &destination);
    istream &get(unsigned char &destination);
// Extract a single character.

    istream &get(streambuf &destination, char delimiter = '\n');
// Call ipfx(0), and if the result is non-zero, get characters until
// the delimiter is seen or EOF, and stuff the characters into the
// streambuf. Doesn't extract the delimiter character. Only sets
// ios::badbit if it can't extract at least one character.

    int get();
// Get one character, and return it in an int. Return EOF if there's
// an error.

    istream &getline(char *data, int length, char delimiter = '\n');
    istream &getline(signed char *data, int length, char delimiter = '\n');
    istream &getline(unsigned char *data, int length, char delimiter = '\n');
// These two are like get(char *data, int length, char delimiter),
// except that they extract the terminating delimiter instead of
// pushing it back.

    istream &ignore(int length = 1, int delimiter = EOF);
// Extract and throw away up to "length" characters. Extraction
// stops if "delimiter" is extracted, or at EOF. If "delimiter"
// is EOF, it won't match any character, and thus will not stop
// extraction.

    int ipfx(int need = 0);
// Perform input-prefix operations.
// The argument "need" is the number of characters that will be
// required, or 0 if you don't know how many you'll need. The
// formatted input functions call this with 0, and the unformatted
// input functions call it with 1.
//      * If the error state is non-zero, this returns zero immediately.
// Otherwise, it returns non-zero when finished.
// If there is a tied stream (see ios::tie()) and need is 0 or greater
// than the number of immediately available characters, the tied
// iostream is flushed.
//      * If ios::skipws is set in the format state, and "need" is zero,
// leading white-space characters are thrown away and the stream
// is advanced to the first available character.
// This returns zero if there is an error while skipping a
// white-space character, otherwise it returns non-zero.

    int peek();
// Calls ipfx(1). If that returns zero, or if the input character
// stream is at EOF, return EOF. Otherwise return the next character
// without extracting it from the input stream.

    istream &putback(char c);
// Attempt to push the last character read back onto the input stream.
// "c" must be the last character read. This does not call ipfx(), but
// it will return without doing anything if the error state is
// non-zero.

    istream &read(void *data, int size);
// Extracts a block of "size" bytes and stores them at "data".
// If EOF is reached before "size" bytes are extracted,
// ios::failbit is set. The number of characters actually
// extracted is available as the return value of istream::gcount().

    istream &seekg(streampos position);
// Absolute-seek the input character stream to "position".

    istream &seekg(streamoff offset, seek_dir direction);
// Relative-seek the input character stream by "offset" relative to
// the current position.

    int sync();
// Establishes consistency between the internal data structure
// and the external character source. This usually means that
// characters that were buffered for input are thrown away, and
// the file pointer is decremented so that it appears that the
// buffered characters were never read.
 
    streampos tellg();
// Return the current file position. The value returned is a magic
// cookie that is usable only as an argument to seekg(streampos).
// Don't perform arithmetic on the return value.

    istream &operator>>(char *);
    istream &operator>>(signed char *s)
        { return operator>>((char *) s); }
    istream &operator>>(unsigned char *s)
        { return operator>>((char *) s); }
// For the string extractors, characters are extracted until a
// white-space is seen. The white-space is pushed back on the
// incoming character stream. If width() is non-zero, it is taken
// as the size of the argument character array, and no more than
// width()-1 characters are extracted. A terminating null character
// is ALWAYS stored, even when nothing else is done because of
// the error state.

    istream &operator>>(char &);
// Extracts a single character, similar to get()

    istream &operator>>(signed char &c);
    istream &operator>>(unsigned char &);
// Extract byte wide integers -128 - +127 and 0 - 255 respectively

    istream &operator>>(short &);
    istream &operator>>(int &);
    istream &operator>>(long &);
// These extract an integer value according to the conversion
// rules in the format state flags. The first character may
// indicate the sign. If ios::oct, ios::dec, or ios::hex are
// set, the number is interpreted using that radix. If none of the
// radix indicators are set, the number is interpreted according
// to the lexical rules for C++ integers: "0x" indicates hex,
// a leading zero indicates octal, and the default is decimal.
// ios::failbit is set if there are no digits (not counting a
// leading "0x") available.

    istream &operator>>(unsigned short &);
    istream &operator>>(unsigned int &);
    istream &operator>>(unsigned long &);
// These extract as the signed integer extractors, except that
// the only sign indicator accepted is "+".
// NOTE: ATT iostreams allows one to enter a negative number into
// an unsigned variable, giving the two's complement.
// This is probably not correct, and isn't allowed here.

    istream &operator>>(float &);
    istream &operator>>(double &);
// These extract floating-point numbers according to the lexical
// rules for C++ floating-point constants. ios::failbit is set
// if there are no digits available, or if the input does not
// parse, and no characters are lost. Badbit is set if the input
// does not parse, and characters were lost in the process.

    istream &operator>>(streambuf*);
// Calls ipfx(0), and if the result is non-zero, extracts characters
// and stuffs them into the argument streambuf until EOF is reached.
// Only sets ios::badbit if it can't get at least one character.

    istream &operator>>(istream &(*manip)(istream&))
    {
        (*manip)(*this);
        return *this;
    }
// Provides an pseudo extractor which allows for parameterless
// manipulators. The target type is pointer to function returning
// istream reference and taking istream reference argument.

    istream &operator>>(ios &(*manip)(ios&))
    {
        (*manip)(*this);
        return *this;
    }
// Similar facility to manipulate an ios object directly

protected:
    istream();  // derived class will initialize ios directly

private:
    
    size_t read_count;
// The number of characters read by the unformatted input functions.

    unsigned long convert_integer(int &negative, int &uns);
// Internal. Convert string representation of integer to
// unsigned long, with sign in a separate variable so that
// one function spans the range of signed and unsigned longs.
// Sets ios::failbit if the result of a conversion won't fit
// in an unsigned long.

};

istream &ws(istream&);
// Manipulator to skip white-space, positioning the input
// character stream to the first available non-white-space
// character.

class iostream : public istream, public ostream {

// A stream that supports both insertion and extraction.

public:
    iostream(streambuf *buf);
// Construct an iostream associated with the argument streambuf.

    virtual ~iostream();
protected:
    iostream(); // derived class will initialize ios directly

};

// Iostream classes that support assignment.
//
// They're used for cin, cout, cerr, and clog, but you should not use them for
// anything else. Instead, use a regular stream and assign a pointer to it.

class istream_withassign : public istream {
public:
    istream_withassign();
    istream_withassign(streambuf *);
    ~istream_withassign();
    istream_withassign &operator=(istream &);
    istream_withassign &operator=(streambuf *);
private:
    short assigned_to;
};

class ostream_withassign : public ostream {
public:
    ostream_withassign();
    ostream_withassign(streambuf *);
    ~ostream_withassign();
    ostream_withassign &operator=(ostream &);
    ostream_withassign &operator=(streambuf *);
private:
    short assigned_to;
};

class iostream_withassign : public iostream {
public:
    iostream_withassign();
    iostream_withassign(streambuf *);
    ~iostream_withassign();
    iostream_withassign &operator=(ios &);
    iostream_withassign &operator=(streambuf *);
private:
    short assigned_to;
};

extern istream_withassign cin;
extern ostream_withassign cout;
extern ostream_withassign cerr;
#ifdef __XENIX__
extern ostream_withassign   clog;
#endif

class IosTies {
public:
    IosTies();
};

extern IosTies __iosties;

#endif  // __IOSTREAM_HPP
