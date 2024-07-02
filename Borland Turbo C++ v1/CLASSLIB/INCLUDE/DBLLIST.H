#ifndef __DBLLIST_H
#define __DBLLIST_H

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
//      DoubleList
//      DoubleList::destroyFromHead
//      DoubleList::destroyFromTail
//
//      DoubleListIterator
//      DoubleListIterator::DoubleListIterator          constructor
//
// Description
//
//      Defines the class DoubleList.
//      Defines the class DoubleListIterator.  A list iterator visits each
//      of the items in a list.
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

#ifndef __DLSTELEM_H
#include <dlstelem.h>
#endif

#ifndef __COLLECT_H
#include <collect.h>
#endif

// End Interface Dependencies ------------------------------------------------


// Class //

class DoubleList:  public Collection
{
public:
            DoubleList() { head = tail = 0; }
    virtual ~DoubleList();

            Object&         peekAtHead() const { return *(head->data); }
            Object&         peekAtTail() const { return *(tail->data); }
            
    virtual void            add( Object& );
    virtual void            detach( const Object&, int = 0 );
            void            addAtHead( Object& );
            void            addAtTail( Object& );
            void            destroyFromHead( const Object& );
            void            destroyFromTail( const Object& );
            void            detachFromHead( const Object&, int = 0 );
            void            detachFromTail( const Object&, int = 0 );

    virtual ContainerIterator& initIterator() const;
            ContainerIterator& initReverseIterator() const;

    virtual classType       isA() const;
    virtual char           *nameOf() const;
    virtual hashValueType   hashValue() const;

private:
            DoubleListElement    *head;
            DoubleListElement    *tail;
    friend  class DoubleListIterator;
};

// Description -------------------------------------------------------------
//
//      Defines the container class DoubleList. 
//
// Constructor
//
//      DoubleList
//
//      Default constructor
//
// Destructor
//
//      ~DoubleList
//
// Public Members
//
//      peekAtHead
//
//      Returns a reference to the object at the head of the list.
//
//      peekAtTail
//
//      Returns a reference to the object at the tail of the list.
//
//      add
//
//      Adds an element to the list.  By default, the element is
//      added to the head of the list.
//
//      addAtHead
//
//      Adds an element at the head of the list.
//
//      addAtTail
//
//      Adds an element to the tail of the list.
//
//      destroyFromHead
//
//      Destroys the given element, searching forward from the head of the
//      list.
//
//      destroyFromTail
//
//      Destroys the given element, searching forward from the head of the
//      list.
//
//      detach
//
//      Detaches the given element.  By default, the element is searched
//      for from the head of the list.
//
//      detachFromHead
//
//      Detachs the given element, searching forward from the head of the
//      list.
//
//      detachFromTail
//
//      Detachs the given element, searching forward from the head of the
//      list.
//
//      isA
//
//      Returns the class type of class DoubleList.
//
//      nameOf
//
//      Returns a pointer to the character string "DoubleList."
//     
//      hashValue
//
//      Inherited from Object.
//
//      initIterator
//
//      Initializes a double list iterator for a forward traversal of the
//      list.
//
//      initReverseIterator
//
//      Initializes a double list iterator for a reverse traversal of the list.
//
// Inherited Members
//
//      printOn
//
//      Inherited from Container.
//
//      isEqual
//
//      Inherited from Container.
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
//      isSortable
//
//      Inherited from Object.
//
//      isAssociation
//
//      Inherited from Object.
//
// End ---------------------------------------------------------------------


// Member Function //

inline void DoubleList::destroyFromHead( const Object& toDestroy )

// Summary -----------------------------------------------------------------
//
//      Destroys an object from the head of a double list.  We remove
//      the object from the list and call that object's destructor.
//
// Parameter
//
//      toDestroy
//
//      The object we are to search for and destroy from the DoubleList.
//
// Functional Description                     
//
//      Inline wrap of detach which deleteObjectToo parameter set to 1.
//
// Remarks
//
//  warnings:
//      No error condition is generated if the object which was specified
//      isn't on the double list.
//
// End ---------------------------------------------------------------------
{
    detachFromHead( toDestroy, 1 );
}
// End Member Function DoubleList::destroyFromHead //


// Member Function //

inline void DoubleList::destroyFromTail( const Object& toDestroy )

// Summary -----------------------------------------------------------------
//
//      Destroys an object from the tail of a double list.  We remove
//      the object from the list and call that object's destructor.
//
// Parameter
//
//      toDestroy
//
//      The object we are to search for and destroy from the DoubleList.
//
// Functional Description                     
//
//      Inline wrap of detach which deleteObjectToo parameter set to 1.
//
// Remarks
//
//  warnings:
//      No error condition is generated if the object which was specified
//      isn't on the double list.
//
// End ---------------------------------------------------------------------
{
    detachFromTail( toDestroy, 1 );
}
// End Member Function DoubleList::destroyFromTail //


// Class //

class DoubleListIterator:  public ContainerIterator
{
public:
            DoubleListIterator( const DoubleList&, int = 1 );
    virtual ~DoubleListIterator();

    virtual                 operator int();
    virtual                 operator Object&();
    virtual Object&         operator ++();
            Object&         operator --();
    virtual void            restart();

private:
            DoubleListElement *currentElement;
            DoubleListElement *startingElement;
};

// Description -------------------------------------------------------------
//
//      Defines the double list iterator class.  Upon initialization, we 
//      set up an internal pointer to our current position in the list.  When
//      an increment or decrement operator is called, we update this 
//      current position.
//
// Constructor
//
//      DoubleListIterator( const DoubleList&, int = 1 )
//
//      Constructor for an iterator.  Note that this isn't a copy
//      constructor, since it takes an object from a different class.
//
// Destructor
//
//      ~DoubleListIterator
//
// Public Members
//
//      operator int
//
//      We are allowed one cast operator to a predefined type.  This
//      operator defines an explicit or an implicit cast from a
//      DoubleListIterator to an integer.
//
//      operator Object&
//
//      Converts a double list iterator to an Object reference.
//
//      operator ++
//
//      The increment operator.
//
//      operator --
//
//      The decrement operator.  This makes sense for double lists.
//
//      restart
//
//      DoubleList iterator restart mechanism.
//
// Private Members
//
//      currentElement
//
//      The current position in the iteration sequence.
//
//      startingElement
//
//      The starting position in the iteration sequence.
//
// End ---------------------------------------------------------------------


// Constructor //

inline DoubleListIterator::DoubleListIterator( const DoubleList& toIterate, int atHead )

// Summary -----------------------------------------------------------------
//
//      Constructor for a list iterator object.
//
// Parameters
//
//      toIterate
//
//      The double list we are to iterate.
//
//      atHead
//
//      Indicates whether we are to start at the head of the list.  If this is
//      not 1, we will start at the tail.
//
// End ---------------------------------------------------------------------
{
    if ( atHead == 1 )
    {
        startingElement = currentElement = toIterate.head;
    }
    else
    {
        startingElement = currentElement = toIterate.tail;
    }
}
// End Constructor DoubleListIterator::DoubleListIterator //


#endif // ifndef __DBLLIST_H //
