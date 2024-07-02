#ifndef __LSTELEM_H
#define __LSTELEM_H

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
//      ListElement
//
// Description
//
//      Defines the class ListElement.  ListElements are used in objects
//      which link other objects together and nowhere else.
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

// End Interface Dependencies ------------------------------------------------

// Class //

class ListElement
{
public:
			ListElement( Object *o ) { data = o; next = 0; }
            ~ListElement() { delete data; }

private:
			ListElement *next;
            Object      *data;
	friend class List;
	friend class ListIterator;
};

// Description -------------------------------------------------------------
//
// 	Defines the abstract class ListElement. 
//
// 	ListElement objects, i.e. objects instantiated of classes derived from
// 	ListElement, are used in sequences where insertions and deletions
// 	are defined.
//
// Public Members
//
//  none
//
// Private Members
//
// 	next
//
// 	Pointer to the next list element.
//
// 	data
//
// 	Pointer to the list element's data.
//
// Friends
//
// 	class List
//
// 	The class which uses class ListElement, class List, is declared
// 	as a friend.
//
// End ---------------------------------------------------------------------


#endif // ifndef __LSTELEM_H //

