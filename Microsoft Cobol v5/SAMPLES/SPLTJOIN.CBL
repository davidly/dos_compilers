      $set noosvs mf ans85
      ***************************************************************
      *                                                             *
      *               (C) Micro Focus Ltd. 1991                     *
      *                                                             *
      *                     SPLTJOIN.CBL                            *
      *                                                             *
      *    This program demonstrates the use of the routines that   *
      *    enable you to separate a filename into its component     *
      *    strings (CBL_SPLIT_FILENAME), and to join strings        *
      *    together to form a filename (CBL_JOIN_FILENAME).         *
      *                                                             *
      ***************************************************************

       working-storage section.
       01 split-buffer    pic x(65).
       01 split-params.
           03  param-length        pic xx comp-x   value 24.
           03  split-join-flag1    pic x  comp-x   value 0.
           03  split-join-flag2    pic x  comp-x.
           03  device-offset       pic xx comp-x.
           03  device-length       pic xx comp-x.
           03  basename-offset     pic xx comp-x.
           03  basename-length     pic xx comp-x.
           03  extension-offset    pic xx comp-x.
           03  extension-length    pic xx comp-x.
           03  total-length        pic xx comp-x.
           03  split-buf-len       pic xx comp-x   value 65.
           03  join-buf-len        pic xx comp-x   value 65.
           03  first-path-component-length pic xx comp-x.
       01 join-buffer              pic x(65).
       01 dev-buffer               pic x(65).
       01 bas-buffer               pic x(65).
       01 ext-buffer               pic x(3) value 'cbl'.

       procedure division.

      * Set up lengths

           move 65 to split-buf-len
                      join-buf-len

      * Set flag for space-terminated, fold to upper

           move 1 to split-join-flag1

           move 'a:\dir\file.ext' to split-buffer
           move 1 to split-join-flag1
           call 'CBL_SPLIT_FILENAME' using split-params
                                           split-buffer

      * This sets up most of the parameters you need for a join

      * The join below replaces the original extension in split-buffer
      * with the extension in ext-buffer, and puts the result in
      * join-buffer.

           move 1 to extension-offset
           move 3 to extension-length
           call 'CBL_JOIN_FILENAME' using split-params
                                          join-buffer
                                          split-buffer
                                          split-buffer
                                          ext-buffer

           if join-buffer = 'A:\DIR\FILE.CBL' then
               display 'first test passed'
           else
               display 'first test failed'
           end-if

      * It is harder to set up a join without doing a split first,
      * but this is what you would need to do.

           move 1 to device-offset
                     basename-offset
                     extension-offset

           move length of dev-buffer to device-length
           move length of bas-buffer to basename-length
           move length of ext-buffer to extension-length
           move length of join-buffer to join-buf-len

           move 0 to split-join-flag1
           move 24 to param-length

           move 'c:\path' to dev-buffer
           move 'basename' to bas-buffer
           move 'ext' to ext-buffer

           call 'CBL_JOIN_FILENAME' using split-params
                                          join-buffer
                                          dev-buffer
                                          bas-buffer
                                          ext-buffer

           if join-buffer = 'c:\path\basename.ext' then
               display 'second test passed'
           else
               display 'second test failed'
           end-if
        stop run.
