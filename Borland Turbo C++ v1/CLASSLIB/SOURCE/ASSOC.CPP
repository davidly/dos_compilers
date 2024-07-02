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
//      Association::isA
//      Association::nameOf
// 	    Association::printOn
//      Association::hashValue
//      Association::isEqual
//      Association::isAssociation
//
// Description
//
// 	    Implementation of member functions for class Association.
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

#ifndef __ASSOC_H
#include <assoc.h>
#endif

// End Interface Dependencies ------------------------------------------------

// Implementation Dependencies ----------------------------------------------
// End Implementation Dependencies -------------------------------------------


// Member Function //

Association::~Association()

// Summary -----------------------------------------------------------------
//
//      Destructor for an Association object.
//
//		We don't do anything here, because the key and value fields will
//		be destroyed automatically.
//
// End ---------------------------------------------------------------------
{
}
// End Destructor //


// Member Function //

classType Association::isA() const

// Summary -----------------------------------------------------------------
//
// 	    Returns the class type of a association.
//
// End ---------------------------------------------------------------------
{
    return associationClass; 
}
// End Member Function Association::isA //


// Member Function //

char *Association::nameOf() const

// Summary -----------------------------------------------------------------
//
// 	    Returns a pointer to the character string "Association."
//
// End ---------------------------------------------------------------------
{
    return "Association";
}
// End Member Function Association::isA //


// Member Function //

void Association::printOn( ostream& outputStream ) const

// Summary -----------------------------------------------------------------
//
// 	    Displays the contents of this association object.
//
// Parameters
//
// 	    outputStream
//
// 	    The stream on which we are to display the association.
//
// End ---------------------------------------------------------------------
{
	outputStream << " " << nameOf() << " { ";
	aKey.printOn( outputStream );
	outputStream << ", ";
	aValue.printOn( outputStream );
	outputStream << " }\n";
}
// End Member Function //


// Member Function //

hashValueType Association::hashValue() const

// Summary -----------------------------------------------------------------
//
// 	    Returns the hash value of an association.  We use the key's
//      hash value.
//
// End ---------------------------------------------------------------------
{
    return aKey.hashValue();
}
// End Member Function Association::hashValue //


// Member Function //

int Association::isEqual( const Object& toObject ) const

// Summary -----------------------------------------------------------------
//
// 	    Returns the hash value of an association.  We use the key's
//      hash value.
//
// End ---------------------------------------------------------------------
{
    return aKey == ( (Association&)toObject ).key();
}
// End Member Function Association::isEqual //


// Member Function //

int Association::isAssociation() const

// Summary -----------------------------------------------------------------
//
// 	    Indicates that the given object is an association.
//
// End ---------------------------------------------------------------------
{
    return 1;
}
// End Member Function Association::isEqual //

