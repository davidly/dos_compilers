#ifndef __FILEDATA_H
#define __FILEDATA_H

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
//      fileDataClass
//      filesByNameClass
//      filesByDateClass
//      filesBySizeClass
//
//      FileData
//
//      FilesByName
//      FilesByName::isEqual
//      FilesByName::isLessThan
//
//      FilesByDate
//      FilesByDate::isEqual
//      FilesByDate::isLessThan
//
//      FilesBySize
//      FilesBySize::isEqual
//      FilesBySize::isLessThan
//
// Description
//
//      Defines file data classes.  These classes are used by DIRECTRY.CPP,
//      which is part of the directory listing example program for the
//      Turbo C++ class library.
//
// End ---------------------------------------------------------------------

// Interface Dependencies ---------------------------------------------------

#ifndef __DIR_H
#include <dir.h>
#define __DIR_H
#endif

#ifndef __CLSDEFS_H
#include <clsdefs.h>
#endif

#ifndef __SORTABLE_H
#include <sortable.h>
#endif

#ifndef __STRNG_H
#include <strng.h>
#endif
                                                             
#ifndef __LDATE_H
#include <ldate.h>
#endif

#ifndef __LTIME_H
#include <ltime.h>
#endif

// End Interface Dependencies ------------------------------------------------


// Macro //

// Summary -----------------------------------------------------------------
//
//      Defines a values for the file classes.  We start from the first
//      available user class number.  The class numbers are defined
//      in CLSDEFS.H, in the class library INCLUDE directory.
//
// End ---------------------------------------------------------------------

#define     fileDataClass       __firstUserClass
#define     filesByNameClass    (fileDataClass+1)
#define     filesByDateClass    (filesByNameClass+1)
#define     filesBySizeClass    (filesByDateClass+1)

// Class //

class FileData: public Sortable
{
public:
                            FileData( ffblk& );
    virtual classType       isA() const { return fileDataClass; }
    virtual char           *nameOf() const { return "FileData"; }
	virtual int             isEqual( const Object& ) const = 0;
	virtual int             isLessThan( const Object& ) const = 0;
    virtual hashValueType   hashValue() const { return 0; }
    virtual void            printOn( ostream& ) const;
protected:
    String                  fileName;
    Date                    fileDate;
    Time                    fileTime;
    long                    fileSize;
};

// Description -------------------------------------------------------------
//
//      Defines a base file class.  Class FileData is derived from the
//      class Sortable, which is part of the class library.
//
// Constructor
//
//      FileData
//
//      Constructs a FileData object from the DOS file block.
//
// Public Members
//
//      isA
//
//      Returns the class type of FileData.
//
//      nameOf
//
//      Returns a pointer to the character string "FileData."
//
//      isEqual
//
//      Determines whether two file data objects are equal.
//      Redeclared as pure virtual.
//
//      isLessThan
//      Determines whether one file data object is less than another.
//      Redeclared as pure virtual.
//      
//      hashValue
//
//      Returns a pre-defined hash value for a FileData object.
//
//      printOn
//
//      Prints the contents of a file data object.
//
// End ---------------------------------------------------------------------


// Class //

class FilesByName:  public FileData
{
public:
                            FilesByName( ffblk& blk ) : FileData( blk ) {}
    virtual classType       isA() const { return filesByNameClass; }
    virtual char           *nameOf() const { return "FilesByName"; }
	virtual int             isEqual( const Object& ) const;
	virtual int             isLessThan( const Object& ) const;
};

// Description -------------------------------------------------------------
//
//      Defines a file class which is sorted by name.  Class FilesByName
//      is derived from the class FileData, which is a user-defined
//      base class.
//
// Constructor
//
//      FilesByName
//
//      Constructs a FilesByName object from the DOS file block.
//
// Public Members
//
//      isA
//
//      Returns the class type of FilesByName.
//
//      nameOf
//
//      Returns a pointer to the character string "FilesByName."
//
//      isEqual
//
//      Determines whether two file data objects are equal.
//
//      isLessThan
//      Determines whether one file data object is less than another.
//      
// Inherited Members
//
//      hashValue
//
//      Inherited from FileData.
//
//      printOn
//
//      Inherited from FileData.
//
// End ---------------------------------------------------------------------


// Class //

class FilesByDate:  public FileData
{
public:
                            FilesByDate( ffblk& blk ) : FileData( blk ) {}
    virtual classType       isA() const { return filesByDateClass; }
    virtual char           *nameOf() const { return "FilesByDate"; }
	virtual                 isEqual( const Object& ) const;
	virtual                 isLessThan( const Object& ) const;
};

// Description -------------------------------------------------------------
//
//      Defines a file class which is sorted by date.  Class FilesByDate
//      is derived from the class FileData, which is a user-defined
//      base class.
//
// Constructor
//
//      FilesByDate
//
//      Constructs a FilesByDate object from the DOS file block.
//
// Public Members
//
//      isA
//
//      Returns the class type of FilesByDate.
//
//      nameOf
//
//      Returns a pointer to the character string "FilesByDate."
//
//      isEqual
//
//      Determines whether two file data objects are equal.
//
//      isLessThan
//      Determines whether one file data object is less than another.
//      
// Inherited Members
//
//      hashValue
//
//      Inherited from FileData.
//
//      printOn
//
//      Inherited from FileData.
//
// End ---------------------------------------------------------------------


// Class //

class FilesBySize:  public FileData
{
public:
                            FilesBySize( ffblk& blk ) : FileData( blk ) {}
    virtual classType       isA() const { return filesBySizeClass; }
    virtual char           *nameOf() const { return "FilesBySize"; }
	virtual                 isEqual( const Object& ) const;
	virtual                 isLessThan( const Object& ) const;
};

// Description -------------------------------------------------------------
//
//      Defines a file class which is sorted by size.  Class FilesBySize
//      is derived from the class FileData, which is a user-defined
//      base class.
//
// Constructor
//
//      FilesBySize
//
//      Constructs a FilesBySize object from the DOS file block.
//
// Public Members
//
//      isA
//
//      Returns the class type of FilesBySize.
//
//      nameOf
//
//      Returns a pointer to the character string "FilesBySize."
//
//      isEqual
//
//      Determines whether two file data objects are equal.
//
//      isLessThan
//      Determines whether one file data object is less than another.
//      
// Inherited Members
//
//      hashValue
//
//      Inherited from FileData.
//
//      printOn
//
//      Inherited from FileData.
//
// End ---------------------------------------------------------------------

#endif    // __FILEDATA_H //
