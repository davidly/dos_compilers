#ifndef __DIRECTRY_H
#define __DIRECTRY_H

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
//      directoryClass
//
//      Directory
//
// Description
//
//      Defines class Directory.
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

#ifndef __SORTARRY_H
#include <sortarry.h>
#endif

#ifndef __FILEDATA_H
#include "filedata.h"
#endif

// End Interface Dependencies ------------------------------------------------


// Macro //

// Summary -----------------------------------------------------------------
//
//      Defines a value for the directory class.  We use the next available
//      number after the class which sorts files by date.
//
// End ---------------------------------------------------------------------

#define    directoryClass           (filesBySizeClass+1)


// Class //

class Directory:  public SortedArray
{
public:
    virtual ~Directory() {}
            enum sortOrder { byName, byDate, bySize };
            Directory( char *, sortOrder );

    virtual classType       isA() { return directoryClass; }
    virtual char           *nameOf() { return "Directory"; }
    virtual hashValueType   hashValue() { return 0; }

    virtual void            printHeader( ostream& ) const;
    virtual void            printSeparator( ostream& ) const;
    virtual void            printTrailer( ostream& ) const;

private:
    void                    addFile( ffblk&, sortOrder );
    String                  mask;
};

// Description -------------------------------------------------------------
//
//      Defines a directory class.  Class Directory is derived from the
//      class SortedArray, which is part of the class library.
//
// Constructor
//
//      Directory
//
//      Constructs a directory object from the given name and sorting
//      order.
//
// Destructor
//
//      ~Directory
//
// Public Members
//
//      sortOrder
//
//      Enumerated order for sorting directories.
//
//      isA
//
//      Returns the class type of Directory.
//
//      nameOf
//
//      Returns a pointer to the character string "Directory."
//
//      hashValue
//
//      Returns a pre-defined hash value for a directory object.
//
// Private Members
//
//      addFile
//
//      Adds a file to the directory structure.
//
// End ---------------------------------------------------------------------


#endif    // __DIRECTRY_H
