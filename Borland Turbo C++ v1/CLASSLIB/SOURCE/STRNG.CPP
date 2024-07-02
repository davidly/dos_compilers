//
// This file contains proprietary information of Borland International.
// Copying or reproduction without prior written approval is prohibited.
//
// Copyright (c) 1990
// Borland International
// 1800 Green Hills Road.
// Scotts Valley, CA 95066
// (408) 438-8400
//

// Contents ----------------------------------------------------------------
//
//      String::String                          copy constructor
//      String::~String
//      String::isEqual
//      String::isLessThan
//      String::isA
//      String::nameOf
//      String::hashValue
//      String::printOn
// 	    String::operator =
//
// Description
//
//      Contains the implementation of class String member functions.
//
// End ---------------------------------------------------------------------

// Interface Dependencies ---------------------------------------------------

#ifndef __CLSTYPES_H
#include <clstypes.h>
#endif

#ifndef __STRNG_H
#include <strng.h>
#endif

// End Interface Dependencies ------------------------------------------------

// Implementation Dependencies ----------------------------------------------

#ifndef __STDLIB_H
#include <stdlib.h>
#define __STDLIB_H
#endif

#ifndef __STRING_H
#include <string.h>
#define __STRING_H
#endif

// End Implementation Dependencies -------------------------------------------


// Member Function //

String::String( const String& sourceString )

// Summary -----------------------------------------------------------------
//
//      Copy constructor
//
// Parameters
//
// 	sourceString
//
// 	The string we are to assign to this.
//
// End ---------------------------------------------------------------------
{
		len = sourceString.len;
		theString = new char[ len ];
		strcpy( theString, sourceString.theString );
}
// End Member Function String::operator = //

// Destructor //

String::~String()

// Summary -----------------------------------------------------------------
//
//      Destructor for a String object.  Deletes the storage for the
//      character string.
//
// End ---------------------------------------------------------------------
{
	delete theString;
}
// End Destructor //


// Member Function //

String::isEqual( const Object& testString ) const

// Summary -----------------------------------------------------------------
//
// 	Determines whether two strings are equal.  Strings
//      are equal if they are the same length and contain the same
//      characters.
//
// Parameters
//
//      testString
//
//      The string we are testing against this.
//
// End ---------------------------------------------------------------------
{
	return ( len == ((String &)testString).len &&
			 !strcmp( theString, ((String &)testString).theString ) );
}
// End Member Function String::isEqual //


// Member Function //

int String::isLessThan( const Object& testString ) const

// Summary -----------------------------------------------------------------
//
//      Determines whether the given string is less than this.  The strings
//      need not be the same length.
//
// Parameters
//
//      testString
//
//      The string we are testing against this.
//
// End ---------------------------------------------------------------------
{
	return ( strcmp ( theString, ((String &)testString).theString ) < 0 );
}
// End Member Function String::isLessThan //


// Member Function //

classType String::isA() const

// Summary -----------------------------------------------------------------
//
//      Returns a predefined value for the class String.
//
// Parameters
//
//      none
//
// End ---------------------------------------------------------------------
{
    return stringClass;
}
// End Member Function String::isA //


// Member Function //

char *String::nameOf() const

// Summary -----------------------------------------------------------------
//
//      Returns the string "String".
//
// Parameters
//
//      none
//
// End ---------------------------------------------------------------------
{
    return "String";
}
// End Member Function String::nameOf //


// Member Function //

hashValueType String::hashValue() const

// Summary -----------------------------------------------------------------
//
//      Returns the hash value of a string object.
//
// End ---------------------------------------------------------------------
{
	hashValueType	value = hashValueType(0);

	for( int i = 0; i < len; i++ )
	{
		value ^= theString[i];
		value = _rotl( value, 1 );
	}
	return value;
}
// End Member Function String::hashValue //


// Member Function //

void    String::printOn( ostream& outputStream ) const

// Summary -----------------------------------------------------------------
//
//      Displays this object on the given stream.
//
// Parameters
//
//      outputStream
//
//      The stream where we are to display the object.
//
// End ---------------------------------------------------------------------
{
    outputStream << theString;
}
// End Member Function String::printOn //


// Member Function //

String& String::operator =( const String& sourceString )

// Summary -----------------------------------------------------------------
//
//      Assignment operator for strings.
//
// Parameters
//
// 	sourceString
//
// 	The string we are to assign to this.
//
// Functional Description
//
// 	We check that we are doing s = s, then copy the contents of
// 	the source string into this string.
//
// End ---------------------------------------------------------------------
{
	if ( *this != sourceString )
	{
		if ( len != sourceString.len )
		{
            delete theString;
			len = sourceString.len;
			theString = new char[ len ];
		}
		(void)strcpy( theString, sourceString.theString );
	}
	return *this;
}
// End Member Function String::operator = //
