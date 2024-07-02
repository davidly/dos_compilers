#ifndef _SORTABLE_H
#define _SORTABLE_H

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
//      Sortable      
//      operator >
//      operator >=
//      operator <=
//
// Description
//
//      Defines the abstract class Sortable and inline member functions.
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

class Sortable:  public Object
{
public:
    virtual ~Sortable();

    virtual int             isEqual( const Object& ) const = 0;
    virtual int             isLessThan( const Object& ) const = 0;
    virtual int             isSortable() const;

    virtual classType       isA() const = 0;
    virtual char            *nameOf() const = 0;
    virtual hashValueType   hashValue() const = 0;

protected:
    virtual void            printOn( ostream& ) const = 0;
};

// Description -------------------------------------------------------------
//
// 	Defines the abstract class Sortable.  Sortable implies that ordering
// 	operations can be performed up pairs of Sortable objects.  The
// 	relational operations depend upon the implementation of the 
// 	classes derived from the class Sortable.
//
// 	Sortable objects, i.e. objects instantiated of classes derived from
// 	Sortable, are used in ordered collections.
//
// Public Members
//
// 	isEqual
//
// 	Returns 1 if two objects are equivalent, 0 otherwise.
// 	Determines equivalence by comparing the contents of the two objects.
//      Perpetuates the pure virtual function inherited from Object.
//
// 	operator <
//
// 	Returns 1 if this is less than a test object.
//
// 	operator >
//
// 	Returns 1 if this is greater than a test object.
//
// 	operator <=
//
// 	Returns 1 if this is less than or equal to a test object.
//
// 	operator >=
//
// 	Returns 1 if this is greater than or equal to a test object.
//
// 	isA()
//
// 	Inherited from Object and redeclared as a pure virtual function.
//
// 	nameOf
//
// 	Inherited from Object and redeclared as a pure virtual function.
// 	
// 	hashValue
//
// 	Inherited from Object and redeclared as a pure virtual function.
//
// Inherited Members
//
//      operator new
//
//      Inherited from Object.
//
// 	operator !=
//
//      Inherited from Object.
//
//      forEach
//
//      Inherited from Object.
//
//      firstThat
//
//      Inherited from Object.
//
//      lastThat
//
//      Inherited from Object.
//
// Protected Members
//
// 	printOn
//
// 	Inherited from Object a redeclared as a pure virtual function.
//
// End ---------------------------------------------------------------------


            int             operator < ( const Sortable&, const Sortable& );
            int             operator > ( const Sortable&, const Sortable& );
            int             operator <=( const Sortable&, const Sortable& );
            int             operator >=( const Sortable&, const Sortable& );

// Function //

inline  int operator < ( const Sortable& test1, const Sortable& test2 )

// Summary -----------------------------------------------------------------
//
//      Determines whether the first object is less than the second.  We
//      do type checking on the two objects (objects of different
//      classes can't be compared, even if they're derived from each other).
//
// Parameters
//
//      test1
//
//      The first object we are testing.
//
//      test2
//
//      The second object we are testing.
//
// End ---------------------------------------------------------------------
{
	return ( (test1.isA() == test2.isA()) && test1.isLessThan( test2 ) );
}
// EndFunction operator < //


// Function //

inline  int operator > ( const Sortable& test1, const Sortable& test2 )

// Summary -----------------------------------------------------------------
//
//      Determines whether the first object is greater than the second.  We
//      just reverse the condition returned from operator < and test for
//      inequality.
//
// Parameters
//
//      test1
//
//      The first object we are testing.
//
//      test2
//
//      The second object we are testing.
//
// End ---------------------------------------------------------------------
{
	return !( test1 < test2 ) && test1 != test2;
}
// EndFunction operator > //


// Function //

inline  int operator >=( const Sortable& test1, const Sortable& test2 )

// Summary -----------------------------------------------------------------
//
//      Determines whether the first object is greater than or equal to
//      the second.  We just reverse the condition returned from operator <.
//
// Parameters
//
//      test1
//
//      The first object we are testing.
//
//      test2
//
//      The second object we are testing.
//
// End ---------------------------------------------------------------------
{
	return ( !( test1 <( test2 ) ) );
}
// EndFunction operator >= //


// Function //

inline  int operator <=( const Sortable& test1, const Sortable& test2 )

// Summary -----------------------------------------------------------------
//
//      Determines whether test1 is less than or equal to test2.
//      We just combine the less than and equal to operators.
//
// Parameters
//
//      test1
//
//      The first object we are testing.
//
//      test2
//
//      The second object we are testing.
//
// End ---------------------------------------------------------------------
{
	return ( test1 < test2 || test1 == test2 );
}
// EndFunction Sortable::operator <= //


#endif // ifndef _SORTABLE_H //
