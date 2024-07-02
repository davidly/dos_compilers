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
//      Container::Container                        copy constructor
//      Container::forEach
//      Container::firstThat
//      Container::lastThat
//      Container::isEqual
//      Container::printOn
//      Container::printHeader
//      Container::printSeparator
//      Container::printTrailer
//
// Description
//
//      Implementation of class Container member functions.
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

#ifndef __CONTAIN_H
#include <contain.h>
#endif

// End Interface Dependencies ------------------------------------------------

// Implementation Dependencies ----------------------------------------------
// End Implementation Dependencies -------------------------------------------


// Constructor //

Container::Container( const Container& toCopy )

// Summary -----------------------------------------------------------------
//
//      Constructors a container and copies the given container into it.
//
// Parameters
//
//      toCopy
//
//      The container which we are to copy.
//
// Functional Description
//
//      We initialize an iterator, then iterate through each object in the
//      container we are copying, constructing and copying as we go.
//
// Remarks
//
//  warnings:
//      We must be sure to delete the container iterator, since it was
//      allocated on the heap.
//
// End ---------------------------------------------------------------------
{
	ContainerIterator &copyIterator = toCopy.initIterator();

	while( int(copyIterator) != 0 )
    {
    } // end while //

    delete &copyIterator;
}
// End Constructor Container::Container //


// Member Function //

Container::~Container()

// Summary -----------------------------------------------------------------
//
//      Destructor for a Container object.
//
//      We don't do anything here, because the derived class will have
//      taken care of deleting all the contained objects.
//
// End ---------------------------------------------------------------------
{
}
// End Destructor //


// Member Function //

void Container::forEach( iterFuncType actionPtr, void *paramListPtr )

// Summary -----------------------------------------------------------------
//
//      Calls the given iterator function on each object in this container.
//
// Parameters
//
//      actionPtr
//
//      Pointer to the action routine which is to be called for each object.
//
//      paramListPtr
//
//      Pointer to the list of parameters which will be passed along to
//      the action routine.
//
// Functional Description
//
//      We initialize an iterator, then iterator through each object,
//      asking the objects to perform the forEach function on themselves.
//
// Remarks
//
//  warnings:
//      The action routine must have a prototype of the form:
//          void action( Object&, void * );
//
//      We must be sure to delete the container iterator, since it was
//      allocated on the heap.
//
// End ---------------------------------------------------------------------
{
	ContainerIterator& containerIterator = initIterator();

	while( int(containerIterator) != 0 )
    {
		containerIterator++.forEach( actionPtr, paramListPtr );
    }
    delete &containerIterator;
}
// End Member Function Container::forEach //


// Member Function //

Object& Container::firstThat( condFuncType testFuncPtr, void *paramListPtr ) const

// Summary -----------------------------------------------------------------
//
//      Finds the first object in the container which satisfies the
//      given condition function.
//
// Parameters
//
//      testFuncPtr
//
//      Pointer to the conditional test routine which is to be called 
//      for this container.
//
//      paramListPtr
//
//      Pointer to the list of parameters which will be passed along to
//      the conditional test routine.
//
// Return Value
//
//      Returns the first object in the container which satisfies the 
//      condition.  Returns NOOBJECT otherwise.
//
// Functional Description
//
//      We initialize an iterator, then iterator through each object,
//      asking the objects to perform the firstThat function on themselves.
//
// Remarks
//
//  warnings:
//      The conditional test routine must have a prototype of the form:
//          int test( Object&, void * );
//
//      The conditional test routine must return 1 if the given object
//      satisfies the condition.
//
//      We must be sure to delete the container iterator, since it was
//      allocated on the heap.
//
// End ---------------------------------------------------------------------
{
	ContainerIterator &containerIterator = initIterator();

	while( int(containerIterator) != 0 )
    {
        Object& testResult = 
                    containerIterator++.firstThat( testFuncPtr, paramListPtr );
		if ( testResult != NOOBJECT )
        {
            delete &containerIterator;
            return testResult;
        }
    } // end while //
    delete &containerIterator;
	return NOOBJECT;
}
// End Member Function Container::firstThat //


// Member Function //

Object& Container::lastThat( condFuncType testFuncPtr, void *paramListPtr ) const

// Summary -----------------------------------------------------------------
//
//      Finds the last object in the container which satisfies the
//      given condition function.
//
// Parameters
//
//      testFuncPtr
//
//      Pointer to the conditional test routine which is to be called 
//      for this object.
//
//      paramListPtr
//
//      Pointer to the list of parameters which will be passed along to
//      the conditional test routine.
//
// Functional Description
//
//      We initialize an iterator, then iterator through each object,
//      asking the objects to perform the lastThat function on themselves.
//      As we iterate, if we find an object which satisfies the condition,
//      we make that object the last object which met the condition.  Note
//      that there is no short-circuiting the search, since we must search
//      through every object in the container to find the last one.
//
// Remarks
//
//  warnings:
//      The conditional test routine must have a prototype of the form:
//          int test( Object&, void * );
//
//      The conditional test routine must return 1 if the given object
//      satisfies the condition.
//
//      We must be sure to delete the container iterator, since it was
//      allocated on the heap.
//
// End ---------------------------------------------------------------------
{
	ContainerIterator& containerIterator = initIterator();

	Object *lastMet = &(containerIterator++.lastThat( testFuncPtr, paramListPtr ));

	while( int(containerIterator) != 0 )
    {
        Object& testResult = 
                    containerIterator++.lastThat( testFuncPtr, paramListPtr );
        if ( testResult != NOOBJECT )
        {
			lastMet = &testResult;
        }
    } // end while //
    delete &containerIterator;
	return *lastMet;
}
// End Member Function Container::lastThat //


// Member Function //

int  Container::isEqual( const Object& testContainer ) const

// Summary -----------------------------------------------------------------
//
//      Determines whether the given container is equal to this.
//
// Parameters
//
//      testContainer
//
//      The container which we will be testing for equality with this.
//
// Return Value
//
//      Returns 1 if the two containers have the same objects in them
//      in the same order.
//
// Functional Description
//
//      We initialize an iterator, then iterator through each object,
//      asking the objects to perform an equality test.  As we iterate, 
//      if we find an object which fails the test, we return 0.  If every
//      object is equal and there are the same number of objects in both
//      containers, we return 1.
//
// Remarks
//
//  warnings:
//      We must be sure to delete the container iterator, since it was
//      allocated on the heap.
//
// End ---------------------------------------------------------------------
{
	ContainerIterator& thisIterator = initIterator();
	ContainerIterator& testContainerIterator =
								((Container &)(testContainer)).initIterator();

	while( int(thisIterator) != 0 && int(testContainerIterator) != 0 )
    {
        int objectsAreNotEqual = 
					(thisIterator++ != testContainerIterator++);
        if ( objectsAreNotEqual )
        {
            delete &testContainerIterator;
            delete &thisIterator;
            return 0;
        }
            
    } // end while //

	if ( int(thisIterator) !=0 || int(testContainerIterator) != 0 )
    {
        delete &testContainerIterator;
        delete &thisIterator;
        return 0;
    }
    else  // one of the containers has more objects than the other.
    {
        delete &testContainerIterator;
        delete &thisIterator;
        return 1;
    }
}
// End Member Function Container::isEqual //


// Member Function //

void Container::printOn( ostream& outputStream ) const

// Summary -----------------------------------------------------------------
//
//      Displays the contents of a container on the given stream.
//
// Parameters
//
//      outputStream
//
//      The stream on which we will be writing the container contents.
//
// Functional Description
//
//      We initialize an iterator, then iterator through each object,
//      asking the objects to print themselves.
//
// Remarks
//
//  warnings:
//      We must be sure to delete the container iterator, since it was
//      allocated on the heap.
//
// End ---------------------------------------------------------------------
{
	ContainerIterator& printIterator = initIterator();

    printHeader( outputStream );

	while( int(printIterator) != 0 )
	{
		printIterator++.printOn( outputStream );
		if ( int(printIterator) != 0 )
        {
            printSeparator( outputStream );
        }
        else // there are no more objects in the container.
        {
            break;
        }
    } // end while //

    printTrailer( outputStream );
    delete &printIterator;
}
// End Member Function Container::printOn //


// Member Function //

void Container::printHeader( ostream& outputStream ) const

// Summary -----------------------------------------------------------------
//
//      Displays a standard header for a container on the given stream.
//
// Parameters
//
//      outputStream
//
//      The stream on which we will be writing the header.
//
// Functional Description
//
//      We print the string returned by nameOf() and an opening brace.
//
// End ---------------------------------------------------------------------
{
    outputStream << nameOf() << " { ";
}
// End Member Function Container::printHeader //


// Member Function //

void Container::printSeparator( ostream& outputStream ) const

// Summary -----------------------------------------------------------------
//
//      Displays a standard separator for a container on the given stream.
//
// Parameters
//
//      outputStream
//
//      The stream on which we will be writing the separator.
//
// End ---------------------------------------------------------------------
{
    outputStream << ",\n    ";
}
// End Member Function Container::printSeparator //


// Member Function //

void Container::printTrailer( ostream& outputStream ) const

// Summary -----------------------------------------------------------------
//
//      Displays a standard trailer for a container on the given stream.
//
// Parameters
//
//      outputStream
//
//      The stream on which we will be writing the trailer.
//
// End ---------------------------------------------------------------------
{
    outputStream << " }\n";
}
// End Member Function Container::printTrailer //

// Member Function //

ContainerIterator::~ContainerIterator()

// Summary -----------------------------------------------------------------
//
//      Destructor for a ContainerIterator object.
//
// End ---------------------------------------------------------------------
{
}
// End Destructor //



