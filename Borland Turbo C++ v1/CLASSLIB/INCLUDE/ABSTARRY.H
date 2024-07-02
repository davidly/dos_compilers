#ifndef __ABSTARRY_H
#define __ABSTARRY_H

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
//      AbstractArray
// 	    AbstractArray::arraySize
//
//      ArrayIterator
//      ArrayIterator::ArrayIterator
//
// Description
//
//      Defines the class AbstractArray.  An array object implies 
//      indexability.  Defines the class ArrayIterator.
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

#ifndef __COLLECT_H
#include <collect.h>
#endif

// End Interface Dependencies ------------------------------------------------


class AbstractArray:  public Collection
{
public:														 
			AbstractArray( int upper, int lower = 0, sizeType aDelta = 0 );
    virtual ~AbstractArray();

            int             lowerBound() const { return lowerbound; }
            int             upperBound() const { return upperbound; }
			sizeType        arraySize() const;

    virtual ContainerIterator& initIterator() const;

    virtual void            add( Object& ) = 0;
	        void			destroy( int i ) { detach( i, 1 ); }
	        void			detach( int, int = 0 );

	virtual	void			detach( const Object&, int = 0 );

    virtual classType       isA() const = 0;
    virtual char           *nameOf() const = 0;
    virtual int             isEqual( const Object& ) const;
	virtual hashValueType   hashValue() const;

	virtual	void			printContentsOn( ostream& ) const;

protected:
            Object&         objectAt( int i ) const
                                { return *theArray[ i - lowerbound ]; }
			void			reallocate( sizeType );
			sizeType		delta;
			int				lowerbound;
			int				upperbound;
			int				whereToAdd;
			Object        **theArray;

	friend  class ArrayIterator;
};

// Description -------------------------------------------------------------
//
//      Defines the class AbstractArray.  The AbstractArray class is 
//      used as a base class for random-access and sorted arrays.
//      The size of the array, i.e. the maximum number of elements 
//      which may be put into the array, is calculated from the bounds 
//      given at the construction of the array object.
//
// Constructor
//
// 	    AbstractArray
//
// 	    Constructor.  Parameter upper specifies the upper bound for the
// 	    index of the array.	Parameter lower specifies a lower bound for
//      the index of the array.  Paramter aDelta specifies the number of 
// 	    array elements by which the array will grow if an element is added 
// 	    to an array	which has no more space for elements.  Specify aDelta = 0 
// 	    if the array should not be allowed to grow.
//
// Public Members
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
// 	    initIterator
//
// 	    Array iterator initializer.
//
//      add
//
//      Pure virtual function.
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
// 	    detach
//
//      Removes a reference to the given object from the array.
//
//      hashValue
//
// 	    Returns a pre-defined value as the hash value of an array.
//
// 	    isEqual
//
// 	    Determines whether two arrays are equal.
//
// 	    printContentsOn
//
// 	    Displays the non-ZERO elements of the array.
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
//      destroy
//
//      Inherited from Collection.
//
// Protected Members
//
// 	    objectAt
//
// 	    Returns a reference to the object at the given index.
//
// 	    reallocate
//
// 	    Expands the pointer array to a new size.
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

inline sizeType AbstractArray::arraySize() const

// Summary -----------------------------------------------------------------
//
//      Returns the current size of the array.
//
// End ---------------------------------------------------------------------
{
	return sizeType( upperbound - lowerbound + 1 );
}
// End Member Function AbstractArray::arraySize //


// Class //

class ArrayIterator:  public ContainerIterator
{
public:
            ArrayIterator( const AbstractArray& );
    virtual ~ArrayIterator();

	virtual				operator int();
	virtual				operator Object&();
	virtual	Object&		operator ++();
	virtual	void		restart();

private:
			int		    currentIndex;
    const   AbstractArray& beingIterated;
};

// Description -------------------------------------------------------------
//
// 	    Defines the array iterator class.  Upon initialization, we set up
// 	    an internal pointer to our current position in the array.  As
//      the increment operator is called, we update this current position.
//
// Constructor
//
//      ArrayIterator( const AbstractArray& )
//
// 	    Constructor for an iterator.  Note that this isn't a copy
// 	    constructor, since it takes an object from a different class.
//
// Destructor
//
// 	    ~ArrayIterator
//
// Public Members
//
// 	    operator int
//
// 	    We are allowed one cast operator to a predefined type.  This
// 	    operator defines an explicit or an implicit cast from a
// 	    ArrayIterator to an integer.
//
//      operator Object&
//
//      Conversion to Object operator.
//
// 	    operator ++
//
//      The increment operator.
//
// 	    restart
//
// 	    Restarts an array iterator.
//
// Private Members
//
// 	    currentIndex
//
// 	    Maintains the position information for this iterator.
//
// 	    beingIterated
//
//      Maintains a pointer to the array being iterated.
//
// End ---------------------------------------------------------------------


// Constructor //

inline  ArrayIterator::ArrayIterator( const AbstractArray& toIterate ) :
			beingIterated( toIterate ), currentIndex( toIterate.lowerbound )

// Summary -----------------------------------------------------------------
//
//      Constructor for a array iterator object.
//
// End ---------------------------------------------------------------------
{
}
// End Constructor ArrayIterator::ArrayIterator //


#endif // ifndef __ABSTARRY_H //
