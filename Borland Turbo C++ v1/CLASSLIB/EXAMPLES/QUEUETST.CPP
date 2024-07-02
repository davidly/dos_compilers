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

// Contents -----------------------------------------------------------------
//
//      main
//
// Description
//
//      Contains a simple example program for class Queue.
//
// End ---------------------------------------------------------------------

// Interface Dependencies ---------------------------------------------------

// None

// End Interface Dependencies ------------------------------------------------

// Implementation Dependencies ----------------------------------------------

#ifndef __IOSTREAM_H
#include <iostream.h>
#define __IOSTREAM_H
#endif

#ifndef __DOS_H
#include <dos.h>
#define __DOS_H
#endif

#ifndef __STDLIB_H
#include <stdlib.h>
#define __STDLIB_H
#endif

#ifndef __LTIME_H
#include <ltime.h>
#endif

#ifndef __QUEUE_H
#include <queue.h>
#endif

// End Implementation Dependencies -------------------------------------------


// Function //

int main()

// Summary -----------------------------------------------------------------
//
//      Illustrates a use of the Queue class.  Saves
//      the current time in a queue, then waits for a random length of
//      time before saving the current time in a queue.  After 7 samplings
//      have been entered in the queue, the queue is printed.
//
//      Usage:  queuetst
//
// Return Value
//
//      noError
//
//      Returns a 0 if no error occurs during execution, a 1 otherwise.
//
// End ---------------------------------------------------------------------
{
    Queue timeLine;

    cout << "\nSampling";
    for ( int i = 0; i < 7; i++ )
    {
        struct time snapShot;
        gettime( &snapShot );
        Time sample( snapShot.ti_hour,
                     snapShot.ti_min,
                     snapShot.ti_sec,
                     snapShot.ti_hund );

        timeLine.put ( *(new Time( sample )) );
        cout << ".";
        delay( rand() % 5000 );
    }

    cout << "\nThe timing samples are:\n\n";

    while( !timeLine.isEmpty() )
        {
        Time& sampleTime = (Time&)timeLine.get();
        cout << sampleTime << "\n";
        delete &sampleTime;
        } // end for all element in the queue.

    return 0;
}
// End Function main //


