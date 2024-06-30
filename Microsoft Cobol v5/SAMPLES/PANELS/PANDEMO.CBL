      $SET ans85 mf noosvs
      *****************************************************************
      *    PANDEMO.CBL: Shows how to use the Panels facility to       *
      *                 create, write to, enable and disable a        *
      *                 user panel under COBOL.                       *
      *                                                               *
      *       calls used by this program:                             *
      *                                                               *
      *       panels: subroutine for handling panel                   *
      *               functions.                                      *
      *                                                               *
      *****************************************************************
       working-storage section.
 
      ******************************************************************
      *  Panels Parameter Block.
      ******************************************************************
 
       01 panels-parameter-block.
        03 ppb-function                pic 9(2) comp-x.
        03 ppb-status                  pic 9(2) comp-x.
        03 ppb-panel-id                pic 9(4) comp-x.
        03 ppb-panel-width             pic 9(4) comp-x.
        03 ppb-panel-height            pic 9(4) comp-x.
        03 ppb-visible-width           pic 9(4) comp-x.
        03 ppb-visible-height          pic 9(4) comp-x.
        03 ppb-first-visible-col       pic 9(4) comp-x.
        03 ppb-first-visible-row       pic 9(4) comp-x.
        03 ppb-panel-start-column      pic 9(4) comp-x.
        03 ppb-panel-start-row         pic 9(4) comp-x.
        03 ppb-buffer-offset           pic 9(4) comp-x.
        03 ppb-vertical-stride         pic 9(4) comp-x.
        03 ppb-update-group.
         05 ppb-update-count           pic 9(4) comp-x.
         05 ppb-rectangle-offset       pic 9(4) comp-x.
         05 ppb-update-start-col       pic 9(4) comp-x.
         05 ppb-update-start-row       pic 9(4) comp-x.
         05 ppb-update-width           pic 9(4) comp-x.
         05 ppb-update-height          pic 9(4) comp-x.
        03 ppb-fill.
         05 ppb-fill-character         pic X.
         05 ppb-fill-attribute         pic X.
        03 ppb-update-mask             pic X.
        03 ppb-scroll-direction        pic 9(2) comp-x.
        03 ppb-scroll-count            pic 9(4) comp-x.
 
       01 ws-save-panel-id             pic 9(4) comp-x.
       01 ws-text-buffer.
          05 filler pic x(20) value "                    ".
          05 filler pic x(20) value "                    ".
          05 filler pic x(20) value "********************".
          05 filler pic x(20) value "********************".
          05 filler pic x(20) value "********************".
          05 filler pic x(20) value "********************".
          05 filler pic x(20) value "** Hello, I am a  **".
          05 filler pic x(20) value "** panel.  To see **".
          05 filler pic x(20) value "** me disappear,  **".
          05 filler pic x(20) value "** press return.  **".
          05 filler pic x(20) value "********************".
          05 filler pic x(20) value "********************".
          05 filler pic x(20) value "********************".
          05 filler pic x(20) value "********************".
          05 filler pic x(20) value "                    ".
          05 filler pic x(20) value "                    ".
 
       01 ws-attrib-buffer.
          05 filler                    pic x(300) value all x"07".
 
       01 ws-accept                    pic x.
 
       procedure division.
       main-line.
           perform redraw-screen
           perform proceed-to-create-a-panel
           perform create-a-panel
           perform write-to-the-panel
           perform enable-the-panel
           perform disable-the-panel
           perform stop-run.
 
       redraw-screen.
           move 2 to ppb-function
           call "panels" using panels-parameter-block
           perform status-check.
 
       proceed-to-create-a-panel.
           display "Press return to make the panel appear"
           accept  ws-accept
           perform redraw-screen.
 
       create-a-panel.
           move 20 to ppb-panel-width
           move 15 to ppb-panel-height
           move  5 to ppb-panel-start-row
           move 20 to ppb-panel-start-column
           move 20 to ppb-visible-width
           move 15 to ppb-visible-height
           move  0 to ppb-first-visible-row
           move  0 to ppb-first-visible-col
           move  3 to ppb-function
           call "panels" using panels-parameter-block
           perform status-check
           move ppb-panel-id to ws-save-panel-id.
 
       write-to-the-panel.
           move ws-save-panel-id to ppb-panel-id
           move  15 to ppb-update-height
           move  20 to ppb-update-width
           move   0 to ppb-update-start-row
           move   0 to ppb-update-start-col
           move 300 to ppb-update-count
           move   0 to ppb-rectangle-offset
           move x"03" to ppb-update-mask
           move   1 to ppb-buffer-offset
           move  20 to ppb-vertical-stride
           move  11 to ppb-function
           call "panels" using panels-parameter-block
                               ws-text-buffer
                               ws-attrib-buffer
           perform status-check.
 
       enable-the-panel.
           move ws-save-panel-id to ppb-panel-id
           move 7 to ppb-function
           call "panels" using panels-parameter-block
           perform status-check.
 
       disable-the-panel.
           accept  ws-accept
           move ws-save-panel-id to ppb-panel-id
           move 8 to ppb-function
           call "panels" using panels-parameter-block
           perform status-check.
 
       status-check.
           if ppb-status not = 0
              display "bad status"
              perform stop-run.
 
       stop-run.
           display "Press return to stop the PANDEMO program"
           accept  ws-accept
           stop run.
