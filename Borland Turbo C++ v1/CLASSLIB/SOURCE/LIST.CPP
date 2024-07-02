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
//      List::add
//      List::destroy
//      List::detach
//      List::initIterator
// 	    List::hashValue
//
//      ListIterator::operator int
//      ListIterator::operator Object&
//      ListIterator::operator ++
//      ListIterator::restart
//
// Description
//
//      Implementation of class List member functions.
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

#ifndef __LIST_H
#include <list.h>
#endif

// End Interface Dependencies ------------------------------------------------


// Implementation Dependencies ----------------------------------------------

#ifndef __LSTELEM_H
#include <lstelem.h>
#endif

// End Implementation Dependencies -------------------------------------------

// Member Function //

List::~List()

// Summary -----------------------------------------------------------------
//
//      Destructor for a List object.
//
// End ---------------------------------------------------------------------
{
	while( head != 0 )
		{
		ListElement *temp = head;
		head = head->next;
		delete temp;
		}
}
// End Destructor //


// Member Function //

void List::add( Object& toAdd )

// Summary -----------------------------------------------------------------
//
//      Adds the given object on the list.
//
// Parameters
//
//      toAdd
//
//      The object we are to add to the list.  Once the object is
//      added, it is owned by the list.
//
// End ---------------------------------------------------------------------
{
	ListElement *newElement = new ListElement( &toAdd );

	newElement->next = head;
	head = newElement;
	itemsInContainer++;
}
// End Member Function List::add //


// Member Function //

void    List::detach( const Object& toDetach, int deleteObjectToo )

// Summary -----------------------------------------------------------------
//
//      Detaches an object from the list.
//
// Parameter
//
//      toDetach
//
//      The object we are to search for and detach from the List.
//
//      deleteObjectToo
//
//      Specifies whether we are to delete the object.
//
// Functional Description                     
//
//      If the object specified is at the head of the list, we remove
//      the reference right away.  Otherwise, we iterate through the list until
//      we find it, then remove the reference.
//
// Remarks
//
//  warnings:
//      No error condition is generated if the object which was specified
//      isn't in the list.
//
// End ---------------------------------------------------------------------
{
    ListElement *cursor = head;

    if ( *(head->data) == toDetach )
	{
		head = head->next;
	}
	else  // the object isn't at the head of the list.
	{

// Body Comment
//
// 	Normally we would do this iteration with a list iterator.
// 	Since we need to keep track of not only the objects in the
// 	list but also the list elements, i.e. the pointer nodes,
// 	we don't use the iterator.
//
// End

		ListElement *trailer = head;

		while ( cursor != 0 )
		{
			cursor = cursor->next;
			if ( *(trailer->data) == toDetach )
			{
    			trailer->next = cursor->next;
				break;
			}
			else // the object isn't the one we want.
			{
				trailer = trailer->next;
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
        if ( deleteObjectToo )
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
// End Member Function List::detach //


// Member Function //

classType List::isA() const

// Summary -----------------------------------------------------------------
//
//      Returns a predefined value for the class List.
//
// Parameters
//
//      none
//
// End ---------------------------------------------------------------------
{
    return listClass;
}
// End Member Function List::isA //

// Member Function //

char *List::nameOf() const

// Summary -----------------------------------------------------------------
//
//      Returns the string "List".
//
// Parameters
//
//      none
//
// End ---------------------------------------------------------------------
{
    return "List";
}
// End Member Function List::nameOf //


// Member Function //

hashValueType List::hashValue() const

// Summary -----------------------------------------------------------------
//
//      Returns the hash value of a list.
//
// End ---------------------------------------------------------------------
{
	return hashValueType(0);
}
// End Member Function List::hashValue //

// Member Function //

ContainerIterator& List::initIterator() const

// Summary -----------------------------------------------------------------
//
//      Initializes an iterator for a list.
//
// End ---------------------------------------------------------------------
{
	return *( (ContainerIterator *)new ListIterator( *this ) );
}
// End Member Function List::initIterator //


// Member Function //

ListIterator::~ListIterator()

// Summary -----------------------------------------------------------------
//
//
//
// End ---------------------------------------------------------------------
{
}
// End Destructor //


// Member Function //

ListIterator::operator int()

// Summary -----------------------------------------------------------------
//
//  Returns an integer value indicating whether the iteration is complete.
//
//    1 indicates not complete, 0 indicates complete.
//
// End ---------------------------------------------------------------------
{
    return currentElement != 0;
}
// End Member Function ListIterator::operator int //


// Member Function //

ListIterator::operator Object&()

// Summary -----------------------------------------------------------------
//
//      Object reference conversion operator.
//
// End ---------------------------------------------------------------------
{
    if ( currentElement == 0 )
    {
        return NOOBJECT;
    }
    else
    {
        return ( (Object&)(*(currentElement->data)) );
    }
}
// End Member Function ListIterator::operator Object& //


// Member Function //

Object& ListIterator::operator ++()

// Summary -----------------------------------------------------------------
//
// 	Increments the list iterator and returns the next object.
//
// End ---------------------------------------------------------------------
{
	ListElement *trailer = currentElement;

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
// End Member Function ListIterator::operator ++ //


// Member Function //

void ListIterator::restart()

// Summary -----------------------------------------------------------------
//
//      Restart function for a list iterator object.
//
// End ---------------------------------------------------------------------
{
	currentElement = startingElement;
}
// End Member Function ListIterator::restart //
