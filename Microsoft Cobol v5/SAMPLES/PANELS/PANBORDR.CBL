      $set noosvs mf ans85
      ************************************************************
      *                                                          *
      *              (C) Micro Focus Ltd. 1989                   *
      *                                                          *
      *                     PANBORDR.CBL                         *
      *                                                          *
      *    This program illustrates the creation of a panel      *
      *    with a particular attribute and describes a simple    *
      *    method of drawing a box around the visible portion    *
      *                                                          *
      ************************************************************
       identification division.
       data division.

       working-storage section.

      * attribute used when creating the panel
       78 white-on-blue                    VALUE X"17".

      * characters used for the panel border
       78 top-left-character               VALUE X"DA".
       78 top-right-character              VALUE X"BF".
       78 bottom-left-character            VALUE X"C0".
       78 bottom-right-character           VALUE X"D9".
       78 top-character                    VALUE X"C4".
       78 side-character                   VALUE X"B3".

      * update masks used when writing to the panel
       78 copy-characters                  VALUE X"01".
       78 fill-characters                  VALUE X"04".

      * backups of the existing backdrop character and attribute
       01 stored-backdrop-character        PIC X.
       01 stored-backdrop-attribute        PIC X.

      * text buffer used when writing the border
       01 panel-text-buffer.
         03 panel-text-character           pic x occurs 80.

       01 dummy-character                  pic x.

       copy "PANLINK.CPY".

       procedure division.
       main-part.
           perform redraw-screen
           perform create-panel
           perform draw-panel-border
           perform enable-panel
           perform stop-run.

       redraw-screen.
      * clear the screen
           move pf-redraw-screen to ppb-function
           call "PANELS" using panels-parameter-block
           perform status-check.

       create-panel.
           move pf-get-screen-info to ppb-function
           call "PANELS" using panels-parameter-block
           perform status-check

      * store the current backdrop character and attribute
           move ppb-fill-character to stored-backdrop-character
           move ppb-fill-attribute to stored-backdrop-attribute

      * set the attribute and character with which the panel is to
      * be created
           move white-on-blue to ppb-fill-attribute
           move space to ppb-fill-character
           move pf-set-screen-backdrop to ppb-function
           call "PANELS" using panels-parameter-block
           perform status-check

      * create the panel
           move 10 to ppb-panel-height
           move 20 to ppb-panel-width
           move 10 to ppb-visible-height
           move 20 to ppb-visible-width
           move 25 to ppb-panel-start-column
           move  5 to ppb-panel-start-row
           move  0 to ppb-first-visible-col
           move  0 to ppb-first-visible-row
           move pf-create-panel to ppb-function
           call "PANELS" using panels-parameter-block
           perform status-check

      * restore the backdrop character and attribute
           move stored-backdrop-character to ppb-fill-character
           move stored-backdrop-attribute to ppb-fill-attribute
           move pf-set-screen-backdrop to ppb-function
           call "PANELS" using panels-parameter-block
           perform status-check.

       draw-panel-border.
      * draw a border on the visible part of the panel
           move 1 to ppb-update-height
           move ppb-visible-width to ppb-update-width
           move ppb-first-visible-col to ppb-update-start-col
           move ppb-first-visible-row to ppb-update-start-row
           move 0 to ppb-rectangle-offset
           move 1 to ppb-buffer-offset
           move ppb-visible-width to ppb-vertical-stride
           move pf-write-panel to ppb-function

      * write the top of the border
           move top-left-character to panel-text-character (1)
           move top-right-character to
                panel-text-character (ppb-update-width)
           move 2 to ppb-update-count
           perform until ppb-update-count NOT < ppb-update-width
             move top-character to
                  panel-text-character (ppb-update-count)
             add 1 to ppb-update-count
           end-perform
           move copy-characters to ppb-update-mask
           call "PANELS" using panels-parameter-block
                               panel-text-buffer
           perform status-check

      * write the bottom of the border
           add ppb-visible-height to ppb-update-start-row
           subtract 1 from ppb-update-start-row
           move bottom-left-character to panel-text-character (1)
           move bottom-right-character to
                panel-text-character (ppb-update-width)
           call "PANELS" using panels-parameter-block
                               panel-text-buffer
           perform status-check

      * write the left-hand side of the border
           move ppb-visible-height to ppb-update-height
           subtract 2 from ppb-update-height
           move ppb-update-height to ppb-update-count
           move 1 to ppb-update-width
           move ppb-first-visible-col to ppb-update-start-col
           move ppb-first-visible-row to ppb-update-start-row
           add 1 to ppb-update-start-row
           move side-character to ppb-fill-character
           move fill-characters to ppb-update-mask
           call "PANELS" using panels-parameter-block
           perform status-check

      * write the right-hand side of the border
           add ppb-visible-width to ppb-update-start-col
           subtract 1 from ppb-update-start-col
           call "PANELS" using panels-parameter-block
           perform status-check.

       enable-panel.
           move pf-enable-panel to ppb-function
           call "PANELS" using panels-parameter-block
           perform status-check.

       status-check.
           if ppb-status not = 0
             display "bad status " ppb-status
             perform stop-run.

       stop-run.
           display "press return to stop the PANBORDR program"
           accept dummy-character
           stop run.
