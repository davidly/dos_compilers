#ifndef _DLSTELEM_H
#define _DLSTELEM_H

//
// This file contains proprietary information of Borland International.
// Copying or reproduction without prior written approval is prohibited.
//
// Copyright (c) 1990
// Borland International
// 1800 Green Hills Road
// Scotts Valley, CA 95066
// (408) 438-8400
//

// Contents ----------------------------------------------------------------
//
//      DoubleListElement
//
// Description
//
//      Defines the class DoubleListElement.  Objects of this class may
//      be part of lists which can be traversed in forward and reverse
//      order.
//
// End ---------------------------------------------------------------------

// Interface Dependencies ---------------------------------------------------

#ifndef _IOSTREAM_H
#include <iostream.h>
#define _IOSTREAM_H
#endif

#ifndef __CLSTYPES_H
#include <clstypes.h>
#endif

#ifndef __OBJECT_H
#include <object.h>
#endif

// End Interface Dependencies ------------------------------------------------

// Class //

class DoubleListElement
{
public:
			DoubleListElement( Object *o ) { data = o; next = previous = 0; }
            ~DoubleListElement() { delete data; }

private:
			DoubleListElement *next;
			DoubleListElement *previous;
            Object            *data;
	friend class DoubleList;
	friend class DoubleListIterator;
};

// Description -------------------------------------------------------------
//
// 	    Defines the abstract class DoubleListElement.
//
// Constructor
//
// 	    DoubleListElement
//
// 	    Constructor based on ListElement constructor which makes a
// 	    list element from an object reference.
//
// Destructor
//
//      ~DoubleListElement
//
//      We delete the data.
//
//
// Private Members
//
//      next
//
//      The next double list element.
//
//      previous
//
//      The previous double list element.
//
//      data
//
//      Pointer to the double list element's data.
//
// Friends
//
// 	    class DoubleList
//
// 	    class DoubleListIterator
//
// End ---------------------------------------------------------------------


#endif // ifndef _DLSTELEM_H //

