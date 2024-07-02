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
// 	    HashTable::isA
// 	    HashTable::nameOf
// 	    HashTable::add
// 	    HashTable::detach
// 	    HashTable::hashValue
// 	    HashTable::findMember
// 	    HashTable::initIterator
//
//      HashTableIterator::HashTableIterator            constructor
//      HashTableIterator::operator ++
//      HashTableIteartor::preIterate
//      HashTableIterator::operator int
//      HashTableIterator::restart
//
// Description
//
//      Class HashTable member functions.
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

#ifndef __HASHTBL_H
#include <hashtbl.h>
#endif

// End Interface Dependencies ------------------------------------------------


// Interface Dependencies ---------------------------------------------------

#ifndef __LIST_H
#include <list.h>
#endif

// End Interface Dependencies ------------------------------------------------


// Member Function //

HashTable::~HashTable()

// Summary -----------------------------------------------------------------
//
//      Destructor for a HashTable object.
//
//		We don't do anything here, because the destructor for Array
//		will take care of destroying the contained objects.
//
// End ---------------------------------------------------------------------
{
}
// End Destructor //


// Member Function //

classType HashTable::isA() const

// Summary -----------------------------------------------------------------
//
// 	    Returns the class type of an hash table.
//
// End ---------------------------------------------------------------------
{
    return hashTableClass; 
}
// End Member Function HashTable::isA //


// Member Function //

char *HashTable::nameOf() const

// Summary -----------------------------------------------------------------
//
// 	    Returns a pointer to the character string "HashTable."
//
// End ---------------------------------------------------------------------
{
    return "HashTable";
}
// End Member Function HashTable::nameOf //


// Member Function //

void HashTable::add( Object& objectToAdd )

// Summary -----------------------------------------------------------------
//
// 	    Adds an element to a hash table.
//
// Parameters
//
//      objectToAdd
//
// 	    The object we are to put in the hash table.
//
// End ---------------------------------------------------------------------
{

    hashValueType index = getHashValue( objectToAdd );

// Body Comment
//
//      Check to see if there is any List object at the given index.
//      If there isn't an object already there, then we use the
//      table's addAt() function to put a new List object there.
//      If there is a List object already there, then we can use its member
//      functions (note that it would be a run-time error to use the member
//      functions of theErrorObject) to add our object to the list.
//
// EndComment

    if( table[ index ] == NOOBJECT )
    {
		table.addAt( *(new List), index );
    }

	((List&)table[ index ]).add( objectToAdd );

}
// End Member Function HashTable::add //


// Member Function //

void HashTable::detach( const Object& objectToDetach, int deleteObjectToo )

// Summary -----------------------------------------------------------------
//
// 	    Detaches an element in a hash table.
//
// Parameters
//
// 	    objectToDetach
//
// 	    The object we are to detach from the hash table.
//
// 	    deleteObjectToo
//
// 	    Indicates whether we are to call the object's destructor
//
// Functional Description
//
// 	    If there is a list of objects at the given hash table entry,
// 	    detach our object in the list.
//
// End ---------------------------------------------------------------------
{

	hashValueType index = getHashValue( objectToDetach );

	if( table[ index ] != NOOBJECT )
    {
		((List&)table[ index ]).detach( objectToDetach, deleteObjectToo );
    }

}
// End Member Function HashTable::detach //


// Member Function //

hashValueType HashTable::hashValue() const

// Summary -----------------------------------------------------------------
//
//      Returns the hash value of a list.
//
// End ---------------------------------------------------------------------
{
	return hashValueType(0);
}
// End Member Function HashTable::hashValue //


// Member Function //

Object& HashTable::findMember( const Object& testObject ) const

// Summary -----------------------------------------------------------------
//
//      Looks up the given object in the hash table and returns a
// 	    reference to the object in the hash table, if the hash table
// 	    contains an object which is equal to the given object.
//
// Parameters
//
// 	    testObject
//
// 	    The object for which we will be searching in this
// 	    hash table.
//
// Return Value
//
// 	    Returns NOOBJECT if this hash table does not have the given
// 	    object.  Returns a reference to the object otherwise.
//
// Functional Description
//
//      Check to see if there is any List object at the given index.
//      If there isn't an object already there, then we don't have
// 	    the object in our hash table.
//      If there is a List object already there, then we can use its member
//      functions (note that it would be a run-time error to use the member
//      functions of theErrorObject) to search for our object in the list.
//
// End ---------------------------------------------------------------------
{

	hashValueType index = getHashValue( testObject );

	if( table[ index ] == NOOBJECT )
	{
		return NOOBJECT;
	}

	return ((List&)table[ index ]).findMember( testObject );
}
// End Member Function HashTable::findMember //


// Member Function //

ContainerIterator& HashTable::initIterator() const

// Summary -----------------------------------------------------------------
//
//      Initializes an iterator for a hash table.
//
// End ---------------------------------------------------------------------
{
	return *( (ContainerIterator *)new HashTableIterator( this->table ) );
}
// End Member Function HashTable::initIterator //



// Constructor //

HashTableIterator::HashTableIterator( const Array& toIterate ) :
                                beingIterated( toIterate )

// Summary -----------------------------------------------------------------
//
//      Constructor for a hash table iterator object.
//
// Functional Description
//
//      We initialize the list iterator to a dummy list's iterator, then
//      initialize the array iterator.  Finally, we invoke operator ++()
//      on the iterator to finish the initialization.
//
// End ---------------------------------------------------------------------
{
    List dummy;
    listIterator = (ListIterator *)&dummy.initIterator();
    indexIterator = (ArrayIterator *)&toIterate.initIterator();
    (void)preIterate();
}
// End Constructor HashTableIterator::HashTableIterator //


// Member Function //

Object& HashTableIterator::operator ++()

// Summary -----------------------------------------------------------------
//
//      Increments a hash table iterator.
//
// End ---------------------------------------------------------------------
{
    if ( preIterate() )
       return (*listIterator)++;
    else
       return NOOBJECT;
}
// End Member Function HashTableIterator::operator ++ //


// Member Function //

int HashTableIterator::preIterate()

// Summary -----------------------------------------------------------------
//
//      Prepares a hash table iterator for the next iteration step.
//
// Functional Description
//
//      If our current list iterator is finished, we bump the array
//      iterator up.  If the element at that index is a valid list,
//      we set up an iterator using that list.
//
//
// End ---------------------------------------------------------------------
{
    while ( *listIterator == NOOBJECT )
    {
        delete listIterator;
        while ( *indexIterator && *indexIterator == NOOBJECT )
            (*indexIterator)++;
        if ( *indexIterator == 0 )
            return 0;
        else // the array iteration isn't over.
        {
            Object& l = *indexIterator;
            List& l1 = (List&)l;
            listIterator = (ListIterator *)&l1.initIterator();
            do {
                (*indexIterator)++;
                } while ( *indexIterator && *indexIterator == NOOBJECT );
        }
    }
    return 1;
}
// End Member Function preIterate //


// Member Function //

HashTableIterator::operator int()

// Summary -----------------------------------------------------------------
//
//      Implements a hash table iterator integer conversion operator.
//      This is used to test for the end of iteration sequence.
//
// End ---------------------------------------------------------------------
{
    return  *indexIterator != 0;
}
// End Member Function HashTableIterator::operator int //


// Member Function //

HashTableIterator::operator Object&()

// Summary -----------------------------------------------------------------
//
//      Conversion to Object operator.
//
// End ---------------------------------------------------------------------
{
    return  *listIterator;
}
// End Member Function HashTableIterator::operator Object& //


// Member Function //

void    HashTableIterator::restart()

// Summary -----------------------------------------------------------------
//
//      Restarts the iteration process.
//
// End ---------------------------------------------------------------------
{
    delete indexIterator;
    delete listIterator;
    List dummy;
    listIterator = (ListIterator *)&dummy.initIterator();
    indexIterator = (ArrayIterator *)&beingIterated.initIterator();
    operator ++();
}
// End Member Function HashTableIterator::restart //
