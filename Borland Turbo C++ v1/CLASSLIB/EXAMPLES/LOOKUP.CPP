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
//      CLASSDEFINITIONS
//      classNames
//      classDefs
//
//      main
//
// Description
//
//      C++ class library example program.  Creates a dictionary from
//      the descriptions of each of the classes in the class Object
//      hierarchy.
//
// End ---------------------------------------------------------------------

// Interface Dependencies ---------------------------------------------------
// End Interface Dependencies ------------------------------------------------

// Implementation Dependencies ----------------------------------------------

#ifndef __IOSTREAM_H
#include <iostream.h>    // stream i/o
#define __IOSTREAM_H
#endif

#ifndef __DICT_H
#include <dict.h>        // class Dictionary
#endif

#ifndef __ASSOC_H
#include <assoc.h>        // class Association
#endif

#ifndef __STRNG_H
#include <strng.h>        // class String
#endif

// End Implementation Dependencies -------------------------------------------


// Macro //

#define CLASSDEFINITIONS 23

// Description -------------------------------------------------------------
//
//     Defines the number of definitions in the dictionary.
//
// End ---------------------------------------------------------------------


// Variable //

static char *classNames[CLASSDEFINITIONS] =
    {
        "Object",
        "Error",
        "Sortable",
        "Association",
        "String",
        "Container",
        "Stack",
        "Queue",
        "Deque",
        "Collection",
        "HashTable",
        "Bag",
        "Set",
        "Dictionary",
        "AbstractArray",
        "Array",
        "SortedArray",
        "List",
        "DoubleList",
        "ContainerIterator",
        "ArrayIterator",
        "ListIterator",
        "DoubleListIterator"
    };


// Description -------------------------------------------------------------
//
//     Used by the main routine to create the dictionary.
//
// End ---------------------------------------------------------------------


// Variable //

static char *classDefs[CLASSDEFINITIONS] =
    {
        "The abstract base class of the hierarchy.\n",
        "Used to indicate the presence of no object reference.\n",
        "Used in ordered collections.\n",
        "A key/value pair, used by the class Dictionary.\n",
        "An example of an instance class, derived from class Sortable.\n",
        "An abstract base class for all classes which contain other objects.\n",
        "A LIFO container class.\n",
        "A FIFO container class.\n",
        "A double-ended container class, allowing both FIFO and LIFO access.\n",
        "An abstract base class for classes which may be tested for membership.\n",
        "A fast lookup implementation of a collection.\n",
        "A collection class implemented by a hash table.\n",
        "A collection in which there may be only one copy of each member.\n",
        "A set of association object, with a lookup function.\n",
        "An abstract base class for arrays.\n",
        "A fixed or expandable array.\n",
        "An array in which objects at successive indices are in order.\n",
        "A collection class in which objects are linked together.\n",
        "A collection of objects which are part of two lists.\n",
        "A class which, when instantiated, is used to iterate over a collection.\n",
        "An iterator which is used on array objects.\n",
        "An iterator which is used on list objects.\n",
        "An iterator which is used on double list objects.\n"
    };


// Description -------------------------------------------------------------
//
//     Used by the main routine to create the dictionary.
//
// End ---------------------------------------------------------------------


// Function //

int main( int argc, char *argv[] )

// Summary -----------------------------------------------------------------
//
//     Dictionary example program.  This program creates a dictionary
//     and inserts strings into the dictionary, then looks up a given
//     string.
//
// Parameters
//
//     argc
//
//     The number of arguments passed to our program from the command line.
//
//     argv
//
//     The array of character pointers which was given on the command line.
//
// Functional Description
//
//     A dictionary object is a container class for association objects.
//     An association is an object which keeps together a key and
//     a value.  In our example, both the key and the value will be
//     String objects.
//
//     We make a dictionary object on the heap, then add associations
//     to the dictionary.  When these associations have been added, we
//     look up the given string in the dictionary and display its
//     definition.
//
// End ---------------------------------------------------------------------
{
    if ( argc != 2 )
    {
        cerr << "Usage:  lookup classname\n";
        return 1;
    }

    Dictionary& classDefinitions = *( new Dictionary );

    for ( int i = 0; i < CLASSDEFINITIONS; i++ )
    {
        String& className = *( new String( classNames[i] ) );
        String& classDef = *( new String( classDefs[i] ) );
        Association& entry = *(new Association( className, classDef ) );

        classDefinitions.add( entry );

    } // end for all class definitions

    Association& definition =
                    classDefinitions.lookup ( *(new String ( argv[1] ) ) );
    if ( definition == NOOBJECT )
    {
        cout << "A definition for " << argv[1] << " was not found in the dictionary.\n";
    }
    else
    {
        cout << definition;
    }
}
// End Function main //

