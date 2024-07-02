#ifndef __FSTREAM_HPP
#define __FSTREAM_HPP

// Iostreams Package
// Bruce Perens, July-August 1990
//
// Modified Steve Teale April 1991
// Copyright Zortech 1990-1991. All Rights Reserved.

#include <iostream.hpp>

class filebuf : public streambuf {

// This is a streambuf class specialized for handling files.
// The get and put pointers are locked together so that reads and writes
// happen at the same offset into the file.

public:
    enum { openprot = 0644 };

    filebuf();
// The default constructor. Creats a filebuf that is not associated
// with any file. open() or attach() can then be used to connect
// to a file.

    filebuf(int file_descriptor, int io_mode = ios::in|ios::out
#ifndef __UNIX__
                            |ios::translated
#endif
           );
// Constructs a filebuf for the open file attached to the argument
// file descriptor.  More comprehensive io_mode information can
// be specified e.g. ios::app, if required

    filebuf(int descriptor, char *memory, int length,
                            int io_mode = ios::in|ios::out
#ifndef __UNIX__
                            |ios::translated
#endif
           );
// Constructs a filebuf for the open file attached to the
// file_descriptor, and sets the buffer to "memory", which is of
// "length" bytes in size. If memory is 0 or length is <= 0,
// it is taken as a request that the file be unbuffered.

    ~filebuf();

    filebuf *attach(int file_descriptor,
                            int io_mode = ios::in|ios::out
#ifndef __UNIX__
                            |ios::translated
#endif
           );
// Attaches an open file to a filebuf. Returns "this" if successful,
// 0 if the filebuf is already attached to a file.

    filebuf *close();
// Flushes output, closes the file, and detaches the file from this
// filebuf. Clears the error state unless there is an error flushing
// the output. Will always close the file and detach it from the
// filebuf, even if there are errors.

    int fd() const { return file; };
// Returns the file descriptor for the connected file. If the
// filebuf is closed or not attached to a file, returns EOF.

    int is_open() const { return file != EOF; };
// Returns non-zero when this filebuf is attached to a file,
// otherwise returns zero.

    filebuf *open(const char *name, int io_mode,
                    int protection = openprot);
// Opens the file "name", and connects it to this filebuf.
// io_mode is a bit-mask containing one or more of the values of
// enum open_mode:
// ios::in     Open for reading.
// ios::out    Open for writing.
// ios::ate    Position to the end-of-file.
// ios::app    Open the file in append mode.
// ios::trunc  Truncate the file on open.
// ios::nocreate   Do not attempt to create the file if it
//             does not exist.
// ios::noreplace  Cause the open to fail if the file exists.
// ios::translate  Convert CR/LF to newline on input and
//             vice versa on output

    streampos seekoff(streamoff offset, seek_dir direction,
                                int which);
// Relative seek the get and put pointers within the file.
// The get and put pointers of a filebuf always point to the
// same byte of the file.

    streambuf *setbuf(char *memory, int length);
// Set the buffer to use "memory", of "length" bytes.
// If memory == 0 or length <= 0, it is taken as a request that
// I/O to the file be unbuffered.

    int sync();
// Flush any bytes in the get buffer, and re-position the file so
// that is appears they were never read. Write any bytes in the
// put buffer to the file.

#if __ZTC__ > 0x214
    int overflow(int c);
#else
    int overflow(int c = EOF);
#endif
// Flush bytes in the put area to the file.

    int underflow();
// Get more bytes for reading.

protected:
    int doallocate();

    int pbackfail(int c);
// Called to atempt recovery if putback attempted at
// start of get buffer

private:
    int file;   // File descriptor for the associated file.
    short mode; // I/O mode from the argument to open().
    char unbuf[2];
                // pseudo buffer for unbuffered operation
    char *gptr_;
    char *egptr_;
                // Save old gptr() & egptr() while using the
                // pushback buffer.
    char pushback_buf[4];
                // Reserve buffer for pushback.
                // Only used if there is no room for pushback in
                // the regular buffer.
    char do_not_seek;
                // Set if the file (device) does not support seeks.
                // This is set for a TTY, or a Unix pipe.
    char own_file_descriptor;
                // Set if the file descriptor is from open, and
                // the file should be closed by the destructor.
    static const int lseek_consts[3];
                // A look up table for the lseek constants from
                // the appropriate C header file

    void buffer_setup();
                // Internal. Set up I/O buffer.
    int newlines();
                // count newline chars in the get buffer
    int syncin();
    int syncout();
                // two halves of sync() function
    int fillbuf();
    int flushbuf();
                // Functions which actually transfer to/from
                // the file
};

class fstream_common : virtual public ios {

// Features common to ifstream, ofstream, and fstream.

public:

    void attach(int file_descriptor, int io_mode);
// Attach the filebuf to the argument file descriptor, error state
// set to ios::failbit|ios::badbit on failure.

    void close();
// Flush the filebuf, and close the file attached to it. Error state
// set ios::failbit|ios::badbit if rdbuf()->sync() fails. File closed
// regardless.

    void open(const char *name, int io_mode,
                int protection = filebuf::openprot);
// Open a file, and attach it to the filebuf. Error state set to
// ios::failbit|ios::badbit on failure

    void setbuf(char *memory, int length)
    {
        buffer.setbuf(memory, length);
    }
// Use the argument memory, of the given length, as the I/O buffer.
    filebuf *rdbuf() { return &buffer; }
// Note that fstream_common::rdbuf returns a filebuf*
// instead of a streambuf*.

protected:
    fstream_common();
    filebuf buffer;
};

class ifstream : public fstream_common, public istream {
public:
    ifstream();
// Create an ifstream not attached to any file.

    ifstream(const char *name, int io_mode = ios::in | ios::nocreate
#ifndef __UNIX__
                                            | ios::translated
#endif
                    ,int protection = filebuf::openprot);
// Open the argument file and create an ifstream attached to it.
                
    ifstream(int file_descriptor, int io_mode = ios::in
#ifndef __UNIX__
                                            | ios::translated
#endif
            );
// Create an ifstream attached to the argument file descriptor.

    ifstream(int file_descriptor, char *memory, int length,
                                            int io_mode = ios::in
#ifndef __UNIX__
                                            | ios::translated
#endif
            );
// Create an ifstream attached to the argument file descriptor, and
// using the argument memory as the I/O buffer.

    ~ifstream();

    void attach(int file_descriptor, int io_mode = ios::in
#ifndef __UNIX__
                                            | ios::translated
#endif
               )
    {
        fstream_common::attach(file_descriptor, io_mode);
    }

    void open(const char *name, int io_mode = ios::in
#ifndef __UNIX__
                                            | ios::translated
#endif
                    ,int protection = filebuf::openprot)
    {
        fstream_common::open(name, io_mode, protection);
    }

};

class ofstream : public fstream_common, public ostream {
public:
    ofstream();
// Create an ofstream not attached to any file.

    ofstream(const char *name, int io_mode = ios::out
#ifndef __UNIX__
                                    | ios::translated
#endif
                    ,int protection = filebuf::openprot);
// Open the argument file and create an ofstream attached to it.
                
    ofstream(int file_descriptor, int io_mode = ios::out
#ifndef __UNIX__
                                    | ios::translated
#endif
            );
// Create an ofstream attached to the argument file descriptor.

    ofstream(int file_descriptor, char *memory, int length,
                                    int io_mode = ios::out
#ifndef __UNIX__
                                    | ios::translated
#endif
            );
// Create an ofstream attached to the argument file descriptor, and
// using the argument memory as the I/O buffer.

    ~ofstream();

    void attach(int file_descriptor, int io_mode = ios::out
#ifndef __UNIX__
                                            | ios::translated
#endif
               )
    {
        fstream_common::attach(file_descriptor, io_mode);
    }

    void open(const char *name, int io_mode = ios::out
#ifndef __UNIX__
                                            | ios::translated
#endif
                    ,int protection = filebuf::openprot)
    {
        fstream_common::open(name, io_mode, protection);
    }

};


class fstream : public fstream_common, public iostream {
public:
    fstream();
// Create an fstream not attached to any file.

    fstream(const char *name, int io_mode = ios::in|ios::out
#ifndef __UNIX__
                                        | ios::translated
#endif
                    ,int protection = filebuf::openprot);
// Open the argument file and create an fstream attached to it.
                
    fstream(int file_descriptor, int io_mode = ios::in | ios::out
#ifndef __UNIX__
                                        | ios::translated
#endif
            );
// Create an fstream attached to the argument file descriptor.

    fstream(int file_descriptor, char *memory, int length,
                                        int io_mode = ios::in | ios::out
#ifndef __UNIX
                                        | ios::translated
#endif
            );
// Create an fstream attached to the argument file descriptor, and
// using the argument memory as the I/O buffer.

    ~fstream();

    void attach(int file_descriptor, int io_mode = ios::in | ios::out
#ifndef __UNIX__
                                            | ios::translated
#endif
               )
    {
        fstream_common::attach(file_descriptor, io_mode);
    }

    void open(const char *name, int io_mode = ios::in | ios::out
#ifndef __UNIX__
                                            | ios::translated
#endif
                    ,int protection = filebuf::openprot)
    {
        fstream_common::open(name, io_mode, protection);
    }

};

#endif  // __FSTREAM_HPP
