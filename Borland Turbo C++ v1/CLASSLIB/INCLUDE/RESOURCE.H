#ifndef __RESOURCE_H
#define __RESOURCE_H

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
//      DESIGN_LIMIT_ON_DEFAULT_HASH_TABLE_SIZE
//      DEFAULT_HASH_TABLE_SIZE
//
//      DESIGN_LIMIT_ON_DEFAULT_BAG_SIZE
//      DEFAULT_BAG_SIZE
//
//      DESIGN_LIMIT_ON_DEFAULT_SET_SIZE
//      DEFAULT_SET_SIZE
//
// Description
//
//      Defines resource constants for C++ class library.
//
// End ---------------------------------------------------------------------

// Interface Dependencies ---------------------------------------------------

#ifndef __LIMITS_H
#include <limits.h>
#define __LIMITS_H
#endif

// End Interface Dependencies ------------------------------------------------

// LiteralSection ----------------------------------------------------------
//
//      hash table size
//
// Description
//
//      Defines the limit on a hash table's size and the default size.
//      Also defines limits and defaults for derived types of class HashTable.
//
// End ---------------------------------------------------------------------

#define DESIGN_LIMIT_ON_DEFAULT_HASH_TABLE_SIZE     UINT_MAX

//
//      The hash table size is defined as a sizeType, which is an 
//      unsigned int.
//

#define DEFAULT_HASH_TABLE_SIZE                     111

//
//      We make a fair size default hash table.  If you care to change
//      the default size, you may do so without harm, as long as your
//      default value does not exceed the design limit on the maximum
//      size for a hash table.  Keep in mind that a hash table is more
//      efficient if the size is a prime number.
//

#define DESIGN_LIMIT_ON_DEFAULT_BAG_SIZE                                    (\
                                DESIGN_LIMIT_ON_DEFAULT_HASH_TABLE_SIZE     \
                                                                            )
//
//      Class Bag is derived from class HashTable and therefore gets the
//      same design limit.
//

#define DEFAULT_BAG_SIZE                            29

//
//      Bags are usually smaller than hash tables.  Of course, if this
//      were a grocery bag, the default would be much smaller.
//

#define DESIGN_LIMIT_ON_DEFAULT_SET_SIZE                                    (\
                                DESIGN_LIMIT_ON_DEFAULT_BAG_SIZE            \
                                                                            )
//
//      Class Set is derived from class Bag and therefore gets the
//      same design limit.
//

#define DEFAULT_SET_SIZE                            29

//
//      Bags and sets are usually the same size.
//

// End LiteralSection hash table size //

#endif // ifndef __RESOURCE_H //


