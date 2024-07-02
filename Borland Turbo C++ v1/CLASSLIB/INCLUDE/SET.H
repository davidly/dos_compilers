#ifndef __SET_H
#define __SET_H

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
//      Set
//      Set::Set                                constructor
//      Set::add
//
// Description
//
//      Defines the abstract class Set.
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

#ifndef __RESOURCE_H
#include "resource.h"
#endif

#ifndef __OBJECT_H
#include "object.h"
#endif

#ifndef __BAG_H
#include "bag.h"
#endif

// End Interface Dependencies ------------------------------------------------


// Class //

class Set:  public Bag
{
public:
            Set( sizeType setSize = DEFAULT_SET_SIZE ) : Bag( setSize ) {}
    virtual ~Set();

    virtual void			add( Object& );

    virtual classType       isA() const;
    virtual char           *nameOf() const;

};

// Description -------------------------------------------------------------
//
// 	Defines the class Set. 
//      
// Public Members
//
// 	isA
//
// 	Inherited from Object.
//
// 	nameOf
//
// 	Inherited from Object.
// 	
// Inherited Members
//
//      add
//
//      Inherited from HashTable
//
//      destroy
//
//      Inherited from HashTable
//
// 	detach
//
//      Inherited from HashTable
//
//      hasMember
//
//      Inherited from HashTable
//
// 	isEmpty
//
//      Inherited from HashTable
//
//      firstThat
//
//      Inherited from HashTable
//
//      lastThat
//
//      Inherited from HashTable
//
// 	hashValue
//
// 	Inherited from Object.
//
// 	operator ==
//
// 	Inherited from Object.
//
// 	printOn
//
// 	Inherited from Object.
//
// End ---------------------------------------------------------------------


#endif // ifndef __SET_H //
