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
//      AbstractArray::AbstractArray                        constructor
//      AbstractArray::~AbstractArray                       destructor
//      AbstractArray::detach                               Object
//      AbstractArray::detach                               int
//      AbstractArray::hashValue
//      AbstractArray::reallocate
//      AbstractArray::isEqual
//      AbstractArray::initIterator
//      AbstractArray::printContentsOn
//
//      ArrayIterator::operator int
//      ArrayIterator::operator Object
//      ArrayIterator::restart
//      ArrayIterator::operator ++
//
// Description
//
//      Implementation of class AbstractArray and class ArrayIterator member
//      functions.
//
// End ---------------------------------------------------------------------

// Interface Dependencies ---------------------------------------------------

#ifndef __IOSTREAM_H
#include <iostream.h>
#define __IOSTREAM_H
#endif

#ifndef __STDLIB_H
#include <stdlib.h>
#define __STDLIB_H
#endif

#ifndef __ASSERT_H
#include <assert.h>
#define __ASSERT_H
#endif

#ifndef __CLSDEFS_H
#include <clsdefs.h>
#endif

#ifndef __CLSTYPES_H
#include <clstypes.h>
#endif

#ifndef __OBJECT_H
#include <object.h>
#endif

#ifndef __CONTAIN_H
#include <contain.h>
#endif

#ifndef __ABSTARRY_H
#include <abstarry.h>
#endif

// End Interface Dependencies ------------------------------------------------

// Implementation Dependencies ----------------------------------------------
// End Implementation Dependencies -------------------------------------------


// Constructor //

AbstractArray::AbstractArray( int anUpper, int aLower, sizeType aDelta )

// Summary -----------------------------------------------------------------
//
//      Constructor for an abstract array.  An abstract array can be made
// 	    to be either of a fixed or expanding size.  In an expanding array,
// 	    when a reference is made to an index greater than the current upper
// 	    bound of the array, the array will grow to allow the given index
//      to reference a valid array object.  The number of elements by
//      which this growth is performed is given by the parameter aDelta.
//
// Parameters
//
//      anUpper
//
//      The upper bound for the array.
//
//      aLower
//
//      The lower bound for the array.  The initial size of the array is
//      calculated from the upper and lower bounds.
//
//      aDelta
//
//      The growth factor for the array.
//
// Functional Description
//
//      We set up the private parts of the array, allocate space for the
//      pointers, then set all the allocated pointers to point to the 
//      error object.
//
// End ---------------------------------------------------------------------
{
	lowerbound = whereToAdd = aLower;
	upperbound = anUpper;
	delta = aDelta;
	theArray = new Object *[ arraySize() ];
    for( int i = 0; i < arraySize(); i++ )
	{
		theArray[ i ] = ZERO;
	} // end for
}
// End Constructor AbstractArray::AbstractArray //


// Destructor //

AbstractArray::~AbstractArray()

// Summary -----------------------------------------------------------------
//
//      Destructor for a AbstractArray object.
//
// End ---------------------------------------------------------------------
{
    for( int i = 0; i < arraySize(); i++ )
        if( theArray[ i ] != ZERO )
            delete theArray[ i ];
	delete [ arraySize() ] theArray;
}
// End Destructor //


// Member Function //

void    AbstractArray::detach( const Object& toDetach, int deleteObjectToo )

// Summary -----------------------------------------------------------------
//
//      Detaches an object from the array.
//
// Parameter
//
//      toDetach
//
//      The object we are to search for and detach from the AbstractArray.
//
//      deleteObjectToo
//
//      Specifies whether we are to delete the object.
//
// Functional Description                     
//
//      If the object specified is at the lower bound of the array, we remove
//      the reference right away.  Otherwise, we iterate through the array until
//      we find it, then remove the reference.
//
// Remarks
//
//  warnings:
//      No error condition is generated if the object which was specified
//      isn't in the array.
//
// End ---------------------------------------------------------------------
{
	if ( toDetach == NOOBJECT )
        return;

    for ( int i = 0; i < arraySize(); i++ )
    {
		if ( ( theArray[ i ] != ZERO ) && ( *theArray[ i ] == toDetach ) )
        {
            if ( deleteObjectToo )
            {
                delete theArray[ i ];
            }
            theArray[ i ] = ZERO;
            itemsInContainer--;
            break;
        }
    } // end for //
}
// End Member Function AbstractArray::detach //


// Member Function //

void    AbstractArray::detach( int atIndex, int deleteObjectToo )

// Summary -----------------------------------------------------------------
//
//      Detaches an object from the array at the given index.
//
// Parameter
//
//      toIndex
//
//      The index from which we are to detach the object.
//
//      deleteObjectToo
//
//      Specifies whether we are to delete the object.
//
// Remarks
//
//  warnings:
//      No error condition is generated if the object which was specified
//      isn't in the array.
//
// End ---------------------------------------------------------------------
{
    if ( theArray[ atIndex - lowerbound ] != ZERO )
    {
		if ( deleteObjectToo )
        {
            delete ( theArray[ atIndex - lowerbound ] );
        }
        theArray[ atIndex - lowerbound ] = ZERO;
        itemsInContainer--;
    } // end if there was an element already there in the array.
}
// End Member Function AbstractArray::detach //


// Member Function //

hashValueType AbstractArray::hashValue() const

// Summary -----------------------------------------------------------------
//
//      Returns the hash value of a array.
//
// End ---------------------------------------------------------------------
{
	return hashValueType(0);
}
// End Member Function AbstractArray::hashValue //


// Member Function //

void AbstractArray::reallocate( sizeType newSize )

// Summary -----------------------------------------------------------------
//
// 	    Reallocates the array's pointer vector to a new size.
//
// Parameters
//
// 	    newSize
//
// 	    The number of pointers which is to be in the new vector.
//
// Functional Description
//
// 	    We allocate space for a new pointer vector of the given size,
// 	    adjusted to take into account the growth factor.  We then copy
// 	    the old vector into the new one and fix up the pointer in the
// 	    array object.
//
// Remarks
//
//  assumptions
// 	    Asserts that the new size of the pointer vector is greater than
// 	    the current size.  We do "expanding-only" arrays, not accordions.
//
// End ---------------------------------------------------------------------
{
    if ( delta == 0 )
    {
        cerr << "Error:  Attempting to expand a fixed size array.";
        exit(__EEXPAND);
    }

	int i;		// Loop counter for moving the pointers from the old vector
				// to the new one.

// Body Comment
//
// 	    We assume that the new pointer vector size is greater than the
// 	    current vector size.
//
// End

	assert ( newSize > arraySize() );

	sizeType adjustedSize = newSize + ( delta - ( newSize % delta ) );

	Object **newArray = new Object *[ adjustedSize ];
    if ( newArray == 0 )
    {
        cerr << "Error:  Out of Memory";
        exit(__ENOMEM);
    }

	for ( i = 0; i < arraySize(); i++ )
	{
		newArray[i] = theArray[i];
	}
	for (; i < adjustedSize; i++ )
	{
		newArray[i] = ZERO;
	}

    delete [ arraySize() ] theArray;
	theArray = newArray;
    upperbound = adjustedSize + lowerbound - 1;

}
// End Member Function AbstractArray::reallocate //


// Member Function //

int AbstractArray::isEqual( const Object& testObject ) const

// Summary -----------------------------------------------------------------
//
// 	    Tests for equality of two arrays.  Two arrays are equal if they
// 	    have the same dimensions and the same objects at the same indices.
//
// Parameters
//
// 	    testObject
//
// 	    The array which we will be testing against this.
//
// End ---------------------------------------------------------------------
{

	if ( lowerbound != ((AbstractArray&)testObject).lowerbound ||
		 upperbound != ((AbstractArray&)testObject).upperbound )
	{
		return 0;
	}

	for ( int i = 0; i < arraySize(); i++ )
	{

// Body Comment
//
// 	    The two array elements can be null, so check that first.
// 		If there are really objects there, compare them for equality.
//
// End

		if ( theArray[i] != ZERO )
		{
			if ( ((AbstractArray&)testObject).theArray[i] != ZERO )
			{
				if ( *theArray[i] !=
					 *( ((AbstractArray &)testObject).theArray[i] ) )
				{
					return 0; // objects weren't equal.
				}
			}
			else // the first pointer wasn't ZERO but the second was
			{
				return 0;
			}
		}
		else
			if ( ((AbstractArray&)testObject).theArray[i] != ZERO )
			{
				return 0;  // first pointer was ZERO but the second wasn't
			}
	}  // end for each element in the array.
	return 1;
}
// End Member Function AbstractArray::isEqual //


// Member Function //

ContainerIterator& AbstractArray::initIterator() const

// Summary -----------------------------------------------------------------
//
//      Initializes an iterator for a list.
//
// End ---------------------------------------------------------------------
{
	return *( (ContainerIterator *)new ArrayIterator( *this ) );
}
// End Member Function AbstractArray::initIterator //


// Member Function //

void AbstractArray::printContentsOn( ostream& outputStream ) const

// Summary -----------------------------------------------------------------
//
//      Displays the non-ZERO contents of an array on the given stream.
//
// Parameters
//
//      outputStream
//
//      The stream on which we will be writing the contents.
//
// Functional Description
//
//      We initialize an iterator, then iterator through each object,
//      asking the objects to print themselves if they are not the
// 	    error object.
//
// Remarks
//
//  warnings:
//      We must be sure to delete the container iterator, since it was
//      allocated on the heap.
//
// End ---------------------------------------------------------------------
{
	ContainerIterator& printIterator = initIterator();

    printHeader( outputStream );

	while( int(printIterator) != 0 )
	{
		Object& arrayObject = printIterator++;
		if ( arrayObject != NOOBJECT )
		{
			arrayObject.printOn( outputStream );

			if ( int(printIterator) != 0 )
			{
            printSeparator( outputStream );
			}
			else // there are no more objects in the array.
			{
				break;
			}
		} // end if the array object is NOOBJECT.
    } // end while //

    printTrailer( outputStream );
    delete &printIterator;
}
// End Member Function AbstractArray::printContentsOn //


// Destructor //

ArrayIterator::~ArrayIterator()

// Summary -----------------------------------------------------------------
//
//      Destructor for a ArrayIterator object.
//
// End ---------------------------------------------------------------------
{
}
// End Destructor //


// Member Function //

ArrayIterator::operator int()

// Summary -----------------------------------------------------------------
//
//      Integer conversion for an array iterator.
//
// End ---------------------------------------------------------------------
{
	return currentIndex <= beingIterated.upperbound;
}
// End Member Function operator int //


// Member Function //

ArrayIterator::operator Object&()

// Summary -----------------------------------------------------------------
//
//      Object reference conversion for an array iterator.
//
// End ---------------------------------------------------------------------
{
	if ( currentIndex <= beingIterated.upperbound )
	{
        return ( (Object&)( beingIterated.objectAt( currentIndex ) ) );
	}
    else // no more elements in the array.
    {
        return NOOBJECT;
    }
}
// End Member Function operator Object& //


// Member Function //

void ArrayIterator::restart()

// Summary -----------------------------------------------------------------
//
//      ArrayIterator restart.
//
// End ---------------------------------------------------------------------
{
	currentIndex = beingIterated.lowerbound;
}
// End Member Function ArrayIterator::restart //


// Member Function //

Object& ArrayIterator::operator ++()

// Summary -----------------------------------------------------------------
//
// 	    Increments the array iterator and returns the next object.
//
// End ---------------------------------------------------------------------
{
	if ( currentIndex <= beingIterated.upperbound )
	{
		currentIndex++;
        return ( (Object&)( beingIterated.objectAt( currentIndex - 1 ) ) );

	}
    else // no more elements in the array.
    {
        return NOOBJECT;
    }

}
// End Member Function ArrayIterator::operator ++//

