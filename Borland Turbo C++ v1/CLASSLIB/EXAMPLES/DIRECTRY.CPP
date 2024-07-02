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
//      Directory::Directory                        constructor
//      Directory::addFile
//
// Description
//
//      Implementation of class Directory member functions.
//
// End ---------------------------------------------------------------------

// Interface Dependencies ---------------------------------------------------

#ifndef __DIR_H
#include <dir.h>
#define __DIR_H
#endif

#ifndef __CLSTYPES_H
#include <clstypes.h>
#endif

#ifndef __DIRECTRY_H
#include "directry.h"
#endif

// End Interface Dependencies ------------------------------------------------

// Implementation Dependencies ----------------------------------------------

#ifndef __FILEDATA_H
#include "filedata.h"
#endif

// End Implementation Dependencies -------------------------------------------


// Constructor //

Directory::Directory( char *pathName, sortOrder sortBy ) :
                    SortedArray( 10, 0, 5 ), mask( pathName )

// Summary -----------------------------------------------------------------
//
//      Constructs a directory object.  A directory object contains
//      a sorted array of the file names which are in the directory.
//
// Parameters
//
//      pathName
//
//      Character pointer to the pathname for the directory.  This
//      pathname may include wildcard characters.
//
//      sortBy
//
//      The order by which we are to sort the directory entries.
//
// Functional Description
//
//      We walk through the directory, adding each of the file names to
//      our directory object.
//
// End ---------------------------------------------------------------------
{
    struct ffblk fileBlock;
    int morePathNames = !findfirst( mask, &fileBlock, 0 );
    while( morePathNames )
    {
        addFile( fileBlock, sortBy );
        morePathNames = !findnext( &fileBlock );
    } // end while more files.
}
// End Constructor Directory::Directory //


// Member Function //

void Directory::addFile( ffblk& fileBlock, sortOrder sortBy )

// Summary -----------------------------------------------------------------
//
//      Adds a file to a directory object.
//
// Parameters
//
//      fileBlock
//
//      The DOS file block we are to add to this directory object.
//
//      sortBy
//
//      The order in which files are to be sorted.
//
// Functional Description
//
//      Depending upon the sort order, we add a new object to the
//      sorted array.
//
// End ---------------------------------------------------------------------
{
    switch( sortBy )
    {
        case byName:
            add( *(new FilesByName( fileBlock )) );
            break;
        case byDate:
            add( *(new FilesByDate( fileBlock )) );
            break;
        case bySize:
            add( *(new FilesBySize( fileBlock )) );
            break;
    } // end switch on sort order.
}
// End Member Function Directory::addFile //


// Member Function //

void Directory::printHeader( ostream& outputStream ) const

// Summary -----------------------------------------------------------------
//
//      Displays the directory mask for the directory listing
//
// Parameters
//
//      outputStream
//
//      The stream on which we will be writing the header.
//
// Functional Description
//
//      We print the directory mask
//
// End ---------------------------------------------------------------------
{
    outputStream << "Directory: " << mask << "\n    ";
}
// End Member Function Directory::printHeader //


// Member Function //

void Directory::printSeparator( ostream& outputStream ) const

// Summary -----------------------------------------------------------------
//
//      Starts a new line for the next directory entry.
//
// Parameters
//
//      outputStream
//
//      The stream on which we will be writing the separator.
//
// End ---------------------------------------------------------------------
{
    outputStream << "\n    ";
}
// End Member Function Directory::printSeparator //


// Member Function //

void Directory::printTrailer( ostream& outputStream ) const

// Summary -----------------------------------------------------------------
//
//      Displays a new line for the trailer.
//
// Parameters
//
//      outputStream
//
//      The stream on which we will be writing the trailer.
//
// End ---------------------------------------------------------------------
{
    outputStream << "\n";
}
// End Member Function Directory::printTrailer //

