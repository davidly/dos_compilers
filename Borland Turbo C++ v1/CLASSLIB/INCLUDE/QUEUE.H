#ifndef __QUEUE_H
#define __QUEUE_H

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
//      Queue
//
// Description
//
//      Defines the class Queue.
//
// End ---------------------------------------------------------------------

// Interface Dependencies ---------------------------------------------------

#ifndef __IOSTREAM_H
#include <iostream.h>
#define __IOSTREAM_H
#endif

#ifndef __CLSTYPES_H
#include "clstypes.h"
#endif

#ifndef __OBJECT_H
#include "object.h"
#endif

#ifndef __CONTAIN_H
#include "contain.h"
#endif

#ifndef __DBLLIST_H
#include "dbllist.h"
#endif

// End Interface Dependencies ------------------------------------------------

// Class //

class Queue:  public Container
{
public:
	virtual ~Queue();

            Object&         peekLeft() const { return theQueue.peekAtHead(); }
            Object&         peekRight() const { return theQueue.peekAtTail(); }
			Object&         get();
            void            put( Object& o ) { theQueue.addAtHead( o ); itemsInContainer++; }

    virtual ContainerIterator& initIterator() const;

    virtual classType       isA() const;
    virtual char           *nameOf() const;
    virtual hashValueType   hashValue() const;

private:
	DoubleList    theQueue;
};

// Description -------------------------------------------------------------
//
// 	Defines the container class Queue.  A queue is a FIFO object.
//      You may inspect elements at either end of the queue, however,
//      you may only remove objects at one end and add objects at the
//      other.  The left end is the end at which objects are enqueued.
//      The right end is where objects may be retrieved.
//
// Public Members
//
//      peekLeft
//
//      Returns a reference to the object at the left end of the queue.
//      The object is still owned by the queue.
//
//      peekRight
//
//      Returns a reference to the object at the right end of the queue.
//      The object is still owned by the queue.
//
//      put
//
//      Enqueues an object.
//
//      get
//
//      Dequeues an object.
//
//      initIterator
//
//      Left-to-right Queue iterator initializer.
//
// 	isA
//
// 	Returns the class type for a queue.
//
// 	nameOf
//
// 	Returns a pointer to the character string "Queue."
// 	
// 	hashValue
//
// 	Returns a pre-defined value for queues.
//
// Inherited Members
//
//      Queue( Queue& )
//
//      Copy constructor.  Inherited from Container.
//
//      isEmpty
//
// 	Inherited from Container.
//
// 	operator ==
//
// 	Inherited from Container.
//
//      forEach
//
// 	Inherited from Container.
//
//      firstThat
//
// 	Inherited from Container.
//
//      lastThat
//
// 	Inherited from Container.
//
//      getItemsInContainer
//
// 	Inherited from Container.
//
//      itemsInContainer
//
// 	Inherited from Container.
//
//      printOn
//
// 	Inherited from Container.
//
//      printHeader
//
// 	Inherited from Container.
//
//      printSeparator
//
// 	Inherited from Container.
//
//      printTrailer
//
// 	Inherited from Container.
//
// Private Members
//
//      theQueue
//
//      The implementation of the queue.
//
// End ---------------------------------------------------------------------


#endif // ifndef __QUEUE_H //
