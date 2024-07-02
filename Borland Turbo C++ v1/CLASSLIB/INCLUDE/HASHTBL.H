#ifndef __HASHTBL_H
#define __HASHTBL_H

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
//      HashTable
//      HashTable::HashTable
//      HashTable::getHashValue
//
// Description
//
//      Defines the abstract class HashTable and associated inline
// 	    functions.  A hash table is a "container-container," that is,
// 	    it contains a number of container objects.
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

#ifndef __RESOURCE_H
#include <resource.h>
#endif

#ifndef __OBJECT_H
#include <object.h>
#endif

#ifndef __CONTAIN_H
#include <contain.h>
#endif

#ifndef __COLLECT_H
#include <collect.h>
#endif

#ifndef __LIST_H
#include <list.h>
#endif

#ifndef __ARRAY_H
#include <array.h>
#endif

// End Interface Dependencies ------------------------------------------------


// Class //

class HashTable:  public Collection
{
public:
            HashTable( sizeType = DEFAULT_HASH_TABLE_SIZE );
    virtual ~HashTable();

    virtual void			add( Object& );
    virtual void            detach( const Object&, int = 0 );

    virtual ContainerIterator& initIterator() const;
    virtual Object&         findMember( const Object& ) const;

    virtual classType       isA() const;
    virtual char           *nameOf() const;
    virtual hashValueType   hashValue() const;

private:
            hashValueType   getHashValue( const Object& ) const;
            sizeType        size;
            Array           table;
};

// Description -------------------------------------------------------------
//
// 	    Defines the class HashTable. 
//      
// Constructors
//
//      HashTable( sizeType )
//
//      Constructs a hash table of the given size.
//
// Destructors
//
//      ~HashTable()
//
//      We provide the destructor for the sole purpose of forcing a call
//      to the destructor for the private member objects of the class.
//
// Public Members
//
//
// 	    initIterator
//
// 	    Initializes an iterator for a hash table.
//
//      add
//
//      Adds an object to the hash table.
//
//      destroy
//
//      Removes an object reference from the hash table and
//      destroys the object.
//
// 	    detach
//
// 	    Removes all references to the object in the hash table.
//      Does not delete the object.  Use this function when the hash table
//      elements are not owned by the hash table.
//
// 	    findMember
//
// 	    Returns a reference to the object which is associated with the
// 	    given key.
//
// 	    hashValue
//
// 	    Returns a pre-defined value for a hash table.
//
// 	    isA
//
// 	    Returns the class type of class HashTable.
//
// 	    nameOf
//
// 	    Returns a pointer to the character string "HashTable."
// 	
// Inherited Members
//
//      hasMember
//
// 	    Inherited from Collection.
//
// 	    isEmpty
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
// Protected Members
//
// 	    itemsInCollection
//
// 	    Inherited from Container.
//
// Private Members
//
//      getHashValue
//
//      Private member function to return the hash value of an object.
//
//      size
//
//      Container for the size of the hash table.
//
//      table
//
//      An array of lists which implements the hash table.
//
// End ---------------------------------------------------------------------


// Constructor //

inline HashTable::HashTable( sizeType aPrime ) : size( aPrime ), table( aPrime )

// Summary -----------------------------------------------------------------
//
//      Construct a hash table of the given size.
//
// Parameters
//
//      aPrime
//
//      The size of the hash table.  To make the hashing algorithm work
//      efficiently, you should make this a prime number.
//
// Functional Description
//
//      We store the passed size and create an array object of that size.
//
// End ---------------------------------------------------------------------
{
}
// End Constructor //


// Member Function //

inline sizeType HashTable::getHashValue( const Object& ofObject ) const

// Summary -----------------------------------------------------------------
//
//      Returns the hash value of the given object.
//
// Parameters
//
//      ofObject
//
//      The object we are to hash.
//
// Functional Description
//
//      We ask the object to hash itself, then modulo that value by the
//      size of our hash table.
//
// End ---------------------------------------------------------------------
{
    return ofObject.hashValue() % size;
}
// End Member Function //


// Class //

class HashTableIterator:  public ContainerIterator
{
public:
            HashTableIterator( const Array& );

	virtual				operator int();
	virtual	Object&		operator ++();
    virtual             operator Object&();
	virtual	void		restart();

private:
            int         preIterate();
            ArrayIterator *indexIterator;
            ListIterator  *listIterator;
    const   Array&      beingIterated;
};

// Description -------------------------------------------------------------
//
// 	    Defines the hash table iterator class.  Upon initialization, we set up
// 	    an internal pointer to our current position in the hash table.  As
//      the increment operator is called, we update this current position.
//
// Constructor
//
//      HashTableIterator( const Array& )
//
// 	    Constructor for an iterator.  Note that this isn't a copy
// 	    constructor, since it takes an object from a different class.
//
// Destructor
//
// 	    ~HashTableIterator
//
// Public Members
//
// 	    operator int
//
// 	    We are allowed one cast operator to a predefined type.  This
// 	    operator defines an explicit or an implicit cast from a
// 	    HashTableIterator to an integer.
//
//      operator Object&
//
//      Conversion operator from HashTableIterator to Object.
//
// 	    operator ++
//
//      The increment operator.
//
// 	    restart
//
// 	    Restarts an hash table iterator.
//
// Private Members
//
//      preIterate
//
//      Begins a step in the iteration.
//
// 	    indexIterator
//
// 	    Maintains the position information in the array for this iterator.
//
// 	    listIterator
//
// 	    Maintains the position information in the lists of the array 
//      for this iterator.
//
//      beingIterated
//
//      A reference to the array hash table which is being iterated.  Used
//      when restarting the iteration.
//
// End ---------------------------------------------------------------------


#endif // ifndef __HASHTBL_H //
