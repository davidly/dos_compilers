#ifndef __LIST_H
#define __LIST_H

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
//      List
//
// 	    ListIterator
//      ListIterator::ListIterator                  constructor
//
// Description
//
//      Defines the class List.  Lists are used to link other objects
// 	together.
// 	Defines the ListIterator class.  A list iterator visits each
// 	of the items in a list.
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

#ifndef __LSTELEM_H
#include <lstelem.h>
#endif

#ifndef __COLLECT_H
#include <collect.h>
#endif

#ifndef __CONTAIN_H
#include <contain.h>
#endif

// End Interface Dependencies ------------------------------------------------


// Class //

class List:  public Collection
{
public:
			List() { head = 0; }
    virtual ~List();

            Object&         peekHead() const { return *(head->data); }

            void            add( Object& );
            void            detach( const Object&, int = 0 );
            void            destroy( const Object& l ) { detach( l, 1 ); }

    virtual classType       isA() const;
    virtual char           *nameOf() const;
    virtual hashValueType   hashValue() const;

    virtual ContainerIterator& initIterator() const;

private:
            ListElement    *head;

    friend  class ListIterator;
};

// Description -------------------------------------------------------------
//
// 	Defines the container class List. 
//
// 	List objects, i.e. objects instantiated of classes derived from
// 	List, are used in sequences where insertions and deletions
// 	are defined.  They operate soley on objects derived from
// 	class ListElement.
//
// Constructor
//
// 	List
//
// 	Constructor.
//
// Public Members
//
//      peekHead
//
//      Returns a reference to the object at the head of the list.
//
//      add
//
//      Adds an object to the list.
//
//      destroy
//
//      Detaches an object from the list and calls that object's destructor.
//
//      detach
//
//      Removes a reference to an object from the list.
//
// 	hasMember
//
// 	Determines whether the list has a given list element.
//
// 	isA
//
// 	Returns the class type of class list.
//
// 	nameOf
//
// 	Returns a pointer to the character string "List."
//
// 	hashValue
//
// 	Returns a pre-defined value for a list object.
//
// Inherited Members
//      
// 	printOn
//
// 	Inherited from Container.
//
// 	isEmpty
//
// 	Inherited from Container.
//
// 	forEach
//
// 	Inherited from Container.
//
// 	firstThat
//
// 	Inherited from Container.
//
// 	lastThat
//
// 	Inherited from Container.
//
// 	isEqual
//
// 	Inherited from Container.
//
// 	isSortable
//
// 	Inherited from Object.
//
// 	isAssociation
//
// 	Inherited from Object.
//
// Private Members
//
// 	head
//
// 	Maintains a pointer to the list element at the head of the list.
//
// End ---------------------------------------------------------------------


// Class //

class ListIterator:  public ContainerIterator
{
public:
            ListIterator( const List& );
    virtual ~ListIterator();

    virtual             operator int();
    virtual             operator Object&();
    virtual Object&     operator ++();
	virtual	void		restart();

private:
			ListElement *currentElement;
			ListElement *startingElement;
};

// Description -------------------------------------------------------------
//
// 	    Defines the list iterator class.  Upon initialization, we set up
// 	    an internal pointer to our current position in the list.  As
// 	    the increment operator is called, we update this current position.
//
// Constructor
//
//      ListIterator( const List& )
//
// 	    Constructor for an iterator.  Note that this isn't a copy
// 	    constructor, since it takes an object from a different class.
//
// Destructor
//
// 	    ~ListIterator
//
// Public Members
//
// 	    operator int
//
// 	    We are allowed one cast operator to a predefined type.  This
// 	    operator defines an explicit or an implicit cast from a
// 	    ListIterator to an integer.
//
//      operator Object&
//
//      Conversion to Object reference operator.
//
// 	    operator ++
//
//      The increment operator.
//
// 	    restart
//
// 	    List iterator restart mechanism.
//
// Private Members
//
//      currentElement
//
// 	    The current position in the iteration sequence.
//
//      startingElement
//
// 	    The starting position in the iteration sequence.
//
// End ---------------------------------------------------------------------


// Constructor //

inline  ListIterator::ListIterator( const List& toIterate )

// Summary -----------------------------------------------------------------
//
//      Constructor for a list iterator object.
//
// End ---------------------------------------------------------------------
{
	currentElement = toIterate.head;
}
// End Constructor ListIterator::ListIterator //


#endif // ifndef __LIST_H //
