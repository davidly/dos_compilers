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

#ifndef __STRSTREAM_H
#include <strstream.h>
#endif

#ifndef __STDIO_H
#include <stdio.h>
#endif

#ifndef __STRNG_H
#include <strng.h>
#endif

#ifndef __LDATE_H
#include <ldate.h>
#endif


const BufSize = 20;

static char *MonthNames[] =
	{
	"January",
	"February",
	"March",
	"April",
	"May",
	"June",
	"July",
	"August",
	"September",
	"October",
	"November",
	"December"
	};

// Member Function //

BaseDate::~BaseDate()

// Summary -----------------------------------------------------------------
//
//      Destructor for a BaseDate object.
//
// End ---------------------------------------------------------------------
{
}
// End Destructor //


// Member Function //

int BaseDate::isEqual( const Object& testDate ) const

// Summary -----------------------------------------------------------------
//
//      Determines whether two BaseDate objects are equal.
//
// End ---------------------------------------------------------------------
{
    return MM == ((BaseDate&)testDate).MM &&
           DD == ((BaseDate&)testDate).DD &&
           YY == ((BaseDate&)testDate).YY;
}
// End Function BaseDate::isEqual //


// Member Function //

int BaseDate::isLessThan( const Object& testDate ) const

// Summary -----------------------------------------------------------------
//
//      Determines whether the current BaseDate is less than the BaseDate
//      passed as an argument.
//
// End ---------------------------------------------------------------------
{
    if( YY != ((BaseDate&)testDate).YY )
        return YY < ((BaseDate&)testDate).YY;
    if( MM != ((BaseDate&)testDate).MM )
        return MM < ((BaseDate&)testDate).MM;
    return DD < ((BaseDate&)testDate).DD;
}
// End BaseDate::isLessThan //


// Member Function //

hashValueType BaseDate::hashValue() const

// Summary -----------------------------------------------------------------
//
//      Returns the hash value of a string object.
//
// End ---------------------------------------------------------------------
{
	return hashValueType( YY + MM + DD );
}
// End Member Function BaseDate::hashValue //


// Member Function //

Date::~Date()

// Summary -----------------------------------------------------------------
//
//      Destructor for a Date object.
//
// End ---------------------------------------------------------------------
{
}
// End Destructor //


// Member Function //

void Date::printOn( ostream& outputStream ) const

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
    char temp[BufSize];
    ostrstream( temp, BufSize ) << MonthNames[ Month() ] << " " <<
        Day() << "," << Year() << ends;
    outputStream << temp;
}
// End Member Function Date::printOn //

// Member Function //

classType Date::isA() const

// Summary -----------------------------------------------------------------
//
// 	    Returns the class type of a Date.
//
// End ---------------------------------------------------------------------
{
	return dateClass;
}
// End Member Function Date::isA //


// Member Function //

char *Date::nameOf() const

// Summary -----------------------------------------------------------------
//
// 	    Returns a pointer to the character string "Date."
//
// End ---------------------------------------------------------------------
{
	return "Date";
}
// End Member Function Date::nameOf //


