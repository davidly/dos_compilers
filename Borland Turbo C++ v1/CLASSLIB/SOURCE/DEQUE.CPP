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
//      Deque::isA
//      Deque::nameOf
//      Deque::getLeft
//      Deque::getRight
//      Deque::initIterator
//      Deque::initReverseIterator
//      Deque::hashValue
//
// Description
//
//      Implementation of class Deque member functions.
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

#ifndef __DEQUE_H
#include <deque.h>
#endif

// End Interface Dependencies ------------------------------------------------

// Implementation Dependencies ----------------------------------------------

#ifndef __DBLLIST_H
#include <dbllist.h>
#endif

// End Implementation Dependencies -------------------------------------------


// Member Function //

Deque::~Deque()

// Summary -----------------------------------------------------------------
//
//      Destructor for a Deque object.
//
//		We don't do anything here, because the destructor for theDeque
//		will destroy all the objects in the Deque.
//
// End ---------------------------------------------------------------------
{
}
// End Destructor //


// Member Function //

classType Deque::isA() const

// Summary -----------------------------------------------------------------
//
// 	    Returns the class type of a double-ended queue.
//
// End ---------------------------------------------------------------------
{
    return dequeClass; 
}
// End Member Function Deque::isA //


// Member Function //

char *Deque::nameOf() const

// Summary -----------------------------------------------------------------
//
// 	    Returns a pointer to the character string "Deque."
//
// End ---------------------------------------------------------------------
{
    return "Deque";
}
// End Member Function Deque::nameOf //


// Member Function //

Object& Deque::getLeft()

// Summary -----------------------------------------------------------------
//
//      Gets an object from the left end of the deque.  The object becomes 
//      the ownership of the receiver.
//
// End ---------------------------------------------------------------------
{
	Object& temp = theDeque.peekAtHead();
    if( temp != NOOBJECT )
        {
    	theDeque.detachFromHead( temp );
        itemsInContainer--;
        }
    return temp;
}
// End Member Function Deque::getLeft //


// Member Function //

Object& Deque::getRight()

// Summary -----------------------------------------------------------------
//
//      Gets an object from the right end of the deque.  The object becomes 
//      the ownership of the receiver.
//
// End ---------------------------------------------------------------------
{
	Object& temp = theDeque.peekAtTail();
    if( temp != NOOBJECT )
        {
    	theDeque.detachFromTail( temp );
        itemsInContainer--;
        }
    return temp;
}
// End Member Function Deque::getLeft //


// Member Function //

ContainerIterator& Deque::initIterator() const

// Summary -----------------------------------------------------------------
//
//      Initializes an iterator for a deque.
//
// End ---------------------------------------------------------------------
{
	return *( (ContainerIterator *)new DoubleListIterator( this->theDeque ) );
}
// End Member Function Deque::initIterator //


// Member Function //

ContainerIterator& Deque::initReverseIterator() const

// Summary -----------------------------------------------------------------
//
//      Initializes a right to left iterator for a deque.
//
// End ---------------------------------------------------------------------
{
	return *((ContainerIterator *)new DoubleListIterator( this->theDeque, 0 ));
}
// End Member Function Deque::initReverseIterator //


// Member Function //

hashValueType Deque::hashValue() const

// Summary -----------------------------------------------------------------
//
//      Returns the hash value of a deque.
//
// End ---------------------------------------------------------------------
{
	return hashValueType(0);
}
// End Member Function Deque::hashValue //
