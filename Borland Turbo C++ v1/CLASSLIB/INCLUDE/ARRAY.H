#ifndef __ARRAY_H
#define __ARRAY_H

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
//      Array
// 	    Array::operator []
//
// Description
//
//      Defines the class Array.  An array object implies indexability.
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

#ifndef __ABSTARRY_H
#include <abstarry.h>
#endif

// End Interface Dependencies ------------------------------------------------


// Class //

class Array:  public AbstractArray
{
public:														 
			Array( int upper, int lower = 0, sizeType aDelta = 0 ) :
		    					AbstractArray( upper, lower, aDelta ) {}
    virtual ~Array();

            Object&         operator []( int ) const;

    virtual void            add( Object& );
            void            addAt( Object&, int );
    virtual classType       isA() const;
    virtual char           *nameOf() const;
};

// Description -------------------------------------------------------------
//
//      Defines the class Array.  The Array class is made up of Objects
// 	    which can be indexed with the given operator.  The size of the
// 	    array, i.e. the maximum number of elements which may be put
// 	    into the array, is calculated from the bounds given at the
// 	    construction of the array object.
//
// Constructor
//
// 	    Array
//
// 	    Constructor.  Parameter upper specifies the upper bound for the
// 	    index of the array.	Parameter lower specifies a lower bound for
// 	    the index of the array.  Paramter aDelta specifies the number of 
// 	    array elements by which the array will grow if an element is added 
// 	    to an array	which has no more space for elements.  Specify aDelta = 0 
// 	    if the array should not be allowed to grow.
//
// Public Members
//
// 	    operator []
//
// 	    Subscript operator.  Returns a reference to the element at the 
// 	    given index.  The subscript operator will report an index out of
// 	    bounds if the index is not in the current range.
//
// 	    lowerBound
//
// 	    Returns the current lower bound of the array.  The lower bound is
// 	    fixed when the array is constructed.
//
// 	    upperBound
//
// 	    Returns the upper bound of the array.  The upper bound is initially
// 	    set when the array is constructed but may increase is more elements
// 	    are added.	The amount by which the upper bound will increase is
// 	    a parameter to the constructor for the array.
//
// 	    arraySize
//
// 	    Returns the size of the array, in elements, as determined by the
// 	    lower bound and the current upper bound.
//
// 	    addAt
//
//      Places an object in the array of the specified idnex, growing the
//      array as needed if the index exceeds the upper bound.
//
//      destroy
//
//      Removes an object reference from the array at the given index and
//      destroys the object.
//
// 	    detach
//
// 	    Removes all references to the object at the given index in the array.
//      Does not delete the object.  Use this function when the array elements
// 	    are not owned by the array.
//
//      add
//
//      Appends an object to the array, expanding the array if necessary.
//      Overrides add member function inherited from Collection.
// 	
//      destroy
//
//      Destroys the given object.
//
// 	    detach
//
//      Removes a reference to the given object from the array.
//
//      hashValue
//
// 	    Returns a pre-defined value as the hash value of an array.
//
// 	    isA
//
// 	    Returns the class type of an array.
//
// 	    nameOf
//
// 	    Returns a pointer to the character string "Array."
// 	
// 	    isEqual
//
// 	    Determines whether two arrays are equal.
//
// Inherited Members
//
//      hasMember
//
//      Inherited from Collection
//
// 	    isEmpty
//
//      Inherited from Collection.
//
//      forEach
//
//      Inherited from Container.
//
//      firstThat
//
//      Inherited from Container.
//
//      lastThat
//
//      Inherited from Container.
//
// 	    printOn
//
// 	    Inherited from Container.
//
// 	    printHeader
//
// 	    Inherited from Object.
//
// 	    printTrailer
//
// 	    Inherited from Object.
//
// 	    printSeparator
//
// 	    Inherited from Object.
//
// Protected Members
//
//      delta
//
//      Defines the number of elements by which we are to expand the
//      array, if needed.
//
//      lowerbound
//
//      Defines the smallest value for an index in this array.
//
//      upperbound
//
//      Defines the largest index in the array which, if referenced,
//      will not cause an array expansion to take place.
//
//      theArray
//
//      Points to the area in which array element references are located.
//
// End ---------------------------------------------------------------------


// Member Function //

inline Object& Array::operator []( int atIndex ) const

// Summary -----------------------------------------------------------------
//
//      Subscript operator for arrays.
//
// Return Value
//
// 	    objectAt
//
// 	    Reference to the object at the given index.
//
// End ---------------------------------------------------------------------
{
	return objectAt( atIndex );
}
#endif // ifndef __ARRAY_H //
