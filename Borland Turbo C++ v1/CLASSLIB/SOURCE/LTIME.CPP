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
//      BaseTime::operator String()
//
// Description
//
//      Implementation of class BaseTime member functions.
//
// End ---------------------------------------------------------------------

// Interface Dependencies ---------------------------------------------------

#ifndef __STRNG_H
#include <strng.h>
#endif

#ifndef __LTIME_H
#include <ltime.h>
#endif

// End Interface Dependencies ------------------------------------------------


// Implementation Dependencies ----------------------------------------------

#ifndef __IOMANIP_H
#include <iomanip.h>
#endif

#ifndef __STRSTREAM_H
#include <strstream.h>
#endif

#ifndef __STDIO_H
#include <stdio.h>
#define __STDIO_H
#endif

// End Implementation Dependencies -------------------------------------------


const BufSize = 20;

// Member Function //

BaseTime::isEqual( const Object& testTime ) const

// Summary -----------------------------------------------------------------
//
//      Determines whether two times are equal.  Times are assumed to be
//      normalized.
//
// Parameters
//
//      testTime
//
//      The time we are testing against this.
//
// End ---------------------------------------------------------------------
{
        return HH == ((BaseTime&)testTime).HH &&
               MM == ((BaseTime&)testTime).MM &&
               SS == ((BaseTime&)testTime).SS &&
               HD == ((BaseTime&)testTime).HD;
}
// End Member Function Time::isEqual //

// Member Function //

BaseTime::isLessThan( const Object& testTime ) const

// Summary -----------------------------------------------------------------
//
//      Determines whether this time is less than the time passed as
//		an argument.  Times are assumed to be normalized.
//
// Parameters
//
//      testTime
//
//      The time we are testing against this.
//
// End ---------------------------------------------------------------------
{
		if( HH != ((BaseTime&)testTime).HH )
			return HH < ((BaseTime&)testTime).HH;
		if( MM != ((BaseTime&)testTime).MM )
			return MM < ((BaseTime&)testTime).MM;
		if( SS != ((BaseTime&)testTime).SS )
			return SS < ((BaseTime&)testTime).SS;
		if( HD == ((BaseTime&)testTime).HD )
			return HD < ((BaseTime&)testTime).HD;
}
// End Member Function Time::isEqual //

// Member Function //

hashValueType BaseTime::hashValue() const

// Summary -----------------------------------------------------------------
//
//      Returns the hash value of a string object.
//
// End ---------------------------------------------------------------------
{
    return hashValueType( HH + MM + SS + HD );
}
// End Member Function BaseTime::hashValue //


// Member Function //

void Time::printOn( ostream& outputStream ) const

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
	char temp[16];

    ostrstream( temp, BufSize ) << 
		((hour()%12 == 0) ? 12 : hour()%12) << ":"
        << setfill( '0' )
		<< setw( 2 ) << minute() << ":"
        << setw( 2 ) << second() << "."
        << setw( 2 ) << hundredths() << " "
		<< ((hour() > 11) ? "p" : "a") << "m" << ends;

    outputStream << temp;
}
// End Member Function Time::printOn //


// Member Function //

classType Time::isA() const

// Summary -----------------------------------------------------------------
//
//      Returns the class type of a Time object.
//
// End ---------------------------------------------------------------------
{
    return timeClass;
}
// End Member Function Time::isA //


// Member Function //

char *Time::nameOf() const

// Summary -----------------------------------------------------------------
//
//      Returns a pointer to the character string "Time."
//
// End ---------------------------------------------------------------------
{
    return "Time";
}
// End Member Function Time::nameOf //

