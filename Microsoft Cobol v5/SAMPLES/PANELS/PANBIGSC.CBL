       WORKING-STORAGE SECTION.
      * --- Program and Help Panels
       01 Program-Panel-ID      PIC 9(4) COMP-X VALUE 0.
       01 Help-Panel-ID         PIC 9(4) COMP-X VALUE 0.

       01 Help-Panel-Text.
        03 FILLER      PIC X(520) VALUE
                               "You are looking at a Help PANEL which
      -                        "will disappear when you press Enter.
      -                        "
      -                        "This demo shows how to use PANELS to
      -                        "DISPLAY and ACCEPT into a screen 181
      -                        "columns wide by 29 lines long.  PANELS
      -                        "will automatically scroll the window for
      -                        "for you when you get to an edge of the
      -                        "the screen.  Use the arrow keys or fill
      -                        "out the fields and see what happens.
      -                        "
      -                        "Press Enter when you're ready and you
      -                        "will be put back in the first screen. ".

       01 Help-Panel-Attributes.
        03 FILLER OCCURS 13 TIMES.
          05 FILLER      PIC X(40) VALUE ALL X"0F".


       01 Work-Variables.
        03 Screen-Height               PIC 9(4) COMP-X.
        03 Screen-Width                PIC 9(4) COMP-X.
        03 Temp-Value                  PIC 9(4) COMP-X.
        03 Char                        PIC X.

      * --- Use For Common Panel Information
       78 Accept-Panel                 VALUE X"AF".
       78 Get-Char                     VALUE X"83".
       01 Set-Panel-For-Accept         PIC 9(2) COMP-X VALUE 56.
       01 Initialize-Accept            PIC 9(2) COMP-X VALUE 49.
       01 Update-Panel-ID              PIC 9(4) COMP-X VALUE 0.

       01 Panels-Parameter-Block.
        03 PPB-Function                PIC 9(2) COMP-X.
        03 PPB-Status                  PIC 9(2) COMP-X.
        03 PPB-Panel-ID                PIC 9(4) COMP-X.
        03 PPB-Panel-Width             PIC 9(4) COMP-X.
        03 PPB-Panel-Height            PIC 9(4) COMP-X.
        03 PPB-Visible-Width           PIC 9(4) COMP-X.
        03 PPB-Visible-Height          PIC 9(4) COMP-X.
        03 PPB-First-Visible-Col       PIC 9(4) COMP-X.
        03 PPB-First-Visible-Row       PIC 9(4) COMP-X.
        03 PPB-Panel-Start-Column      PIC 9(4) COMP-X.
        03 PPB-Panel-Start-Row         PIC 9(4) COMP-X.
        03 PPB-Buffer-Offset           PIC 9(4) COMP-X.
        03 PPB-Vertical-Stride         PIC 9(4) COMP-X.
        03 PPB-Update-Group.
         05 PPB-Update-Count           PIC 9(4) COMP-X.
         05 PPB-Rectangle-Offset       PIC 9(4) COMP-X.
         05 PPB-Update-Start-Col       PIC 9(4) COMP-X.
         05 PPB-Update-Start-Row       PIC 9(4) COMP-X.
         05 PPB-Update-Width           PIC 9(4) COMP-X.
         05 PPB-Update-Height          PIC 9(4) COMP-X.
        03 PPB-Fill.
         05 PPB-Fill-Character         PIC X.
         05 PPB-Fill-Attribute         PIC X.
        03 PPB-Update-Mask             PIC X.
        03 PPB-Scroll-Direction        PIC 9(2) COMP-X.
        03 PPB-Scroll-Count            PIC 9(4) COMP-X.

      *  Values of PPB-Function.
       78 PF-Get-Screen-Info           VALUE 0.
       78 PF-Set-Screen-Backdrop       VALUE 1.
       78 PF-Redraw-Screen             VALUE 2.
       78 PF-Create-Panel              VALUE 3.
       78 PF-Shift-Panel               VALUE 4.
       78 PF-Get-Panel-Info            VALUE 5.
       78 PF-Delete-Panel              VALUE 6.
       78 PF-Enable-Panel              VALUE 7.
       78 PF-Disable-Panel             VALUE 8.
       78 PF-Flush-Panel               VALUE 9.
       78 PF-Scroll-Panel              VALUE 10.
       78 PF-Write-Panel               VALUE 11.
       78 PF-Read-Panel                VALUE 12.
       78 PF-Get-Panel-At-Position     VALUE 13.

      *  Values of PPB-Scroll-Direction.
       78 PS-Scroll-Up                 VALUE 0.
       78 PS-Scroll-Down               VALUE 1.
       78 PS-Scroll-Left               VALUE 2.
       78 PS-Scroll-Right              VALUE 3.

      *  Error Codes.
       78 PE-No-Error                  VALUE 0.
       78 PE-Not-Created               VALUE 1.
       78 PE-Invalid-ID                VALUE 2.
       78 PE-Invalid-Parameters        VALUE 3.
       78 PE-Invalid-Function          VALUE 4.
       78 PE-No-Room-For-Panel         VALUE 5.
       78 PE-Panel-Too-Large           VALUE 6.
       78 PE-Invalid-Direction         VALUE 7.
       78 PE-Invalid-Scroll-Count      VALUE 8.
       78 PE-Cannot-Initialise         VALUE 9.

       01  DIST-TABLE.
           05      L1-1            PIC X(04).
           05      L1-2            PIC X(04).
           05      L1-3            PIC X(04).
           05      L1-4            PIC X(04).
           05      L1-5            PIC X(04).
           05      L1-6            PIC X(04).
           05      L1-7            PIC X(04).
           05      L1-8            PIC X(04).
           05      L1-9            PIC X(04).
           05      L1-10           PIC X(04).
           05      L1-11           PIC X(04).
           05      L1-12           PIC X(04).
           05      L1-13           PIC X(04).
           05      L1-14           PIC X(04).
           05      L1-15           PIC X(04).

       SCREEN SECTION.
       01  MY-SCREEN.
         10        LINE IS 2     COLUMN IS 01
                         VALUE 'COLUMN 1'.
         10        LINE IS 2     COLUMN IS 28
                         VALUE 'COLUMN 31'.
         10        LINE IS 2     COLUMN IS 58
                         VALUE 'COLUMN 61'.
         10        LINE IS 2     COLUMN IS 88
                         VALUE 'COLUMN 91'.
         10        LINE IS 2     COLUMN IS 118
                         VALUE 'COLUMN 121'.
         10        LINE IS 2     COLUMN IS 148
                         VALUE 'COLUMN 151'.
         10        LINE IS 2     COLUMN IS 178
                         VALUE 'COLUMN 181'.
         10        LINE IS 05    COLUMN IS 1
                         VALUE 'LINE  5'.
         10        LINE IS 09    COLUMN IS 1
                         VALUE 'LINE 09'.
         10        LINE IS 13    COLUMN IS 1
                         VALUE 'LINE 13'.
         10        LINE IS 17    COLUMN IS 1
                         VALUE 'LINE 17'.
         10        LINE IS 21    COLUMN IS 1
                         VALUE 'LINE 21'.
         10        LINE IS 25    COLUMN IS 1
                         VALUE 'LINE 25'.
         10        LINE IS 29    COLUMN IS 1
                         VALUE 'LINE 29'.

         10        LINE IS 23    COLUMN IS 60
                         VALUE '... Press Enter'.

         10        LINE IS 5     COLUMN IS 31
                   PIC X(04)  AUTO   REVERSE-VIDEO   USING L1-13.
         10                      COLUMN IS 61
                   PIC X(04)  AUTO   REVERSE-VIDEO   USING L1-14.
         10                      COLUMN IS 91
                   PIC X(04)  AUTO   REVERSE-VIDEO   USING L1-1.
         10                      COLUMN IS 121
                   PIC X(04)  AUTO  REVERSE-VIDEO    USING L1-2.
         10                      COLUMN IS 151
                   PIC X(04)  AUTO  REVERSE-VIDEO    USING L1-3.
         10                      COLUMN IS 181
                   PIC X(04)  AUTO  REVERSE-VIDEO    USING L1-4.
         10        LINE IS 09    COLUMN IS 31
                   PIC X(04)  AUTO  REVERSE-VIDEO    USING L1-5.
         10        LINE IS 13    COLUMN IS 31
                   PIC X(04)  AUTO  REVERSE-VIDEO    USING L1-6.
         10        LINE IS 17    COLUMN IS 31
                   PIC X(04)  AUTO  REVERSE-VIDEO    USING L1-7.
         10        LINE IS 21    COLUMN IS 31
                   PIC X(04)  AUTO  REVERSE-VIDEO    USING L1-8.
         10        LINE IS 25    COLUMN IS 31
                   PIC X(04)  AUTO  REVERSE-VIDEO    USING L1-9.
         10        LINE IS 29    COLUMN IS 31
                   PIC X(04)  AUTO  REVERSE-VIDEO    USING L1-10.

       PROCEDURE DIVISION.

      *    Initialize Adis to work with panels.
           CALL Accept-Panel USING Initialize-Accept,
                                   Update-Panel-ID.

           PERFORM Create-Program-Panel

      *    Make ACCEPT/DISPLAY happen in the Program Panel
           CALL Accept-Panel USING Set-Panel-For-Accept,
                                      Program-Panel-ID

      *    Display the main screen
           DISPLAY MY-SCREEN.

      *    Pause ...
           CALL Get-Char USING Char.

               PERFORM Create-Help-Panel.
               CALL Get-Char USING Char.
               PERFORM Disable-Help-Panel.

      *    Accept data into the main screen
           ACCEPT MY-SCREEN.

           STOP RUN.


       Create-Program-Panel.

           MOVE 200 TO PPB-Panel-Width
           MOVE 50 TO PPB-Panel-Height
           MOVE 80 TO PPB-Visible-Width
           MOVE 25 TO PPB-Visible-Height
           MOVE 0 TO PPB-First-Visible-Col
           MOVE 0 TO PPB-First-Visible-Row
           MOVE 0 TO PPB-Panel-Start-Column
           MOVE 0 TO PPB-Panel-Start-Row
           MOVE PF-Create-Panel TO PPB-Function
           CALL "PANELS" USING Panels-Parameter-Block
      *    Save the ID of the panel
           MOVE PPB-Panel-ID TO Program-Panel-ID.

      *    Enable the panel so that the panel becomes visible
           MOVE PF-Enable-Panel TO PPB-Function
           CALL "PANELS" USING Panels-Parameter-Block.


       Create-Help-Panel.
           MOVE 40 TO PPB-Panel-Width
           MOVE 13 TO PPB-Panel-Height
           MOVE 40  TO PPB-Visible-Width
           MOVE 13 TO PPB-Visible-Height
           MOVE 0 TO PPB-First-Visible-Col
           MOVE 0 TO PPB-First-Visible-Row
           MOVE 14 TO PPB-Panel-Start-Column
           MOVE 09 TO PPB-Panel-Start-Row
           MOVE PF-Create-Panel TO PPB-Function
           CALL "PANELS" USING Panels-Parameter-Block
      *    Save the ID of the panel
           MOVE PPB-Panel-ID TO Help-Panel-ID.

      *    Write data to the Help Panel
           MOVE 1 TO PPB-Buffer-Offset
           MOVE 40      TO PPB-Vertical-Stride
      *    Number of Chars in Panel = Panel Width *
      *                               Panel Height
           COMPUTE Temp-Value = 40 * 13
           MOVE Temp-Value TO PPB-Update-Count
           MOVE 0 TO PPB-Rectangle-Offset
           MOVE 0 TO PPB-Update-Start-Col
           MOVE 0 TO PPB-Update-Start-Row
           MOVE 40       TO PPB-Update-Width
           MOVE 13       TO PPB-Update-Height
           MOVE PF-Write-Panel TO PPB-Function
           MOVE X"33" TO PPB-Update-Mask
           CALL "PANELS" USING Panels-Parameter-Block
                               Help-Panel-Text
                               Help-Panel-Attributes.

      *    Enable the panel so that the panel becomes visible
           MOVE PF-Enable-Panel TO PPB-Function
           CALL "PANELS" USING Panels-Parameter-Block.

       Disable-Help-Panel.
           MOVE Help-Panel-ID TO PPB-Panel-ID.
           MOVE PF-Delete-Panel TO PPB-Function.
           CALL "PANELS" USING Panels-Parameter-Block.

                                         