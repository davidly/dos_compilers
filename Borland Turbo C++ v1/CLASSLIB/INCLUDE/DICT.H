#ifndef __DICT_H
#define __DICT_H

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
// 	    Dictionary
//
// Description
//
// 	    Defines the class Dictionary.  Dictionary holds a set of objects
// 	    of type Association, which each contain a key and a value.
// 	    Dictionary uses the key to look up the associated value.
//
// End ---------------------------------------------------------------------

// Interface Dependencies ---------------------------------------------------

#ifndef __STDLIB_H
#include <stdlib.h>
#define __STDLIB_H
#endif

#ifndef __IOSTREAM_H
#include <iostream.h>
#define __IOSTREAM_H
#endif

#ifndef __CLSTYPES_H
#include <clstypes.h>
#endif

#ifndef __CLSDEFS_H
#include <clsdefs.h>
#endif

#ifndef __OBJECT_H
#include <object.h>
#endif

#ifndef __ASSOC_H
#include <assoc.h>
#endif

#ifndef __SET_H
#include <set.h>
#endif

// End Interface Dependencies ------------------------------------------------


// Class //

class Dictionary : public Set
{
public:
			Dictionary() {}
			Dictionary( Dictionary& );
    virtual ~Dictionary();

	virtual void			add( Object& );
            Association&    lookup( const Object& ) const;

    virtual classType       isA() const;
    virtual char           *nameOf() const;
};

// Description -------------------------------------------------------------
//
// 	    Defines the class Dictionary.  Dictionary holds a set of objects
// 	    of type Association, which each contain a key and a value.
// 	    Dictionary uses the key to look up the associated value.
//
// Constructor
//
// 	    Dictionary
//
// 	    Default constructor.
//
// Destructor
//
// 	    ~Dictionary
//
// Public Members
//
//      add
//
//      Adds an object to the collection.
//
// 	    lookup
//
// 	    Converts an object to an association with no value, then finds
// 	    that association in the dictionary.
//
// 	    isA
//
// 	    Returns the class type of dictionary.
//
// 	    nameOf
//
// 	    Returns a character pointer to the string "Dictionary."
//
// 	    hashValue
//
// 	    Inherited from Object.
//
// Inherited Members
//
//      destroy
//
//      Removes an object reference from the collection and
//      destroys the object.
//
// 	    detach
//
// 	    Removes all references to the object in the collection.
//      Does not delete the object.  Use this function when the collection
//      elements are not owned by the collection.
//
// 	    lookup
//
// 	    Inherited from HashTable.
//
//      hasMember
//
// 	    Test whether an object is part of the collection.  Returns 1 if
//      the object reference is found in the array.
//
// 	    initIterator
//
// 	    Inherited from HashTable.
//
// 	    isEmpty
//
// 	    Returns a 1 if the collection has no members.  Returns a 0
// 	    otherwise.
//
//      firstThat
//
//      Returns the first object that satisfies the given condition.
//
//      lastThat
//
//      Returns the last object that satisfies the given condition.
//
// End ---------------------------------------------------------------------


#endif // ifndef __DICT_H //
