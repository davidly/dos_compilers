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
// 	    Dictionary::isA
// 	    Dictionary::nameOf
// 	    Dictionary::lookup
// 	    Dictionary::add
//
// Description
//
// 	    Implementation of member functions for class Dictionary.
//
// End ---------------------------------------------------------------------

// Interface Dependencies ---------------------------------------------------

#ifndef __OBJECT_H
#include <object.h>
#endif

#ifndef __DICT_H
#include <dict.h>
#endif

// End Interface Dependencies ------------------------------------------------


// Implementation Dependencies ----------------------------------------------

#ifndef __CONTAIN_H
#include <contain.h>
#endif

#ifndef __ASSOC_H
#include <assoc.h>
#endif

// End Implementation Dependencies -------------------------------------------


// Member Function //

Dictionary::~Dictionary()

// Summary -----------------------------------------------------------------
//
//      Destructor for a Dictionary object.
//
//		We don't do anything here, because the destructor for HashTable
//		will take care of destroying the contained objects.
//
// End ---------------------------------------------------------------------
{
}
// End Destructor //


// Member Function //

classType Dictionary::isA() const

// Summary -----------------------------------------------------------------
//
// 	    Returns the class type of a dictionary.
//
// End ---------------------------------------------------------------------
{
    return dictionaryClass; 
}
// End Member Function Dictionary::isA //


// Member Function //

char *Dictionary::nameOf() const

// Summary -----------------------------------------------------------------
//
// 	    Returns a pointer to the character string "Dictionary."
//
// End ---------------------------------------------------------------------
{
    return "Dictionary";
}
// End Member Function Dictionary::nameOf //


// Member Function //

Association& Dictionary::lookup( const Object& toLookUp ) const

// Summary -----------------------------------------------------------------
//
// 	    Looks up an object in the dictionary.
//
// Parameters
//
// 	    toLookUp
//
// 	    The object to be searched for in the dictionary.
//
// End ---------------------------------------------------------------------
{
    Association toFind( (Object&)toLookUp, NOOBJECT );
    // OK to cast to non-const object here, since it doesn't get
    // put into a dictionary, but is only used for comparisons.

	Association& found = (Association&)findMember( toFind );
	return found;
}
// End Member Function Dictionary::lookup //


// Member Function //

void Dictionary::add( Object& objectToAdd )

// Summary -----------------------------------------------------------------
//
// 	    Adds an object of type Association to the dictionary.
//
// Parameters
//
// 	    objectToAdd
//
// 	    The object to be added to the dictionary.
//
// End ---------------------------------------------------------------------
{
    if( !objectToAdd.isAssociation() )
	{
		cerr << "Error:  Object must be association type.";
        exit( __ENOTASSOC );
	}
	else
	{
		Set::add( objectToAdd );
	}
}
// End Member Function Dictionary::add //
