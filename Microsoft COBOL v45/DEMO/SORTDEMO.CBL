      $set ans85 vsc2 nobound noqual noalter norw mf noms
      ************************************************************
      *                                                          *
      *                     SORTDEMO.CBL                         *
      *                                                          *
      *    This program demonstrates using API function calls    *
      *    in a COBOL program. A number of sort routines are     *
      *    also demonstrated:                                    *
      *        COBOL table, COBOL file, exchange, shell,         *
      *        insertion, heap, quick and bubble sorts.          *
      *                                                          *
      ************************************************************
      * Version: 1.5.5 (phase 4)
      *
      * Called Routines: DosBeep           - sounds the speaker
      *                  DosSleep          - delays program execution
      *                  VioGetConfig      - gets the hardware video
      *                                      configuration
      *                  VioGetMode        - gets the video mode
      *                  VioSetMode        - dets the video mode
      *                  VioWrtCharStrAtt  - writes a character string and
      *                                      attributes to the screen
      *                  VioWrtNCell       - writes one character and its
      *                                      attribute to the screen
      *                  KbdFlushBuffer    - flushes the keyboard buffer
      *                  KbdCharIn         - reads one character from the
      *                                      keyboard buffer
      *
      *****************************************************************
      *
      *
      * System Requirements:  IBM PC or compatible
      *                           running DOS 3.x
      *                       IBM PS/2 Model 30
      *                       IBM PC/AT or compatible
      *                       IBM PS/2 Model 50,60,70,80
      *                           running DOS 3.x or OS/2
      *
      *****************************************************************
      *
      * Compile and link notes: This program must be BOUND to run under
      *                         DOS.
      *
      *  Assuming the files for the COBOL compiler and Animator are
      *  correctly installed:
      *
      *    To compile, the following files must be present:
      *    ------------------------------------------------
      *        SORTDEMO.CBL
      *
      *    To link, the following files must be present:
      *    ---------------------------------------------
      *        LCOBOL.LIB   )(Must be in current directory, or available
      *        OS2.LIB      )(on the path defined by the LIB environment
      *                      (variable.
      *        LINK.EXE (OS/2 Linker)
      *
      *
      *    To bind (for use on DOS), the following files must be present:
      *    --------------------------------------------------------------
      *        API.LIB       (must be in current directory)
      *        BIND.EXE
      *        CBLBIND.LIB  )(can be in any directory which must be
      *        CBLBIND.NOT  )(specified on the BIND command line
      *        OS2.LIB      )
      *
      *
      *    For DOS
      *    -------
      *      compile the program as shown below:
      *           COBOL SORTDEMO.CBL OPTSPEED NOTRICKLE ;
      *
      *      then link (using OS/2 linker):
      *           LINK SORTDEMO/NOD,,,COBLIB+OS2;
      *      or
      *           LINK SORTDEMO/NOD,,,LCOBOL+OS2;
      *
      *      and bind (assuming all files in current directory):
      *           BIND SORTDEMO CBLBIND.LIB OS2.LIB -N @CBLBIND.NOT
      *
      *
      *    For OS/2,
      *    ---------
      *      compile the program as shown below:
      *           COBOL SORTDEMO.CBL OPTSPEED NOTRICKLE ;
      *
      *      then link:
      *           LINK SORTDEMO/NOD,,,COBLIB+OS2 ;
      *      or
      *           LINK SORTDEMO/NOD,,,LCOBOL+OS2 ;
      *
      *    To run on DOS or OS/2,
      *        SORTDEMO
      *
      *****************************************************************
      *
      * Animation notes:
      * ----------------
      *    When animating VIO API function calls, it is necessary to
      *    use the FLASH-CALLS directive to ensure that the user screen
      *    is written to by the VIO calls rather than the Animator
      *    screen. Try Animating with and without this directive to see
      *    the effect.
      *
      *-----------------------------------------------------------------
      *
      * To Animate the program (OS/2 only),
      * ----------------------------------
      *
      *      compile the program as shown below:
      *           COBOL SORTDEMO.CBL ANIM ;
      *
      *      Then, to animate:
      *           ANIMATE SORTDEMO FLASH-CALLS
      *
      *
      /
      *****************************************************************
       environment division.
       configuration section.
       special-names.
           call-convention 3 is api.

       input-output section.
       file-control.
           select sort-file assign to "sorttemp"
               sort status is sort-status.
       data division.
       file section.
       sd  sort-file.
       01  sort-rec.
           05  sort-key                pic 99.
           05  sort-color              pic x.
           05  sort-bar                pic x(50).

      *****************************************************************
       working-storage section.
      *****************************************************************
      *
      * Constants section
      *

       78  escape-key-pressed          value x"1b".
       78  up-arrow-scan-code          value 72.
       78  down-arrow-scan-code        value 80.

       78  cobol-table-line-number     value 4.
       78  cobol-line-number           value 5.
       78  exchange-line-number        value 6.
       78  quick-line-number           value 7.
       78  shell-line-number           value 8.
       78  heap-line-number            value 9.
       78  insert-line-number          value 10.
       78  bubble-line-number          value 11.
       78  randomize-line-number       value 13.
       78  sound-sw-line-number        value 15.
       78  speed-up-line-number        value 16.
       78  slow-down-line-number       value 17.
       78  speed-counter-line-number   value 19.
       78  prompt-line-number          value 22.
       78  message-line-number         value 25.

       78  cobol-table-literal         value "Cobol table".
       78  cobol-literal               value "cobol File".
       78  exchange-literal            value "Exchange".
       78  quick-literal               value "Quick".
       78  shell-literal               value "Shell".
       78  heap-literal                value "Heap".
       78  insert-literal              value "Insert".
       78  bubble-literal              value "Bubble".
       78  randomize-literal           value "Randomize".
      *
      * End of constants section
      *

       01  seed                        pic 9(12)   comp-5.
       01  mod                         pic 9(12)   comp-5.
       01  rand                        pic 9v9(11) comp-5.
       01  integer                     pic 999     comp-5.
       01  sort-status                 pic xx.

       01  stack-sub                   pic 9(4)    comp-5.
       01  upper-stack occurs 6 times  pic 9(4)    comp-5.
       01  lower-stack occurs 6 times  pic 9(4)    comp-5.
       01  pivot-element               pic 99      comp-5.

       01  array.
           05  a-data                  occurs      50 times.
               10  a-length            pic 99      comp-5.
               10  a-color             pic x.
               10  a-string            pic x(50).
       01  backup-array.
           05  ba-data                 occurs      50 times.
               10  ba-length           pic 99      comp-5.
               10  ba-color            pic x.
               10  ba-string           pic x(50).
       01  array-max                   pic 99      comp-5.
       01  sub                         pic 99      comp-5.
       01  sub-1                       pic 99      comp-5.
       01  sub-2                       pic 99      comp-5.
       01  sub-x                       redefines sub-2 pic x.
       01  max-loop                    pic 99      comp-5.
       01  last-element-saved          pic 99      comp-5.
       01  last-choice                 pic x       value space.

       01  swap-line                   pic 99      comp-5.
       01  swap-line-1                 pic 99      comp-5.
       01  temp-sub                    pic 99      comp-5.
       01  max-limit                   pic 99      comp-5.
       01  parent                      pic 99      comp-5.
       01  child                       pic 99      comp-5.
       01  smallest-line               pic 9(4)    comp-5.
       01  offset                      pic 99      comp-5.

       01  bar                         pic x(50)   value all x"dc".

       01  hold-array-element.
           05  h-length                pic 99      comp-5.
           05  h-color                 pic x.
           05  h-string                pic x(50).

       01  start-time.
           05  start-hr                pic 99.
           05  start-min               pic 99.
           05  start-sec               pic 99.
           05  start-hsec              pic 99.
           05  start-decimal           redefines   start-hsec pic v99.
       01  end-time.
           05  end-hr                  pic 99.
           05  end-min                 pic 99.
           05  end-sec                 pic 99.
           05  end-hsec                pic 99.
           05  end-decimal             redefines   end-hsec   pic v99.

       01  start-time-secs             pic 9(4)v99.
       01  end-time-secs               pic 9(4)v99.
       01  elapsed                     pic 9999v99.

       01  pause                       pic 9(4)    comp-5.
       01  pause-dword                 pic 9(8)    comp-5.
       01  frequency                   pic 9(4)    comp-5  value zeros.
       01  freq                        pic 9(4)    comp-5.

       01  time-screen-line            pic 99.

       01  updated-screen-sw           pic xxx     value "OFF".
       01  halt-sw                     pic xxx.
       01  auto-sound-toggle-sw        pic xxx     value "ON".

       01  hilite-screen-data-item.
           05  filler                  pic xx      value spaces.
           05  hilite-item             pic x(12).
           05  filler                  pic x       value space.
           05  disp-elapsed            pic x(7).
           05  filler                  pic x(6)    value spaces.

       01  edited-elapsed              pic zzzz.zz.
       01  edited-elapsed-red redefines edited-elapsed pic x(7).

       01  menu-screen-buffer-data.
        02 filler.
            05 filler  pic x(30) value "ษออออออออออออออออออออออออออออป".
            05 filler  pic x(30) value "บ    COBOL SORTING DEMO      บ".
            05 filler  pic x(30) value "บ                            บ".
            05 filler  pic x(30) value "บ  Cobol table               บ".
            05 filler  pic x(30) value "บ  cobol File                บ".
            05 filler  pic x(30) value "บ  Exchange                  บ".
            05 filler  pic x(30) value "บ  Quick                     บ".
            05 filler  pic x(30) value "บ  Shell                     บ".
            05 filler  pic x(30) value "บ  Heap                      บ".
            05 filler  pic x(30) value "บ  Insertion                 บ".
            05 filler  pic x(30) value "บ  Bubble                    บ".
            05 filler  pic x(30) value "บ                            บ".
            05 filler  pic x(30) value "บ  Randomize                 บ".
            05 filler  pic x(30) value "บ                            บ".
            05 filler  pic x(3)  value "บ  ".
            05 ms-toggle-sound-var
                       pic x(6)  value    "Toggle".
            05 filler  pic x(8)  value          " sound: ".
            05 sound-sw pic xxx value "OFF".
            05 filler  pic x(10) value                     "         บ".
      *     05 filler  pic x(30) value "บ                            บ".
        02 menu-screen-speed-up-line.
            05 filler  pic x(3)  value "บ  ".
            05 ms-speed-up-var pic x(24).
            05 filler  pic x(3)  value                            "  บ".
        02 menu-screen-slow-down-line.
            05 filler  pic x(3)  value "บ  ".
            05 ms-slow-down-var pic x(25).
            05 filler  pic xx    value                             " บ".
        02 filler.
            05 filler  pic x(30) value "บ                            บ".
            05 filler  pic x(23) value "บ  Speed (X/100 sec.): ".
            05 disp-pause pic zzz9.
            05 filler  pic x(3)  value                            "  บ".
            05 filler  pic x(30) value "บ                            บ".
            05 filler  pic x(30) value "บ Type first character of    บ".
        02 menu-screen-choice-line.
            05 filler  pic x(19) value "บ choice (CFEQSHIBR".
            05 ms-speed-up-char     pic x.
            05 ms-slow-down-char    pic x.
            05 ms-toggle-sound-char pic x.
            05 filler  pic x(8)  value                       "):     บ".
        02 filler.
            05 filler  pic x(30) value "บ or ESC key to end program: บ".
            05 filler  pic x(30) value "ศออออออออออออออออออออออออออออผ".

       01  menu-screen-buffer redefines menu-screen-buffer-data
                                       occurs 24 times.
           05 menu-screen-line         pic x(30).
       01  menu-screen-sub-max         pic 99       comp-5 value 24.
       01  menu-screen-sub             pic 99       comp-5.
       01  menu-screen-hilite-attr     pic x        value x"0f".
       01  menu-screen-normal-attr     pic x        value x"07".
       01  menu-screen-revvid-attr     pic x        value x"70".
       01  menu-screen-speed-up-msg    pic x(24)    value
               "< Will speed up the sort".
       01  menu-screen-slow-down-msg   pic x(25)    value
               "> Will slow down the sort".
       01  menu-screen-toggle-sound-msg pic x(6)    value
               "Toggle".
       01  menu-screen-speed-up-lit    pic x        value "<".
       01  menu-screen-toggle-sound-lit pic x        value "T".
       01  menu-screen-slow-down-lit   pic x        value ">".
       01  menu-screen-cobol-lit-tab   pic x(11)    value "Cobol table".
       01  menu-screen-cobol-lit       pic x(10)    value "cobol File".

       01  msg-line                    pic x(30).
       01  msg-attr                    pic x       value x"87".
       01  cobol-msg                   pic x(30)    value
               "Cobol sort only when speed = 0".
       01  wait-msg                    pic x(30)    value
               "        Please standby".

      /
      *****************************************************************
      *
      * General OS/2 parameters
      *
      *****************************************************************

       01  handle-zeros pic 9(4)       comp-5       value 0.
      *
      * screen-line = row, on screen, starting from 0.
      * screen-col  = Column, on screen, starting from 0.
      *
       01  screen-line                 pic 9(4) comp-5.
       01  screen-col                  pic 9(4) comp-5.
      *
      *****************************************************************
      * Parameters for VioWerNCell
      *****************************************************************
      *
      * VioWrtNCell writes one character and one attribute to the
      *    screen 'n' number of times.
      *
      * The field "NUM-CHARS-ON-SCREEN" = the number of times
      *                                   to write the character/
      *                                   attribute to the
      *                                   screen.
      *
       01  viowrtncell-data.
           05  viowrtncell-char        pic x        value space.
           05  viowrtncell-attr        pic x        value x"07".
       01  viowrtncell-count           pic 9(4)     comp-5.
       01  num-chars-on-screen         pic 9(4)     comp-5.
      *
      *****************************************************************
      * Parameters for VioWrtCharStrAtt
      *****************************************************************
      *
      * VioWrtCharStrAtt writes a string and its attributes to the
      *    screen.
      *
      * The data item "VIOWRTCHARSTRATT-LENGTH" = the number of
      *                                           characters and
      *                                           attributes to
      *                                           write.
      *
       01  viowrtcharstratt-data       pic x(50).
       01  viowrtcharstratt-attr       pic x.
       01  viowrtcharstratt-length     pic 9(4) comp-5 value 50.
      *
      *****************************************************************
      * Parameter for VioGetConfig
      *****************************************************************
      *
      * VioGetConfig identifies the type of video card and video
      *    monitor on the target machine.
      *
      * The field "VIOGETCONFIG-LENGTH" specifies the length,
      *    in words, of the group item "VIOGETCONFIG".
      *
      * The field "VIOGETCONFIG-ADAPTER" specifies the type of
      *    video card you have:
      *                        = 0 = monochrome
      *                        = 1 = CGA
      *                        = 2 = EGA
      *                        = 3 = VGA
      *                        = 7 = PS/2 adapter 8514/A
      *
      * The field "VIOGETCONFIG-DISPLAY specifies the type of
      *    computer monitor you have:
      *                        = 0 = monochrome
      *                        = 1 = CGA
      *                        = 2 = EGA
      *                        = 3 = PS/2 monochrome 8503
      *                        = 4 = PS/2 color 8512/8513
      *                        = 9 = PS/2 color 8514
      *
       01  viogetconfig-data.
           05  viogetconfig-length     pic 9(4) comp-5 value 10.
           05  viogetconfig-adapter    pic 9(4) comp-5.
           05  viogetconfig-display    pic 9(4) comp-5.
           05  filler                  pic 9(8) comp-5.
      *
      *****************************************************************
      * Parameters for VioGetMode and VioSetMode
      *****************************************************************
      *
      * This parameter to the routine (VioGetMode and VioSetMode) that
      *    identifies the software video mode.
      * This information is needed to determine
      *    how many columns, rows and colors the video adapter and
      *    monitor can handle.
      *                                                                 .
      * The field "VIOMODE-LENGTH" specifies the length,
      *    in words, of the group item "VIOMODE-DATA".
      *
      * The fields returned are as follows:
      * -----------------------------------
      *
      *       VIOMODE-MODE will = 1 if the target machine is in color mode.
      *                         = 0 if the target machine in monochrome mode.
      *       VIOMODE-COLORS will = 0 if the number of available colors = 2
      *                           = 2 if the number of available colors = 16
      *                  The number of colors available is controlled
      *                    by the type of adapter and monitor.
      *                    A monochrome adapter has only 2 available
      *                    colors; a color graphics system can have
      *                    a maximum of 16 colors.
      *
      *       VIOMODE-COLS = the number of text columns available to the
      *                    program.
      *       VIOMODE-ROWS = the number of text rows available to the
      *                    program.
      *
       01  viomode-data.
           05  viomode-length          pic 9(4) comp-5 value 8.
           05  viomode-mode            pic 99 comp-5.
           05  viomode-colors          pic 99 comp-5.
           05  viomode-cols            pic 9(4) comp-5.
           05  viomode-rows            pic 9(4) comp-5.
      *
      *****************************************************************
      * This area saves the original video mode data. After the
      *   program is finished,the user's video mode will be restored.
      *****************************************************************
      *
       01  viomode-save-data           pic x(16).
      *
      *****************************************************************
      * Parameters for KbdCharIn
      *****************************************************************
      *
      * KbdCharIn gets one character from the keyboard buffer with no
      *   echo.
      *
      * KBDCHARIN-CHAR = the character from the keyboard buffer.
      *
      * KBDCHARIN-SCAN = the scan code of the character.
      *
      * KBDCHARIN-WAIT-FLAG = 0 = instructs the function to wait
      *                            until there is character
      *                            available.
      *                     = 1 = don't wait for a character if
       01  kbdcharin-wait-flag         pic 9(4)    comp-5  value 0.
       01  kbdcharin-data.
           05  kbdcharin-char          pic x.
           05  kbdcharin-scan          pic 99      comp-5.
           05  kbdcharin-status        pic 99      comp-5.
           05  filler                  pic 9(14)   comp-5.


      /
      *****************************************************************
       procedure division.
      *****************************************************************
       10000-start-section section.
       10000-start.
           perform 20000-initialize
           perform 21000-get-character
           perform 30000-sort-and-input-loop thru 30000-exit
              until kbdcharin-char = escape-key-pressed
           perform 40000-restore-users-video-mode
           perform 20400-clear-the-screen
           stop run.
       10000-exit.
           exit.

      /
      *****************************************************************
       20000-initialize.
      *****************************************************************
           move 0 to pause
           move pause to disp-pause
           move spaces to ms-speed-up-var
           move spaces to ms-toggle-sound-var
           move menu-screen-slow-down-msg to ms-slow-down-var
           move space to ms-speed-up-char
           move space to ms-toggle-sound-char
           move menu-screen-slow-down-lit to ms-slow-down-char
           perform 20100-get-video-config-info
           perform 20200-get-video-mode
           perform 20300-set-video-mode
           perform 20400-clear-the-screen
           perform 20500-flush-kbd-buffer
           perform 20600-init-unsorted-array
           perform 20700-display-unsorted-bars
           perform 20800-display-menu-screen.
       20000-exit.
           exit.
      *****************************************************************
       20100-get-video-config-info.
      *****************************************************************
      *
      * Get the video configuration of the machine. This determines
      *   whether or not to use color display attributes and how many
      *   bars can be displayed.
      *
      * All OS/2 API functions are called like far PASCAL routines:
      * i.e. you must supply the parameters in reverse order or use
      * call-convention 3. We use call-convention 3, having called it
      * api. Also, the API names must be LITLINKED so that they will be
      * satisfied at link time by referencing OS2.LIB. In order to
      * force this for each name, the name must be prefixed by
      * double-underscore ("__").
      *
           call api "__VioGetConfig" using
               by value     handle-zeros
               by reference viogetconfig-data
               by value     handle-zeros
           if return-code not = zeros
               display "ERROR IN VioGetConfig"
               go to 99999-os2-error-abort.
       20100-exit.
           exit.

      *****************************************************************
       20200-get-video-mode.
      *****************************************************************
      *
      * Get the current video mode.
      *
           call api "__VioGetMode" using
               by reference viomode-data
               by value     handle-zeros
           if return-code not = zeros
               display "ERROR IN VioGetMode"
               go to 99999-os2-error-abort
           end-if
      *
      * Save the current mode data to restore the user's
      *    mode at the end of the job.
      *
           move viomode-data to viomode-save-data.
       20200-exit.
           exit.

      *****************************************************************
       20300-set-video-mode.
      *****************************************************************
      *
      * Set the video mode.
      *
           evaluate viogetconfig-adapter
               when 0 perform 20322-set-mono-video-mode
               when 1 perform 20324-set-cga-video-mode
               when 2 perform 20326-set-ega-video-mode
               when 3 perform 20328-set-vga-video-mode
               when 7 perform 20328-set-vga-video-mode
               when other
                   display "ERROR - UNRECOGNISED VIDEO ADAPTER"
                   go to 99999-os2-error-abort
           end-evaluate
           move 80 to viomode-cols
           perform 20330-call-viosetmode
           if return-code not = zeros
               display "ERROR IN SETTING VIDEO MODE"
               go to 99999-os2-error-abort
           end-if.
       20300-exit.
           exit.

      *****************************************************************
       20322-set-mono-video-mode.
      *****************************************************************
           move 25 to viomode-rows
           move 0 to viomode-mode
           move 0 to viomode-colors
           move 2000 to num-chars-on-screen.
       20322-exit.
           exit.

      *****************************************************************
       20324-set-cga-video-mode.
      *****************************************************************
      *
      * If a CGA adapter but a monochrome screen, setup
      *    in monochrome mode.
      *
           if viogetconfig-display = zeros
               perform 20322-set-mono-video-mode
           else
               move 25 to viomode-rows
               move 1 to viomode-mode
               move 4 to viomode-colors
               move 2000 to num-chars-on-screen
           end-if.
       20324-exit.
           exit.

      *****************************************************************
       20326-set-ega-video-mode.
      *****************************************************************
      *
      * If a EGA adapter but a monochrome screen, setup
      *    in monochrome mode.
      *
           if viogetconfig-display = zeros
               perform 20322-set-mono-video-mode
           else
               move 43 to viomode-rows
               move 1 to viomode-mode
               move 4 to viomode-colors
               move 3440 to num-chars-on-screen
           end-if.
       20326-exit.
           exit.

      *****************************************************************
       20328-set-vga-video-mode.
      *****************************************************************
      *
      * If a VGA adapter but a monochrome screen, setup
      *    in monochrome mode.
      *
           if viogetconfig-display = zeros
               perform 20322-set-mono-video-mode
           else
               move 50 to viomode-rows
               move 1 to viomode-mode
               move 4 to viomode-colors
               move 4000 to num-chars-on-screen
           end-if.
       20328-exit.
           exit.

      *****************************************************************
       20330-call-viosetmode.
      *****************************************************************
      *
      * Sets the video mode.
      *
      * Inputs to the routine are the following:
      *
      *    viomode-data = Contains the video mode data
      *
           call api "__VioSetMode" using
               by reference viomode-data
               by value     handle-zeros.
       20330-exit.
           exit.

      *****************************************************************
       20400-clear-the-screen.
      *****************************************************************
      *
      * Clear the screen by writing 1 space to every character position
      *    on the screen.
      *
           move 0 to screen-line
           move 0 to screen-col
           move num-chars-on-screen to viowrtncell-count
      *
      * VioWrtNCell writes one character and attribute, (a single
      *    character and its attribute are refered to as a "cell")
      *    to the screen 'viowrtncell-count' times.
      *
           call api "__VioWrtNCell" using
               by reference viowrtncell-data
               by value     viowrtncell-count
               by value     screen-line
               by value     screen-col
               by value     handle-zeros
           if return-code not = zeros
               display "ERROR IN CLEARING THE SCREEN"
               go to 99999-os2-error-abort
           end-if.
       20400-exit.
           exit.

      *****************************************************************
       20500-flush-kbd-buffer.
      *****************************************************************
      *
      * Flushes the keyboard buffer.
      *
           call api "__KbdFlushBuffer" using
               by value handle-zeros
           if return-code not = zeros
               display "ERROR IN FLUSHING THE KEYBOARD BUFFER"
               go to 99999-os2-error-abort.
       20500-exit.
           exit.

      /
      *****************************************************************
       20600-init-unsorted-array.
      *****************************************************************
      *
      * Initialize the arrays "ARRAY" and "BACKUP-ARRAY" with
      *    the length of each bar on the screen, and the color of
      *    each bar.
      *
      * "Array" is used as a scratch area. Each entry in the array
      *    is initialized with a value from 1 to the maximum number
      *    screen lines. When we picking random numbers, they must
      *    be between 1 and the maximum number of screen lines. In
      *    picking a random number, use the random number as an
      *    index into "array" and zero out that entry. In this way, it
      *    will be known that the random number is chosen.
      *    For example, if random number "5" is picked, zeros are moved
      *    to "a-length (5)". If random number "5" is picked
      *    again, it can seen that "a-length (5)" = zeros and it is
      *    therefore known that the number "5" has been
      *    previously chosen and another must be generated.
      *
           move viomode-rows to array-max
           perform varying sub from 1 by 1
                   until sub > array-max
               move sub to a-length (sub)
           end-perform
      *
      * Initialize the random number seed.
      *
           perform 20610-get-starting-time
           compute seed = start-time-secs / 86400 * 259199
      *
           perform varying sub from 1 by 1
                   until sub > array-max
      *
      * Pick a random number (integer).
      *
               perform 20620-get-random-integer
      *
      * Continue to generate random numbers until one is generated
      *    that has not been picked before.
      *
               perform 20620-get-random-integer thru 20620-exit
                   until a-length (integer) not = zeros
      *
      * A unique random number (integer) is chosen. Initialize
      *    length and color fields of the backup array.
      *
               move a-length (integer) to ba-length (sub)
               move zero to a-length (integer)
               move ba-length (sub) to sub-2
               move bar (1:sub-2) to ba-string (sub)
               if viomode-colors = 0
                   move x"07" to sub-x
               end-if
               perform until sub-2 < 16
                   subtract 15 from sub-2
               end-perform
               inspect ba-color (sub)
                   replacing characters by sub-x
           end-perform.
       20600-exit.
           exit.

      *****************************************************************
       20610-get-starting-time.
      *****************************************************************
      *
      * Accepts the system time and computes the number of seconds
      *   since midnight.
      *
           accept start-time from time
           compute start-time-secs = ((start-hr * 60) * 60)
                                        + (start-min * 60)
                                        + start-sec
                                        + start-decimal.
       20610-exit.
           exit.


      *****************************************************************
       20620-get-random-integer.
      *****************************************************************
      *
      * Compute a random number integer (integer).
      *
           compute mod = seed * 7141 + 54773
           divide mod by 259119 giving mod remainder seed
           compute rand = seed / 259119
           compute integer = 1 + (array-max) * rand.
       20620-exit.
           exit.

      *****************************************************************
       20700-display-unsorted-bars.
      *****************************************************************
      *
      * Displays the unsorted bars on the screen.
      *
           move 50 to viowrtcharstratt-length
           move 0 to screen-col
           perform varying sub from 1 by 1
                   until sub > array-max
               move ba-data (sub) to a-data (sub)
               compute screen-line = sub - 1
               move a-string (sub) to viowrtcharstratt-data
               move a-color (sub) to viowrtcharstratt-attr
               perform 20710-call-viowrtcharstratt
           end-perform
           if msg-line not = spaces
               move spaces to msg-line
               perform 30110-update-message-line
           end-if.
       20700-exit.
           exit.

      *****************************************************************
       20705-display-sorted-bars.
      *****************************************************************
      *
      * Displays the sorted bars on the screen.
      *
           move 50 to viowrtcharstratt-length
           move 0 to screen-col
           perform varying sub from 1 by 1
                   until sub > array-max
               compute screen-line = sub - 1
               move a-string (sub) to viowrtcharstratt-data
               move a-color (sub) to viowrtcharstratt-attr
               perform 20710-call-viowrtcharstratt
           end-perform
           if msg-line not = spaces
               move spaces to msg-line
               perform 30110-update-message-line
           end-if.
       20705-exit.
           exit.

      *****************************************************************
       20710-call-viowrtcharstratt.
      *****************************************************************
      *
      * Writes a string and its attributes the the screen.
      *
      * The following inputs must be initialized:
      *
      *               : viowrtcharstratt-data with the
      *                    string one wants to write
      *               : viowrtcharstratt-att with the
      *                    attribute characters one wants
      *                    to write. Note that the first
      *                    attribute is used for every
      *                    character to write.
      *               : viowrtcharstratt-length =
      *                    length of the string (and
      *                    attribute) to write.
      *               : screen-line = the screen row to
      *                    to write on, starting from 0.
      *               : screen-col = the screen column to
      *                    write on starting from 0.
      *
           call api "__VioWrtCharStrAtt" using
                by reference viowrtcharstratt-data
                by value     viowrtcharstratt-length
                by value     screen-line
                by value     screen-col
                by reference viowrtcharstratt-attr
                by value     handle-zeros
           if return-code not = zeros
               display "ERROR IN VioWrtCharStrAtt"
               go to 99999-os2-error-abort.
       20710-exit.
           exit.

      *****************************************************************
       20800-display-menu-screen.
      *****************************************************************
      *
      * Displays the menu screen.
      *
           move 50 to screen-col
           move 30 to viowrtcharstratt-length
           move menu-screen-hilite-attr to viowrtcharstratt-attr
           perform varying menu-screen-sub from 1 by 1
                   until menu-screen-sub > menu-screen-sub-max
               compute screen-line = menu-screen-sub - 1
               move menu-screen-line (menu-screen-sub) to
                       viowrtcharstratt-data
               perform 20710-call-viowrtcharstratt
           end-perform
      *
      * Write the "COBOL" sort line in a different attribute, if
      *    necessary.
      *
           if pause not = 0
               perform 20810-unhilite-cobol-sort
           end-if
      *
      * Clear the message line.
      *
           move spaces to viowrtcharstratt-data
           compute screen-line = message-line-number - 1
           perform 20710-call-viowrtcharstratt.
       20800-exit.
           exit.

      ******************************************************************
       20810-unhilite-cobol-sort.
      *****************************************************************
      *
      * Print "Cobol" on the menu, in dim attributes. Because
      *    it is printed with dim attributes, this indicates
      *    that the option may not chosen.
      *

           compute screen-line = cobol-table-line-number - 1
           move 51 to screen-col
           move spaces to hilite-screen-data-item
           move menu-screen-cobol-lit-tab to hilite-item
           move menu-screen-normal-attr to viowrtcharstratt-attr
           move hilite-screen-data-item to viowrtcharstratt-data
           move 28 to viowrtcharstratt-length
           perform 20710-call-viowrtcharstratt.
           compute screen-line = cobol-line-number - 1
           move 51 to screen-col
           move spaces to hilite-screen-data-item
           move menu-screen-cobol-lit to hilite-item
           move menu-screen-normal-attr to viowrtcharstratt-attr
           move hilite-screen-data-item to viowrtcharstratt-data
           move 28 to viowrtcharstratt-length
           perform 20710-call-viowrtcharstratt.
       20810-exit.
           exit.

      *****************************************************************
       21000-get-character.
      *****************************************************************
      *
      * Get a character from the keyboard (with no echo).
      *
           call api "__KbdCharIn" using
               by reference kbdcharin-data
               by value     kbdcharin-wait-flag
               by value     handle-zeros
           if return-code not = zeros
               display "ERROR IN KbdCharIn"
               go to 99999-os2-error-abort.
       21000-exit.
           exit.

      /
      *****************************************************************
       30000-sort-and-input-loop.
      *****************************************************************
      *
      * A character (kbdcharin-char) has been input. If it is a
      *    recognized character, act on it; else, get another.
      *
      * Performed until kbdcharin-char = hex 1B
      *    (i.e. the ESCAPE key is pressed).
      *
           evaluate true
               when kbdcharin-char = "C" or "c"
                   perform 30150-cobol-table-sort
               when kbdcharin-char = "F" or "f"
                   perform 30100-cobol-sort
               when kbdcharin-char = "E" or = "e"
                   perform 30200-exchange-sort
               when kbdcharin-char = "Q" or = "q"
                   perform 30300-quick-sort
               when kbdcharin-char = "S" or = "s"
                   perform 30400-shell-sort
               when kbdcharin-char = "H" or = "h"
                   perform 30500-heap-sort
               when kbdcharin-char = "I" or = "i"
                   perform 30600-insert-sort
               when kbdcharin-char = "B" or = "b"
                   perform 30700-bubble-sort
               when kbdcharin-char = ">" or = "."
                   perform 30800-slow-down-the-sort
               when kbdcharin-char = "<" or = ","
                   perform 30900-speed-up-the-sort
               when kbdcharin-char = "T" or = "t"
                   perform 31000-toggle-sound
               when kbdcharin-char = "R" or "r"
                   perform 31100-randomize-array
           end-evaluate
      *
      * Check for up arrow and down arrow keystrokes.
      *
           evaluate true
            also true
               when kbdcharin-char = x"00" or = x"e0"
                also kbdcharin-scan = up-arrow-scan-code
                   perform 31200-select-previous-choice
               when kbdcharin-char = x"00" or = x"e0"
                also kbdcharin-scan = down-arrow-scan-code
                   perform 31300-select-next-choice
           end-evaluate
      *
      * Get next keystroke from the user
      *
           perform 21000-get-character.
       30000-exit.
           exit.

      ****************************************************************
       30100-cobol-sort.
      ****************************************************************
      *
      * This routine will perform a COBOL file sort.
      *
      * Note that a COBOL sort will only be performed if the program is
      *    running at full speed, i.e., pause = 0 (the "<" key was
      *    typed until the speed, as displayed on the menu screen, =
      *    zeros).
      *
           if pause not = 0
               move cobol-msg to msg-line
               perform 30110-update-message-line
           else
               move kbdcharin-char to last-choice
               if msg-line not = spaces
                   move spaces to msg-line
                   perform 30110-update-message-line
               end-if
      *
      * Highlight the entry.
      *
               move spaces to hilite-screen-data-item
               move zeros to elapsed
               move cobol-line-number to time-screen-line
               move cobol-literal to hilite-item
               move menu-screen-revvid-attr to viowrtcharstratt-attr
               perform 30120-write-time-on-screen
               move "ON" to updated-screen-sw
               perform 20700-display-unsorted-bars
               perform 20610-get-starting-time
      *
               sort sort-file
                   on ascending key sort-key
                   input procedure is sort-input-procedure-section
                   output procedure is sort-output-procedure-section
      *
      * The sort has completed.  Now, clear the highlight around
      *    the elapsed time.
      *
               perform 30140-clear-time-hilight
           end-if.
       30100-exit.
           exit.

      *****************************************************************
       30110-update-message-line.
      *****************************************************************
      *
      * This section of code writes the "error msg" line to the screen.
      *
           move msg-attr to viowrtcharstratt-attr
           move msg-line to viowrtcharstratt-data
           move 30 to viowrtcharstratt-length
           compute screen-line = message-line-number - 1
           move 50 to screen-col
           perform 20710-call-viowrtcharstratt.
       30110-exit.
           exit.

      *****************************************************************
       30120-write-time-on-screen.
      *****************************************************************
      *
      * Writes the elapsed time to the screen.
      *
      * Inputs to this routine are the following:
      *
      *    elapsed = the elapsed time in seconds.
      *    viowrtcharstratt-attr = the attribute to use when the
      *                                elapsed time is written to the
      *                                screen.
      *    time-screen-line = the screen line to write on.
      *
           move 28 to viowrtcharstratt-length
           move elapsed to edited-elapsed
           move edited-elapsed-red to disp-elapsed
           compute screen-line = time-screen-line - 1
           move 51 to screen-col
           move hilite-screen-data-item to viowrtcharstratt-data
           perform 20710-call-viowrtcharstratt.
       30120-exit.
           exit.

      *****************************************************************
       30130-update-time-on-screen.
      *****************************************************************
      *
      * Updates the screen with the elapsed time.
      *
      * Inputs to this routine are the following:
      *
      *    start-time-secs = The start time, in seconds.
      *    time-screen-line = The screen line (relative from 0) to
      *                          write the elapsed time on.
      *
           accept end-time from time
           compute end-time-secs = ((end-hr * 60) * 60)
                                      + (end-min * 60)
                                      + end-sec
                                      + end-decimal
           compute elapsed = end-time-secs - start-time-secs
           move menu-screen-revvid-attr to viowrtcharstratt-attr
           perform 30120-write-time-on-screen.
       30130-exit.
           exit.

      *****************************************************************
       30140-clear-time-hilight.
      *****************************************************************
      *
      * Clears the highlight attribute around the elapsed time.
      *
           move menu-screen-hilite-attr to viowrtcharstratt-attr
           perform 30120-write-time-on-screen.
       30140-exit.
           exit.
      /
      ******************************************************************
       30150-cobol-table-sort.
      ******************************************************************
      *
      * This routine will perform a sort using the MF table sort.
      *
      * The program must be running at full speed for this option to be
      *    accepted.
      *
           if pause not = 0
               move cobol-msg to msg-line
               perform 30110-update-message-line
           else
               move kbdcharin-char to last-choice
               if msg-line not = spaces
                   move spaces to msg-line
                   perform 30110-update-message-line
               end-if
      *
      * Highlight the entry
      *
               move spaces to hilite-screen-data-item
               move zeros to elapsed
               move cobol-table-line-number to time-screen-line
               move cobol-table-literal to hilite-item
               move menu-screen-revvid-attr to viowrtcharstratt-attr
               perform 30120-write-time-on-screen
               move "ON" to updated-screen-sw
               perform 20700-display-unsorted-bars
               perform 20610-get-starting-time
      *
               sort a-data on ascending a-length
      *
               perform 20705-display-sorted-bars
               perform 30130-update-time-on-screen
               perform 30140-clear-time-hilight
           end-if.
       30150-exit.
           exit.
      /
      *****************************************************************
       30200-exchange-sort.
      *****************************************************************
      *
      * The exchange sort (starting with the first element in the
      *    array) compares each element of array with every
      *    following element. If any of the following elements are
      *    smaller the the current element, swap the 2 elements.
      *    Continue through the array to the end.
      *
           move kbdcharin-char to last-choice
           move exchange-line-number to time-screen-line
           move exchange-literal to hilite-item
           move "ON" to updated-screen-sw
           perform 20700-display-unsorted-bars
           perform 20610-get-starting-time
           perform varying sub from 1 by 1
                   until sub > array-max
               move sub to smallest-line
               compute temp-sub = sub + 1
               perform varying sub-1 from temp-sub by 1
                       until sub-1 > array-max
                   if a-length (sub-1) <
                           a-length (smallest-line)
                       move sub-1 to smallest-line
                   end-if
               end-perform
               if smallest-line > sub
                   move sub to swap-line
                   move smallest-line to swap-line-1
                   perform 30210-swap-two-bars
               end-if
           end-perform
      *
      * The sort is complete. Clear the screen highlight
      *    around the elapsed time.
      *
           perform 30140-clear-time-hilight.
       30200-exit.
           exit.

      *****************************************************************
       30210-swap-two-bars.
      *****************************************************************
      *
      * Swaps two elements in array and updatesthe screen.
      *
      * Inputs to this routine are the following:
      *
      *    swap-line
      *       = specifies the subscript of one member to swap.
      *    swap-line-1
      *       = specifies the subscript of the other member to
      *            swap.
      *
           move a-data (swap-line) to hold-array-element
           move a-data (swap-line-1) to a-data (swap-line)
           move hold-array-element to a-data (swap-line-1)

           compute screen-line = swap-line - 1
           move 0 to screen-col
           move swap-line to freq
           perform 30220-write-one-bar-to-screen

           compute screen-line = swap-line-1 - 1
           move 0 to screen-col
           move swap-line-1 to freq
           perform 30220-write-one-bar-to-screen.
       30210-exit.
           exit.

      *****************************************************************
       30220-write-one-bar-to-screen.
      *****************************************************************
      *
      * Writes one bar to the screen.
      *
      * Inputs to this routine are the following:
      *
      *       array = contains one element to be written
      *       freq = subscript into the array
      *       screen-col = col number, minus 1, on screen to write to
      *       screen-line = line number, minus 1, to write to
      *
           move 50 to viowrtcharstratt-length
           move a-string (freq) to viowrtcharstratt-data
           move a-color (freq) to viowrtcharstratt-attr
           perform 20710-call-viowrtcharstratt
           perform 30230-call-dos-beep
           perform 30130-update-time-on-screen.
       30220-exit.
           exit.

      *****************************************************************
       30230-call-dos-beep.
      *****************************************************************
      *
      * Beeps the speaker.
      *
      * Inputs to this routine are the following:
      *
      *       PAUSE = The number of 1/100 second increments to sound
      *                    the speaker.
      *       FREQ  = The frequency in hertz to beep.
      *
           if pause not = zeros
               move pause to pause-dword
               if sound-sw = "ON "
                   compute frequency = 50 * a-length (freq)
                   multiply 8 by pause
                   call api "__DosBeep" using
                       by value frequency
                       by value pause
                   move pause-dword to pause
               else
                   multiply 8 by pause-dword
                   call api "__DosSleep" using by value pause-dword
               end-if
           end-if.
       30230-exit.
           exit.

      /
      *****************************************************************
       30300-quick-sort.
      *****************************************************************
      *
      * The quick sort routine works by picking a "pivot" element in
      *    the array. It will move all larger elements to one
      *    side of the pivot and all smaller elements to the other
      *    side. The subscript information of the 2 members just
      *    swapped then is saved on a stack; the routine is entered
      *    again. This is repeated until the stack is exhasted.
      *
           move kbdcharin-char to last-choice
           move quick-line-number to time-screen-line
           move quick-literal to hilite-item
           move "ON" to updated-screen-sw
           perform 20700-display-unsorted-bars
           perform 20610-get-starting-time
           move 1 to lower-stack (1)
           move array-max to upper-stack (1)
           move 1 to stack-sub
           perform until stack-sub = zeros
               if lower-stack (stack-sub) not <
                                 upper-stack (stack-sub)
                   subtract 1 from stack-sub
               else
                   move lower-stack (stack-sub) to sub
                   move upper-stack (stack-sub) to sub-1
                   move a-length (sub-1) to pivot-element
                   perform 30310-select-member-to-swap thru 30310-exit
                       until sub not < sub-1
                   move upper-stack (stack-sub) to sub-1
                   move upper-stack (stack-sub) to swap-line
                   move sub to swap-line-1
                   perform 30210-swap-two-bars
                   perform 30320-adjust-stack
                   add 1 to stack-sub
               end-if
           end-perform
      *
      *    The sort is completed. Clear the screen highlight around
      *      the elapsed time.
      *
           perform 30140-clear-time-hilight.
       30300-exit.
           exit.

      *****************************************************************
       30310-select-member-to-swap.
      *****************************************************************
      *
      * performed until sub not < sub-1
      *
           perform until ((sub not < sub-1)
                       or (a-length (sub) > pivot-element))
               add 1 to sub
           end-perform
           perform until ((sub not < sub-1)
                       or (a-length (sub-1) < pivot-element))
               subtract 1 from sub-1
           end-perform
           if sub < sub-1
               move sub to swap-line
               move sub-1 to swap-line-1
               perform 30210-swap-two-bars
           end-if.
       30310-exit.
           exit.

      *****************************************************************
       30320-adjust-stack.
      *****************************************************************
           if (sub - lower-stack (stack-sub)) <
                      (upper-stack (stack-sub) - sub)
               move lower-stack (stack-sub) to
                    lower-stack (stack-sub + 1)
               compute upper-stack (stack-sub + 1) = sub - 1
               compute lower-stack (stack-sub) = sub + 1
           else
               compute lower-stack (stack-sub + 1) = sub + 1
               move upper-stack (stack-sub) to
                    upper-stack (stack-sub + 1)
               compute upper-stack (stack-sub) = sub - 1
           end-if.
       30320-exit.
           exit.

      /
      *****************************************************************
       30400-shell-sort.
      *****************************************************************
      *
      * The shell sort begins by (1) comparing far-apart elements
      *    (separated by the value of the offset variable, which is
      *    initially half the distance between the first and the last
      *    elements), and then by (2) comparing closer elements.
      *    When offset = 1, a bubble sort is being performed.
      *
           move kbdcharin-char to last-choice
           move shell-line-number to time-screen-line
           move shell-literal to hilite-item
           move "ON" to updated-screen-sw
           perform 20700-display-unsorted-bars
           perform 20610-get-starting-time
           compute offset = array-max / 2
           perform until offset < 1
               compute max-limit = array-max - offset
               move 1 to sub-2
               perform until sub-2 < 1
                   move zeros to sub-2
                   perform varying sub-1 from 1 by 1
                           until sub-1 > max-limit
                       compute swap-line-1 = sub-1 + offset
                       if a-length (sub-1) >
                                a-length (swap-line-1)
                           move sub-1 to swap-line
                           perform 30210-swap-two-bars
                           move sub-1 to sub-2
                       end-if
                   end-perform
                   compute max-limit = sub-1 - offset
               end-perform
               compute offset = offset / 2
           end-perform
      *
      * The sort has completed. Clear the screen highlight
      *    around the elapsed time.
      *
           perform 30140-clear-time-hilight.
       30400-exit.
           exit.

      /
      *****************************************************************
       30500-heap-sort.
      *****************************************************************
      *
      * The heap sort calls two other procedures: "30510-percolate-up"
      *    and "30520-percolate-down".
      * The percolate-up procedure turns array into a "heap" as shown
      *    below:
      *
      *                          array(1)
      *                         /        \
      *                 array(2)          array(3)
      *                 /      \          /      \
      *            array(4)  array(5)  array(6)  array(7)
      *            /      \  /      \  /      \  /      \
      *          ...     ......    ......    ......     ...
      *
      *     where each "PARENT" (e.g. array(1), array(2)...) is larger
      *          than its "CHILD" [e.g. array(1) is a parent for
      *          array(2)].
      *
      *     Therefore, after the first "PERFORM VARYING", the largest
      *          array member will be in array(1).
      *
      * The second "PERFORM VARYING" swaps the element in array(1) with
      *    the element in the variable "ARRAY-MAX", rebuilds the
      *    heap with percolate-down for array-max - 1 and loops.
      *    This is continued until the array is sorted.
      *
           move kbdcharin-char to last-choice
           move heap-line-number to time-screen-line
           move heap-literal to hilite-item
           move "ON" to updated-screen-sw
           perform 20700-display-unsorted-bars
           perform 20610-get-starting-time
           perform varying sub from 2 by 1
                   until sub > array-max
               perform 30510-percolate-up
           end-perform
           perform varying sub from array-max by -1
                   until sub < 2
               move sub to swap-line
               move 1 to swap-line-1
               perform 30210-swap-two-bars
               compute sub-1 = sub - 1
               perform 30520-percolate-down
           end-perform
      *
      * The sort is completed. now, clear the screen highlight
      *    around the elapsed time.
      *
           perform 30140-clear-time-hilight.
       30500-exit.
           exit.

      *****************************************************************
       30510-percolate-up.
      *****************************************************************
           move sub to sub-2
           move "OFF" to halt-sw
           perform until ((sub-2 = 1)
                       or (halt-sw = "ON"))
               compute parent = sub-2 / 2
               if a-length (sub-2) > a-length (parent)
                   move parent to swap-line
                   move sub-2 to swap-line-1
                   perform 30210-swap-two-bars
                   move parent to sub-2
               else
                   move "ON" to halt-sw
               end-if
           end-perform.
       30510-exit.
           exit.

      *****************************************************************
       30520-percolate-down.
      *****************************************************************
           move 1 to sub-2
           move "OFF" to halt-sw
           perform until halt-sw = "ON"
               compute child = 2 * sub-2
               if child > sub-1
                   move "ON" to halt-sw
               else
                   compute swap-line = child + 1
                   if swap-line not > sub-1
                       if a-length (swap-line) >
                                a-length (child)
                           compute child = child + 1
                       end-if
                   end-if
                   if a-length (sub-2) < a-length (child)
                       move sub-2 to swap-line
                       move child to swap-line-1
                       perform 30210-swap-two-bars
                       move child to sub-2
                   else
                       move "ON" to halt-sw
                   end-if
               end-if
           end-perform.
       30520-exit.
           exit.

      /
      *****************************************************************
       30600-insert-sort.
      *****************************************************************
      *
      * The insert sort compares the length of each successive element
      *    in array with the lengths of all the preceding elements.
      *    When the proper place in the array for the element is
      *    found insert the element and move all following elements
      *    down one place.
      *
           move kbdcharin-char to last-choice
           move insert-line-number to time-screen-line
           move insert-literal to hilite-item
           move "ON" to updated-screen-sw
           perform 20700-display-unsorted-bars
           perform 20610-get-starting-time
           perform varying sub from 2 by 1
                   until sub > array-max
               move "OFF" to halt-sw
               move a-data (sub) to hold-array-element
               move sub to sub-1
               perform until ((sub-1 < 2)
                          or (halt-sw = "ON"))
                   if a-length (sub-1 - 1) > h-length
                       move a-data (sub-1 - 1) to
                            a-data (sub-1)
                       compute screen-line = sub-1 - 1
                       move 0 to screen-col
                       move sub-1 to freq
                       perform 30220-write-one-bar-to-screen
                       subtract 1 from sub-1
                   else
                       move "ON" to halt-sw
                   end-if
               end-perform
               move hold-array-element to a-data (sub-1)
               compute screen-line = sub-1 - 1
               move 0 to screen-col
               move sub-1 to freq
               perform 30220-write-one-bar-to-screen
           end-perform
      *
      * The sort is completed. Clear the screen highlight
      *    around the elapsed time.
      *
           perform 30140-clear-time-hilight.
       30600-exit.
           exit.

      /
      *****************************************************************
       30700-bubble-sort.
      *****************************************************************
      *
      * The bubble sort will search through array and compare
      *    adjacent elements with the current element. If the
      *    adjacent element is less than the current element, they
      *    will be swapped. This is done until no more elements are
      *    swapped.
      *
           move kbdcharin-char to last-choice
           move bubble-line-number to time-screen-line
           move bubble-literal to hilite-item
           move "ON" to updated-screen-sw
           perform 20700-display-unsorted-bars
           perform 20610-get-starting-time
           move array-max to max-loop
           move 99 to last-element-saved
           perform until last-element-saved = zeros
               move zeros to last-element-saved
               perform varying sub from 1 by 1
                       until sub > (max-loop - 1)
                   if a-length (sub) > a-length (sub + 1)
                       move sub to swap-line swap-line-1
                       add 1 to swap-line-1
                       perform 30210-swap-two-bars
                       move sub to last-element-saved
                   end-if
               end-perform
               move last-element-saved to max-loop
           end-perform
      *
      * The sort is completed. Clear the screen highlight
      *    around the elapsed time.
      *
           perform 30140-clear-time-hilight.
       30700-exit.
           exit.

      /
      *****************************************************************
       30800-slow-down-the-sort.
      *****************************************************************
      *
      * User typed the ">" key, increase the time the beep sounds.
      *
           if pause not = 30
               add 1 to pause
               if pause = 1
                   if auto-sound-toggle-sw = "ON"
                       move "ON " to sound-sw
                       move "ON" to updated-screen-sw
                       move "OFF" to auto-sound-toggle-sw
                   end-if
               end-if
               move pause to disp-pause
               perform 30810-update-speed-variables
               if updated-screen-sw = "ON"
                   move "OFF" to updated-screen-sw
                   perform 20700-display-unsorted-bars
                   perform 20800-display-menu-screen
               else
                   perform 30820-update-screen-speed
                   perform 30830-update-screen-prompts
               end-if
           end-if.
       30800-exit.
           exit.

      *****************************************************************
       30810-update-speed-variables.
      *****************************************************************
           evaluate pause
               when 30 move spaces to ms-slow-down-var
                       move space to ms-slow-down-char
               when 29 move menu-screen-slow-down-msg to
                           ms-slow-down-var
                       move menu-screen-slow-down-lit to
                           ms-slow-down-char
               when 1  move menu-screen-speed-up-msg
                           to ms-speed-up-var
                       move menu-screen-speed-up-lit
                           to ms-speed-up-char
                       move menu-screen-toggle-sound-msg
                           to ms-toggle-sound-var
                       move menu-screen-toggle-sound-lit
                           to ms-toggle-sound-char
               when 0  move spaces to ms-speed-up-var
                       move space to ms-speed-up-char
                       move space to ms-toggle-sound-var
                       move space to ms-toggle-sound-char
           end-evaluate.
       30810-exit.
           exit.

      *****************************************************************
       30820-update-screen-speed.
      *****************************************************************
      *
      * Updates the speed counter on the screen.
      *
           move 30 to viowrtcharstratt-length
           compute screen-line = speed-counter-line-number - 1
           move 50 to screen-col
           move menu-screen-line (speed-counter-line-number) to
               viowrtcharstratt-data
           move menu-screen-hilite-attr to viowrtcharstratt-attr
           perform 20710-call-viowrtcharstratt.
       30820-exit.
           exit.

      *****************************************************************
       30830-update-screen-prompts.
      *****************************************************************
      *
      * This routine updates the prompts on the screen that inform the
      *    user that they can speed up or slow down the sort at will by
      *    using the "<" and ">" keys.
      *
      * Also updated is the "Cobol" sort menu entry. If the speed of
      *    the sort is zero, "Cobol" is printed in bold characters,
      *    otherwise, it is printed in dim characters (indicating the
      *    the option can not be chosen).
      *
           move 30 to viowrtcharstratt-length
           move menu-screen-hilite-attr to viowrtcharstratt-attr
           move 50 to screen-col
           evaluate true
               when pause = 30 or = 29
                   perform 30840-write-slow-down-prompts
               when pause = 0
                   perform 30850-write-speed-up-prompts
                   perform 30860-hilite-cobol-sort
               when pause = 1
                   perform 30850-write-speed-up-prompts
                   perform 20810-unhilite-cobol-sort
           end-evaluate
           if msg-line not = spaces
               move spaces to msg-line
               perform 30110-update-message-line
           end-if.
       30830-exit.
           exit.

      *****************************************************************
       30840-write-slow-down-prompts.
      *****************************************************************
      *
      * This routine writes the prompts that tells the user how to
      *    use the ">" key.
      *
           move menu-screen-slow-down-line to
               viowrtcharstratt-data
           compute screen-line = slow-down-line-number - 1
           perform 20710-call-viowrtcharstratt
           move menu-screen-choice-line to viowrtcharstratt-data
           compute screen-line = prompt-line-number - 1
           perform 20710-call-viowrtcharstratt.
       30840-exit.
           exit.

      *****************************************************************
       30850-write-speed-up-prompts.
      *****************************************************************
      *
      * This routine writes the prompts that tells the user how to
      *    use the "<" key.
      *
           move menu-screen-speed-up-line to
               viowrtcharstratt-data
           compute screen-line = speed-up-line-number - 1
           perform 20710-call-viowrtcharstratt
           move menu-screen-choice-line to viowrtcharstratt-data
           compute screen-line = prompt-line-number - 1
           perform 20710-call-viowrtcharstratt.
       30850-exit.
           exit.

      *****************************************************************
       30860-hilite-cobol-sort.
      *****************************************************************
      *
      * Print "Cobol" on the menu, in highlighted attributes. Because
      *    it is printed in highlighted attributes, this indicates
      *    that the option may chosen.
      *
           move 28 to viowrtcharstratt-length
           compute screen-line = cobol-table-line-number - 1
           move 51 to screen-col
           move spaces to hilite-screen-data-item
           move menu-screen-cobol-lit-tab to hilite-item
           move menu-screen-hilite-attr to viowrtcharstratt-attr
           move hilite-screen-data-item to viowrtcharstratt-data
           perform 20710-call-viowrtcharstratt.
           move 28 to viowrtcharstratt-length
           compute screen-line = cobol-line-number - 1
           move 51 to screen-col
           move spaces to hilite-screen-data-item
           move menu-screen-cobol-lit to hilite-item
           move menu-screen-hilite-attr to viowrtcharstratt-attr
           move hilite-screen-data-item to viowrtcharstratt-data
           perform 20710-call-viowrtcharstratt.
       30860-exit.
           exit.

      *****************************************************************
       30900-speed-up-the-sort.
      *****************************************************************
      *
      * User typed the "<" key, decrease the time the beep sounds.
      *
           if pause not = zeros
               subtract 1 from pause
               if pause = zeros
                   if sound-sw = "ON "
                       move "OFF" to sound-sw
                       move "ON" to auto-sound-toggle-sw
                       move "ON" to updated-screen-sw
                   end-if
               end-if
               move pause to disp-pause
               perform 30810-update-speed-variables
               if updated-screen-sw = "ON"
                   move "OFF" to updated-screen-sw
                   perform 20700-display-unsorted-bars
                   perform 20800-display-menu-screen
               else
                   perform 30820-update-screen-speed
                   perform 30830-update-screen-prompts
               end-if
           end-if.
       30900-exit.
           exit.

      *****************************************************************
       31000-toggle-sound.
      *****************************************************************
      *
      * Toggle the sound on or off.
      *
           if pause not = zeros
               move "OFF" to auto-sound-toggle-sw
               if sound-sw = "OFF"
                   move "ON " to sound-sw
               else
                   move "OFF" to sound-sw
               end-if
               move 30 to viowrtcharstratt-length
               compute screen-line = sound-sw-line-number - 1
               move 50 to screen-col
               move menu-screen-line (sound-sw-line-number) to
                   viowrtcharstratt-data
               move menu-screen-hilite-attr to viowrtcharstratt-attr
               perform 20710-call-viowrtcharstratt
               if msg-line not = spaces
                   move spaces to msg-line
                   perform 30110-update-message-line
               end-if
           end-if.
       31000-exit.
           exit.

      ****************************************************************
       31100-randomize-array.
      ****************************************************************
      *
      * Re-randomize the bars on the screen.
      *
           move spaces to hilite-screen-data-item
           move randomize-literal to hilite-item
           move randomize-line-number to time-screen-line
           move zeros to elapsed
           move menu-screen-revvid-attr to viowrtcharstratt-attr
           perform 30120-write-time-on-screen
           move spaces to msg-line
           move wait-msg to msg-line
           perform 30110-update-message-line
           perform 20600-init-unsorted-array
           perform 20700-display-unsorted-bars
           perform 20800-display-menu-screen.
       31100-exit.
           exit.

      *****************************************************************
       31200-select-previous-choice.
      *****************************************************************
      *
      * The up-arrow key was typed. Depending on the last choice
      *    taken, perform the proper sort.
      *
           evaluate true
               when last-choice = space
                   perform 30700-bubble-sort
                   move "B" to last-choice
               when last-choice = "F" or = "f"
                   perform 30100-cobol-sort
                   move "C" to last-choice
               when last-choice = "E" or = "e"
                   perform 30100-cobol-sort
                   move "F" to last-choice
               when last-choice = "Q" or = "q"
                   perform 30200-exchange-sort
                   move "E" to last-choice
               when last-choice = "S" or = "s"
                   perform 30300-quick-sort
                   move "Q" to last-choice
               when last-choice = "H" or = "h"
                   perform 30400-shell-sort
                   move "S" to last-choice
               when last-choice = "I" or = "i"
                   perform 30500-heap-sort
                   move "H" to last-choice
               when last-choice = "B" or = "b"
                   perform 30600-insert-sort
                   move "I" to last-choice
               when last-choice = "C" or "c"
                   perform 30700-bubble-sort
                   move "B" to last-choice
           end-evaluate.
       31200-exit.
           exit.

      *****************************************************************
       31300-select-next-choice.
      *****************************************************************
      *
      * The down-arrow key was typed. Depending on the last sort
      *    execute the proper sort.
      *
           evaluate true
               when last-choice = space
                   perform 30100-cobol-sort
                   move "C" to last-choice
               when last-choice = "C" or "c"
                   perform 30100-cobol-sort
                   move "F" to last-choice
               when last-choice = "F" or "f"
                   perform 30200-exchange-sort
                   move "E" to last-choice
               when last-choice = "E" or = "e"
                   perform 30300-quick-sort
                   move "Q" to last-choice
               when last-choice = "Q" or = "q"
                   perform 30400-shell-sort
                   move "S" to last-choice
               when last-choice = "S" or = "s"
                   perform 30500-heap-sort
                   move "H" to last-choice
               when last-choice = "H" or = "h"
                   perform 30600-insert-sort
                   move "I" to last-choice
               when last-choice = "I" or = "i"
                   perform 30700-bubble-sort
                   move "B" to last-choice
               when last-choice = "B" or = "b"
                   perform 30100-cobol-sort
                   move "C" to last-choice
           end-evaluate.
       31300-exit.
           exit.

      *****************************************************************
       40000-restore-users-video-mode.
      *****************************************************************
      *
      * Restore the original video mode before quitting.
      *
           move viomode-save-data to viomode-data.
           perform 20330-call-viosetmode.
       40000-exit.
           exit.

      *****************************************************************
       99999-os2-error-abort.
      *****************************************************************
      *
      * Reports an OS/2 API error.
      *
      * Inputs to the routine are the following:
      *
      *    RETURN-CODE = OS/2 error code returned from the OS/2
      *                   routine.
      *
           display "AX = " , return-code
           display "PROGRAM IS ABORTING"
           stop run.
       99999-exit.
           exit.

      /
      *****************************************************************
       sort-input-procedure-section section.
       sort-input-start.
      *****************************************************************
           perform varying sub from 1 by 1
                   until sub > array-max
               release sort-rec from a-data (sub)
           end-perform.
       sort-input-exit.
           exit.

      *****************************************************************
       sort-output-procedure-section section.
       sort-output-start.
      *****************************************************************
           perform varying sub from 1 by 1
                   until sub > array-max
               return sort-file into a-data (sub)
               compute screen-line = sub - 1
               move sub to freq
               move 0 to screen-col
               move 50 to viowrtcharstratt-length
               move a-string (freq) to viowrtcharstratt-data
               move a-color (freq) to viowrtcharstratt-attr
               perform 20710-call-viowrtcharstratt
           end-perform
           perform 30130-update-time-on-screen.
       sort-output-exit.
           exit.

