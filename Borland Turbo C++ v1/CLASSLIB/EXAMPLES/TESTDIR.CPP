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
//     main
//
// Description
//
//     Directory listing program.  Lists directories in the given sorting
//     order.
//
// End ---------------------------------------------------------------------

// Interface Dependencies ---------------------------------------------------

// None

// End Interface Dependencies ------------------------------------------------

// Implementation Dependencies ----------------------------------------------

#ifndef __STDLIB_H
#include <stdlib.h>
#define __STDLIB_H
#endif

#ifndef __IOSTREAM_H
#include <iostream.h>
#define __IOSTREAM_H
#endif

#ifndef __DIRECTRY_H
#include "directry.h"
#endif

// End Implementation Dependencies -------------------------------------------


// Function //

int    main( int argc, char *argv[] )

// Summary -----------------------------------------------------------------
//
//     directry [options] template
//
//     Displays a sorted listing of the given pathnames.  The template
//     may contain wildcard characters.
//
//     options:  One of the following
//
//     -sn        Sort by name
//
//     -sd        Sort by date
//
//     -ss        Sort by size
//
// Parameters
//
//     argc
//
//     The number of arguments passed on the command line.  There must
//     be at least 1 argument other than the command name.
//
//     argv
//
//     A vector of character strings which are the arguments to the
//     command line.
//
// End ---------------------------------------------------------------------
{
    if ( argc < 2 || argc > 3 )
    {
        cerr << "Usage:  directry [options] template\n";
        exit(1);
    }

    sortOrder sorting;              // Defines the sorting order for the
                                    // pathnames.

    int path;                       // Defines the argument at which the
                                    // pathname occurs.

    if ( argc != 3 )
    {
    sorting = Directory::byName;
    path = 1;
    }
    else // the optional sort argument was specified.
    {
        String sortArg( argv[1] );
        String sortByName( "-sn" );
        String sortByDate( "-sd" );
        String sortBySize( "-ss" );

        path = 2;

        if ( sortArg == sortByName )
        {
        sorting = Directory::byName;
        }
        else if ( sortArg == sortByDate )
        {
        sorting = Directory::byDate;
        }
        else if ( sortArg == sortBySize )
        {
        sorting = Directory::bySize;
        }
    }

// Body Comment
//
//     At this point, we will have established our sorting order.
//     We now construct a directory list of the given sort order
//     and display that list.
//
// End

    Directory sortedDirectory( argv[path], sorting );
    sortedDirectory.printContentsOn( cout );
}
// End Function main //

