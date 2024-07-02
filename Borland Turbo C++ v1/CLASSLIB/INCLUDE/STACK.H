#ifndef __STACK_H
#define __STACK_H

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
//      Stack
//
// Description
//
//      Defines the class Stack.
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

// Class //

class Stack:  public Container
{
public:
    virtual ~Stack();

			void            push( Object& );
            Object&         pop();
			Object&         top() const;
    virtual int             isEmpty() const;

    virtual ContainerIterator& initIterator() const;

    virtual classType       isA() const;
    virtual char           *nameOf() const;
    virtual hashValueType   hashValue() const;

private:
	List    theStack;
};

// Description -------------------------------------------------------------
//
// 	Defines the container class Stack.
//
// Public Members
//
// 	push
//
// 	Pushes an object on the stack.
//
// 	pop
// 
// 	Pops an object from the stack and delivers that object into the
//      ownership of the receiver.
//
//      top
//
//      Returns a refrence to the object on the top of the stack.  The
//      object remains in the ownership of the stack.  You must make 
//      sure not to destroy this object while it is still owned by the stack.
//
//      initIterator
//
//      Stack iterator initializer.
//
// 	isA
//
// 	Returns the class type for a stack.
//
// 	nameOf
//
// 	Returns a pointer to the character string "Stack."
// 	
// 	hashValue
//
// 	Returns a pre-defined value for stacks.
//
// 	isEmpty
//
// 	Returns whether the stack is empty.
//
// End ---------------------------------------------------------------------

#endif  // __STACK_H

