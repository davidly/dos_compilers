// NT Virtual Apple One
// Written by David Lee
// Simulates the Apple 1 runtime environment enough to run simple apps.
// Uses the mos6502 emulator for the CPU
// Hooks are installed to emulate the Apple 1's keyboard and display functionality.
// If the monitor is loaded, it overwrites those hooks with the real code.
// Useful:  https://www.sbprojects.net/projects/apple1/wozmon.php
//          http://s3data.computerhistory.org/brochures/apple.applei.1976.102646518.pdf
//

#define UNICODE

#include <stdio.h>
#include <vector>
#include <chrono>

#ifdef _MSC_VER
    #include <conio.h>
    #include <windows.h>
    #include <djltrace.hxx>
    #include <djl_cycle.hxx>
    #include <djl_con.hxx>
#else
    #include <unistd.h>
    #include <sys/select.h>
    #include <termios.h>
    #include <time.h>
    template < typename T, size_t N > size_t _countof( T ( & arr )[ N ] ) { return std::extent< T[ N ] >::value; }    
    #define _stricmp strcasecmp
    #define MAX_PATH 1024
    #include <djltrace.hxx>
#endif

using namespace std;
using namespace std::chrono;

#include "mos6502.hxx"

CDJLTrace tracer;
static bool g_executionEnded = false;
static bool g_KbdPeekHappened = false;
static bool g_forceUppercase = true; // the apple 1 way
static uint16_t g_startAddress = 0xff00; // The monitor entrypoint
static bool g_fStartAddressSpecified = false;
static bool g_useHooks = false;
static bool g_use40x24 = true;

template <class T> T get_max( T a, T b )
{
    if ( a > b )
        return a;
    return b;
}

template <class T> T get_min( T a, T b )
{
    if ( a < b )
        return a;
    return b;
}

void usage( char const * perr = 0 )
{
    if ( perr )
        printf( "error: %s\n", perr );

    printf( "NT Virtual Apple 1 Machine: emulates an Apple 1 on Windows\n" );
    printf( "usage: ntvao [-a] [-c] [-i] [-p] [-s:X] [-t] [-u] [.hex file>]\n" );
    printf( "  arguments:\n" );
    printf( "     -a     address at which the run is started, e.g. /a:0x1000\n" );
    printf( "            this overrides the default, which is 0xff00 or the first address in the input file.\n" );
#ifdef _MSC_VER
    printf( "     -c     don't set the console to 40x24. do exit ntvao when the Apple 1 app completes.\n" );
#else
    printf( "     -c     Exit ntvao when the Apple 1 app completes.\n" );
#endif
    printf( "     -h     don't automatically install the Apple 1 monitor and BASIC; use hook emulation instead.\n" );
    printf( "     -i     when tracing is enabled with -t, also show each instruction executed.\n" );
    printf( "     -p     show performance information at app exit.\n" ); 
    printf( "     -s:X   speed in Hz. Default is as fast as possible.\n" );
    printf( "            for the Apple 1's speed use -s:1022727\n" );
    printf( "     -t     enable debug tracing to ntvao.log\n" );
    printf( "     -u     disable converting output chars to uppercase.\n" );
    printf( "  notes:\n" );
    printf( "     --     to assemble, load, and run test.s:\n" );
    printf( "                sbasm30306\\sbasm.py test.s\n" );
    printf( "                ntvao -c test.hex\n" );
    printf( "     --     .hex files can be in Apple 1 format or Intel hex format.\n" );
    printf( "     --     any 6502 app will run but with no OS support it can be hard to tell.\n" );
    printf( "     --     when using -c, ntvao will exit when the app calls 0xff1f instead of starting the monitor\n" );
    printf( "     --     control keys:\n" );
    printf( "                ^c        gracefully exit the ntvao\n" );
    printf( "                ^d        save a 64k memory dump in ntvao.dmp\n" );
    printf( "                ^l        load a file into the keyboard input stream. This is\n" );
    printf( "                          likely an Apple 1 format .hex for monitor or .bas for BASIC\n" );
    printf( "                ^q        quit ntvao at the next app keyboard read\n" );
    printf( "                ^r        soft reset via the 6502's 0xfffc reset vector\n" );
    printf( "                ^break    forcibly exit the app\n" );
    exit( -1 );
} //usage

#ifdef _MSC_VER

    void output_char( char ch )
    {
        printf( "%c", ch );
    } //output_char

#else

    struct termios orig_termios;

    void reset_terminal_mode()
    {
        tcsetattr( 0, TCSANOW, &orig_termios );
    }

    void set_conio_terminal_mode()
    {
        struct termios new_termios;

        tcgetattr( 0, &orig_termios );
        memcpy( &new_termios, &orig_termios, sizeof( new_termios ) );

        atexit( reset_terminal_mode );
        cfmakeraw( &new_termios );
        tcsetattr( 0, TCSANOW, &new_termios );
    } //set_conio_terminal_mode

    int _kbhit()
    {
        struct timeval tv = { 0L, 0L };
        fd_set fds;
        FD_ZERO( &fds );
        FD_SET( 0, &fds );
        return ( select( 1, &fds, NULL, NULL, &tv ) > 0 );
    }

    int _getch()
    {
        int r;
        unsigned char c;

        if ( ( r = read( 0, &c, sizeof( c ) ) ) < 0 )
            return r;

        return c;
    } // _getch

    void output_char( char ch )
    {
        if ( 0xa == ch )
            printf( "%c", 0xd );
        
        printf( "%c", ch );
        fflush( stdout );
    } //output_char

    char * gets_s(  char * buf, size_t bufsize )
    {
        // getline (hangs, no echo)
        // fscanf (works, no echo )
        // fgets (hangs, no echo)

        size_t len = 0;
        do
        {
            char ch = _getch();
            if ( '\n' == ch || '\r' == ch )
            {
                output_char ( 0xa );
                break;
            }

            if ( len >= ( bufsize - 1 ) )                
                break;

            if ( 0x7f == ch || 8 == ch ) // backspace (it's not 8 for some reason)
            {
                if ( len > 0 )
                {
                    output_char( 8 );
                    output_char( ' ' );
                    output_char( 8 );
                    len--;
                }
            }
            else
            {
                output_char( ch );
                buf[ len++ ] = ch;
            }
        } while( true );

        buf[ len ] = 0;
        return buf;
    
    }

#endif

void DumpBinaryData( uint8_t * pData, uint32_t length, uint32_t indent )
{
    uint64_t offset = 0;
    uint64_t beyond = length;
    const uint64_t bytesPerRow = 32;
    uint8_t buf[ bytesPerRow ];

    while ( offset < beyond )
    {
        for ( int i = 0; i < indent; i++ )
            tracer.TraceQuiet( " " );

        tracer.TraceQuiet( "%#10llx  ", offset );

        uint64_t cap = get_min( offset + bytesPerRow, beyond );
        uint64_t toread = ( ( offset + bytesPerRow ) > beyond ) ? ( length % bytesPerRow ) : bytesPerRow;

        memcpy( buf, pData + offset, toread );

        for ( uint64_t o = offset; o < cap; o++ )
            tracer.TraceQuiet( "%02x ", buf[ o - offset ] );

        uint32_t spaceNeeded = ( bytesPerRow - ( cap - offset ) ) * 3;

        for ( uint32_t sp = 0; sp < ( 1 + spaceNeeded ); sp++ )
            tracer.TraceQuiet( " " );

        for ( uint64_t o = offset; o < cap; o++ )
        {
            char ch = buf[ o - offset ];

            if ( ch < ' ' || 127 == ch )
                ch = '.';
            tracer.TraceQuiet( "%c", ch );
        }

        offset += bytesPerRow;

        tracer.TraceQuiet( "\n" );
    }
} //DumpBinaryData

void CreateMemoryDump()
{
    FILE * fp = fopen( "ntvao.dmp", "w" );
    if ( 0 == fp )
    {
        tracer.Trace( "can't create memory dump file, error %d\n", errno );
        return;
    }

    uint64_t offset = 0;
    uint64_t length = 65536;
    const uint64_t bytesPerRow = 32;

    while ( offset < length )
    {
        fprintf( fp, "%04X: ", (uint32_t) offset );

        for ( uint64_t o = offset; o < ( offset + bytesPerRow ); o++ )
            fprintf( fp, "%02X ", memory[ o ] );

        offset += bytesPerRow;
        fprintf( fp, "\n" );
    }

    fclose( fp );
} //CreateMemoryDump

void mos6502_invoke_halt( void )
{
    g_executionEnded = true;
} //mos6502_invoke_halt

// this hook is invoked to emulate an Apple 1 if the Apple 1 monitor isn't installed

uint8_t mos6502_invoke_hook( void )
{
    uint16_t address = cpu.pc;

    if ( 0xffe5 == address ) // apple 1
    {
        printf( "%X", 0xf & cpu.a );
        return 0x60; // rts
    }
    else if ( 0xffdc == address ) // apple 1
    {
        printf( "%02X", cpu.a );
        return 0x60; // rts
    }
    else if ( 0xffef == address ) // apple 1
    {
        char c = cpu.a;
#ifdef _MSC_VER        
        if ( 0x0d != c )
#endif        
        {
            if ( g_forceUppercase )
                c = toupper( c );
            output_char( c );
        }

        return 0x60; // rts
    }
    else if ( 0xff1f == address )
    {
        // On the Apple 1 this emits a CR then returns to the monitor
        // Here the app is just terminated

        output_char( '\n' );

        g_executionEnded = true;
        cpu.end_emulation();
        return 0;
    }

    return memory[ address ];
} //mos6502_invoke_hook

static vector<char> g_inputText;
static uint32_t g_inputOffset = 0;

void LoadInputFile()
{
    printf( "filename to read: " );
    fflush( stdout );
    char acfilename[ MAX_PATH ];
    char * result = gets_s( acfilename, _countof( acfilename ) );
    if ( result )
    {
        tracer.Trace( "reading file %s to input stream\n", result );
        FILE * fp = fopen( result, "r" );
        if ( fp )
        {
            uint32_t sizeSoFar = 0;
            int prev = 0;
            do
            {
                int next = fgetc( fp );
                if ( EOF == next )
                    break;

                if ( 0xa == next ) // the Apple 1 uses 0x0d; Windows uses 0x0a.
                    next = 0xd;

                if ( 0xd == next && prev == 0xd )
                    continue;

                prev = next;
                g_inputText.resize( sizeSoFar + 1 );
                g_inputText[ sizeSoFar ] = (char) next;
                sizeSoFar++;
            } while( true );
            
            fclose( fp );
        }
        else
        {
            printf( "failed to open the file, error %d", errno );
            output_char( 0xa ); // so linux and Windows can each do their thing
        }
    }
} //LoadInputFile

uint8_t mos6502_apple1_load( uint16_t address )
{
    // only called just before a load of these addresses

    if ( 0xd011 == address )
    {
        // KBDCR -- sets bit 7 when a key is available

        if ( g_inputText.size() > 0 )
            return 0x80; // a key is available

        g_KbdPeekHappened = true;

        if ( _kbhit() )
        {
            // if the input event is a control character, process it and don't pass it on
            // 1..26 are ^a through ^z. ^c isn't sent through _getch. pass through carriage returns and backspace

            char ch = _getch();
#ifndef _MSC_VER
            if ( 0xa == ch )
                ch = 0xd;
#endif

            if ( ch < 26 && 0x08 != ch && 0x0d != ch && 0x7f != ch )
            {
                // ^ character processing...

                if ( 17 == ch ) // 'q' for quit
                {
                    g_executionEnded = true;
                    cpu.end_emulation();
                }
                else if ( 4 == ch ) // 'd'
                    CreateMemoryDump();
                else if ( 12 == ch ) // 'l'
                {
                    LoadInputFile();
                    if ( g_inputText.size() > 0 )
                        return 0x80;
                }
                else if ( 18 == ch ) // 'r'
                    cpu.soft_reset();

                return 0; // no key is available for the emulated app -- control codes are for the host
            }

            // translate backspace to what the Apple 1 wants -- an undercore, which virtually backspaces

            if ( 0x08 == ch || 0x7f == ch )
                ch = 0x5f;

            // put the character in the buffer to be read later

            g_inputText.resize( 1 );
            g_inputText[ 0 ] = ch;
            g_inputOffset = 0;
            return 0x80;    // a key is available
        }
        else
        {
#ifdef _MSC_VER            
            SleepEx( 1, FALSE ); // prevent a tight busy loop
#else
            struct timespec ts;
            ts.tv_sec = 0;
            ts.tv_nsec = 10000000; // 10ms.  ms * 10^6 == ns.
            nanosleep( &ts, 0 );            
#endif            
            return 0; // high bit off, no key available
        }
    }
    else if ( 0xd010 == address )
    {
        // KBD -- returns an uppercase char if a key is available. It's up to the caller
        // to be certain one is ready using KBDCR. This function won't block.

        if ( g_inputText.size() > 0 )
        {
            char ch = g_inputText[ g_inputOffset++ ];
            if ( g_inputOffset == g_inputText.size() )
            {
                g_inputOffset = 0;
                g_inputText.resize( 0 );
            }

            ch = toupper( ch );      // the Apple 1 expects only upppercase
            ch |= 0x80;              // the high bit should be set on the Apple 1
            memory[ 0xd011 ] = 0;    // this should alread be reset
            return ch;
        }

        g_KbdPeekHappened = true;

        if ( _kbhit() )
        {
            char ch = _getch();
            tracer.Trace( "_getch returned %02x\n", ch );
            ch = toupper( ch );      // the Apple 1 expects only upppercase
            ch |= 0x80;              // the high bit should be set on the Apple 1
            memory[ 0xd011 ] = 0;    // this should alread be reset
            return ch;
        }
    }

    return memory[ address ];
} //mos6502_apple1_load

void mos6502_apple1_store( uint16_t address )
{
    // only called just after a store of these addresses

    if ( 0xd012 == address )
    {
        char ch = 0x7f & memory[ 0xd012 ];
        if ( 0x7f != ch && 0x0a != ch ) // ignore 0a, and translate 0d to 0a, and 7f, which programs the hardware
        {
            if ( 0x0d == ch )
                ch = 0x0a;

            output_char( ch );
        }
        memory[ 0xd012 ] = 0;  // Indicate that the character has been consumed
    }
} //mos6502_apple1_store

// Note that I didn't write nor do I own the monitor and basic code here.

const uint64_t MonitorCode[] =
{
    0xa9d0128c7fa058d8, 0xc9d0138dd0118da7, 0xc803f09bc913f0df, 0xa9ffef20dca90f10, 
    0x308801a0ffef208d, 0x10adfb10d011adf6, 0xc9ffef20020099d0, 0xaa00a9ffa0d4d08d, 
    0xc90200b9c82b850a, 0xf0f490aec9d4f08d, 0xf0d2c9ebf0bac9f0, 0xb92a84298628863b, 
    0x06900ac9b0490200, 0x0a0a1190fac98869, 0x2628260a04a20a0a, 0xc4e0d0c8f8d0ca29, 
    0xa510502b2497f02a, 0xe6b5d026e6268128, 0x3000246cff444c27, 0x95259527b502a22b, 
    0x8da914d0f7d0ca23, 0xffdc2025a5ffef20, 0x20baa9ffdc2024a5, 0xa1ffef20a0a9ffef, 
    0x24a52b86ffdc2024, 0xc1b029e525a528c5, 0x24a525e602d024e6, 0x4a4a4a48c8100729, 
    0x090f2968ffe5204a, 0x2c06690290bac9b0, 0x60d0128dfb30d012, 0x0000ff000f000000, 
};

const uint64_t BasicCode[] =
{
    0xfb10d011ade2b04c, 0xf020298a60d010ad, 0xe3c94ce485a0a923, 0x8da90cb024c520a9, 
    0x88a0a9e3c92007a0, 0xe2e6e2b100a0f8d0, 0xe7152060e3e602d0, 0xa5e6c5e2a5e57620, 
    0xe06d20efb0e7e5e3, 0xa5e285caa5e03b4c, 0xa5e6854ca5e385cb, 0xe71520ded0e7854d, 
    0xa5e285e4a5e56d20, 0xa9d886c7b0e385e5, 0x8598e02a20fa85a0, 0xe02a20aae02a20e4, 
    0xfa84e01820e51b20, 0xe4a5e9100a1810aa, 0xc9208ae0112003d0, 0x30aae01a2025a9e3, 
    0xa605d001c9e485f5, 0xa2ce8448e3cd4cd8, 0xc6049051c9cf86ed, 0x88aaceb14850e9cf, 
    0x04b0c0e0fa10ceb1, 0x01e968aaf23000e0, 0xf8200330e424e9d0, 0x3f29aa1010ceb1ef, 
    0xe3c920a06918e485, 0xe00c20ec90c0e088, 0xd028c9a4f05dc968, 0x5095e118209ef08a, 
    0xe04c2ba0119078d5, 0xf49050d5ee3420e3, 0xe8234c7895efe420, 0x01e938e7f0ee3420, 
    0xf5185095e1182060, 0xd6d014a0e1024c78, 0xda8550b5e8e11820, 0xdb8578b5a848ce65, 
    0xb0cbe5cac448cf65, 0xa9da85fe69daa5e3, 0xb1c8db85db65a8ff, 0xf0980fd000ccd9da, 
    0x8800cc99da9168f5, 0xd080a0ea60e8f710, 0x02a0e70a2000a995, 0x20bfa9e70a207894, 
    0x94e29e2000a0e3c9, 0xce8551b5eaeaea78, 0xbc20e8e8cf8579b5, 0xf615b076d54eb5e1, 
    0xe4c450b4ceb1a84e, 0xda91c1d083a00490, 0x918a50b4e59050f6, 0xda8551b560e8e8da, 
    0x8579b5e48502e938, 0xb100a0e58500e9db, 0xb560e485dae518e4, 0xb5cf857bb5ce8553, 
    0xe8db8579b5da8551, 0xa094789400a0e8e8, 0x0875d54db55094c8, 0x68079077d54fb548, 
    0xb1a860505602b028, 0xf3b028a868e485ce, 0x4ff6edd0e4c5dab1, 0x4ce1d720d7b04df6, 
    0x26ce06e25420e736, 0xda65e6a5180d90cf, 0xe785db65e7a5e685, 0x10e726e60609f088, 
    0x0820e6a5e77e4ce4, 0x90e506a095e7a5e7, 0xe58555a9e76f4c28, 0xa5da85cea5e25b20, 
    0xe684e71520db85cf, 0x06ca0910cfa5e784, 0xa0e71520e76f20e5, 0xffc5f0ee6c206010, 
    0xdfc9f84602d084c9, 0x009906f09bc911f0, 0xc4208ba00a10c802, 0x0320f6308801a0e3, 
    0x8dc9e3c920eaeae0, 0x60020099dfa9d6d0, 0xd946e3cd20efd320, 0x8400a0e3c920bea9, 
    0xa5f6a60c10f824fa, 0xc920a0a9e51b20f7, 0x84e29e209affa2e3, 0x912020a2c8858af1, 
    0xa9e0850069c8a5e4, 0xe0a1e1850269aa00, 0x834c03f0b0c9f029, 0x00cd99e0b102a0e8, 
    0xf1a5e38a20f8d088, 0xe091a8f004c9c8e5, 0xcba5e485e0f1caa5, 0xccc5e4a5e58500e9, 
    0xcaa54590cde5e5a5, 0x00e9cba5e685e0f1, 0xcae6e691cab1e785, 0xcac5e2a5cbe602d0, 
    0xe4b5e0b0cbe5e3a5, 0xa8e0b1f910caca95, 0xf8d098e691e0b188, 0xf575f7b50910f824, 
    0x007e10f7f0e8f795, 0x2071d014a0000000, 0xe3a5e685e2a5e715, 0x85e2a5e57520e785, 
    0x200ed0e585e3a5e4, 0x85e6a5e56d20e715, 0xa500a0e385e7a5e2, 0xb0e5e5cba5e4c5ca, 
    0xc6e5c602d0e4a516, 0xc6e7c602d0e6a5e4, 0xa5e090e691e4b1e6, 0x60cb85e7a5ca85e6, 
    0x30eb00b9c8e3c920, 0x8500a906d08dc9f7, 0xd0122c24e68da924, 0x06a060d0128dfb30, 
    0x4c0330d924eed320, 0xa0692aeb9a4ce2b6, 0x0afeb153d00200dd, 0xc82930feb1880630, 
    0xfea100a24898c886, 0xc0c9fe1148494aaa, 0xa868f3d0c8e80190, 0xf1a6f1e6e4c04c8a, 
    0xc8a66002009dbcf0, 0xfab00200dde8a0a9, 0xbdb6d04a3f29feb1, 0x1ac93f6906b00200, 
    0x69900ac94f696f90, 0xc9e029feb1c8fda6, 0xb5c885a8b57af020, 0x100afeb188f185d1, 
    0xb435300a38b088fa, 0xda10e880b4ff8458, 0x10ca22b07ec9b3f0, 0xa48094291006a004, 
    0xa4a894c8a45894ff, 0x20b9a81f29d194f1, 0xff852a76a9a80aec, 0xfeb1fd86c8c801d0, 
    0xe04c0ea005d08430, 0xc8a64ac3b003c9e3, 0xa2c904900200bde8, 0xc88606f0dfc90af0, 
    0xb1fda688c8e41c20, 0x8458b4cf100a88fe, 0x9f29feb1e880b4ff, 0x4898f385f285edd0, 
    0xa918c984d0b4fd86, 0x00b9c800a2f9850a, 0x658a48f2650f2902, 0xd0f9c668aa1c30f3, 
    0xd0f1c4f386f285f2, 0x1c20f184c8c9a4de, 0xa0a9b0f3a5a868e4, 0xa2f286f3858b1000, 
    0xa5f985b0a9c98604, 0x68fdf3a5e563ddf2, 0xfdf2a5f3850d90e5, 0xe7d0f9e6f285e563, 
    0xb0c90ef0cae8f9a5, 0x0430c924c98502f0, 0x24e3c9200bf0faa5, 0xcac80200990410f8, 
    0x10e8640a0160c110, 0x85caa52703000000, 0xe7a5e8e785cba5e6, 0x4cc5e485e6a5e585, 
    0x01a026b04de5e5a5, 0xe5e4b1c8cee5e4b1, 0x71e6a500a019b0cf, 0x18e7e60390e685e4, 
    0xcfa5c8e4f1cea5c8, 0xa5f84660cab0e4f1, 0xa5cb854da5ca854c, 0xa9cd854ba5cc854a, 
    0xa9fe85fc85fb8500, 0x0569d0a5601d8500, 0xd3850069d1a5d285, 0xcbe5d3a5cac5d2a5, 
    0x91cea5e36b4c0390, 0xd2a5d091c8cfa5d0, 0xd091c8d3a5d091c8, 0xd091c8d091c800a9, 
    0xcd85d3a5cc85d2a5, 0xcf84ce854390d0a5, 0xf040c90e30e6ff20, 0xd049c906e6284c0a, 
    0xe6ff20cf8549a907, 0xd0854aa5d1854ba5, 0x94b0cde5d1a5ccc5, 0xb106d0cec5c8d0b1, 
    0xd0b1c80ef0cfc5d0, 0xa068d185d0b1c848, 0x200369d0a5dbf000, 0x78950069d1a5e70a, 
    0x98881cd040c9cfa5, 0x03a0789488e70a20, 0x10f930d0b1c878f6, 0xa2d585d48500a909, 
    0x1810e0b100a04820, 0x0820e6ff2081300a, 0xd424a095e6ff20e7, 0xe6b0e6ff20ca0110, 
    0x0a20e0a51fd028c9, 0x30d4247895e1a5e7, 0x00a9e70a2001a90b, 0x30e6ff2078f67895, 
    0xc90610d424d3b0f9, 0xd685a8d446d0b004, 0xd7850a5529e998b9, 0xc5aa29e998b9a868, 
    0xe6ff20489809b0d7, 0x85ea10b99590d6a5, 0xfc20cf85ea88b9ce, 0xe600ce6ce6d84ce6, 
    0x60e0b1e1e602d0e0, 0x6050950330ca7794, 0xb500a0e3e04c66a0, 0xb5cf85a0b5ce8550, 
    0x48ceb1cf850ef078, 0xce8568cf85ceb1c8, 0x1520e74a2060e888, 0xc5a095e7082098e7, 
    0xf602d0cfc506d0ce, 0xe75920e782206050, 0xca1b30cf24e71520, 0x04d0cfa5e7152060, 
    0x0820ffa9f3f0cea5, 0x20e930cf24a095e7, 0x0820cee53898e715, 0x00a02350cfe598e7, 
    0xe71520e76f209010, 0xdb85cfa5da85cea5, 0xda65cea518e71520, 0x70db65cfa5e70820, 
    0xa4e7152060a095dd, 0x0cf0cfa58805f0ce, 0xa9c8a8070924a560, 0xf7b024c4e3c920a0, 
    0xa5e71520e7b12060, 0xe3c920ada90a10cf, 0xd58488ef50e77220, 0xa6e51b20cea6cf86, 
    0x85cea5e7152060cf, 0xf88488f785cfa5f6, 0x60f584f4850aa9c8, 0x10cfa4cea5e71520, 
    0xda8550b5e71520f2, 0xda91cea5db8578b5, 0x6860e8da91cfa5c8, 0xe3cd200510d52468, 
    0x60d784ffa060d546, 0x8525a907f0efcd20, 0xcaa560e8d48488d6, 0xfca541a05ad0cba4, 
    0xa5fce6a85eb008c9, 0x0899e1a5010099e0, 0xdda5011099dca501, 0x6d20e71520011899, 
    0xa53bd037a00490e5, 0x2cdd84dc85e5a4e4, 0x900369184f30d011, 0x859ad986ffa2c801, 
    0xd924e67920e184e0, 0x71dca500a0184910, 0x4cc5c80190dda4dc, 0x34a0cdd04dc4d1d0, 
    0xa54aa0e3e04cd946, 0x0fb9a8fcc6f7f0fc, 0xdd850117b9dc8501, 0x8aa80107b900ffbe, 
    0xe3c42063a0e87a4c, 0xdcb1c8aadcb101a0, 0xfbc6e2b34ce51b20, 0xb5a8c4f0fba55ba0, 
    0x78b5f0d0011fd950, 0x012fb9e9d00127d9, 0x20db850137b9da85, 0x0120e79320cae715, 
    0x950167b9fba4cae8, 0x082000a0015fb99f, 0x20e75920e78220e7, 0x05f0cea5fba4e715, 
    0x013fb91210013759, 0xbedd850147b9dc85, 0xc687d00157b9014f, 0x08c9fba554a060fb, 
    0x9950b5a8fbe69af0, 0x6001289978b50120, 0x99cea5fba4e71520, 0xa9016799cfa5015f, 
    0x379900a9012f9901, 0xdda5013f99dca501, 0x014f99e0a5014799, 0x152060015799e1a5, 
    0x012f99cea5fba4e7, 0x000000e9664ccfa5, 0x0000000000000000, 0x03030303ab000000, 
    0x0303030303030303, 0x3c3cc0c03f3f0303, 0xc00f303c3c3c3c3c, 0x0303abab0055ffcc, 
    0xcfcf55ffff55ffff, 0xc3c3c355ffcfcfcf, 0x55565656cff0f055, 0x030303030355ffff, 
    0x030303ffffff0303, 0x0303030303030303, 0x03ab000303030303, 0x0303070303030357, 
    0x0303030303030303, 0xffffffffffaa0303, 0xf24b355d19ffff17, 0x54f8e2b7ad6f87ec, 
    0x4a33102282859680, 0x7a4740014a0b0613, 0xcbb6165b0923ff00, 0x4ef624fffffbffff, 
    0x366fa323ff005059, 0x23baaec2221cd723, 0x20c4031e3021ffff, 0x1e30a0ffffffc100, 
    0x50013aaabcb6d3a4, 0x5b16ff3ca5d8d87e, 0x004e0c001dc40328, 0x57c6bc00b0a6003e, 
    0xffffffffff27018c, 0xefe0e0e0e8ffffe8, 0xeee7e7e5e5e3e3ef, 0xe7e7efe2e7e7efef, 
    0xe2ececece7ececec, 0xebefe8e8e1e8ff00, 0xefeeefffffe0ffff, 0xe7e7e7e8ff00e7e7, 
    0xe8eeeeeeeee2e1e8, 0xe8e7eeefe1e1ffff, 0xefe1eeffffffe7ee, 0xe9e8e9ebefefe8e7, 
    0xe8e8ffe8e8e8e8e9, 0xefeeefefe8e7eee8, 0xeeeeeeefeeeeefee, 0xffffffffffe8e8e1, 
    0xcfd437b6b7b2b3be, 0xd9d347cecfcca0cf, 0xa0cdc5cd58c1d4ce, 0xa0cfcfd44cccd5c6, 
    0xd2c1d0a0d9cec1cd, 0xcec9d2d4d353cec5, 0xc244cec5a0cfce47, 0xc3cec1d2c2a0c4c1, 
    0xd5d3cfc7a0b8be48, 0xc5d2a0c4c1c253c2, 0xc6a0b8be4ed2d5d4, 0xcea0c4c1c253d2cf, 
    0xd0d0cfd4d354d8c5, 0xaaaa20d4c1a0c4c5, 0xbe0dd2d2c5a020aa, 0x45c7cec1d235b5b2, 
    0xcfa0d2d4d34dc9c4, 0xd4c5d20ddc4cc6d6, 0xc5cec9cca0c5d0d9, 0xc34c0390d9463f8d, 
    0x8da0cea69acfa6e8, 0x86e3c42099a002d0, 0xd984fea0cf86bace, 0xf184e29920c884c8, 
    0xe6e4912030a920a2, 0xce850ac8a4cea6d9, 0xd2f074c90200b9c8, 0xc8c8f0b00ac9b049, 
    0xffb9480200b9c884, 0x9568e7082000a001, 0x2003d0c7c9cea5a0, 0xffffffe8014ce76f, 
    0x0b2015d0ec132050, 0x6f20e7822010d0ec, 0x5920e782200350e7, 0xffffe7364c5056e7, 
    0xcecfc7ccd17fffc1, 0xbf9395968b989ac5, 0xbeacb0bc2b2d32b2, 0xfbddffffff618e35, 
    0x2005104f15efc920, 0xcb1050954f35efc9, 0x8b608d6040efc94c, 0x03600000338c7e00, 
    0x9d47c989400012bf, 0x8d6040000a9d6817, 0x00003c8c7e008b60, 0xa1b4674b1bbf0360, 
    0x67a8aca9ae078c07, 0x9d67b0acafb4078c, 0x078c67a3afacafb2, 0xb2a9aef4b0afaba5, 
    0xb2a9aeb4270e7fb0, 0xb2a9aeb4280e7fb0, 0xb4af67a9a60764b0, 0x7f78aca5b478a7af, 
    0xb3b5a267b2a5ad02, 0xb2a5b4b5b2eea7af, 0x67aea5b8b4398c7e, 0x07b4af27b3b4a5b0, 
    0x37057fa6afb2199d, 0x28057fa9aeb0b5b4, 0x2a057fa9aeb0b5b4, 0xa5aee4a9aeb0b5b4, 
    0x7fb4a1a247ffff00, 0x230d7fa4a9ad300d, 0xa3a1acac67a4a9ad, 0x470080c1c0804000, 
    0x9b689b67db8c688c, 0x0751017f8c638c50, 0x715780c480842988, 0xacafada5ed148807, 
    0xacaff2a8a9ada5ed, 0xaca5ae880871a3af, 0x0771089d68088368, 0x8d76aeafb4766088, 
    0xa4b8198807518b76, 0xa1a2f3b5b3f2b2ae, 0xa5ebb2aee4b3a7ee, 0xc18139880751b0a5, 
    0x880651002f0f7f4f, 0x8c6a8c57820cc229, 0xa5ae60b4a8a5ae42, 0x278c351e7e4fb4a8, 
    0xafe4fe8b09880751, 0xdedca1aee4aff2ad, 0xddc39eddde9cdd9c, 0xad9d4700cbcdcacf, 
    0xa5ad9d76acafada5, 0x8c60afa6e6a8a9ad, 0xa3acf2a1b5b4af20, 0xa5ac208c60b3a3f2, 
    0xb2b5ae60b2b5eea4, 0xb4208c60aca9b3f4, 0x20229a7e7aaca9b3, 0x1fbf0360bf036000, 
    0x854fb5e8e8e7b120, 0x984eb4db8577b5da, 0xc920dab109b076d5, 0x85ffa9ee0f4cc8e3, 
    0x95789500a9e860d5, 0x50954ff53877b5a0, 0xa5e71520ffe8234c, 0x342060cea528d0cf, 
    0xc021b030c9c8a4ee, 0x3420eaea601db028, 0xceb401a28aea60ee, 0xf0caca9448b44c94, 
    0xe3e04c77a060aaf5, 0xa5e25420f9d07ba0, 0x4c03d0dba507d0da, 0xe626cf26ce06e77e, 
    0xe7a5dac5e6a5e726, 0xe6a5e7850a90dbe5, 0xd088cee6e685dae5, 0xffffffffffff60e1, 
    0x4ca500ce6ce71520, 0x48a54cc64dc602d0, 0x00a048c649c602d0, 0x4cc5caa548914cb1, 
    0x534ce0904de5cba5, 0xc8a5a89bb028c9ee, 0x206ea0aa98eaea60, 0xa0e3c420a88ae3c4, 
    0x06e71520e3c44c72, 0xd0dcb0fa30cf26ce, 0x152060d6b0cec504, 0xe7084c9f94ceb1e7, 
    0x152048cea5ee3420, 0xffffff60ce9168e7, 0xa5e685cea5ee6c20, 0xe420e2444ce785cf, 
    0xb4eee420e1344cee, 0x8801b0fe6950b578, 0x95ce6518db84da85, 0x00a07895cf659850, 
    0xf178b5c8dad150b5, 0x1520e8234c80b0da, 0x4fa5e708204ea5e7, 0x7f2900694ec504d0, 
    0x4fa511a0a0954f85, 0x264e260a4069180a, 0x0820cea5f2d0884f, 0xe27a4ca095cfa5e7, 
    0xa54cc4cea4e71520, 0xa548841f904de5cf, 0x1520eeb64c4985cf, 0xe5cfa5cac4cea4e7, 
    0x85cfa54a8409b0cb, 0xeaeecb4ce5b74c4b, 0x7120efc920eaeaea, 0xa9ee0320efbf4ce1, 
    0x02008d74a9c885ff, 0xe73620e8e7362060, 0x854a8500a96050b5, 0x8510a94b8508a94c, 
    0x01d078d5e5ad4c4d, 0x4ce5b720e1024c18, 0xe85b4ce5b720e836, 0xe00c4c8801d080e0, 
};

static bool ishex( char c )
{
    return ( ( c >= 'A' && c <= 'F' ) || ( c >= 'a' && c <= 'f' ) || ( c >= ' ' && c <= '9' ) );
} //ishex

uint8_t read_byte( char * p )
{
    char ac[3];
    ac[0] = p[0];
    ac[1] = p[1];
    ac[2] = 0;

    return (uint8_t) strtoul( ac, 0, 16 );
} //read_byte

uint16_t read_word( char * p )
{
    char ac[5];
    ac[0] = p[0];
    ac[1] = p[1];
    ac[2] = p[2];
    ac[3] = p[3];
    ac[4] = 0;

    return (uint16_t) strtoul( ac, 0, 16 );
} //read_word

// http://www.piclist.com/techref/fileext/hex/intel.htm
// :, reclen(1), offset(2), rectype(1), data/info, chksum(1)

bool load_file_intel_format( FILE * fp )
{
    char acLine[ 120 ];

    do
    {
        char * buf = fgets( acLine, _countof( acLine), fp );

        if ( buf && strlen( buf ) >= 11 )
        {
            if ( ':' != buf[ 0 ] )
                usage( "error: input Intel HEX file is malformed" );

            uint8_t reclen = read_byte( buf + 1 );
            uint16_t offset = read_word( buf + 3 );
            uint8_t rectyp = read_byte( buf + 7 );

            if ( 1 == rectyp ) // eof
                break;

            if ( 0 != rectyp  )
                usage( "file format not recognized" );

            for ( uint8_t x = 0; x < reclen; x++ )
            {
                if ( feof( fp ) )
                    usage( "malformed input file" );

                uint8_t val = read_byte( buf + ( 2 * x ) + 9 );
                memory[ offset + x ] = val;
            }
        }
        else
            break;
    } while ( true );

    fclose( fp );

    //DumpBinaryData( memory + 0x400, 0x100, 2 );
    return true;
} //load_file_intel_format

// sample Apple 1 input file:
// 1000: A9 05 C5 04 F0 09 10 0F
// 1008: 30 15 B0 1B 4C 2F 10 A9
// 1010: 3D 20 EF FF 4C 2F 10 A9
// 1018: 2B 20 EF FF 4C 2F 10 A9
// 1020: 2D 20 EF FF 4C 2F 10 A9
// 1028: 43 20 EF FF 4C 2F 10 A9
// 1030: 24 20 EF FF 4C 1F FF

static bool load_file( char const * file_path )
{               
    bool ok = false;
    FILE *fp = fopen( file_path, "r" );
    char acLine[ 120 ];
    bool first_address = true;
    uint16_t initial_address = 0;

    if ( 0 != fp )
    {
        char c = fgetc( fp );
        fseek( fp, 0, SEEK_SET );

        if ( ':' == c )
            return load_file_intel_format( fp );

        // read the file and write the data into memory

        do
        {
            char * buf = fgets( acLine, _countof( acLine), fp );

            if ( buf && strlen( buf ) >= 7 )
            {
                if ( ':' != buf[ 4 ] || ' ' != buf[ 5 ] )
                    usage( "error: input HEX file is malformed" );

                uint16_t a = (uint16_t) strtoul( buf, 0, 16 );
                if ( first_address )
                {
                    first_address = false;
                    initial_address = a;

                    if ( !g_fStartAddressSpecified )
                        g_startAddress = a;
                }

                char * pbyte = acLine + 5; // at the space
                ok = true;

                while ( ' ' == *pbyte && ishex( * ( pbyte + 1 ) ) )
                {
                    pbyte++;

                    uint8_t b = (uint8_t) strtoul( pbyte, 0, 16 );
                    pbyte += 2;
                    memory[ a++ ] = b;
                }
            }
            else
                break;
        } while ( true );

        fclose( fp );

        DumpBinaryData( memory + initial_address, 0x100, 2 );
    }

    return ok;
} //load_file

uint64_t invoke_command( char const * pcFile, uint64_t clockrate )
{
    cpu.power_on();

    // load a file if one was specified

    if ( pcFile )
    {
        bool ok = load_file( pcFile );
        if ( !ok )
        {
            printf( "unable to load command %s\n", pcFile );
            exit( 1 );
        }
    }

    // Apple 1 apps expect these

    cpu.pc = g_startAddress;
    cpu.sp = 0xff;

    if ( g_useHooks )
    {
        // Set hooks for Apple 1 API compatibility instead of using the Apple 1 Monitor
        
        memory[ 0xff1f ] = OPCODE_HOOK;   // GETLINE monitor entry point
        memory[ 0xffe5 ] = OPCODE_HOOK;   // PRHEX. Prints the low nibble in A as hex
        memory[ 0xffdc ] = OPCODE_HOOK;   // PRBYTE. Prints the byte in A as a 2-digit hex number
        memory[ 0xffef ] = OPCODE_HOOK;   // ECHO character in A to the terminal
    }
    else
    {
        memcpy( memory + 0xff00, MonitorCode, sizeof( MonitorCode ) );
        memcpy( memory + 0xe000, BasicCode, sizeof( BasicCode ) );

        // if in monitor mode and using -c command-line mode, insert a HALT where apps
        // will jump when they're done executing.

        if ( !g_use40x24 )
            memory[ 0xff1f ] = OPCODE_HALT;
    }

    g_executionEnded = false;
    uint64_t cycles_executed = 0;
#ifdef _MSC_VER    
    CPUCycleDelay delay( clockrate );
#endif    
    uint64_t cycles_since_last_kbd_peek = 0;

    do
    {
        uint64_t cycles_this_run = cpu.emulate( 1000 );
        cycles_executed += cycles_this_run;
        cycles_since_last_kbd_peek += cycles_this_run;

        if ( g_executionEnded )
            break;

        if ( g_KbdPeekHappened )
        {
            // peeking the keyboard sleeps, throwing off execution times. Start again.

#ifdef _MSC_VER
            delay.Reset();
#endif            
            cycles_since_last_kbd_peek = 0;
            g_KbdPeekHappened = false;
            continue;
        }

#ifdef _MSC_VER        
        delay.Delay( cycles_since_last_kbd_peek );
#endif        
    } while ( true );

    return cycles_executed;
} //invoke_command

#ifdef _MSC_VER

BOOL WINAPI ControlHandler( DWORD fdwCtrlType )
{
    if ( CTRL_C_EVENT == fdwCtrlType )
    {
        g_executionEnded = true;
        cpu.end_emulation();
        return TRUE;
    }

    return FALSE;
} //ControlHandler

#endif

static void Render( long long n, char * ac )
{
    if ( n < 0 )
    {
        strcat( ac, "-" );
        Render( -n, ac );
        return;
    }
   
    if ( n < 1000 )
    {
        sprintf( ac + strlen( ac ), "%lld", n );
        return;
    }

    Render( n / 1000, ac );
    sprintf( ac + strlen( ac ), ",%03lld", n % 1000 );
    return;
} //RenderNumberWithCommas

static char * RenderNumberWithCommas( long long n, char * ac )
{
    ac[ 0 ] = 0;
    Render( n, ac );
    return ac;
} //RenderNumberWithCommas

int ends_with( const char * str, const char * end )
{
    size_t len = strlen( str );
    size_t lenend = strlen( end );

    if ( len < lenend )
        return false;

    return ( 0 == _stricmp( str + len - lenend, end ) );
} //ends_with

int main( int argc, char * argv[] )
{
    char * pcHEX = 0;
    bool trace = false;
    bool traceInstructions = false;
    uint64_t clockrate = 0;
    bool showPerformance = false;

    for ( int i = 1; i < argc; i++ )
    {
        char *parg = argv[i];
        char c = *parg;

        if ( '-' == c || '/' == c )
        {
            char ca = tolower( parg[1] );

            if ( 'a' == ca )
            {
                if ( ':' == parg[2] )
                {
                    g_startAddress = (uint16_t) strtoul( parg + 3 , 0, 16 );
                    g_fStartAddressSpecified = true;
                }
                else
                    usage( "colon required after a argument" );
            }
            else if ( 's' == ca )
            {
                if ( ':' == parg[2] )
                    clockrate = (uint64_t) strtoull( parg + 3 , 0, 10 );
                else
                    usage( "colon required after c argument" );
            }
            else if ( 'h' == ca )
                g_useHooks = true;
            else if ( 'i' == ca )
                traceInstructions = true;
            else if ( 't' == ca )
                trace = true;
            else if ( 'u' == ca )
                g_forceUppercase = false;
            else if ( 'p' == ca )
                showPerformance = true;
            else if ( 'c' == ca )
                g_use40x24 = false;
            else if ( '?' == ca )
                usage();
            else
                usage( "invalid argument specified" );
        }
        else
        {
            if ( 0 == pcHEX )
                pcHEX = parg;
            else
                usage( "too many arguments" );
        }
    }

    tracer.Enable( trace, L"ntvao.log", true );
    tracer.SetQuiet( true );
    tracer.SetFlushEachTrace( true );
    cpu.trace_instructions( traceInstructions );

    if ( 0 == pcHEX && g_useHooks )
        usage( "no command specified and hooks mean no Apple 1 monitor is installed" );

    char acHex[ MAX_PATH ] = {0};
    if ( 0 != pcHEX )
    {
        strcpy( acHex, pcHEX );

        FILE * fp = fopen( acHex, "r" );
        if ( fp )
            fclose( fp );
        else
        {
            if ( ends_with( acHex, ".hex" ) )
                usage( "can't find command file" );
            else
            {
                strcat( acHex, ".hex" );
                FILE * fp = fopen( acHex, "r" );
                if ( fp )
                    fclose( fp );
                else
                    usage( "can't find command file" );
            }
        }
    }

    memset( &cpu, 0, sizeof( cpu ) );
    memset( memory, 0, sizeof( memory ) );

#ifdef _MSC_VER
    ConsoleConfiguration consoleConfig;
    if ( g_use40x24 )
        consoleConfig.EstablishConsole( 40, 24, ControlHandler );
#else
    set_conio_terminal_mode();
#endif

    high_resolution_clock::time_point tStart = high_resolution_clock::now();

    uint64_t total_cycles = invoke_command( ( 0 != acHex[ 0 ] ) ? acHex : 0, clockrate );

#ifdef _MSC_VER
    consoleConfig.RestoreConsole();
#else
    reset_terminal_mode();    
#endif

    printf( "\n" );
    if ( showPerformance )
    {
        high_resolution_clock::time_point tDone = high_resolution_clock::now();
        long long totalTime = duration_cast<std::chrono::milliseconds>( tDone - tStart ).count();

        char ac[ 100 ];
        printf( "elapsed milliseconds: %16s\n", RenderNumberWithCommas( totalTime, ac ) );
        printf( "6502 cycles: %25s\n", RenderNumberWithCommas( total_cycles, ac ) );
        printf( "clock rate: " );
        if ( 0 == clockrate )
        {
            printf( "      %20s\n", "unbounded" );
            uint64_t total_ms = total_cycles * 1000 / 1022727;
            printf( "ms at 1.022727 Mhz: %18s == ", RenderNumberWithCommas( total_ms, ac ) );

            uint16_t days = (uint16_t) ( total_ms / 1000 / 60 / 60 / 24 );
            uint16_t hours = (uint16_t) ( ( total_ms % ( 1000 * 60 * 60 * 24 ) ) / 1000 / 60 / 60 );
            uint16_t minutes = (uint16_t) ( ( total_ms % ( 1000 * 60 * 60 ) ) / 1000 / 60 );
            uint16_t seconds = (uint16_t) ( ( total_ms % ( 1000 * 60 ) ) / 1000 );
            uint64_t milliseconds = ( ( total_ms % 1000 ) );
            printf( "%u days, %u hours, %u minutes, %u seconds, %llu milliseconds\n", days, hours, minutes, seconds, milliseconds );
        }
        else
            printf( "      %20s Hz\n", RenderNumberWithCommas( clockrate, ac ) );
    }

    tracer.Shutdown();
} //main


