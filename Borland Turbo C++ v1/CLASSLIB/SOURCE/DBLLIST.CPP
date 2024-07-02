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
//      DoubleList::isA
//      DoubleList::nameOf
//      DoubleList::add
//      DoubleList::addAtHead
//      DoubleList::addAtTail
//      DoubleList::detach
//      DoubleList::detachFromHead
//      DoubleList::detachFromTail
//      DoubleList::initIterator
//      DoubleList::initReverseIterator
// 	    DoubleList::hashValue
//
//      DoubleListIterator::operator int
//      DoubleListIterator::operator Object&
//      DoubleListIterator::operator ++
//      DoubleListIterator::restart
//      DoubleListIterator::operator --
//
// Description
//
//      Implementation of class DoubleList member functions.
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

#ifndef __DLSTELEM_H
#include <dlstelem.h>
#endif

#ifndef __DBLLIST_H
#include <dbllist.h>
#endif

// End Interface Dependencies ------------------------------------------------

// Implementation Dependencies ----------------------------------------------
// End Implementation Dependencies -------------------------------------------


// Member Function //

DoubleList::~DoubleList()

// Summary -----------------------------------------------------------------
//
//      Destructor for a DoubleList object.
//
// End ---------------------------------------------------------------------
{
	while( head != 0 )
		{
		DoubleListElement *temp = head;
		head = head->next;
		delete temp;
		}
}
// End Destructor //


// Member Function //

classType DoubleList::isA() const

// Summary -----------------------------------------------------------------
//
// 	    Returns the class type of a double list.
//
// End ---------------------------------------------------------------------
{
    return doubleListClass; 
}
// End Member Function DoubleList::isA //


// Member Function //

char *DoubleList::nameOf() const

// Summary -----------------------------------------------------------------
//
// 	    Returns a pointer to the character string "DoubleList."
//
// End ---------------------------------------------------------------------
{
    return "DoubleList";
}
// End Member Function DoubleList::nameOf //


// Member Function //

void DoubleList::add( Object& toAdd )

// Summary -----------------------------------------------------------------
//
//      Adds the given object on the double list at the head of the list.
//
// Parameters
//
//      toAdd
//
//      The object we are to add to the head of the list.  Once the object is
//      added, it is owned by the double list.
//
// Functional Description
//
//      Wrap of addAtHead.
//
// End ---------------------------------------------------------------------
{
    addAtHead( toAdd );
}
// End Member Function DoubleList::add //


// Member Function //

void DoubleList::addAtHead( Object& toAdd )

// Summary -----------------------------------------------------------------
//
//      Adds the given object on the double list at the head of the list.
//
// Parameters
//
//      toAdd
//
//      The object we are to add to the head of the list.  Once the object is
//      added, it is owned by the double list.
//
// End ---------------------------------------------------------------------
{
	DoubleListElement *newElement = new DoubleListElement( &toAdd );

	if ( head )
	{
		head->previous = newElement;
		newElement->next = head;
		head = newElement;
	}
	else
	{
		tail = head = newElement;
	}
	itemsInContainer++;
}
// End Member Function DoubleList::addAtHead //


// Member Function //

void DoubleList::addAtTail( Object& toAdd )

// Summary -----------------------------------------------------------------
//
//      Adds the given object on the double list at the tail of the list.
//
// Parameters
//
//      toAdd
//
//      The object we are to add to the tail of the list.  Once the object is
//      added, it is owned by the double list.
//
// End ---------------------------------------------------------------------
{
	DoubleListElement *newElement = new DoubleListElement( &toAdd );

	if ( tail )
	{
		tail->next = newElement;
		newElement->previous = tail;
		tail = newElement;
	}
	else
	{
		head = tail = newElement;
	}
	itemsInContainer++;
}
// End Member Function DoubleList::addAtTail //


// Member Function //

void DoubleList::detach( const Object& toDetach, int destroyToo )

// Summary -----------------------------------------------------------------
//
//      Detaches an object from a double list.  By default the object
// 	    is searched for starting at the head of the list.
//
// Parameter
//
//      toDetach
//
//      The object we are to search for and destroy from the DoubleList.
//
// 	    destroyToo
//
// 	    Indicates whether we are also to destroy the object.
//
// Functional Description                     
//
//      Wrap of detachFromHead.
//
// Remarks
//
//  warnings:
//      No error condition is generated if the object which was specified
//      isn't on the double list.
//
// End ---------------------------------------------------------------------
{
	detachFromHead( toDetach, destroyToo );
}
// End Member Function DoubleList::detach //


// Member Function //

void DoubleList::detachFromHead( const Object& toDetach, int deleteToo )

// Summary -----------------------------------------------------------------
//
//      Detaches an object from the head of a double list.
//
// Parameter
//
//      toDetach
//
//      The object we are to search for and detach from the DoubleList.
//
//      deleteToo
//
//      Specifies whether we are to delete the object.
//
// Functional Description                     
//
//      If the object specified is at the head of the double list, we remove
//      the reference right away.  Otherwise, we iterate through the double list until
//      we find it, then remove the reference.
//
// Remarks
//
//  warnings:
//      No error condition is generated if the object which was specified
//      isn't on the double list.
//
// End ---------------------------------------------------------------------
{
    DoubleListElement *cursor = head;

    if ( *(head->data) == toDetach )
	{
        if( head->next == 0 )
            tail = 0;
		head = head->next;
	}
	else  // the object isn't at the head of the list.
	{

// Body Comment
//
// 	    Normally we would do this iteration with a list iterator.
// 	    Since we need to keep track of not only the objects in the
// 	    list but also the list elements, i.e. the pointer nodes,
// 	    we don't use the iterator.
//
// End


		while ( cursor != 0 )
		{
			if ( *(cursor->data) == toDetach )
			{
			    cursor->previous->next = cursor->next;
                cursor->next->previous = cursor->previous;
			    break;
			}
			else // the object isn't the one we want.
			{
                cursor = cursor->next;
			}
		} // end while

	} // end else the object wasn't at the head of the list.

// Body Comment
//
//  Now cursor points to the object that we've found
//
// End

    if( cursor != 0 )
    {
        itemsInContainer--;
        if ( deleteToo )
        {
            delete cursor->data;
        }
        else
        {
            cursor->data = 0;       // insure that we don't delete the data
        }

        delete cursor;
    }
}

// End Member Function DoubleList::detachFromHead //


// Member Function //

void DoubleList::detachFromTail( const Object& toDetach, int deleteToo )

// Summary -----------------------------------------------------------------
//
//      Detaches an object from the tail of a double list.
//
// Parameter
//
//      toDetach
//
//      The object we are to search for and detach from the DoubleList.
//
//      deleteToo
//
//      Specifies whether we are to delete the object.
//
// Functional Description                     
//
//      If the object specified is at the tail of the double list, we remove
//      the reference right away.  Otherwise, we iterate backwards through 
//      the double list until we find it, then remove the reference.
//
// Remarks
//
//  warnings:
//      No error condition is generated if the object which was specified
//      isn't on the double list.
//
// End ---------------------------------------------------------------------
{
    DoubleListElement *cursor = tail;

    if ( *(tail->data) == toDetach )
	{
        if( tail->previous == 0 )
            head = 0;
		tail = tail->previous;
	}
	else  // the object isn't at the tail of the list.
	{

// Body Comment
//
// 	    Normally we would do this iteration with a list iterator.
// 	    Since we need to keep track of not only the objects in the
// 	    list but also the list elements, i.e. the pointer nodes,
// 	    we don't use the iterator.
//
// End


		while ( cursor != 0 )
		{
			if ( *(cursor->data) == toDetach )
			{
			    cursor->previous->next = cursor->next;
                cursor->next->previous = cursor->previous;
				break;
			}
			else // the object isn't the one we want.
			{
                cursor = cursor->previous;
			}
		} // end while

	} // end else the object wasn't at the tail of the list.

// Body Comment
//
//  Now cursor points to the object that we've found
//
// End

    if( cursor != 0 )
    {
        itemsInContainer--;
        if ( deleteToo )
        {
            delete cursor->data;
        }
        else
        {
            cursor->data = 0;       // insure that we don't delete the data
        }

        delete cursor;
    }
}
// End Member Function DoubleList::detachFromTail //


// Member Function //

ContainerIterator& DoubleList::initIterator() const

// Summary -----------------------------------------------------------------
//
//      Initializes an iterator for a double list.
//
// End ---------------------------------------------------------------------
{
	return *( (ContainerIterator *)new DoubleListIterator( *this ) );
}
// End Member Function DoubleList::initIterator //


// Member Function //

ContainerIterator& DoubleList::initReverseIterator() const

// Summary -----------------------------------------------------------------
//
//      Initializes an iterator for a double list.
//
// End ---------------------------------------------------------------------
{
	return *( (ContainerIterator *)new DoubleListIterator( *this, 0 ) );
}
// End Member Function DoubleList::initReverseIterator //


// Member Function //

hashValueType DoubleList::hashValue() const

// Summary -----------------------------------------------------------------
//
//      Returns the hash value of a double list.
//
// End ---------------------------------------------------------------------
{
	return hashValueType(0);
}
// End Member Function DoubleList::hashValue //


// Member Function //

DoubleListIterator::operator int()

// Summary -----------------------------------------------------------------
//
//      Integer conversion operator for a Double List iterator.
//
// End ---------------------------------------------------------------------
{
    return ( currentElement != 0 );
}
// End Member Function DoubleListIterator::operator int //


// Member Function //

DoubleListIterator::operator Object&()

// Summary -----------------------------------------------------------------
//
//      Object conversion operator for a Double List iterator.
//
// End ---------------------------------------------------------------------
{
    return ( (Object&)(*(currentElement->data)) );
}
// End Member Function DoubleListIterator::operator Object& //


// Member Function //

Object& DoubleListIterator::operator ++()

// Summary -----------------------------------------------------------------
//
// 	    Increments the list iterator and returns the next object.
//
// Return Value
//
// 	    listObject
//
//      A reference to the object which is after the current object
// 	    in the iterator sequence.
//
// End ---------------------------------------------------------------------
{
	DoubleListElement *trailer = currentElement;

	if ( currentElement != 0 )
	{
		currentElement = currentElement->next;
		return ( (Object&)(*(trailer->data)) );
	}
	else // no more elements in the list.
	{
		return NOOBJECT;
	}
}
// End Member Function DoubleListIterator::operator ++ //


// Member Function //

void DoubleListIterator::restart()

// Summary -----------------------------------------------------------------
//
//      Restart function for a list iterator object.
//
// End ---------------------------------------------------------------------
{
	currentElement = startingElement;
}
// End Member Function DoubleListIterator::restart //


// Member Function //

Object& DoubleListIterator::operator --()

// Summary -----------------------------------------------------------------
//
// 	    Decrements the list iterator and returns the previous object.
//
// Return Value
//
// 	    listObject
//
//      A reference to the object which is before the current object
// 	    in the iterator sequence.
//
// End ---------------------------------------------------------------------
{
	DoubleListElement *trailer = currentElement;

	if ( currentElement != 0 )
	{
		currentElement = currentElement->previous;
		return ( (Object&)(*(trailer->data)) );
	}
	else // no more elements in the list.
	{
		return NOOBJECT;
	}
}
// End Member Function DoubleListIterator::operator -- //


// Destructor //

DoubleListIterator::~DoubleListIterator()

// Summary -----------------------------------------------------------------
//
//      Destructor for a DoubleListIterator object.
//
// End ---------------------------------------------------------------------
{
}
// End Destructor //
