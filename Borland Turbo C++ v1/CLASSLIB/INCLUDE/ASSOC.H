#ifndef __ASSOC_H
#define __ASSOC_H

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
// 	    Association
// 	    Association::Association
// 	    Association::Association					copy constructor
//
// Description
//
// 	    Defines the class Association, which is an object that can
// 	    be stored in a Dictionary.  An Association contains references
// 	    to two Objects, a Key and a Value.
//
// End ---------------------------------------------------------------------

// Interface Dependencies ---------------------------------------------------

#ifndef __IOSTREAM_H
#include <iostream.h>
#define __IOSTREAM_H
#endif

#ifndef __CLSTYPES_H
#include <clstypes.h>
#define __CLSTYPES_H
#endif

#ifndef __OBJECT_H
#include <object.h>
#define __OBJECT_H
#endif

// End Interface Dependencies ------------------------------------------------

// Class //

class Association : public Object
{
public:
			Association( Object& k, Object& v ) : aKey( k ), aValue( v ) {}
            Association( const Association& a ) :
                                    aKey( a.key() ), aValue( a.value() ) {}
    virtual ~Association();

            Object&         key() const { return aKey; }
            Object&         value() const { return aValue; }

	virtual classType       isA() const;
	virtual char           *nameOf() const;
	virtual hashValueType   hashValue() const;
    virtual int             isEqual( const Object& ) const;
    virtual int             isAssociation() const;
    virtual void            printOn( ostream& ) const;

private:
			Object&			aKey;
			Object&			aValue;
};

// Description -------------------------------------------------------------
//
// 	    Defines an association class.  An association keeps two objects
// 	    together and treats them as a single object.
//
// Constructors
//
// 	    Association( Object& k, Object& v )
//
// 	    Constructor from two objects.
//
// 	    Association( Association& a )
//
// 	    Copy constructor.
//
// Public Members
//
// 	    key
//
// 	    Returns a reference to the key
//
// 	    value
//
// 	    Returns a reference to the value of the association.
//
// Private Members
//
//      aKey
//
//      aValue
//
// End ---------------------------------------------------------------------


#endif // ifndef __ASSOC_H //

