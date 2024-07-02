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
//      Sortable::~Sortable
//      Sortable::isSortable()
//
// Description
//
//      Implementation of the class Sortable member functions
//
// End ---------------------------------------------------------------------

// Interface Dependencies ---------------------------------------------------

#ifndef __CLSTYPES_H
#include <clstypes.h>
#endif

#ifndef __OBJECT_H
#include <object.h>
#endif

#ifndef __SORTABLE_H
#include <sortable.h>
#endif

// End Interface Dependencies ------------------------------------------------


// Implementation Dependencies ----------------------------------------------
// End Implementation Dependencies -------------------------------------------


// Member Function //

Sortable::~Sortable()

// Summary -----------------------------------------------------------------
//
//      Destructor for a Sortable object.
//
// End ---------------------------------------------------------------------
{
}
// End Destructor //


// Member Function //

int Sortable::isSortable() const

// Summary -----------------------------------------------------------------
//
//      indicates whether an Object is sortable
//
// Return Value
//
//      returns 1, since every object of type Sortable is sortable.
//
// End ---------------------------------------------------------------------
{
    return 1;
}
// End Member Function Sortable::isSortable //

