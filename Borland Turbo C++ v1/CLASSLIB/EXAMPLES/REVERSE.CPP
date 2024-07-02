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
//      main
//
// Description
//
//      Contains a simple example program for class Stack.
//
// End ---------------------------------------------------------------------

// Interface Dependencies ---------------------------------------------------

// None

// End Interface Dependencies ------------------------------------------------

// Implementation Dependencies ----------------------------------------------

#ifndef __IOSTREAM_H
#include <iostream.h>       // stream i/o
#define __IOSTREAM_H
#endif

#ifndef __STACK_H
#include <stack.h>          // Stack class.
#endif

#ifndef __STRNG_H
#include <strng.h>          // String class.  Note that this is not <string.h>!
#endif

// End Implementation Dependencies -------------------------------------------


// Function //

int main()

// Summary -----------------------------------------------------------------
//
//      Illustrates a use of the Stack class.  Reads in strings until
//      you enter the string "reverse," then prints out the strings
//      in reverse order.  Returns the number of strings read in, not
//      including "reverse."
//
//      Usage:  reverse
//
// End ---------------------------------------------------------------------
{
    Stack theStack;
    String reverse("reverse");

    cout << "\nEnter some strings.  Reverse will collect the strings\n";
    cout << "for you until you enter the string \"reverse.\"  Reverse\n";
    cout << "will then print out the strings you have entered, but in\n";
    cout << "reverse order.  Begin entering strings now.\n";
    for(;;)
    {
        char inputString[255];
        cin >> inputString;
        String& newString = *( new String( inputString ) );
        if ( newString != reverse )
        {
            theStack.push( newString );
        }
        else // "reverse" was entered.
        {
            break;
        }
    } // end for loop until "reverse" is entered.

    cout << "\nThe strings you entered (if any) are:\n";

    while( !(theStack.isEmpty()) )
    {
        String oldString = (String&)theStack.pop();
        cout << oldString << "\n";
    }
    return 0;
}
// End Function main //


