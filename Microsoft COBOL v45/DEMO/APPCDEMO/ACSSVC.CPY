      *******************************************************************
      *                                                                 *
      *                  (C) Micro Focus Ltd. 1990                      *
      *                                                                 *
      *                       ACSSVC copy file                          *
      *                                                                 *
      *******************************************************************

      *=================================================================
      *                 verb parameter constants
      *=================================================================

       78 sv-add                               value 0.
       78 sv-change                            value 1.
       78 sv-ignore                            value 0.
       78 sv-no-add                            value 1.
       78 sv-no-send                           value 1.
       78 sv-send                              value 0.

       78 sv-no                                value h"00".
       78 sv-yes                               value h"01".
       78 sv-a                                 value h"01".
       78 sv-ae                                value h"00".
       78 sv-alert-subvectors                  value h"02".
       78 sv-ascii-to-ebcdic                   value h"00".
       78 sv-ebcdic-to-ascii                   value h"01".
       78 sv-g                                 value h"02".
       78 sv-intrv                             value h"00".
       78 sv-nmvt                              value h"01".
       78 sv-no-intrv                          value h"01".
       78 sv-off                               value h"00".
       78 sv-on                                value h"01".
       78 sv-pdstats-subvectors                value h"03".
       78 sv-substitute                        value h"00".
       78 sv-round-trip                        value h"01".
       78 sv-user-defined                      value h"00".

      *=================================================================
      *                 return codes
      *=================================================================

       78 sv-invalid-verb-segment              value h"f008".
       78 sv-invalid-verb                      value h"ffff".
       78 sv-keylock-secured                   value h"f013".
       78 sv-ok                                value h"0000".
       78 sv-parameter-check                   value h"0001".
       78 sv-comm-subsystem-not-loaded         value h"f012".
       78 sv-state-check                       value h"0002".
       78 sv-unexpected-dos-error              value h"f011".

       78 sv-conversion-error                  value h"00000406".
       78 sv-data-exceeds-ru-size              value h"00000302".
       78 sv-invalid-character-set             value h"00000402".
       78 sv-invalid-data-segment              value h"00000006".
       78 sv-invalid-data-type                 value h"00000303".
       78 sv-invalid-direction                 value h"00000401".
       78 sv-invalid-first-character           value h"00000404".
       78 sv-invalid-message-action            value h"00000621".
       78 sv-invalid-set                       value h"00000624".
       78 sv-invalid-storage-size              value h"00000627".
       78 sv-sscp-pu-session-not-active        value h"00000301".
       78 sv-table-error                       value h"00000405".
       78 sv-invalid-nmvt-header               value h"00000304".
       78 sv-invalid-char-not-found            value h"00000630".
       78 sv-invalid-source-code-page          value h"00000631".
       78 sv-invalid-target-code-page          value h"00000632".

      *=================================================================
      *                 operation codes
      *=================================================================

       78 sv-convert                           value h"1a00".
       78 sv-define-trace                      value h"1d00".
       78 sv-get-cp-convert-table              value h"1900".
       78 sv-log-message                       value h"1f00".
       78 sv-transfer-ms-data                  value h"1c00".


      *=================================================================
      *                verb structures
      *=================================================================
      *-----------------------------------------------------------------
      *                convert service verb record definitions
      *-----------------------------------------------------------------

      *--------------- convert verb ------------------------------------
       01 convert-verb redefines vcb.
         03 opcode-cvt          pic 9(4) comp-x.
         03 filler              pic x(2).
         03 primary-rc-cvt      pic 9(4) comp-x.
         03 secondary-rc-cvt    pic 9(8) comp-x.
         03 direction-cvt       pic 9(2) comp-x.
         03 char-set-cvt        pic 9(2) comp-x.
         03 len-cvt             pic 9(4) comp-5.
         03 src-ptr-cvt         usage pointer.
         03 targ-ptr-cvt        usage pointer.
      *-----------------------------------------------------------------

      *--------------- define-trace verb -------------------------------
       01  define-trace-verb redefines vcb.
         03 opcode-dft          pic 9(4) comp-x.
         03 filler              pic x(2).
         03 primary-rc-dft      pic 9(4) comp-x.
         03 secondary-rc-dft    pic 9(8) comp-x.
         03 filler              pic x(8).
         03 dt-set-dft          pic 9(2) comp-x.
         03 appc-dft            pic 9(2) comp-x.
         03 filler              pic x.
         03 srpi-dft            pic 9(2) comp-x.
         03 sdlc-dft            pic 9(2) comp-x.
         03 tkn-rng-dlc-dft     pic 9(2) comp-x.
         03 pcnet-dlc-dft       pic 9(2) comp-x.
         03 dft-data            pic 9(2) comp-x.
         03 acdi-data           pic 9(2) comp-x.
         03 filler              pic x.
         03 comm-serv-dft       pic 9(2) comp-x.
         03 filler              pic x(16).
         03 reset-trc-dft       pic 9(2) comp-x.
         03 trunc-dft           pic 9(4) comp-5.
         03 strg-size-dft       pic 9(4) comp-5.
         03 filler              pic x(65).
      *-----------------------------------------------------------------

      *--------------- get-cp-convert-table verb -----------------------
       01 get-cp-convert-table-verb redefines vcb.
         03 opcode-gcp             pic 9(4) comp-x.
         03 filler                 pic x(2).
         03 primary-rc-gcp         pic 9(4) comp-x.
         03 secondary-rc-gcp       pic 9(8) comp-x.
         03 source-cp-gcp          pic 9(4) comp-x.
         03 target-cp-gcp          pic 9(4) comp-x.
         03 conv-tbl-addr-gcp      usage pointer.
         03 char-not-fnd-gcp       pic 9(2) comp-x.
         03 sub-char-gcp           pic 9(2) comp-x.
      *-----------------------------------------------------------------

      *--------------- log-message verb --------------------------------
       01 log-message-verb redefines vcb.
         03 opcode-lmg               pic 9(4) comp-x.
         03 filler                   pic x(2).
         03 primary-rc-lmg           pic 9(4) comp-x.
         03 secondary-rc-lmg         pic 9(8) comp-x.
         03 msg-num-lmg              pic 9(4) comp-5.
         03 origntr-id-lmg           pic x(8).
         03 msg-file-name-lmg        pic x(3).
         03 msg-action-lmg           pic 9(2) comp-x.
         03 msg-ins-len-lmg          pic 9(4) comp-x.
         03 msg-ins-addr-lmg         usage pointer.
      *-----------------------------------------------------------------

      *--------------- transfer-ms-data verb----------------------------
       01 transfer-ms-data-verb redefines vcb.
         03 opcode-tmd               pic 9(4) comp-x.
         03 type-tmd                 pic 9(2) comp-x.
         03 filler                   pic x.
         03 primary-rc-tmd           pic 9(4) comp-x.
         03 secondary-rc-tmd         pic 9(8) comp-x.
         03 options-tmd              pic 9(2) comp-x.
         03 filler                   pic x.
         03 origntr-id-tmd           pic x(8).
         03 dlen-tmd                 pic 9(4) comp-5.
         03 data-ptr-tmd             usage pointer.
      *-----------------------------------------------------------------

