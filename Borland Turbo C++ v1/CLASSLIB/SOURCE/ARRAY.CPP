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
//      Array::isA
//      Array::nameOf
//      Array::add
//      Array::addAt
//
// Description
//
//      Implementation of class Array member functions.
//
// End ---------------------------------------------------------------------

// Interface Dependencies ---------------------------------------------------

#ifndef __CLSTYPES_H
#include <clstypes.h>
#endif

#ifndef __OBJECT_H
#include <object.h>
#endif

#ifndef __CONTAIN_H
#include <contain.h>
#endif

#ifndef __ARRAY_H
#include <array.h>
#endif

// End Interface Dependencies ------------------------------------------------

// Implementation Dependencies ----------------------------------------------
// End Implementation Dependencies -------------------------------------------


// Member Function //

Array::~Array()

// Summary -----------------------------------------------------------------
//
//      Destructor for an Array object.
//
//		We don't do anything here, because the destructor for AbstractArray
//		will take care of destroying the contained objects.
//
// End ---------------------------------------------------------------------
{
}
// End Destructor //


// Member Function //

classType Array::isA() const

// Summary -----------------------------------------------------------------
//
// 	    Returns the class type of an array.
//
// End ---------------------------------------------------------------------
{
    return arrayClass; 
}
// End Member Function Array::isA //


// Member Function //

char *Array::nameOf() const

// Summary -----------------------------------------------------------------
//
// 	    Returns a pointer to the character string "Array."
//
// End ---------------------------------------------------------------------
{
    return "Array";
}
// End Member Function Array::nameOf //


// Member Function //

void Array::add( Object& toAdd )

// Summary -----------------------------------------------------------------
//
//      Adds the given object to the array.
//
// Parameters
//
//      toAdd
//
//      The object we are to add to the array.  Once the object is
//      added, it is owned by the array.
//
// End ---------------------------------------------------------------------
{

// Body Comment
//
//      We search for the first available space for an array element.
//      Since the user may have inserted an element with addAt or
//      with the subscript operator, we check first before overwriting
//      anything.
//
// End

    while( theArray[ whereToAdd ] != ZERO && whereToAdd <= upperbound )
    {
        whereToAdd++;
    } // end while an array index already has an element.

	if( whereToAdd > upperbound )
    {
		reallocate( whereToAdd - lowerbound + 1 );
	}
	theArray[ whereToAdd++ ] = &toAdd;
	itemsInContainer++;

}
// End Member Function Array::add //


// Member Function //

void Array::addAt( Object& toAdd, int atIndex )

// Summary -----------------------------------------------------------------
//
//      Adds the given object to the array at the given index.  If there
//      is an object already at that index, destroys the object.
//
// Parameters
//
//      toAdd
//
//      The object we are to add to the array.  Once the object is
//      added, it is owned by the array.
//
//      atIndex
//
//      The index at which to add the object.
//
// End ---------------------------------------------------------------------
{

	if( atIndex > upperbound )
    {
		reallocate( atIndex - lowerbound + 1 );
    }

    if ( theArray[ atIndex ] != ZERO )
    {
        delete theArray[ atIndex ];
        itemsInContainer--;
    }
	theArray[ atIndex ] = &toAdd;
	itemsInContainer++;
}
// End Member Function Array::addAt //


