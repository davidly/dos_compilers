#ifndef __COLLECT_H
#define __COLLECT_H

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
//      Collection
//
// Description
//
//      Defines the abstract class Collection.  Collections group objects
//      together and specify operations.
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

#ifndef __OBJECT_H
#include <object.h>
#endif

#ifndef __CONTAIN_H
#include <contain.h>
#endif

// End Interface Dependencies ------------------------------------------------

// Class //

class Collection:  public Container
{
public:
	virtual ~Collection();

    virtual void			add( Object& ) = 0;
    virtual void            detach( const Object&, int = 0 ) = 0;
    virtual int             hasMember( const Object& ) const;
    virtual Object&         findMember( const Object& ) const;
	virtual ContainerIterator& initIterator() const = 0;

            void            destroy( const Object& o ) { detach( o, 1 ); }

    virtual classType       isA() const = 0;
    virtual char           *nameOf() const = 0;
    virtual hashValueType   hashValue() const = 0;
};

// Description -------------------------------------------------------------
//
// 	    Defines the abstract class Collection.  A Collection is a 
//      grouping of objects on which addition and deletion of objects
//      may occur.  In addition, a Collection supports a membership test.
//      
// Public Members
//
//      add
//
//      Adds an object to the collection.
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
//      hasMember
//
// 	    Test whether an object is part of the collection.  Returns 1 if
//      the object reference is found in the array.
//
//      findMember
//
// 	    Test whether an object is part of the collection.  Returns a
// 	    reference to the object in the collection if the object is found.
//
// 	    initIterator
//
// 	    Iterator initializer.  Redeclared as pure virtual.
//
// 	    isA
//
// 	    Redeclared as pure virtual.
//
// 	    nameOf
//
// 	    Redeclared as pure virtual.
// 	
// 	    hashValue
//
// 	    Redeclared as pure virtual.
//
//  Inherited Members
//
// 	    isEmpty
//
// 	    Inherited from Container.
//
// 	    forEach
//
// 	    Inherited from Container.
//
//      firstThat
//
// 	    Inherited from Container.
//
//      lastThat
//
// 	    Inherited from Container.
//
// 	    printOn
//
// 	    Inherited from Container.
//
//      isEqual
//
// 	    Inherited from Container.
//
// 	    isSortable
//
// 	    Inherited from Object.
//
// 	    isAssociation
//
// 	    Inherited from Object.
//
// End ---------------------------------------------------------------------


#endif // ifndef __COLLECT_H //
