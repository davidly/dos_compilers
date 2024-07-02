#ifndef __SORTARRY_H
#define __SORTARRY_H

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
//      SortedArray
//      SortedArray::SortedArray                    constructor
// 	    SortedArray::operator []
//
// Description
//
//      Defines the class SortedArray.
//
// End ---------------------------------------------------------------------

// Interface Dependencies ---------------------------------------------------

#ifndef __IOSTREAM_H
#include <iostream.h>
#define __IOSTREAM_H
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

#ifndef __ABSTARRY_H
#include <abstarry.h>
#endif

// End Interface Dependencies ------------------------------------------------


// Class //

class SortedArray:  public AbstractArray
{
public:
			SortedArray( int upper, int lower = 0, sizeType aDelta = 0 );
    virtual ~SortedArray();

			const Sortable& operator []( int ) const;

    virtual void            add( Object& );
	virtual	void			detach( const Object&, int = 0 );
    virtual classType       isA() const;
    virtual char           *nameOf() const;

private:
            int             lastElementIndex;
};

// Description -------------------------------------------------------------
//
//      Defines the class SortedArray.  The SortedArray class is an
// 	array in which any elements which are added are added in sorted
// 	order.  
//
// Constructor
//
// 	SortedArray
//
// 	Constructor.  Uses the AbstractArray class constructor.
//
// Public Members
//
// 	    operator []
//      
// 	    Subscript operator.  The subscript operator for sorted array
//      returns a constant object.  Allowing assignments to an object 
//      at a particular index might violate the sorting of the array.
//
//      add
//
//      Appends an object to the array, keeping the array elements sorted
//      and expanding the array if necessary.
// 	
// 	    detach
//
// 	    Removes a reference to the object from the array.
//
// 	    isA
//
// 	    Returns the class type of a sorted array.
//
// 	    nameOf
//
// 	    Returns a character pointer to the string "SortedArray."
//
// Inherited Members
//
// 	lowerBound
//
// 	Inherited from class AbstractArray.
//
// 	upperBound
//
// 	Inherited from class AbstractArray.
//
// 	arraySize
//
// 	Inherited from class AbstractArray.
//
//      destroy
//
//      Removes an object reference from the array.
//
//      hashValue
//
// 	Inherited from AbstractArray.
//
// 	isEqual
//
// 	Inherited from AbstractArray.
//
// 	    printOn
//
// 	    Inherited from Container.
//
// Protected Members
//
//      delta
//
// 	Inherited from Array and made protected.
//
//      lowerbound
//
// 	Inherited from Array and made protected.
//
//      upperbound
//
// 	Inherited from Array and made protected.
//
//      array
//
// 	Inherited from Array and made protected.
//
// Private Members
//
//      lastElementIndex
//
//      The index of the last element in the sorted array.
//
// End ---------------------------------------------------------------------


// Constructor //

inline  SortedArray::SortedArray( int upper, int lower, sizeType aDelta ) :
						                AbstractArray( upper, lower, aDelta )

// Summary -----------------------------------------------------------------
//
//      Constructor for a sorted array object.
//
// End ---------------------------------------------------------------------
{
    lastElementIndex = lowerbound - 1;
}
// End Constructor SortedArray::SortedArray //


// Member Function //

inline const Sortable& SortedArray::operator []( int atIndex ) const

// Summary -----------------------------------------------------------------
//
//      Subscript operator for sorted arrays.
//
// Return Value
//
// 	sortableAt
//
// 	Reference to the sortable object at the given index.
//
// End ---------------------------------------------------------------------
{
    return (Sortable&)objectAt( atIndex );
}
// End Member Function SortedArray::operator [] //


#endif // ifndef __SORTARRY_H //
