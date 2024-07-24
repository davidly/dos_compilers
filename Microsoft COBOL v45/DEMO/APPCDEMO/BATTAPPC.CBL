      $set mf ans85 noosvs
      *******************************************************************
      *                                                                 *
      *                                                                 *
      *                  (C) Micro Focus Ltd. 1990                      *
      *                                                                 *
      *                         BATTAPPC.CBL                            *
      *                                                                 *
      *      COBOL Advanced Program to Program (APPC) Demonstration     *
      *                                                                 *
      *                         Battleships                             *
      *                    communications module                        *
      *                                                                 *
      *******************************************************************

      *******************************************************************
      *        BATTAPPC - links two battleships games using APPC        *
      *                                                                 *
      *  This program is called by BATTLEL & BATTLER to communicate     *
      *  between one another.                                           *
      *                                                                 *
      *  The communications that take place are:                        *
      *        - to bring up a link between the two programs            *
      *        - to take down a link                                    *
      *        - to send coordinates to a program                       *
      *        - to receive coordinates from a program                  *
      *        - to send a damage report to a program                   *
      *        - to receive a damage report from a program              *
      *                                                                 *
      *  The method of communication is entirey transparent to the      *
      *  users of the game.  So long as the same interface is used,     *
      *  this module could be replaced by one which used a different    *
      *  communications protocol.                                       *
      *                                                                 *
      *  The interface consists of two parameters.  The first parameter *
      *  is the operation code - indicating which function to perform.  *
      *  The second parameter is a buffer area which is used to pass    *
      *  information between the communicating programs.                *
      *                                                                 *
      *  The result of any operation is returned to the calling program *
      *  in the RETURN-CODE system variable.  A zero value indicates    *
      *  success and a non-zero value indicates some error  - In this   *
      *  example program, the error handling is very simple - in that   *
      *  the programs will stop if any error is received.  You may,     *
      *  however, decide to provide more intelligent error handling, in *
      *  which the user of the game may be given alternative courses of *
      *  action when such an error occurs.                              *
      *                                                                 *
      *******************************************************************
       Special-names.
           call-convention 3 is api.

       Working-Storage Section.
       copy "appc.cpy".
       copy "acssvc.cpy".

      *-----------------------------------------------------------------
      * Working variables
      *-----------------------------------------------------------------
       01  tp-name                     pic x(64) value spaces.
       78  tp-name-len                 value 64.
       01  tp-id                       pic x(8) value spaces.
       01  lu-alias                    pic x(8) value spaces.
       01  plu-alias                   pic x(8) value spaces.
       01  conv-id                     pic x(4) value spaces.
       01  mode-name                   pic x(8) value spaces.
       78  mode-name-len               value 8.

       01  what-received               pic 9(4) comp-x.
       01  request-to-send-received    pic 9(2) comp-x.
       01  state-flag                  pic 9(2) comp-x.
           88 Sending-State            value 1.
           88 Receiving-State          value 0.

       01  data-buffer-length          pic 9(4) comp-5.
       01  data-buffer-ptr             usage pointer.
       01  data-buffer-address
           redefines data-buffer-ptr.
           03 data-buffer-offset       pic 9(4) comp-5.
           03 data-buffer-selector     pic 9(4) comp-5.
       01  alloc-flags                 pic 9(4) comp-5 value 1.
       01  key-char pic x.


      *-----------------------------------------------------------------
      * following items used for constructing error message
      *-----------------------------------------------------------------
       01  bin-dword.
           03 bin-dword-msw            pic 9(4) comp-x.
           03 bin-dword-lsw            pic 9(4) comp-x.
       01  bin-val.
           03 bin-val-1                pic 9(2) comp-x.
           03 bin-val-2                pic 9(2) comp-x.

       01  hex-idx-1                   pic 9(2) comp-x.
       01  hex-idx-2                   pic 9(2) comp-x.
       01  hex-disp                    pic x(4).
       01  hex-string                  pic x(16)
                                      value "0123456789ABCDEF".
       01  clear-char                  pic x value " ".
       01  clear-attr                  pic 9(2) comp-x value 7.
       01  screen-pos                  pic 9(4) comp-x value h"0100".
       01  error-msg.
           03 filler                   pic x(25)
                                      value 'APPC/ACSSVC Error Verb=x"'.
           03 error-1                  pic x(4).
           03 filler                   pic x(17)
                                      value '" Primary Code=x"'.
           03 error-2                  pic x(4).
           03 filler                   pic x(19)
                                      value '" Secondary Code=x"'.
           03 error-3                  pic x(4).
           03 error-4                  pic x(4).
           03 filler                   pic x value '"'.

      *-----------------------------------------------------------------
      *  interface paramters
       LINKAGE SECTION.
      *-----------------------------------------------------------------
       01 Comm-Code                    Pic 9(2) Comp.
       01 Comm-Buffer                  Pic x(12).

      *-----------------------------------------------------------------
       01 Shared-Segment-Buffer        Pic x(12).
      *    This is a special linkage item - not used as a parameter -
      *    but as a buffer whose address is set to a shared unnamed
      *    segment, allocated later on.  This type of memory is
      *    required by some APPC verbs - see later for details
      *
      *-----------------------------------------------------------------


      *=================================================================
      *
      *---------------------Call Interface------------------------------
       PROCEDURE DIVISION using
                                   by value Comm-Code
                                   by reference Comm-Buffer.
      *-----------------------------------------------------------------
      *=================================================================


      *-----------------------------------------------------------------
       Evaluate-Operation.
      *    work out which high level operation to perform
      *
      *-----------------------------------------------------------------
           Evaluate Comm-Code
               When 1      Perform Bring-Up-Link
               When 2      Perform Take-Down-Link
               When 3      Perform Send-Coords
               When 4      Perform Receive-Coords
               When 5      Perform Send-Report
               When 6      Perform Receive-Report
               When other  move 1 to Return-Code
           End-Evaluate
           move 0 to Return-Code
           Exit Program.

      *-----------------------------------------------------------------
       Error-Exit.
      *  quick exit in case of error during APPC
      *
      *-----------------------------------------------------------------
           move 1 to Return-Code
           Exit Program.

      *-----------------------------------------------------------------
       Bring-Up-Link.
      *    High level function to initiate a communication between
      *    two transaction programs playing the game.
      *
      *    The verbs issued to start a conversation are  different
      *    for each program - only one end may start the communication
      *    with a MC-ALLOCATE verb - this is received at the other end
      *    by a RECEIVE-ALLOCATE verb.
      *
      *    The LU-ALIAS, partner LU-ALIAS, MODE-NAME and TP-NAME which
      *    are defined in the configuration profile for this
      *    communication are placed in variables for various verbs to
      *    use.  These names must match up with those defined in the
      *    configuration currently active - switch to the
      *    communications Manager session and check to see that the
      *    correct profile is loaded.
      *
      *    Some fields passed in the Verb Control Block have to be
      *    defined in EBCDIC - all of these fields are converted from
      *    ASCII using a special utility routine provided as part
      *    of the Communications Manager software (ie. ACSSVC.DLL)  -
      *    this is done initially and the converted fields are saved in
      *    temporary variables for later use.
      *
      *    The other verbs (seen in capitals) are used to request
      *    resources of APPC before a conversation starts (TP-STARTED)
      *    and is only required on the MC-ALLOCATE side.  The other
      *    verb (ie MC-FLUSH) causes the allocation request to be sent
      *    to the remote machine immediately - this is because send
      *    buffers are not normally sent off until a buffer becomes
      *    full - so as to minimise on transmissions.  The MC-FLUSH
      *    verb is useful in this situation if you want a remote
      *    program to connect immediately.
      *
      *    Comm-buffer is used to tell this module which program is
      *    calling it - so that it can decide which set of verbs to
      *    issue.
      *
      *-----------------------------------------------------------------
           If Comm-Buffer = "PLAYER1"
      *            local end
      *            initialise configuration names
               move 'DEMOPLU1' to plu-alias
               move 'DEMOLU1 ' to lu-alias
               move 'DEMOMODE' to mode-name
               move 'BATTLE  ' to tp-name
      *            convert to EBCDIC
               Perform Convert-Tp-Name
               Perform Convert-Mode-Name
      *            issue APPC verbs to request resources and send
      *            immediate an allocation request to the remote machine
               Perform TP-STARTED
               Perform MC-ALLOCATE
               Perform MC-FLUSH
           Else
      *            remote end
      *            initialise configuration name
               move 'BATTLE  ' to Tp-Name
      *            convert to EBCDIC
               Perform Convert-Tp-Name
      *            issue APPC verb to receive allocation request
               Perform RECEIVE-ALLOCATE
           End-If
      *       allocate a buffer to be used by send and receive verbs
           Perform Allocate-Shared-Memory.

      *-----------------------------------------------------------------
       Allocate-Shared-Memory.
      *    Send and receive verbs: MC-SEND-DATA and MC-RECEIVE-AND-WAIT
      *    require the data buffer used as one of their parameters to
      *    be an unnamed shared segment - this is allocated with
      *    the DosAllocSeg api call with alloc-flag = 1
      *
      *-----------------------------------------------------------------
           move zero to Data-Buffer-Offset
           move Length of Comm-Buffer to Data-Buffer-Length
           move 1 to Alloc-Flags
      *        for COBOL/2 Toolset, do next statement
      *        call "cobolapi"
           call "__DosAllocSeg" using
                           by value Alloc-Flags
                           by reference Data-Buffer-Selector
                           by value Data-Buffer-Length
           If RETURN-CODE not = zero
               Go to Error-Exit
           End-If.


      *-----------------------------------------------------------------
       Take-Down-Link.
      *    This high level routine stops a conversation and releases
      *    resources used by the conversation.
      *
      *    The conversation is stopped at the sending end, ie the
      *    machine at which the last send verb was issued,  with
      *    the verb MC-DEALLOCATE.
      *
      *    The MC-DEALLOCATE verb is issued with type FLUSH which
      *    performs the same function as MC-FLUSH before the
      *    deallocation is sent - causing any unsent buffers to be
      *    transmitted.
      *
      *    The MC-RECEIVE-AND-WAIT is the verb issued at the receiving
      *    end, ie the machine at which the last receive verb was
      *    issued.  This verb waits until the deallocation signal
      *    arrives from the sending end.
      *
      *    The TP-ENDED verb is used to release resources at both
      *    ends of the terminated conversation.
      *
      *-----------------------------------------------------------------
           If Sending-State
               Perform MC-DEALLOCATE
           Else
               Perform MC-RECEIVE-AND-WAIT
           End-If
           Perform TP-ENDED.


      *-----------------------------------------------------------------
       Send-Coords.
      *    This high level operation sends coordinates contained in
      *    the buffer to be sent to the remote machine and then makes
      *    ready to receive a damage report from it.
      *
      *    MC-SEND-DATA causes the contents of the buffer to be sent
      *    to the particular LU defined.
      *
      *    After successful completion of MC-SEND-DATA , the
      *    conversation is placed in receive state by the
      *    MC-PREPARE-TO-RECEIVE verb - this is in readiness to receive
      *    the damage report of the coordinates specified.
      *
      *    The MC-PREPARE-TO-RECEIVE also flushes the send buffer so
      *    that nothing is left before any receive verbs take place.
      *
      *-----------------------------------------------------------------
           set address of Shared-Segment-Buffer to Data-Buffer-Ptr
           move Comm-Buffer to Shared-Segment-Buffer
           Perform MC-SEND-DATA
           Perform MC-PREPARE-TO-RECEIVE.

      *-----------------------------------------------------------------
       Receive-Report.
      *    The damage report is received using the verb
      *    MC-RECEIVE-AND-WAIT.  This verb waits indefinitely for the
      *    remote machine to send data.  When something is received
      *    a check is made that the data received is complete - if you
      *    are sending large amounts of information, data may be
      *    contained in several buffers and the 'what-received' verb
      *    contains a code to indicate if the buffer is complete or
      *    not.  This routine performs a loop issuing the verb until
      *    the last buffer arrives.
      *
      *-----------------------------------------------------------------
           move zero to what-received
           perform until what-received = ap-data-complete
               Perform MC-RECEIVE-AND-WAIT
           end-perform
           set address of Shared-Segment-Buffer to Data-Buffer-Ptr
           move Shared-Segment-Buffer to Comm-Buffer.


      *-----------------------------------------------------------------
       Receive-Coords.
      *    The coordinates are received using the MC-RECEIVE-AND-WAIT
      *    verb.  The buffer is received followed by a signal from the
      *    remote machine that it is ready to receive - so that the
      *    local end can send the damage report.  The signal passed to
      *    the MC-RECEIVE-AND-WAIT verb is contained in the
      *    'what-received' field.
      *
      *-----------------------------------------------------------------
           move zero to what-received
           perform until what-received = ap-send
               Perform MC-RECEIVE-AND-WAIT
           end-perform
           set address of Shared-Segment-Buffer to Data-Buffer-Ptr
           move Shared-Segment-Buffer to Comm-Buffer.


      *-----------------------------------------------------------------
       Send-Report.
      *    This sends the buffer using an MC-SEND-DATA verb followed
      *    by MC-FLUSH to transmit the buffer.
      *
      *-----------------------------------------------------------------
           set address of Shared-Segment-Buffer to Data-Buffer-Ptr
           move Comm-Buffer to Shared-Segment-Buffer
           Perform MC-SEND-DATA
           Perform MC-FLUSH.


      *=================================================================
      *=================================================================
      *-----------------------------------------------------------------
      *    The conversion routines below use a service utility called
      *    the Common Services Programming Interface.  It provides:
      *       -  ASCII/EBCDIC conversion in both directions
      *       -  traces API verbs and data
      *       -  provides translation tables for specified code pages
      *       -  records messages in CM message log
      *       -  sends network management messages to a network
      *            management service
      *
      *    Here we only use it for ASCII-EBCDIC using the CONVERT verb
      *
      *-----------------------------------------------------------------
      * ASCII-EBCDIC conversion routines

       Convert-Mode-Name.
           move all x"00" to VCB
           move sv-convert to opcode-cvt
           move sv-ascii-to-ebcdic to direction-cvt
           move sv-a to char-set-cvt
           move mode-name-len to len-cvt
           set src-ptr-cvt to address of mode-name
           set targ-ptr-cvt to address of mode-name
           perform Execute-Acssvc-Verb
           perform Check-Error.

       Convert-Tp-Name.
           move all x"00" to VCB
           move sv-convert to opcode-cvt
           move sv-ascii-to-ebcdic to direction-cvt
           move sv-ae to char-set-cvt
           move tp-name-len to len-cvt
           set src-ptr-cvt to address of tp-name
           set targ-ptr-cvt to address of tp-name
           perform Execute-Acssvc-Verb
           perform Check-Error.

      *-----------------------------------------------------------------
      *
      * The following routines define the call interfaces to the
      * various APPC verbs required above
      *
      *
      *-----------------------------------------------------------------

      *-----------------------------------------------------------------
       Receive-Allocate.
      *    wait receipt of allocation request from local machine
      *    and then start a new transaction program
      *
      *    The VCB should always be initialized with low values before
      *    any fields are loaded.  The verb returns a tp-id and a
      *    conv-id which are to be used by subsequent verbs during the
      *    conversation.
      *
      *    LU-Alias, PLU-Alias and mode name of the session are also
      *    returned.
      *
      *    A check on the return codes should always be made after
      *    issuing a verb.  In this case an error causes an immediate
      *    return to the calling program to occur.
      *
      *-----------------------------------------------------------------
           move all x"00" to VCB
           move ap-receive-allocate to opcode-ral
           move tp-name to tp-name-ral
           set Receiving-State to True
           perform Execute-Appc-Verb
           perform Check-Error
           move tp-id-ral to tp-id
           move conv-id-ral to conv-id
           move lu-alias-ral to lu-alias
           move plu-alias-ral to plu-alias
           move mode-name-ral to mode-name.

      *-----------------------------------------------------------------
       MC-Receive-and-Wait.
      *    wait for data or signal to be sent.  The 'what-received'
      *    field is returned by this call and indicates the type of
      *    information sent eg. data buffer or a signal to start
      *    sending data.
      *
      *    The buffer that the data is sent to MUST be a shared,
      *    unnamed segment of memory.  This is allocated using the
      *    DosAllocSeg function call (with flags=1).
      *
      *-----------------------------------------------------------------
           set Receiving-State to True
           move all x"00" to VCB
           move ap-m-receive-and-wait to opcode-mrw
           move ap-mapped-conversation to opext-mrw
           move tp-id to tp-id-mrw
           move conv-id to conv-id-mrw
           set dptr-mrw to Data-Buffer-Ptr
           move Data-Buffer-Length to max-len-mrw
           perform Execute-Appc-Verb
           If prim-rc-mda not = h"0009"
      *            if primary return code = h"0009"
      *              don't treat as error - returned when receiving
      *              deallocation signal from MC-DEALLOCATE verb
               perform check-error
           End-If
           move what-rcvd-mrw to what-received
           move rts-rcvd-mrw to request-to-send-received.


      *-----------------------------------------------------------------
       MC-Allocate.
      *    send an allocaton request to a remote machine to start a
      *    conversation.  This verbs requires certain names defined in
      *    the configuration profile.
      *
      *-----------------------------------------------------------------
           move all x"00" to VCB
           move ap-m-allocate to opcode-mal
           move ap-mapped-conversation to opext-mal
           move 1 to opext-mal
           move tp-id to tp-id-mal
           move ap-confirm-sync-level to sync-lvl-mal
           move ap-when-session-allocated to rtn-ctl-mal
           move plu-alias to plu-alias-mal
           move mode-name to mode-name-mal
           move tp-name to tp-name-mal
           move ap-none to security-mal
           set Sending-State to True
           perform Execute-Appc-Verb
           perform Check-Error
           move conv-id-mal to conv-id.

      *-----------------------------------------------------------------
       MC-Send-Data.
      *    send a buffer to the remote machine.  The buffer MUST be
      *    a shared unnamed segment of memory.  This is allocated using
      *    the DosAllocSeg function call (with flags=1).
      *
      *-----------------------------------------------------------------
           set Sending-State to True
           move all x"00" to VCB
           move ap-m-send-data to opcode-msd
           move ap-mapped-conversation to opext-msd
           move tp-id to tp-id-msd
           move conv-id to conv-id-msd
           move data-buffer-length to dlen-msd
           set dptr-msd to data-buffer-ptr
           perform Execute-Appc-Verb
           perform Check-Error
           move rts-rcvd-msd to request-to-send-received.

      *-----------------------------------------------------------------
       MC-Deallocate.
      *    close a conversation
      *
      *-----------------------------------------------------------------
           set Sending-State to True
           move all x"00" to VCB
           move ap-m-deallocate to opcode-mda
           move ap-mapped-conversation to opext-mda
           move tp-id to tp-id-mda
           move conv-id to conv-id-mda
           move ap-flush to dealloc-type-mda
           perform Execute-Appc-Verb
           perform Check-Error.

      *-----------------------------------------------------------------
       MC-Flush.
      *    cause any unsent data to be transmitted immediately
      *
      *-----------------------------------------------------------------
           move all x"00" to VCB
           move ap-m-flush to opcode-fls
           move ap-mapped-conversation to opext-fls
           move tp-id to tp-id-fls
           move conv-id to conv-id-fls
           perform Execute-Appc-Verb
           perform Check-Error.

      *-----------------------------------------------------------------
       MC-Prepare-To-Receive.
      *    cause a change of conversation state from send to receive -
      *    this must be done before a MC-SEND-DATA verb can be issued
      *    by the remote end - when it is in receive state.  This verb
      *    causes the local end to go into receive state.
      *
      *-----------------------------------------------------------------
           set Receiving-State to True
           move all x"00" to VCB
           move ap-m-prepare-to-receive to opcode-ptr
           move ap-mapped-conversation to opext-ptr
           move tp-id to tp-id-ptr
           move conv-id to conv-id-ptr
           move ap-flush to ptr-type-ptr
           perform Execute-Appc-Verb
           perform Check-Error.

      *-----------------------------------------------------------------
       TP-Started.
      *    allocate resources for conversation
      *
      *-----------------------------------------------------------------
           move all x"00" to VCB
           move ap-tp-started to opcode-tps
           move lu-alias to lu-alias-tps
           move tp-name to tp-name-tps
           perform Execute-Appc-Verb
           perform Check-Error
           move tp-id-tps to tp-id.

      *-----------------------------------------------------------------
       TP-Ended.
      *    release resources used by earlier conversation
      *
      *-----------------------------------------------------------------
           move all x"00" to VCB
           move ap-tp-ended to opcode-tpe
           move tp-id to tp-id-tpe
           perform Execute-Appc-Verb.

      *-----------------------------------------------------------------
       Execute-Appc-Verb.
      *    interface to appc/acssvc uses load-time dynamic linking
      *    two methods may be employed:
      *        - to specify IMPORTS statements in .DEF file
      *        - to use ACS.LIB link library
      *
      *    (both methods are used in BATTLE.CMD)
      *
      *-----------------------------------------------------------------
           call "__APPC" using by reference vcb.

      *-----------------------------------------------------------------
       Execute-Acssvc-Verb.
      *
      *-----------------------------------------------------------------
           call "__ACSSVC" using by reference vcb.

      *-----------------------------------------------------------------
       Check-Error.
      *    if any error on the primary return code - convert error
      *    to hex display, display error, wait for key and exit program
      *
      *-----------------------------------------------------------------
           if prim-rc-vcb not = 0
               move opcode-vcb to bin-val
               perform bin-to-hexdisp
               move hex-disp to error-1
               move prim-rc-vcb to bin-val
               perform bin-to-hexdisp
               move hex-disp to error-2
               move sec-rc-vcb to bin-dword
               move bin-dword-msw to bin-val
               perform bin-to-hexdisp
               move hex-disp to error-3
               move bin-dword-lsw to bin-val
               perform bin-to-hexdisp
               move hex-disp to error-4
               call "cbl_clear_scr"
                   using clear-char
                         clear-attr
               call "cbl_set_csr_pos" using screen-pos
               display error-msg
               display "press any key to continue"
               call "cbl_read_kbd_char"
                   using key-char
               go to Error-Exit
           end-if.

      *-----------------------------------------------------------------
       Bin-to-Hexdisp.
      *    converts bin-val - a binary word value into a displayable
      *    hex value that can be inserted into the error message string
      *
      *-----------------------------------------------------------------
           divide bin-val-1 by 16
               giving hex-idx-1 remainder hex-idx-2
           add 1 to hex-idx-1 hex-idx-2
           move hex-string(hex-idx-1:1) to hex-disp(1:1)
           move hex-string(hex-idx-2:1) to hex-disp(2:1)
           divide bin-val-2 by 16
               giving hex-idx-1 remainder hex-idx-2
           add 1 to hex-idx-1 hex-idx-2
           move hex-string(hex-idx-1:1) to hex-disp(3:1)
           move hex-string(hex-idx-2:1) to hex-disp(4:1).

