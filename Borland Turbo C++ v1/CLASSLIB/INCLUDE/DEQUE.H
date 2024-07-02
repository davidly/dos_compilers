#ifndef __DEQUE_H
#define __DEQUE_H

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
//      Deque
//
// Description
//
//      Defines the class Deque.
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

#ifndef __CONTAIN_H
#include <contain.h>
#endif

#ifndef __DBLLIST_H
#include <dbllist.h>
#endif

// End Interface Dependencies ------------------------------------------------

// Class //

class Deque:  public Container
{
public:
    virtual ~Deque();

            Object&         peekLeft() const { return theDeque.peekAtHead(); }
            Object&         peekRight() const { return theDeque.peekAtTail(); }
			Object&         getLeft();
			Object&         getRight();
			void            putLeft( Object& o )
                                { theDeque.addAtHead( o ); itemsInContainer++; }
			void            putRight( Object& o )
                                { theDeque.addAtTail( o ); itemsInContainer++; }

    virtual ContainerIterator& initIterator() const;
            ContainerIterator& initReverseIterator() const;

    virtual classType       isA() const;
    virtual char           *nameOf() const;
    virtual hashValueType   hashValue() const;

private:
	DoubleList    theDeque;
};

// Description -------------------------------------------------------------
//
// 	    Defines the container class Deque.  A deque is a double-ended queue.
//      You may inspect, add, and remove elements at either end of the 
//      deque.
//
// Public Members
//
//      peekLeft
//
//      Returns a reference to the object at the left end of the deque.
//      The object is still owned by the deque.
//
//      peekRight
//
//      Returns a reference to the object at the right end of the deque.
//      The object is still owned by the deque.
//
//      putLeft
//
//      Enqueues an object at the left end.
//
//      putRight
//
//      Enqueues an object at the right end.
//
//      getLeft
//
//      Dequeues an object from the left end.
//
//      getRight
//
//      Dequeues an object from the right end.
//
//      initIterator
//
//      Left-to-right Deque iterator initializer.
//
//      initReverseIterator
//
//      Right-to-left Deque iterator initializer.
//
// 	    isA
//
// 	    Returns the class type for a deque.
//
// 	    nameOf
//
// 	    Returns a pointer to the character string "Deque."
// 	
// 	    hashValue
//
// 	    Returns a pre-defined value for deques.
//
// Inherited Members
//
//      Deque( Deque& )
//
//      Copy constructor.  Inherited from Container.
//
//      isEmpty
//
// 	    Inherited from Container.
//
// 	    isEqual
//
// 	    Inherited from Container.
//
//      forEach
//
// 	    Inherited from Container.
//
//      firstThat
//
// 	    Inherited from Container.
//
//      lastThat
//
// 	    Inherited from Container.
//
//      getItemsInContainer
//
// 	    Inherited from Container.
//
//      printOn
//
// 	    Inherited from Container.
//
//      printHeader
//
// 	    Inherited from Container.
//
//      printSeparator
//
// 	    Inherited from Container.
//
//      printTrailer
//
// 	    Inherited from Container.
//
// Private Members
//
//      theDeque
//
//      The implementation of the deque.
//
// End ---------------------------------------------------------------------


#endif // ifndef __DEQUE_H //
