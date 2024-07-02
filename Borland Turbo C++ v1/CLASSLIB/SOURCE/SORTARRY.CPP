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
//      SortedArray::~SortedArray
//      SortedArray::add
//      SortedArray::detach
//
// Description
//
//      Implementation of class SortedArray.
//
// End ---------------------------------------------------------------------

// Interface Dependencies ---------------------------------------------------

#ifndef __STDLIB_H
#include <stdlib.h>
#define __STDLIB_H
#endif

#ifndef __OBJECT_H
#include <object.h>
#endif

#ifndef __SORTARRY_H
#include <sortarry.h>
#endif

// End Interface Dependencies ------------------------------------------------

// Implementation Dependencies ----------------------------------------------

#ifndef __ASSERT_H
#include <assert.h>
#define __ASSERT_H
#endif

#ifndef __CLSTYPES_H
#include <clstypes.h>
#endif

#ifndef __SORTABLE_H
#include <sortable.h>
#endif

#ifndef __CONTAIN_H
#include <contain.h>
#endif

// End Implementation Dependencies -------------------------------------------


// Member Function //

SortedArray::~SortedArray()

// Summary -----------------------------------------------------------------
//
//      Destructor for a SortedArray object.
//
//		We don't do anything here, because the destructor for Array
//		will take care of destroying the contained objects.
//
// End ---------------------------------------------------------------------
{
}
// End Destructor //


// Member Function //

void    SortedArray::add( Object& toAdd )

// Summary -----------------------------------------------------------------
//
//      Adds an object to the sorted array.
//
// Parameter
//
//      toAdd
//
//      The object we are to add to SortedArray.
//
// Functional Description
//
//      We check that the object we are adding is indeed sortable, then
//      expand the array if needed.  We then search for the point to
//      insert the object and move the succeeding objects down the array
//      to make room for the new object.
//  
// End ---------------------------------------------------------------------
{

    if ( toAdd.isSortable() )
    {
        if ( lastElementIndex == upperbound )
        {
            reallocate( arraySize() + 1 );
        }

        int insertionPoint = 0;
        while ( insertionPoint <= lastElementIndex - lowerbound &&
                ((Sortable&)(*(theArray[ insertionPoint ])) < (Sortable&)toAdd) )
        {
            insertionPoint++;
        }

		for ( int i = lastElementIndex - lowerbound; i >= insertionPoint; i-- )
		{
			theArray[i+1] = theArray[i];
		}
		theArray[ insertionPoint ] = &toAdd;
		itemsInContainer++;
		lastElementIndex++;

    }
    else // the object we are to add isn't sortable.
    {
        cerr << "Error:  Object must be sortable.";
        exit(__ENOTSORT);
    }
}
// End Member Function SortedArray::add //


// Member Function //

void    SortedArray::detach( const Object& toDetach, int deleteObjectToo )

// Summary -----------------------------------------------------------------
//
//      Detachs an object to the sorted array.
//
// Parameter
//
//      toDetach
//
//      The object we are to detach to SortedArray.
//
// Functional Description
//
// End ---------------------------------------------------------------------
{
	if ( toDetach == NOOBJECT )
        return;

    int detachPoint, moveCount;

    for ( detachPoint = lowerbound; detachPoint <= upperbound; detachPoint++ )
    {
		if ( *theArray[ detachPoint ] == toDetach )
        {
            if ( deleteObjectToo )
            {
                delete theArray[ detachPoint ];
            }
            for ( moveCount = detachPoint; 
                  moveCount < lastElementIndex;
                  moveCount++ )
            {
				theArray[ moveCount ] = theArray[ moveCount + 1 ];
            }
            theArray[ lastElementIndex-- ] = ZERO;
            itemsInContainer--;
            return;
        }
    } // end for //
}
// End Member Function SortedArray::detach //


// Member Function //

classType SortedArray::isA() const

// Summary -----------------------------------------------------------------
//
//      Returns a predefined value for the class SortedArray.
//
// Parameters
//
//      none
//
// End ---------------------------------------------------------------------
{
    return sortedArrayClass;
}
// End Member Function SortedArray::isA //


// Member Function //

char *SortedArray::nameOf() const

// Summary -----------------------------------------------------------------
//
//      Returns the string "SortedArray".
//
// Parameters
//
//      none
//
// End ---------------------------------------------------------------------
{
    return "SortedArray";
}
// End Member Function SortedArray::nameOf //
