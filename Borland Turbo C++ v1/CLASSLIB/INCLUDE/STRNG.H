#ifndef _STRNG_H
#define _STRNG_H

//
// This file contains proprietary information of Borland International.
// Copying or reproduction without prior written approval is prohibited.
//
// Copyright (c) 1990
// Borland International
// 1800 Green Hills Road
// Scotts Valley, CA 95066
// (408) 438-8400
//

// Contents ----------------------------------------------------------------
//
//      String      
//      String::isEqual
//      String::isLessThan
//      String::printOn
//      String::operator char*
//
// Description
//
//      Defines the instance class String and inline member functions.
//
// End ---------------------------------------------------------------------

// Interface Dependencies ---------------------------------------------------

#ifndef __IOSTREAM_H
#include <iostream.h>
#define __IOSTREAM_H
#endif

#ifndef __STRING_H
#include <string.h>
#define __STRING_H
#endif

#ifndef __CLSTYPES_H
#include <clstypes.h>
#endif

#ifndef __OBJECT_H
#include <object.h>
#endif

#ifndef __SORTABLE_H
#include <sortable.h>
#endif

// End Interface Dependencies ------------------------------------------------

// Class //

class String:  public Sortable
{
public:
			String( const char * );
			String( const String& );
    virtual ~String();

    virtual int             isEqual( const Object& ) const;
    virtual int             isLessThan( const Object& ) const;

    virtual classType       isA() const;
    virtual char            *nameOf() const;
    virtual hashValueType   hashValue() const;
	virtual void            printOn( ostream& ) const;

            String&         operator =( const String& );
							operator const char *() const;
private:
            sizeType        len;
            char           *theString;
};

// Description -------------------------------------------------------------
//
// 	    Defines the instance class String.  String objects may be used
//      anywhere an instance object is called for.  A string object 
//      is always terminated by a null.
//
// Constructor
//
//      String
//
//      Constructs a String object from a given character string.
//
// Destructor
//
//      ~String
//
//      String destructor.
//
// Public Members
//
// 	    isEqual
//
// 	    Returns 1 if two strings are equivalent, 0 otherwise.
// 	    Determines equivalence by calling strcmp().
//
// 	    isLessThan
//
// 	    Returns 1 if this is less than a test String.
//
// 	    isA
//
// 	    Returns the class type of class String.
//
// 	    nameOf
//
// 	    Returns a pointer to the character string "String."
//
// 	    hashValue
//
// 	    Returns the hash value of a string object.
//
// 	    printOn
//
// 	    Prints the contents of the string.
//
// 	    operator char*
//
// 	    Character pointer conversion operator.
//
// 	    operator =
//
// 	    Assignment operator for two string objects.
//
// Inherited Members
//
//      operator new
//
//      Inherited from Object.
//
//      forEach
//
//      Inherited from Object.
//
//      firstThat
//
//      Inherited from Object.
//
//      lastThat
//
//      Inherited from Object.
//
// 	    isSortable
//
// 	    Inherited from Sortable.
//
// 	    isAssociation
//
// 	    Inherited from Object.
//
// End ---------------------------------------------------------------------


// Constructor //

inline String::String( const char *aPtr )

// Summary -----------------------------------------------------------------
//
//      Constructor for a string object.
//
// Parameters
//
//      aPtr
//
//      Pointer to the characters out of which we are to construct a 
//      String object.
//
// Functional Description
//
//      We assign the string's length to len, then allocate space into
//      which we will store the string's characters.  You may construct
//      String objects out of local character strings.
//
// End ---------------------------------------------------------------------
{
    if ( aPtr && *aPtr )
    {
		len = strlen( aPtr ) + 1;
        theString = new char[ len ];
	    (void)strcpy( theString, aPtr );
    }
    else  // make a null string String object.
    {
        len = 0;
        theString = 0;
    }
}
// End Constructor //


// Member Function //

inline String::operator const char *() const

// Summary -----------------------------------------------------------------
//
//      Converts a string object to a character pointer.
//
// Remarks
//
// warnings:
// 	    You may not modifiy the returned string.
//
// End ---------------------------------------------------------------------
{
	return theString;
}
// End Member Function String::operator char* //


#endif // ifndef _STRNG_H //
