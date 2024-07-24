      *******************************************************************
      *                                                                 *
      *                  (C) Micro Focus Ltd. 1990                      *
      *                                                                 *
      *                      APPC copy file                             *
      *                                                                 *
      *******************************************************************

      *=================================================================
      *                 verb parameter constants
      *=================================================================

       78 ap-no                                value h"00".
       78 ap-yes                               value h"01".
       
       78 ap-abend                             value h"05".
       78 ap-abend-prog                        value h"02".
       78 ap-abend-svc                         value h"03".
       78 ap-abend-timer                       value h"04".
       78 ap-basic-conversation                value h"00".
       78 ap-buffer                            value h"00".
       78 ap-confirm-sync-level                value h"01".
       78 ap-flush                             value h"01".
       78 ap-hard                              value h"01".
       78 ap-immediate                         value h"01".
       78 ap-ll                                value h"01".
       78 ap-long                              value h"01".
       78 ap-mapped-conversation               value h"01".
       78 ap-none                              value h"00".
       78 ap-pgm                               value h"02".
       78 ap-prog                              value h"00".
       78 ap-same                              value h"01".
       78 ap-short                             value h"00".
       78 ap-soft                              value h"00".
       78 ap-svc                               value h"01".
       78 ap-sync-level                        value h"00".
       78 ap-when-session-allocated            value h"00".
       78 ap-when-session-free                 value h"02".
       
       78 ap-confirm-what-received             value h"0200".
       78 ap-confirm-deallocate                value h"0400".
       78 ap-confirm-send                      value h"0300".
       78 ap-data                              value h"0001".
       78 ap-data-complete                     value h"0002".
       78 ap-data-incomplete                   value h"0004".
       78 ap-send                              value h"0100".
       
      *=================================================================
      *                 return codes
      *=================================================================
       78 ap-allocation-error                  value h"0003".
       78 ap-cancelled                         value h"0021".
       78 ap-comm-subsystem-abended            value h"f003".
       78 ap-comm-subsystem-not-loaded         value h"f004".
       78 ap-conv-failure-retry                value h"000f".
       78 ap-conv-failure-no-retry             value h"0010".
       78 ap-conversation-type-mixed           value h"0019".
       78 ap-dealloc-abend                     value h"0005".
       78 ap-dealloc-abend-prog                value h"0006".
       78 ap-dealloc-abend-svc                 value h"0007".
       78 ap-dealloc-abend-timer               value h"0008".
       78 ap-dealloc-normal                    value h"0009".
       78 ap-invalid-verb-segment              value h"f008".
       78 ap-ok                                value h"0000".
       78 ap-parameter-check                   value h"0001".
       78 ap-prog-error-no-trunc               value h"000c".
       78 ap-prog-error-purging                value h"000e".
       78 ap-prog-error-trunc                  value h"000d".
       78 ap-state-check                       value h"0002".
       78 ap-svc-error-no-trunc                value h"0011".
       78 ap-svc-error-purging                 value h"0013".
       78 ap-svc-error-trunc                   value h"0012".
       78 ap-tp-busy                           value h"f002".
       78 ap-unexpected-dos-error              value h"f011".
       78 ap-unsuccessful                      value h"0014".
       78 ap-stack-too-small                   value h"f015".
       
       78 ap-allocate-not-pending              value h"00000509".
       78 ap-alloc-failure-no-retry            value h"00000004".
       78 ap-alloc-failure-retry               value h"00000005".
       78 ap-attach-mgr-inactive               value h"00000508".
       78 ap-bad-conv-id                       value h"00000002".
       78 ap-bad-conv-type                     value h"00000011".
       78 ap-bad-ll                            value h"000000f1".
       78 ap-bad-lu-name                       value h"00000003".
       78 ap-bad-return-control                value h"00000014".
       78 ap-bad-security                      value h"00000013".
       78 ap-bad-sync-level                    value h"00000012".
       78 ap-bad-tp-id                         value h"00000001".
       78 ap-confirm-bad-state                 value h"00000032".
       78 ap-confirm-not-ll-bdy                value h"00000033".
       78 ap-confirm-on-sync-lvl-none          value h"00000031".
       78 ap-confirmed-bad-state               value h"00000041".
       78 ap-conv-type-mismatch                value h"10086034".
       78 ap-dealloc-bad-type                  value h"00000051".
       78 ap-dealloc-conf-bad-state            value h"00000053".
       78 ap-dealloc-flush-bad-state           value h"00000052".
       78 ap-dealloc-log-ll-wrong              value h"00000057".
       78 ap-dealloc-not-ll-bdy                value h"00000055".
       78 ap-flush-not-send-state              value h"00000061".
       78 ap-invalid-data-segment              value h"00000006".
       78 ap-invalid-process                   value h"00000525".
       78 ap-invalid-semaphore-handle          value h"000000d6".
       78 ap-no-use-of-snasvcmg                value h"00000017".
       78 ap-p-to-r-invalid-type               value h"000000a1".
       78 ap-p-to-r-not-ll-bdy                 value h"000000a2".
       78 ap-p-to-r-not-send-state             value h"000000a3".
       78 ap-pip-len-incorrect                 value h"00000016".
       78 ap-pip-not-allowed                   value h"10086031".
       78 ap-pip-not-spec-correct              value h"10086032".
       78 ap-rcv-and-post-not-ll-bdy           value h"000000d2".
       78 ap-r-t-s-bad-state                   value h"000000e1".
       78 ap-rcv-and-post-bad-fill             value h"000000d5".
       78 ap-rcv-and-post-bad-state            value h"000000d1".
       78 ap-rcv-and-wait-bad-fill             value h"000000b5".
       78 ap-rcv-and-wait-bad-state            value h"000000b1".
       78 ap-rcv-and-wait-not-ll-bdy           value h"000000b2".
       78 ap-rcv-immd-bad-fill                 value h"000000c4".
       78 ap-rcv-immd-bad-state                value h"000000c1".
       78 ap-security-not-valid                value h"080f6051".
       78 ap-send-data-bad-map-name            value h"000000f3".
       78 ap-send-data-not-send-state          value h"000000f2".
       78 ap-send-error-bad-type               value h"00000103".
       78 ap-sync-level-not-supported          value h"10086041".
       78 ap-send-error-log-ll-wrong           value h"00000102".
       78 ap-too-many-tps                      value h"00000243".
       78 ap-tp-name-not-recognized            value h"10086021".
       78 ap-t-pgm-not-avail-no-retry          value h"084c0000".
       78 ap--pgm-not-avail-retry              value h"084b6031".
       78 ap-undefined-tp-name                 value h"00000506".
       78 ap-unknown-partner-mode              value h"00000018".
       
      *=================================================================
      *                 operation codes
      *=================================================================
       78 ap-b-allocate                        value h"0100".
       78 ap-b-confirm                         value h"0300".
       78 ap-b-confirmed                       value h"0400".
       78 ap-b-deallocate                      value h"0500".
       78 ap-b-flush                           value h"0600".
       78 ap-b-get-attributes                  value h"0700".
       78 ap-b-prepare-to-receive              value h"0a00".
       78 ap-b-receive-and-post                value h"0d00".
       78 ap-b-receive-and-wait                value h"0b00".
       78 ap-b-receive-immediate               value h"0c00".
       78 ap-b-request-to-send                 value h"0e00".
       78 ap-b-send-data                       value h"0f00".
       78 ap-b-send-error                      value h"1000".
       78 ap-b-test-rts                        value h"1200".
       
       78 ap-m-allocate                        value h"0100".
       78 ap-m-confirm                         value h"0300".
       78 ap-m-confirmed                       value h"0400".
       78 ap-m-deallocate                      value h"0500".
       78 ap-m-flush                           value h"0600".
       78 ap-m-get-attributes                  value h"0700".
       78 ap-m-prepare-to-receive              value h"0a00".
       78 ap-m-receive-and-post                value h"0d00".
       78 ap-m-receive-and-wait                value h"0b00".
       78 ap-m-receive-immediate               value h"0c00".
       78 ap-m-request-to-send                 value h"0e00".
       78 ap-m-send-data                       value h"0f00".
       78 ap-m-send-error                      value h"1000".
       78 ap-m-test-rts                        value h"1200".
       
       78 ap-get-type                          value h"0800".
       78 ap-receive-allocate                  value h"1600".
       78 ap-tp-ended                          value h"1300".
       78 ap-tp-started                        value h"1400".
       
       
      *=================================================================
      *                verb structures
      *=================================================================

      *-----------------------------------------------------------------
      *                verb control block
      *
      * this is a buffer which is passed to all of the APPC verbs.
      * the contents of the VCB are different for each verb called
      * Not all the fields of the VCB are used in every verb call,
      * those that are not should be zeroed.
      *
      * The VCB is defined below - and the redefinitions that follow
      * specify the structure of each verb.
      *
      *-----------------------------------------------------------------
       01 vcb.
         03 opcode-vcb          pic 9(4) comp-x.
         03 opext-vcb           pic 9(2) comp-x.
         03 filler              pic x.
         03 prim-rc-vcb         pic 9(4) comp-x.
         03 sec-rc-vcb          pic 9(8) comp-x.
         03 filler              pic x(290).

      *-----------------------------------------------------------------
      *                transaction program control interface
      *-----------------------------------------------------------------

      *--------------- receive-allocate verb ---------------------------
       01 rcv-alloc-verb redefines vcb.
         03 opcode-ral          pic 9(4) comp-x.
         03 filler              pic x(2).
         03 prim-rc-ral         pic 9(4) comp-x.
         03 sec-rc-ral          pic 9(8) comp-x.
         03 tp-name-ral         pic x(64).
         03 tp-id-ral           pic x(8).
         03 conv-id-ral         pic x(4).
         03 sync-lvl-ral        pic 9(2) comp-x.
         03 conv-type-ral       pic 9(2) comp-x.
         03 user-id-ral         pic x(10).
         03 lu-alias-ral        pic x(8).
         03 plu-alias-ral       pic x(8).
         03 mode-name-ral       pic x(8).
         03 filler              pic x(28).
      *-----------------------------------------------------------------
       
      *--------------- tp-ended ----------------------------------------
       01 tp-ended-verb redefines vcb.
         03 opcode-tpe          pic 9(4) comp-x.
         03 filler              pic x(2).
         03 prim-rc-tpe         pic 9(4) comp-x.
         03 sec-rc-tpe          pic 9(8) comp-x.
         03 tp-id-tpe           pic x(8).
         03 filler              pic x(28).
      *-----------------------------------------------------------------
       
      *--------------- tp-started --------------------------------------
       01 tp-started-verb redefines vcb.
         03 opcode-tps          pic 9(4) comp-x.
         03 filler              pic x(2).
         03 prim-rc-tps         pic 9(4) comp-x.
         03 sec-rc-tps          pic 9(8) comp-x.
         03 lu-alias-tps        pic x(8).
         03 tp-id-tps           pic x(8).
         03 tp-name-tps         pic x(64).
      *-----------------------------------------------------------------
       
      *-----------------------------------------------------------------
      *        Transaction programming interface - basic conversation
      *-----------------------------------------------------------------
       
      *--------------- allocate ----------------------------------------
       01 alloc-verb redefines vcb.
         03 opcode-alc          pic 9(4) comp-x.
         03 opext-alc           pic 9(2) comp-x.
         03 filler              pic x.
         03 prim-rc-alc         pic 9(4) comp-x.
         03 sec-rc-alc          pic 9(8) comp-x.
         03 tp-id-alc           pic x(8).
         03 conv-id-alc         pic x(4).
         03 conv-type-alc       pic 9(2) comp-x.
         03 sync-lvl-alc        pic 9(2) comp-x.
         03 filler              pic x(2).
         03 rtn-ctl-alc         pic 9(2) comp-x.
         03 filler              pic x(9).
         03 plu-alias-alc       pic x(8).
         03 mode-name-alc       pic x(8).
         03 tp-name-alc         pic x(64).
         03 security-alc        pic 9(2) comp-x.
         03 filler              pic x(11).
         03 pwd-alc             pic x(10).
         03 user-id-alc         pic x(10).
         03 pip-dlen-alc        pic 9(4) comp-5.
         03 pip-dptr-alc        usage pointer.
         03 filler              pic x(26).
      *-----------------------------------------------------------------

      *--------------- confirm -----------------------------------------
       01 cnfrm-verb redefines vcb.
         03 opcode-cfm          pic 9(4) comp-x.
         03 opext-cfm           pic 9(2) comp-x.
         03 filler              pic x.
         03 prim-rc-cfm         pic 9(4) comp-x.
         03 sec-rc-cfm          pic 9(8) comp-x.
         03 tp-id-cfm           pic x(8).
         03 conv-id-cfm         pic x(4).
         03 rts-rcvd-cfm        pic 9(2) comp-x.
      *-----------------------------------------------------------------
       
      *--------------- confirmed ---------------------------------------
       01 cnfrmd-verb redefines vcb.
         03 opcode-cfd          pic 9(4) comp-x.
         03 opext-cfd           pic 9(2) comp-x.
         03 filler              pic x.
         03 prim-rc-cfd         pic 9(4) comp-x.
         03 sec-rc-cfd          pic 9(8) comp-x.
         03 tp-id-cfd           pic x(8).
         03 conv-id-cfd         pic x(4).
      *-----------------------------------------------------------------
       
      *--------------- deallocate --------------------------------------
       01 dealloc-verb redefines vcb.
         03 opcode-dal          pic 9(4) comp-x.
         03 opext-dal           pic 9(2) comp-x.
         03 filler              pic x.
         03 prim-rc-dal         pic 9(4) comp-x.
         03 sec-rc-dal          pic 9(8) comp-x.
         03 tp-id-dal           pic x(8).
         03 conv-id-dal         pic x(4).
         03 filler              pic x.
         03 dealloc-type-dal    pic 9(2) comp-x.
         03 log-dlen-dal        pic 9(4) comp-5.
         03 log-dptr-dal        usage pointer.
      *-----------------------------------------------------------------
       
      *--------------- flush -------------------------------------------
       01 flush-verb redefines vcb.
         03 opcode-fls          pic 9(4) comp-x.
         03 opext-fls           pic 9(2) comp-x.
         03 filler              pic x.
         03 prim-rc-fls         pic 9(4) comp-x.
         03 sec-rc-fls          pic 9(8) comp-x.
         03 tp-id-fls           pic x(8).
         03 conv-id-fls         pic x(4).
      *-----------------------------------------------------------------
       
      *--------------- get-attributes ----------------------------------
       01 get-atts-verb redefines vcb.
         03 opcode-gat          pic 9(4) comp-x.
         03 opext-gat           pic 9(2) comp-x.
         03 filler              pic x.
         03 prim-rc-gat         pic 9(4) comp-x.
         03 sec-rc-gat          pic 9(8) comp-x.
         03 tp-id-gat           pic x(8).
         03 conv-id-gat         pic x(4).
         03 filler              pic x.
         03 sync-lvl-gat        pic 9(2) comp-x.
         03 mode-name-gat       pic x(8).
         03 net-name-gat        pic x(8).
         03 lu-name-gat         pic x(8).
         03 lu-alias-gat        pic x(8).
         03 plu-alias-gat       pic x(8).
         03 plu-un-name-gat     pic x(8).
         03 filler              pic x(2).
         03 fqplun-gat          pic x(17).
         03 filler              pic x.
         03 user-id-gat         pic x(10).
         03 filler              pic x(26).
      *-----------------------------------------------------------------
       
      *--------------- prepare-to-receive ------------------------------
       01 prp-to-rcv-verb redefines vcb.
         03 opcode-ptr          pic 9(4) comp-x.
         03 opext-ptr           pic 9(2) comp-x.
         03 filler              pic x.
         03 prim-rc-ptr         pic 9(4) comp-x.
         03 sec-rc-ptr          pic 9(8) comp-x.
         03 tp-id-ptr           pic x(8).
         03 conv-id-ptr         pic x(4).
         03 ptr-type-ptr        pic 9(2) comp-x.
         03 locks-ptr           pic 9(2) comp-x.
      *-----------------------------------------------------------------
       
      *--------------- receive-and-post --------------------------------
       01 rcv-and-post-verb redefines vcb.
         03 opcode-rap          pic 9(4) comp-x.
         03 opext-rap           pic 9(2) comp-x.
         03 filler              pic x.
         03 prim-rc-rap         pic 9(4) comp-x.
         03 sec-rc-rap          pic 9(8) comp-x.
         03 tp-id-rap           pic x(8).
         03 conv-id-rap         pic x(4).
         03 what-rcvd-rap       pic 9(4) comp-x.
         03 filler              pic x.
         03 fill-rap            pic 9(2) comp-x.
         03 rts-rcvd-rap        pic 9(2) comp-x.
         03 filler              pic x.
         03 max-len-rap         pic 9(4) comp-5.
         03 dlen-rap            pic 9(4) comp-5.
         03 dptr-rap            usage pointer.
         03 sema-rap            pic 9(8) comp-5.
         03 filler              pic x.
      *-----------------------------------------------------------------

      *--------------- receive-and-wait --------------------------------
       01 rcv-and-wait-verb redefines vcb.
         03 opcode-raw          pic 9(4) comp-x.
         03 opext-raw           pic 9(2) comp-x.
         03 filler              pic x.
         03 prim-rc-raw         pic 9(4) comp-x.
         03 sec-rc-raw          pic 9(8) comp-x.
         03 tp-id-raw           pic x(8).
         03 conv-id-raw         pic x(4).
         03 what-rcvd-raw       pic 9(4) comp-x.
         03 filler              pic x.
         03 fill-raw            pic 9(2) comp-x.
         03 rts-rcvd-raw        pic 9(2) comp-x.
         03 filler              pic x.
         03 max-len-raw         pic 9(4) comp-5.
         03 dlen-raw            pic 9(4) comp-5.
         03 dptr-raw            usage pointer.
         03 filler              pic x(5).
      *-----------------------------------------------------------------

      *--------------- receive-immediate -------------------------------
       01 rcv-imm-verb redefines vcb.
         03 opcode-rim          pic 9(4) comp-x.
         03 opext-rim           pic 9(2) comp-x.
         03 filler              pic x.
         03 prim-rc-rim         pic 9(4) comp-x.
         03 sec-rc-rim          pic 9(8) comp-x.
         03 tp-id-rim           pic x(8).
         03 conv-id-rim         pic x(4).
         03 what-rcvd-rim       pic 9(4) comp-x.
         03 filler              pic x.
         03 fill-rim            pic 9(2) comp-x.
         03 rts-rcvd-rim        pic 9(2) comp-x.
         03 filler              pic x.
         03 max-len-rim         pic 9(4) comp-5.
         03 dlen-rim            pic 9(4) comp-5.
         03 dptr-rim            usage pointer.
         03 filler              pic x(5).
      *-----------------------------------------------------------------
       
      *--------------- request-to-send ---------------------------------
       01 rq-to-snd-verb redefines vcb.
         03 opcode-rts          pic 9(4) comp-x.
         03 opext-rts           pic 9(2) comp-x.
         03 filler              pic x.
         03 prim-rc-rts         pic 9(4) comp-x.
         03 sec-rc-rts          pic 9(8) comp-x.
         03 tp-id-rts           pic x(8).
         03 conv-id-rts         pic x(4).
      *-----------------------------------------------------------------
       
      *--------------- send-data ---------------------------------------
       01 snd-data-verb redefines vcb.
         03 opcode-sdt          pic 9(4) comp-x.
         03 opext-sdt           pic 9(2) comp-x.
         03 filler              pic x.
         03 prim-rc-sdt         pic 9(4) comp-x.
         03 sec-rc-sdt          pic 9(8) comp-x.
         03 tp-id-sdt           pic x(8).
         03 conv-id-sdt         pic x(4).
         03 rts-rcvd-sdt        pic 9(2) comp-x.
         03 filler              pic x.
         03 dlen-sdt            pic 9(4) comp-5.
         03 dptr-sdt            usage pointer.
         03 filler              pic x(2).
      *-----------------------------------------------------------------
       
      *--------------- send-error --------------------------------------
       01 snd-err-verb redefines vcb.
         03 opcode-ser          pic 9(4) comp-x.
         03 opext-ser           pic 9(2) comp-x.
         03 filler              pic x.
         03 prim-rc-ser         pic 9(4) comp-x.
         03 sec-rc-ser          pic 9(8) comp-x.
         03 tp-id-ser           pic x(8).
         03 conv-id-ser         pic x(4).
         03 rts-rcvd-ser        pic 9(2) comp-x.
         03 err-type-ser        pic 9(2) comp-x.
         03 filler              pic x(2).
         03 log-dlen-ser        pic 9(4) comp-5.
         03 l-dptr-ser          usage pointer.
      *-----------------------------------------------------------------
       
      *--------------- test-rts ----------------------------------------
       01 test-rts-verb redefines vcb.
         03 opcode-tst          pic 9(4) comp-x.
         03 opext-tst           pic 9(2) comp-x.
         03 filler              pic x.
         03 prim-rc-tst         pic 9(4) comp-x.
         03 sec-rc-tst          pic 9(8) comp-x.
         03 tp-id-tst           pic x(8).
         03 conv-id-tst         pic x(4).
         03 filler              pic x.
      *-----------------------------------------------------------------
       
      *-----------------------------------------------------------------
      *        Transaction programming interface - mapped conversation
      *-----------------------------------------------------------------

      *--------------- mc-allocate -------------------------------------
       01 mc-alloc-verb redefines vcb.
         03 opcode-mal          pic 9(4) comp-x.
         03 opext-mal           pic 9(2) comp-x.
         03 filler              pic x.
         03 prim-rc-mal         pic 9(4) comp-x.
         03 sec-rc-mal          pic 9(8) comp-x.
         03 tp-id-mal           pic x(8).
         03 conv-id-mal         pic x(4).
         03 conv-type-mal       pic 9(2) comp-x.
         03 sync-lvl-mal        pic 9(2) comp-x.
         03 filler              pic x(2).
         03 rtn-ctl-mal         pic 9(2) comp-x.
         03 filler              pic x(9).
         03 plu-alias-mal       pic x(8).
         03 mode-name-mal       pic x(8).
         03 tp-name-mal         pic x(64).
         03 security-mal        pic 9(2) comp-x.
         03 filler              pic x(11).
         03 pwd-mal             pic x(10).
         03 user-id-mal         pic x(10).
         03 pip-dlen-mal        pic 9(4) comp-5.
         03 pip-dptr-mal        usage pointer.
         03 filler              pic x(26).
      *-----------------------------------------------------------------

      *--------------- mc-confirm --------------------------------------
       01 mc-cnfrm-verb redefines vcb.
         03 opcode-mcm          pic 9(4) comp-x.
         03 opext-mcm           pic 9(2) comp-x.
         03 filler              pic x.
         03 prim-rc-mcm         pic 9(4) comp-x.
         03 sec-rc-mcm          pic 9(8) comp-x.
         03 tp-id-mcm           pic x(8).
         03 conv-id-mcm         pic x(4).
         03 rts-rcvd-mcm        pic 9(2) comp-x.
      *-----------------------------------------------------------------
       
      *--------------- mc-confirmed ------------------------------------
       01 mc-cnfrmd-verb redefines vcb.
         03 opcode-mcd         pic 9(4) comp-x.
         03 opext-mcd           pic 9(2) comp-x.
         03 filler              pic x.
         03 prim-rc-mcd         pic 9(4) comp-x.
         03 sec-rc-mcd          pic 9(8) comp-x.
         03 tp-id-mcd           pic x(8).
         03 conv-id-mcd         pic x(4).
      *-----------------------------------------------------------------
       
      *--------------- mc-deallocate -----------------------------------
       01 mc-dealloc-verb redefines vcb.
         03 opcode-mda          pic 9(4) comp-x.
         03 opext-mda           pic 9(2) comp-x.
         03 filler              pic x.
         03 prim-rc-mda         pic 9(4) comp-x.
         03 sec-rc-mda          pic 9(8) comp-x.
         03 tp-id-mda           pic x(8).
         03 conv-id-mda         pic x(4).
         03 filler              pic x.
         03 dealloc-type-mda    pic 9(2) comp-x.
         03 filler              pic x(6).
      *-----------------------------------------------------------------
       
      *--------------- mc-flush ----------------------------------------
       01 mc-flush-verb redefines vcb.
         03 opcode-mfl          pic 9(4) comp-x.
         03 opext-mfl           pic 9(2) comp-x.
         03 filler              pic x.
         03 prim-rc-mfl         pic 9(4) comp-x.
         03 sec-rc-mfl          pic 9(8) comp-x.
         03 tp-id-mfl           pic x(8).
         03 conv-id-mfl         pic x(4).
      *-----------------------------------------------------------------
       
      *--------------- mc-get-attributes -------------------------------
       01 mc-get-atts-verb redefines vcb.
         03 opcode-mga          pic 9(4) comp-x.
         03 opext-mga           pic 9(2) comp-x.
         03 filler              pic x.
         03 prim-rc-mga         pic 9(4) comp-x.
         03 sec-rc-mga          pic 9(8) comp-x.
         03 tp-id-mga           pic x(8).
         03 conv-id-mga         pic x(4).
         03 filler              pic x.
         03 sync-lvl-mga        pic 9(2) comp-x.
         03 mode-name-mga       pic x(8).
         03 net-name-mga        pic x(8).
         03 lu-name-mga         pic x(8).
         03 lu-alias-mga        pic x(8).
         03 plu-alias-mga       pic x(8).
         03 plu-un-name-mga     pic x(8).
         03 filler              pic x(2).
         03 fqplun-mga          pic x(17).
         03 filler              pic x.
         03 user-id-mga         pic x(10).
         03 filler              pic x(26).
      *-----------------------------------------------------------------
       
      *--------------- mc-prepare-to-receive ---------------------------
       01 mc-prp-to-rcv-verb redefines vcb.
         03 opcode-mpr          pic 9(4) comp-x.
         03 opext-mpr           pic 9(2) comp-x.
         03 filler              pic x.
         03 prim-rc-mpr         pic 9(4) comp-x.
         03 sec-rc-mpr          pic 9(8) comp-x.
         03 tp-id-mpr           pic x(8).
         03 conv-id-mpr         pic x(4).
         03 ptr-type-mpr        pic 9(2) comp-x.
         03 locks-mpr           pic 9(2) comp-x.
      *-----------------------------------------------------------------
       
      *--------------- mc-receive-and-post -----------------------------
       01 mc-rcv-and-post-verb redefines vcb.
         03 opcode-mrp          pic 9(4) comp-x.
         03 opext-mrp           pic 9(2) comp-x.
         03 filler              pic x.
         03 prim-rc-mrp         pic 9(4) comp-x.
         03 sec-rc-mrp          pic 9(8) comp-x.
         03 tp-id-mrp           pic x(8).
         03 conv-id-mrp         pic x(4).
         03 what-rcvd-mrp       pic 9(4) comp-x.
         03 filler              pic x(2).
         03 rts-rcvd-mrp        pic 9(2) comp-x.
         03 filler              pic x.
         03 max-len-mrp         pic 9(4) comp-5.
         03 dlen-mrp            pic 9(4) comp-5.
         03 dptr-mrp            usage pointer.
         03 sema-mrp            pic 9(8) comp-5.
         03 filler              pic x.
      *-----------------------------------------------------------------

      *--------------- mc-receive-and-wait -----------------------------
       01 mc-rcv-and-wait-verb redefines vcb.
         03 opcode-mrw          pic 9(4) comp-x.
         03 opext-mrw           pic 9(2) comp-x.
         03 filler              pic x.
         03 prim-rc-mrw         pic 9(4) comp-x.
         03 sec-rc-mrw          pic 9(8) comp-x.
         03 tp-id-mrw           pic x(8).
         03 conv-id-mrw         pic x(4).
         03 what-rcvd-mrw       pic 9(4) comp-x.
         03 filler              pic x(2).
         03 rts-rcvd-mrw        pic 9(2) comp-x.
         03 filler              pic x.
         03 max-len-mrw         pic 9(4) comp-5.
         03 dlen-mrw            pic 9(4) comp-5.
         03 dptr-mrw            usage pointer.
         03 filler              pic x(5).
      *-----------------------------------------------------------------

      *--------------- mc-receive-immediate ----------------------------
       01 mc-rcv-imm-verb redefines vcb.
         03 opcode-mri          pic 9(4) comp-x.
         03 opext-mri           pic 9(2) comp-x.
         03 filler              pic x.
         03 prim-rc-mri         pic 9(4) comp-x.
         03 sec-rc-mri          pic 9(8) comp-x.
         03 tp-id-mri           pic x(8).
         03 conv-id-mri         pic x(4).
         03 what-rcvd-mri       pic 9(4) comp-x.
         03 filler              pic x(2).
         03 rts-rcvd-mri        pic 9(2) comp-x.
         03 filler              pic x.
         03 max-len-mri         pic 9(4) comp-5.
         03 dlen-mri            pic 9(4) comp-5.
         03 dptr-mri            usage pointer.
         03 filler              pic x(5).
      *-----------------------------------------------------------------
       
      *--------------- mc-request-to-send ------------------------------
       01 mc-rq-to-snd-verb redefines vcb.
         03 opcode-mrs          pic 9(4) comp-x.
         03 opext-mrs           pic 9(2) comp-x.
         03 filler              pic x.
         03 prim-rc-mrs         pic 9(4) comp-x.
         03 sec-rc-mrs          pic 9(8) comp-x.
         03 tp-id-mrs           pic x(8).
         03 conv-id-mrs         pic x(4).
      *-----------------------------------------------------------------
       
      *--------------- mc-send-data ------------------------------------
       01 mc-snd-data-verb redefines vcb.
         03 opcode-msd          pic 9(4) comp-x.
         03 opext-msd           pic 9(2) comp-x.
         03 filler              pic x.
         03 prim-rc-msd         pic 9(4) comp-x.
         03 sec-rc-msd          pic 9(8) comp-x.
         03 tp-id-msd           pic x(8).
         03 conv-id-msd         pic x(4).
         03 rts-rcvd-msd        pic 9(2) comp-x.
         03 filler              pic x.
         03 dlen-msd            pic 9(4) comp-5.
         03 dptr-msd            usage pointer.
         03 filler              pic x(2).
      *-----------------------------------------------------------------
       
      *--------------- mc-send-error -----------------------------------
       01 mc-snd-err-verb redefines vcb.
         03 opcode-mse          pic 9(4) comp-x.
         03 opext-mse           pic 9(2) comp-x.
         03 filler              pic x.
         03 prim-rc-mse         pic 9(4) comp-x.
         03 sec-rc-mse          pic 9(8) comp-x.
         03 tp-id-mse           pic x(8).
         03 conv-id-mse         pic x(4).
         03 rts-rcvd-mse        pic 9(2) comp-x.
         03 err-type-mse        pic 9(2) comp-x.
         03 filler              pic x(8).
      *-----------------------------------------------------------------
       
      *--------------- mc-test-rts -------------------------------------
       01 mc-test-rts-verb redefines vcb.
         03 opcode-mtr          pic 9(4) comp-x.
         03 opext-mtr           pic 9(2) comp-x.
         03 filler              pic x.
         03 prim-rc-mtr         pic 9(4) comp-x.
         03 sec-rc-mtr          pic 9(8) comp-x.
         03 tp-id-mtr           pic x(8).
         03 conv-id-mtr         pic x(4).
         03 filler              pic x.
      *-----------------------------------------------------------------

      *-----------------------------------------------------------------
      *        type independent conversation interface
      *-----------------------------------------------------------------

      *--------------- get-type ----------------------------------------
       01 get-type-verb redefines vcb.
         03 opcode-gtt          pic 9(4) comp-x.
         03 opext-gtt           pic 9(2) comp-x.
         03 filler              pic x.
         03 prim-rc-gtt         pic 9(4) comp-x.
         03 sec-rc-gtt          pic 9(8) comp-x.
         03 tp-id-gtt           pic x(8).
         03 conv-id-gtt         pic x(4).
         03 conv-type-gtt       pic 9(2) comp-x.
      *-----------------------------------------------------------------

