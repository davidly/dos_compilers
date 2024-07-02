//
// This file contains proprietary information of Borland International.
// Copying or reproduction without prior written approval is prohibited.
//
// Copyright (c) 1990
// Borland International
// 1800 Scotts Valley Dr.
// Scotts Valley, CA 95066
// (408) 438-8400
//

// Contents ----------------------------------------------------------------
//
//      main
//
// Description
//
//      Contains a simple example program for class String.
//
// End ---------------------------------------------------------------------

// Interface Dependencies ---------------------------------------------------

// None

// End Interface Dependencies ------------------------------------------------

// Implementation Dependencies ----------------------------------------------

#ifndef __IOSTREAM_H
#include <iostream.h>
#define __IOSTREAM_H
#endif

#ifndef __STRNG_H
#include <strng.h>
#endif

// End Implementation Dependencies -------------------------------------------


// Function //

int main( int argc, char *argv[] )

// Summary -----------------------------------------------------------------
//
//      Illustrates a use of the String class.  Displays the alphabetically
//      last string out of the given command line and returns the position
//      of that string.
//
//      Usage:  strngmax string1 [string2 ...]
//
// Parameters
//
//      argc
//
//      The number of arguments passed on the command line.  There must
//      be at least 1 argument other than the command name.
//
//      argv
//
//      A vector of character strings which are the arguments to the
//      command line.
//
// Return Value
//
//     maxPosition
//
//     The position on the command line of the last string.  Returns
//     1 if an error occurs.
//
// End ---------------------------------------------------------------------
{
    if ( argc < 2 )
    {
        cerr << "Usage:  strngmax string1 [string2 ...]\n";
        return 1;
    }

    String theLargestString( argv[1] );
    int    maxPosition = 1;
    int nextArg = 2;

    while ( nextArg < argc )
    {
        String argListString ( argv[nextArg++] );
        if ( argListString > theLargestString )
        {
            theLargestString = argListString;
            maxPosition = nextArg - 1;
        }
    } // end while more arguments on the command line.

    cout << theLargestString << "\n";
    return maxPosition;
}
// End Function main //


