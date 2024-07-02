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
//      Stack::push
//      Stack::pop
//      Stack::top
//      Stack::initIterator
// 	    Stack::hashValue
//
// Description
//
//      Implementation of class Stack member functions.
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

#ifndef __STACK_H
#include <stack.h>
#endif

// End Interface Dependencies ------------------------------------------------

// Implementation Dependencies ----------------------------------------------

#ifndef __LIST_H
#include <list.h>
#endif

// End Implementation Dependencies -------------------------------------------


// Member Function //

Stack::~Stack()

// Summary -----------------------------------------------------------------
//
//      Destructor for a Stack object.
//
//      We don't do anything here, because the destructor for theStack
//      will destroy all the contained objects.
//
// End ---------------------------------------------------------------------
{
}
// End Destructor //


// Member Function //

void Stack::push( Object& toPush )

// Summary -----------------------------------------------------------------
//
//      Pushes the given object on the stack.
//
// Parameters
//
//      toPush
//
//      The object we are to push on the stack.  Once the object is
//      pushed, it is owned by the stack.
//
// End ---------------------------------------------------------------------
{
	theStack.add( toPush );
}
// End Member Function Stack::push //


// Member Function //

Object& Stack::pop()

// Summary -----------------------------------------------------------------
//
//      Pops an object from the stack.
//
// End ---------------------------------------------------------------------
{
	Object& temp = theStack.peekHead();
	theStack.detach( temp );
	return temp;
}
// End Member Function Stack::pop //


// Member Function //

Object& Stack::top() const

// Summary -----------------------------------------------------------------
//
//      Peeks at the object on the top of the stack.
//
// End ---------------------------------------------------------------------
{
	return theStack.peekHead();
}
// End Member Function Stack::top //


// Member Function //

int Stack::isEmpty() const

// Summary -----------------------------------------------------------------
//
//      Indicates whether the stack is empth
//
// End ---------------------------------------------------------------------
{
    return theStack.isEmpty();
}
// End Member Function Stack::isEmtpy //


// Member Function //

ContainerIterator& Stack::initIterator() const

// Summary -----------------------------------------------------------------
//
//      Initializes an iterator for a stack.
//
// End ---------------------------------------------------------------------
{
	return *( (ContainerIterator *)new ListIterator( this->theStack ) );
}
// End Member Function Stack::initIterator //

// Member Function //

classType Stack::isA() const

// Summary -----------------------------------------------------------------
//
//      Returns a predefined value for the class Stack.
//
// Parameters
//
//      none
//
// End ---------------------------------------------------------------------
{
    return stackClass;
}
// End Member Function Stack::isA //

// Member Function //

char *Stack::nameOf() const

// Summary -----------------------------------------------------------------
//
//      Returns the string "Stack".
//
// Parameters
//
//      none
//
// End ---------------------------------------------------------------------
{
    return "Stack";
}
// End Member Function Stack::nameOf //


// Member Function //

hashValueType Stack::hashValue() const

// Summary -----------------------------------------------------------------
//
//      Returns the hash value of a stack.
//
// End ---------------------------------------------------------------------
{
	return hashValueType(0);
}
// End Member Function Stack::hashValue //

