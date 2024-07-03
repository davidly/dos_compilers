// Turbo Pascal v3.02a generates apps that try to determine the speed of the CPU at startup.
// On emulators this can cause many instructions to be executed and throws off benchmark numbers.
// This code replaces the call to do the speed check with NOP instructions.

#include <stdio.h>
#include <string.h>
#include <process.h>
#include <stdint.h>

void usage()
{
    printf( "usage: p app.com\n" );
    exit( 1 );
} //usage

long portable_filelen( FILE * fp )
{
    long current = ftell( fp );
    fseek( fp, 0, SEEK_END );
    long len = ftell( fp );
    fseek( fp, current, SEEK_SET );
    return len;
} //portable_filelen

int main( int argc, char * argv[] )
{
    if ( 2 != argc )
        usage();

    FILE * fp = fopen( argv[1], "r+b" );
    if ( !fp )
    {
        printf( "can't open file %s\n", argv[1] );
        usage();
    }

    long len = portable_filelen( fp );
    if ( len < 0x8a9 )
    {
        printf( "file length: %ld\n", len );
        printf( "file seems too small\n" );
        exit( 1 );
    }

    char acBuf[ 32 ];
    fseek( fp, 7, SEEK_SET );
    fread( acBuf, 30, 1, fp );
    acBuf[ 30 ] = 0;

    if ( strcmp( acBuf, "Copyright (C) 1985 BORLAND Inc" ) )
    {
        printf( "file doesn't appear to be a Turbo Pascal v3.02a generated app\n" );
        exit( 1 );
    }

    uint8_t abytes[ 3 ] = { 0 };
    fseek( fp, 0x8a7, SEEK_SET );
    fread( abytes, 3, 1, fp );

    if ( 0x90 == abytes[ 0 ] && 0x90 == abytes[ 1 ] && 0x90 == abytes[ 2 ] )
    {
        printf( "file is apparently already patched\n" );
        exit( 0 );
    }

    if ( 0xe8 != abytes[ 0 ] || 0xe8 != abytes[ 1 ] || 0xf7 != abytes[ 2 ] )
    {
        printf( "file doesn't have call 0f7e8h at offset 08a7h\n" );
        printf( "values there: %02x, %02x, %02x\n", abytes[ 0 ], abytes[ 1 ], abytes[ 2 ] );
        exit( 1 );
    }

    abytes[ 0 ] = 0x90;
    abytes[ 1 ] = 0x90;
    abytes[ 2 ] = 0x90;
    fseek( fp, 0x8a7, SEEK_SET );
    int result = fwrite( abytes, 3, 1, fp );
    if ( 1 != result )
    {
        printf( "couldn't write the NOP instructions, error %d\n", errno );
        exit( 1 );
    }

    fclose( fp );
    printf( "file %s successfully patched to remove startup cpu timing code\n", argv[ 1 ] );

    return 0;
} //main


