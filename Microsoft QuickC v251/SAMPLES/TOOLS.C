/* TOOLS - Module containing several general functions that can be used
 * from any program. Include TOOLS.H to use.
 */

#include <conio.h>
#include <string.h>
#include <time.h>
#include <graph.h>
#include <bios.h>
#include "tools.h"

/* delay - Pauses for a specified number of microseconds. Used to slow
 * life by delaying between generations.
 *
 * Params: wait - time in microseconds
 *
 * Return: None
 */
void delay( clock_t wait )
{

    clock_t t1, t2;

    if( !wait )
        return;

    t1 = wait + clock();
    do
    {
        t2 = clock();
    } while( t2 < t1 );
}

/* getkey - Gets a key from the keyboard. This routine distinguishes
 * between ASCII keys and function or control keys with different shift
 * states. It also accepts a flag to return immediately if no key is
 * available.
 *
 * Params: waitflag - Code to indicate how to handle keyboard buffer:
 *   NO_WAIT     Return 0 if no key in buffer, else return key
 *   WAIT        Return first key if available, else wait for key
 *   CLEAR_WAIT  Throw away any key in buffer and wait for new key
 *
 * Return: One of the following:
 *
 *   Keytype                                High Byte    Low Byte
 *   -------                                ---------    --------
 *   No key available (only with NO_WAIT)       0           0
 *   ASCII value                                0        ASCII code
 *   Unshifted function or keypad               1        scan code
 *   Shifted function or keypad                 2        scan code
 *   CTRL function or keypad                    3        scan code
 *   ALT function or keypad                     4        scan code
 *
 * Note:   getkey cannot return codes for keys not recognized by BIOS
 *         int 16, such as the CTRL-UP or the 5 key on the numeric keypad.
 */
unsigned getkey( int waitflag )
{
    unsigned inkey, shiftstate;

    /* If CLEAR_WAIT, drain the keyboard buffer. */
    if( waitflag == CLEAR_WAIT )
        while( _bios_keybrd( _KEYBRD_READY ) )
            _bios_keybrd( _KEYBRD_READ );

    /* If NO_WAIT, return 0 if there is no key ready. */
    if( !waitflag && !_bios_keybrd( _KEYBRD_READY ) )
        return FALSE;

    /* Get key code. */
    inkey = _bios_keybrd( _KEYBRD_READ );

    /* If low byte is not zero, it's an ASCII key. Check scan code to see
     * if it's on the numeric keypad. If not, clear high byte and return.
     */
    if( inkey & 0x00ff )
        if( (inkey >> 8) < 69 )
            return( inkey & 0x00ff );

    /* For function keys and numeric keypad, put scan code in low byte
     * and shift state codes in high byte.
     */
    inkey >>= 8;
    shiftstate = _bios_keybrd( _KEYBRD_SHIFTSTATUS ) & 0x000f;
    switch( shiftstate )
    {
        case 0:
            return( 0x0100 | inkey );  /* None (1)    */
        case 1:
        case 2:
        case 3:
            return( 0x0200 | inkey );  /* Shift (2)   */
        case 4:
            return( 0x0300 | inkey );  /* Control (3) */
        case 8:
            return( 0x0400 | inkey );  /* Alt (4)     */
    }
}
