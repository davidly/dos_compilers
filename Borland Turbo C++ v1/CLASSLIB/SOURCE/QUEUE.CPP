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
//      Queue::get
//      Queue::initIterator
//      Queue::hashValue
//
// Description
//
//      Implementation of class Queue member functions.
//
// End ---------------------------------------------------------------------

// Interface Dependencies ---------------------------------------------------

#ifndef __CLSTYPES_H
#include <clstypes.h>
#endif

#ifndef __OBJECT_H
#include <object.h>
#endif

#ifndef __QUEUE_H
#include <queue.h>
#endif

// End Interface Dependencies ------------------------------------------------

// Implementation Dependencies ----------------------------------------------

#ifndef __DBLLIST_H
#include <dbllist.h>
#endif

// End Implementation Dependencies -------------------------------------------


// Member Function //

Queue::~Queue()

// Summary -----------------------------------------------------------------
//
//      Destructor for a Queue object.
//
//		We don't do anything here, because the destructor for theQueue
//		will take care of destroying the contained objects.
//
// End ---------------------------------------------------------------------
{
}
// End Destructor //


// Member Function //

Object& Queue::get()

// Summary -----------------------------------------------------------------
//
//      Gets an object from the queue.  The object becomes the ownership
//      of the receiver.
//
// Return Value
//
// 	    firstIn
//
// 	    We return the element which is a the tail of the queue, i.e. the
// 	    first element in to the queue.
//
// End ---------------------------------------------------------------------
{
	Object& temp = theQueue.peekAtTail();
	if ( temp != NOOBJECT )
        {
		theQueue.detachFromTail( temp );
        itemsInContainer--;
        }
    return temp;
}
// End Member Function Queue::get //


// Member Function //

classType Queue::isA() const

// Summary -----------------------------------------------------------------
//
//      Returns a predefined value for the class Queue.
//
// Parameters
//
//      none
//
// End ---------------------------------------------------------------------
{
    return queueClass;
}
// End Member Function Queue::isA //


// Member Function //

char *Queue::nameOf() const

// Summary -----------------------------------------------------------------
//
//      Returns the string "Queue".
//
// Parameters
//
//      none
//
// End ---------------------------------------------------------------------
{
    return "Queue";
}
// End Member Function Queue::nameOf //


// Member Function //

hashValueType Queue::hashValue() const

// Summary -----------------------------------------------------------------
//
//      Returns the hash value of a queue.
//
// End ---------------------------------------------------------------------
{
	return hashValueType(0);
}
// End Member Function Queue::hashValue //

// Member Function //

ContainerIterator& Queue::initIterator() const

// Summary -----------------------------------------------------------------
//
//      Initializes an iterator for a queue.
//
// End ---------------------------------------------------------------------
{
    return *( (ContainerIterator *)new DoubleListIterator( theQueue ) );
}
// End Member Function Queue::initIterator //

