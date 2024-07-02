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
//      Collection::findMember
//      Collection::hasMember
//
// Description
//
//      Implementation of class Collection member functions.
//
// End ---------------------------------------------------------------------

// Interface Dependencies ---------------------------------------------------

#ifndef __CLSTYPES_H
#include <clstypes.h>
#endif

#ifndef __COLLECT_H
#include <collect.h>
#endif

// End Interface Dependencies ------------------------------------------------

// Implementation Dependencies ----------------------------------------------

#ifndef __CONTAIN_H
#include <contain.h>
#endif

// End Implementation Dependencies -------------------------------------------


// Member Function //

Collection::~Collection()

// Summary -----------------------------------------------------------------
//
//      Destructor for a Collection object.
//
//		We don't have to do anything here.  The derived class will
//		destroy all objects in the container.
//
// End ---------------------------------------------------------------------
{
}
// End Destructor //


// Member Function //

Object& Collection::findMember( const Object& testObject ) const

// Summary -----------------------------------------------------------------
//
// Functional Description
//
//      We initialize an iterator, then iterate through each object,
// 	    doing a comparison of objects.  Note that the iteration is
// 	    a shallow one, that is, if our collection is made up of
// 	    container objects, we don't check to see whether those containers
// 	    contain the object we are looking for.
//
// Remarks
//
//  warnings:
//      We must be sure to delete the container iterator, since it was
//      allocated on the heap.
//
// End ---------------------------------------------------------------------
{
	ContainerIterator& containerIterator = initIterator();

	while( int(containerIterator) != 0 )
	{
		Object& listObject = containerIterator++;

		if ( listObject == testObject )
		{
			delete &containerIterator;
			return listObject;
		}
	} // end while //
	delete &containerIterator;
	return NOOBJECT;
}
// End Member Function Collection::findMember //


// Member Function //

int Collection::hasMember( const Object& testObject ) const

// Summary ----------------------------------------------------------------
//
//      Collection
//
// Description
//
//      Defines the abstract class Collection.  Collections group objects
//      together and specify operations.
//
// End ---------------------------------------------------------------------
{
	return findMember( testObject ) != NOOBJECT;
}
// End Member Function Collection::hasMember //
