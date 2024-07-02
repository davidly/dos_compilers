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
//
// Description
//
//      Implementation of member functions for class Set.
//
// End ---------------------------------------------------------------------

// Interface Dependencies ---------------------------------------------------

#ifndef __CLSTYPES_H
#include <clstypes.h>
#endif

#ifndef __SET_H
#include <set.h>
#endif

// End Interface Dependencies ------------------------------------------------

// Implementation Dependencies ----------------------------------------------
// End Implementation Dependencies -------------------------------------------


// Member Function //

Set::~Set()

// Summary -----------------------------------------------------------------
//
//      Destructor for a Set object.
//
//		We don't do anything here, because the destructor for HashTable
//		will take care of destroying the contained objects.
//
// End ---------------------------------------------------------------------
{
}
// End Destructor //


// Member Function //

classType Set::isA() const

// Summary -----------------------------------------------------------------
//
//      Returns the class type of a set.
//
// End ---------------------------------------------------------------------
{
    return setClass;
}
// End Member Function Set::isA //


// Member Function //

char *Set::nameOf() const

// Summary -----------------------------------------------------------------
//
//      Returns a pointer to the character string "Set".
//
// End ---------------------------------------------------------------------
{
    return "Set";
}
// End Member Function Set::isA //


// Member Function //

void Set::add( Object& objectToAdd )

// Summary -----------------------------------------------------------------
//
//      Adds an object to the set.  Sets may have only one copy of an object
//      in the set at any time.
//
// Parameters
//
//      objectToAdd
//
// End ---------------------------------------------------------------------
{
	if ( !(Bag::hasMember( objectToAdd )) )
    {
		Bag::add( objectToAdd );
    }
}
// End Member Function Set::add //



