#ifndef __SSTREAM_HPP
#define __SSTREAM_HPP

// Iostreams Package
// Bruce Perens, July-August 1990
//
// Modified Steve Teale April 1991
// Copyright Zortech 1990-1991. All Rights Reserved.

#include <iostream.hpp>

const int default_allocation = 32;

class strstreambuf : public streambuf {

// This is a streambuf that holds a character array, and I/O is to that
// character array instead of a file or some external character stream.
// There is a dynamic-allocation mode that allocates space for characters
// as needed. Get, put, and seeks are supported within the character array.
// The call freeze() returns a pointer to the array, so that the data may
// be read by conventional string-handling routines.

public:

// state flags
    enum sstream_flags {
        statmem = 1,
// Set if the buffer was set with an argument to the constructor or
// setbuf, and I should not do dynamic allocation if it runs out of
// space.

        frozen = 2,
// Set when the buffer is frozen.
        merged = 4,
// Set if the get and put areas are considered to be overlapped. This
// will be the case if the strstreambuf is dynamic, or if a simultaneous
// seek of both the get and put pointers has been done.
        rdonly = 0x10
// Puts are not allowed.
    };

    strstreambuf(int chunksize = default_allocation);
// Create a strstreambuf in dynamic-allocation mode, with the initial
// allocation at least "chunksize" bytes long, defaulted to default
// allocation

    strstreambuf(char *memory, int length = 0,
                    char *start_of_put_area = 0);
// Create a strstreambuf using the static buffer at "memory".
// If "length" is positive, that is taken as the length of the
// buffer. If it is zero, the length is taken from strlen(memory).
// If "length" is negative, the buffer is assumed to be of infinite
// length.
//
// The get pointer is initialized to "memory". If "start_of_put_area"
// is zero, the get area covers the entire buffer and a put will be
// considered an error. If "start_of_put_area" is non-zero, the
// get area consists of the bytes between "memory" and
// "start_of_put_area" - 1, and the put area consists of the bytes
// between "start_of_put_area" and the end of the buffer.

    strstreambuf(unsigned char *memory, int length = 0,
                    unsigned char *start_of_put_area = 0);
// Same as above, but for an unsigned character buffer.

    strstreambuf(void * (*allocate_function)(size_t),
                    void (*free_function)(void *),
                    int chunksize = default_allocation);
// Create a streambuf in dynamic allocation mode. Use
// void * allocate_function(size_t length) to allocate memory,
// and void free_function(void * memory) to free it. Allocation
// chunk size can be specified.

    ~strstreambuf();

    void freeze(int on = 1);
    void unfreeze() { freeze(0); }
// If the argument is non-zero, "freeze" the strstreambuf. This
// inhibits automatic deletion of the current character buffer.
// This is only important in dynamic-allocation mode. Stores into
// the buffer are invalid when it is "frozen". Calling this with
// a zero argument "un-freezes" the buffer. Deleting a strstreambuf
// will not de-allocate a frozen buffer - you must delete it yourself.

    int pcount() const { return pptr()-pbase(); }
// Return the number of characters inserted. Not accurate after
// a seek.

    char *str();
// Freeze the buffer and return a pointer to its first byte.
// The pointer may be null if no bytes have been stored and the
// buffer is in dynamic-allocation mode. The buffer may be "un-frozen"
// by calling freeze(0). Deleting a strstreambuf will not de-allocate
// a frozen buffer - you must delete it yourself.

    streambuf *setbuf(char *memory, int length);
// The memory argument is not used. The next time the streambuf
// does dynamic allocation, it will allocate at least "length" bytes.
// This function in fact sets the allocation granularity.

#if __ZTC__ > 0x214
    int overflow(int c = EOF);
#else
    int overflow(int c);
#endif

    int underflow();
    streampos seekoff(streamoff offset, seek_dir direction,
                    int which =ios::in|ios::out);
    int sync();
// All of these are virtual functions derived from streambuf.
// There's more documentation on them in iostream.h .

protected:
    int doallocate();

private:
    short sflags;
    int chunk;
// The minimum amount to allocate when doing dynamic allocation.

    void *(*allocate_function)(size_t size);
// Points to the function used to allocate memory.

    void (*free_function)(void *memory);
// Points to the function used to free memory.

    void buffer_setup(char *memory, int length,
                    char *start_of_put_area);
};

class istrstream : public istream {

// A class of istream that takes as input a character array, and extracts
// information from it.

public:
    istrstream(char *memory, int length = 0);
// Create an istrstream attached to the character array at "memory",
// of length "length". If length is zero, strlen() is used, if length
// is negative, the stream is considered to be of a length equivalent
// to the maximum value of type size_t.

    ~istrstream();
    strstreambuf *rdbuf() { return &buffer; }

private:
    strstreambuf buffer;
};

class ostrstream : public ostream {

// A class of ostream that inserts information into a character array.

public:
    ostrstream();
// Create an ostrstream in dynamic-allocation mode.

    ostrstream(char *memory, int length, int mode=ios::out);
// Create an ostrstream attached to the character array at "memory",
// of length "length". If ios::ate or ios::app is set in "mode",
// the buffer is assumed to contain a null-terminated string, and
// the put area begins at the null character. Otherwise the put
// area will begin at "memory".

    ~ostrstream();

    int pcount() const { return buffer.pcount(); }
// Returns the number of bytes that have been put into the buffer.

    char *str();
// Freezes the buffer, and returns a pointer to the first byte of the
// buffer. Once the buffer is frozen it will not be deleted by
// the destructor of the stream: it becomes the user's responsibility
// to delete it.
    void unfreeze();
// Unfreeze the buffer and unconditionally clear the state flags.

    strstreambuf *rdbuf() { return &buffer; }
private:
    strstreambuf buffer;
};


class strstream : public iostream {

// A class of iostream that inserts and extracts information in a character
// array.

public:
    strstream();
// Create a strstream in dynamic-allocation mode.

    strstream(char *memory, int length = 0, int mode = ios::in|ios::out);
// Create a strstream attached to the character array at "memory",
// of length "length". If length is zero, then "memory" is assumed to
// contain a null terminated string, and the langth is taken from
// strlen. If ios::ate or ios::app is set in "mode", the buffer is
// assumed to contain a null-terminated string, and the put area begins
// at the null character. Otherwise the put area will begin at "memory".

    ~strstream();

    char *str();
// Freezes the buffer, and returns a pointer to the first byte of the
// buffer. Once the buffer is frozen it will not be deleted by
// the destructor of the stream: it becomes the user's responsibility
// to delete it.
    void unfreeze();
// Unfreeze the buffer and unconditionally clear the state flags.

    strstreambuf *rdbuf() { return &buffer; }

private:
    strstreambuf buffer;
};

#endif // __SSTREAM_HPP
