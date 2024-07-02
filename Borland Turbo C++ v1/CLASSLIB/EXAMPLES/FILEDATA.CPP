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
//      FileData::FileData                            constructor
//
// Description
//
//     Class FileData member function implementation.
//
// End ---------------------------------------------------------------------

// Interface Dependencies ---------------------------------------------------

#ifndef __IOSTREAM_H
#include <iostream.h>
#define __IOSTREAM_H
#endif

#ifndef __IOMANIP_H
#include <iomanip.h>
#define __IOMANIP_H
#endif

#ifndef __DIR_H
#include <dir.h>
#define __DIR_H
#endif

#ifndef __CSLTYPES_H
#include <clstypes.h>
#endif

#ifndef __FILEDATA_H
#include "filedata.h"
#endif

// End Interface Dependencies ------------------------------------------------

// Implementation Dependencies ----------------------------------------------
// End Implementation Dependencies -------------------------------------------


// Constructor //

FileData::FileData( ffblk& blk ) :
    fileName( blk.ff_name ),
    fileDate( (blk.ff_fdate >> 5) & 0x000F,
              blk.ff_fdate & 0x0001F,
              (blk.ff_fdate >> 9) + 1980 ),
    fileSize( blk.ff_fsize ),
    fileTime( blk.ff_ftime >> 11,
              (blk.ff_ftime >> 5) & 0x3F,
              blk.ff_ftime & 0x1F )

// Summary -----------------------------------------------------------------
//
//     Constructor for a file data object.  Constructs the file name
//     file data, and file size objects.
//
// Parameters
//
//     blk
//
//     The DOS file block structure we are to use to construct the
//     file data object.
//
// End ---------------------------------------------------------------------
{
}
// End Constructor //


// Member Function //

void FileData::printOn( ostream& outputStream ) const

// Summary -----------------------------------------------------------------
//
//     Displays the contents of a file data object on the given stream.
//
// Parameters
//
//     outputStream
//
//     The stream on which we are to display.
//
// End ---------------------------------------------------------------------
{
    outputStream << setw( 14 ) << setiosflags( ios::left )   << fileName
                 << setw( 18 ) << fileDate
                 << setw( 17 ) << resetiosflags( ios::left ) << fileTime
                 << setw( 10 ) << fileSize << " bytes";
}
// End Member Function printOn //

// Member Function //

int FilesByName::isEqual( const Object& testFile ) const

// Summary -----------------------------------------------------------------
//
//      Determines whether two files are equal by comparing their names.
//
// Return Value
//
//      Returns 1 if the files have the same name, 0 otherwise.
//
// End ---------------------------------------------------------------------
{
    return fileName == ( (FilesByName&)testFile ).fileName;
}
// End Member Function FilesByName::isEqual //


// Member Function //

int FilesByName::isLessThan( const Object& testFile ) const

// Summary -----------------------------------------------------------------
//
//      Determines the ordering of two files by comparing their names.
//
// Return Value
//
//      Returns 1 if this file is less than the given file, 0 otherwise.
//
// End ---------------------------------------------------------------------
{
    return fileName < ( (FilesByName&)testFile ).fileName;
}
// End Member Function FilesByName::isLessThan //


// Member Function //

int FilesByDate::isEqual( const Object& testFile ) const

// Summary -----------------------------------------------------------------
//
//      Determines whether two files by are equal by comparing their dates.
//
// Return Value
//
//      Returns 1 if the files have the same date, 0 otherwise.
//
// End ---------------------------------------------------------------------
{
    return fileDate == ( (FilesByDate&)testFile ).fileDate &&
           fileTime == ( (FilesByDate&)testFile ).fileTime;
}
// End Member Function FilesByDate::isEqual //


// Member Function //

int FilesByDate::isLessThan( const Object& testFile ) const

// Summary -----------------------------------------------------------------
//
//      Determines the ordering of two files by comparing their names.
//
// Return Value
//
//      Returns 1 if this file is less than the given file, 0 otherwise.
//
// End ---------------------------------------------------------------------
{
    if( fileDate == ( (FilesByDate&)testFile ).fileDate )
        return fileTime < ( (FilesByDate&)testFile ).fileTime;
    else
        return fileDate < ( (FilesByDate&)testFile ).fileDate;
}
// End Member Function FilesByDate::isLessThan //


// Member Function //

int FilesBySize::isEqual( const Object& testFile ) const

// Summary -----------------------------------------------------------------
//
//      Determines the whether two files are equal by comparing their
//      sizes.
//
// Return Value
//
//      Returns 1 if this file is less than the given file, 0 otherwise.
//
// End ---------------------------------------------------------------------
{
    return fileSize == ( (FilesBySize&)testFile ).fileSize;
}
// End Member Function FilesBySize::isEqual //


// Member Function //

int FilesBySize::isLessThan( const Object& testFile ) const

// Summary -----------------------------------------------------------------
//
//      Determines the ordering of two files by comparing their sizes.
//
// Return Value
//
//      Returns 1 if this file is less than the given file, 0 otherwise.
//
// End ---------------------------------------------------------------------
{
    return fileSize < ( (FilesBySize&)testFile ).fileSize;
}
// End Member Function FilesBySize::isLessThan //

