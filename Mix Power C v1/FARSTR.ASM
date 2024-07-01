;
;   Copyright (c) Mix Software 1988
;
; ============================================================
;        Far string functinos
; ============================================================
;
; -------------------------------------------------------
;   farstrcat(string1, string2) - concatenate strings
;   farstrncat(string1, string2, n) - concatenate strings
; -------------------------------------------------------
;
         IDT  farstrcat
         IF   LONGNAME
         LDEF farstrcat
         LDEF farstrncat
         ENDIF
         IF   SHORTNAME
         DEF  Fstrcat
         DEF  Fstrncat
         ENDIF
;
farstrcat equ  $
Fstrcat  PUSH BP
         MOV  BP,SP
         MOV  CX,-1           ; no limit on length
CAT      PUSH DS
         MOV  DI,[BP][%PARM1]
         MOV  ES,[BP][%PARM2]
         MOV  SI,[BP][%PARM3]
         MOV  DS,[BP][%PARM4]
         CLD
         XOR  AX,AX
         PUSH CX
         MOV  CX,-1
         REPNZ                ; search for zero on string 1
         SCASB
         POP  CX
         DEC  DI              ; overwrite the '\0' terminator
COPY     LODSB
         STOSB
         TEST AL,AL
         JZ   DONE
         LOOP COPY
         MOV  %[DI],%0
DONE     POP  AX
         MOV  DS,AX
         MOV  AX,[BP][%PARM1] ; result is pointer to string1
         MOV  DX,ES
         POP  BP
         RETSEG
farstrncat  equ  $
Fstrncat PUSH BP
         MOV  BP,SP
         MOV  CX,[BP][%PARM5] ; cx = limit on length
         JCXZ DONE
         JMPS CAT
         END
;
; -------------------------------------------------------
;   farstrchr(string1, c) - search string for character
; -------------------------------------------------------
;       char *farstrchr(s, c)
;       char far *s;
;       int  c;
;
;       Purpose: Searches for first occurrence of c in s
;       Returns: Pointer to c if s contains c
;                NULL if s does not contain c
;
;
         IDT  farstrchr
         IF   LONGNAME
         LDEF farstrchr
         ENDIF
         IF   SHORTNAME
         DEF  Fstrchr
         ENDIF
;
Fstrchr  equ  $
farstrch PUSH BP
         MOV  BP,SP
         MOV  DI,[BP][%PARM1]
         MOV  ES,[BP][%PARM2]
         MOV  CX,-1
         XOR  AL,AL
         CLD
         REPNZ
         SCASB
         NOT  CX              ; CX = length including '\0'
         MOV  DI,[BP][%PARM1]
         MOV  AL,[BP][%PARM3]
         REPNZ
         SCASB
         JNZ  NOFIND
         DEC  DI
         MOV  AX,DI
         MOV  DX,ES
         POP  BP
         RETSEG
NOFIND   XOR  AX,AX
         XOR  DX,DX
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;   farstrrchr(string, c) - search string for last occurance of c
; -------------------------------------------------------
;
         IDT  farstrrchr
         IF   LONGNAME
         LDEF farstrrchr
         ENDIF
         IF   SHORTNAME
         DEF  Fstrrchr
         ENDIF
;
farstrrchr  equ  $
Fstrrchr PUSH BP
         MOV  BP,SP
         MOV  DI,[BP][%PARM1]
         MOV  ES,[BP][%PARM2]
         CLD
         MOV  CX,-1
         XOR  AL,AL
         CLD
         REPNZ                ; find end of string
         SCASB
         NOT  CX
         STD
         MOV  DI,[BP][%PARM1]
         ADD  DI,CX
         DEC  DI
         MOV  AX,[BP][%PARM3]
         REPNZ
         SCASB
         CLD
         JZ   FOUND
         XOR  AX,AX
         XOR  DX,DX
         POP  BP
         RETSEG
FOUND    INC  DI              ; Return pointer to c
         MOV  AX,DI
         MOV  DX,ES
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;   farstrncmp(string1, string2,n) - compare strings
; -------------------------------------------------------
;
         IDT  farstrncmp
         IF   LONGNAME
         LDEF farstrncmp
         ENDIF
         IF   SHORTNAME
         DEF  Fstrncmp
         ENDIF
;
farstrncmp  equ  $
Fstrncmp MOV  BX,SP
         MOV  CX,[BX][%PARM5-2]
         JCXZ EQUAL
         PUSH DS
         MOV  SI,[BX][%PARM1-2]
         MOV  DI,[BX][%PARM3-2]
         MOV  ES,[BX][%PARM4-2]
         MOV  DS,[BX][%PARM2-2]
         MOV  DX,DI
         XOR  AX,AX
         MOV  BX,CX
         CLD
         REPNZ                ; search for zero on string 1
         SCASB
         NEG  CX
         ADD  CX,BX
         MOV  DI,DX
         REPZ
         CMPSB
         MOV  AL,%[SI][%-1]
         SEGES
         SUB  AL,%[DI][%-1]
         CBW
         POP  CX
         MOV  DS,CX
         RETSEG
EQUAL    XOR  AX,AX
         RETSEG
         END
;
;
; -------------------------------------------------------
;   farstrcmp(string1, string2) - compare strings
; -------------------------------------------------------
;
         IDT  farstrcmp
         IF   LONGNAME
         LDEF farstrcmp
         ENDIF
         IF   SHORTNAME
         DEF  Fstrcmp
         ENDIF
;
farstrcmp  equ  $
Fstrcmp  MOV  BX,SP
         PUSH DS
         MOV  SI,[BX][%PARM1-2]
         MOV  DI,[BX][%PARM3-2]
         MOV  ES,[BX][%PARM4-2]
         MOV  DS,[BX][%PARM2-2]
         CLD
         MOV  DX,DI
         XOR  AX,AX
         MOV  CX,-1
         REPNZ                ; search for zero on string 1
         SCASB
         INC  CX
         NEG  CX
         MOV  DI,DX
         REPZ
         CMPSB
         MOV  AL,%[SI][%-1]
         SEGES
         SUB  AL,%[DI][%-1]
         CBW
         POP  CX
         MOV  DS,CX
         RETSEG
         END
;
; -------------------------------------------------------
;   farstrcmpi(string1, string2) - compare strings, ignore case
; -------------------------------------------------------
;
         IDT  farstrcmpi
         IF   LONGNAME
         LDEF farstrcmpi
         LDEF farstrnicmp
         ENDIF
         IF   SHORTNAME
         DEF  Fstrcmpi
         DEF  Fstrnicm
         ENDIF
farstrcmpi equ $
Fstrcmpi EQU  $
         PUSH BP
         MOV  BP,SP
         PUSH DS
         MOV  SI,[BP][%PARM1]
         MOV  DS,[BP][%PARM2]
         MOV  DI,[BP][%PARM3]
         MOV  ES,[BP][%PARM4]
         MOV  CX,-1
CMP      LODSB
         SEGES
         MOV  BL,[DI]
         INC  DI
         TEST AL,AL           ; end of string1?
         JZ   END1
         TEST BL,BL
         JZ   END1
         CMP  AL,BL
         JNZ  NOTEQUAL
NEXT     LOOP CMP
EQUAL    XOR  AX,AX           ; strings are equal
         POP  CX
         MOV  DS,CX
         POP  BP
         RETSEG
END1     XOR  AH,AH           ; end of both?
         XOR  BH,BH
         SUB  AX,BX
         POP  CX
         MOV  DS,CX
         POP  BP
         RETSEG
NOTEQUAL CMP  AL,'A'
         JB   NOTAL
         CMP  AL,'Z'
         JA   NOTAL
         ADD  AL,'a'-'A'
NOTAL    CMP  BL,'A'
         JB   NOTBL
         CMP  BL,'Z'
         JA   NOTBL
         ADD  BL,'a'-'A'
NOTBL    CMP  AL,BL
         JZ   NEXT
         MOV  AL,[SI][%-1]
         SEGES
         MOV  BL,[DI][%-1]
         JMPS END1
;
farstrnicmp equ $
Fstrnicm PUSH BP
         MOV  BP,SP
         PUSH DS
         MOV  SI,[BP][%PARM1]
         MOV  DS,[BP][%PARM2]
         MOV  DI,[BP][%PARM3]
         MOV  ES,[BP][%PARM4]
         MOV  CX,[BP][%PARM5]
         JCXZ EQUAL
         JMPS CMP
         END
;
; -------------------------------------------------------
;   farstrcpy(string1, string2) - copy strings
; -------------------------------------------------------
;
         IDT  farstrcpy
         IF   LONGNAME
         LDEF farstrcpy
         ENDIF
         IF   SHORTNAME
         DEF  Fstrcpy
         ENDIF
;
farstrcpy equ  $
Fstrcpy  MOV  BX,SP
         MOV  SI,[BX][%PARM3-2]
         MOV  DI,SI
         MOV  ES,[BX][%PARM4-2]
         MOV  CX,-1
         XOR  AX,AX
         CLD
         REPNZ
         SCASB
         NOT  CX
         MOV  DI,[BX][%PARM1-2]
         MOV  ES,[BX][%PARM2-2]
         MOV  DX,DS
         MOV  DS,[BX][%PARM4-2]
         MOV  AX,DI
         REP
         MOVSB
         MOV  DS,DX
         MOV  DX,ES
         RETSEG
         END
;
; -------------------------------------------------------
;   farstrncpy(string1, string2, n) - copy string
;       copy exactly n characters from string2 to string1
;       if n < length of string2, no null is appended
;       if n > length of string2, string1 padded with '\0'
; -------------------------------------------------------
;
         IDT  farstrncpy
         IF   LONGNAME
         LDEF farstrncpy
         ENDIF
         IF   SHORTNAME
         DEF  Fstrncpy
         ENDIF
;
farstrncpy  equ  $
Fstrncpy PUSH BP
         MOV  BP,SP
         MOV  DI,[BP][%PARM1]
         MOV  DX,DS
         MOV  DS,[BP][%PARM2]
         MOV  SI,[BP][%PARM3]
         MOV  ES,[BP][%PARM4]
         MOV  CX,[BP][%PARM5]
         JCXZ DONE
         CLD
COPY     LODSB
         STOSB
         TEST AL,AL
         JZ   ENDSTR
         LOOP COPY
DONE     MOV  DS,DX
         MOV  DX,ES
         MOV  AX,[BP][%PARM1]
         POP  BP
         RETSEG
ENDSTR   DEC  CX
         JCXZ DONE
         XOR  AX,AX
         REP
         STOSB
         JMPS DONE
         END
;
; -------------------------------------------------------
;       int farstrspn(s1, s2)
;       char *s1, *s2;
;
;       Purpose: Searches from beginning of s1
;                until a character NOT in s2 is found
;       Returns: Length of string segment in s1 consisting
;                entirely of characters contained in s2
; -------------------------------------------------------
;
         IDT  farstrspn
         IF   LONGNAME
         LDEF farstrspn
         ENDIF
         IF   SHORTNAME
         DEF  Fstrspn
         ENDIF
;
farstrspn equ  $
Fstrspn  PUSH BP
         MOV  BP,SP
         PUSH DS
         MOV  SI,[BP][%PARM1]
         MOV  DS,[BP][%PARM2]
         MOV  DI,[BP][%PARM3]
         MOV  ES,[BP][%PARM4]
         MOV  CX,-1
         XOR  AL,AL
         CLD
         REPNZ                ; get length of string2
         SCASB
         NOT  CX
         MOV  BX,CX
         XOR  DX,DX           ; initial index
         JCXZ DONE
NEXTCH   LODSB
         TEST AL,AL
         JZ   DONE
         MOV  CX,BX
         MOV  DI,[BP][%PARM3]
         REPNZ
         SCASB
         JNZ  DONE
         INC  DX
         JMPS NEXTCH
DONE     MOV  AX,DX
         POP  DX
         MOV  DS,DX
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;       int farstrcspn(s1, s2)
;       char *s1, *s2;
;
;       Purpose: Searches from beginning of s1
;                until a character in s2 is found
;       Returns: Length of string segment in s1 consisting
;                entirely of characters NOT contained in s2
; -------------------------------------------------------
;
         IDT  farstrcspn
         IF   LONGNAME
         LDEF farstrcspn
         ENDIF
         IF   SHORTNAME
         DEF  Fstrcspn
         ENDIF
;
farstrcspn  equ  $
Fstrcspn PUSH BP
         MOV  BP,SP
         PUSH DS
         MOV  SI,[BP][%PARM1]
         MOV  DS,[BP][%PARM1]
         MOV  DI,[BP][%PARM3]
         MOV  ES,[BP][%PARM4]
         MOV  CX,-1
         XOR  AL,AL
         CLD
         REPNZ                ; get length of string2
         SCASB
         NOT  CX
         MOV  BX,CX
         XOR  DX,DX           ; initial index
         JCXZ DONE
NEXTCH   LODSB
         TEST AL,AL
         JZ   DONE
         MOV  CX,BX
         MOV  DI,[BP][%PARM3]
         REPNZ
         SCASB
         JZ   DONE
         INC  DX
         JMPS NEXTCH
DONE     MOV  AX,DX
         POP  DX
         MOV  DS,DX
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;       int farstrpbrk(s1, s2)
;       char *s1, *s2;
;
;       Purpose: Searches from beginning of s1
;                until a character in s2 is found
;       Returns: pointer to first character found
; -------------------------------------------------------
;
         IDT  farstrpbrk
         IF   LONGNAME
         LDEF farstrpbrk
         ENDIF
         IF   SHORTNAME
         DEF  Fstrpbrk
         ENDIF
;
farstrpbrk  equ  $
Fstrpbrk PUSH BP
         MOV  BP,SP
         PUSH DS
         MOV  SI,[BP][%PARM1]
         MOV  DS,[BP][%PARM2]
         MOV  DI,[BP][%PARM3]
         MOV  ES,[BP][%PARM4]
         MOV  CX,-1
         XOR  AL,AL
         CLD
         REPNZ                ; get length of string2
         SCASB
         NOT  CX
         MOV  BX,CX
         JCXZ DONE
NEXTCH   LODSB
         TEST AL,AL
         JZ   NONE
         MOV  CX,BX
         MOV  DI,[BP][%PARM3]
         REPNZ
         SCASB
         JZ   DONE
         JMPS NEXTCH
DONE     DEC  SI
         MOV  AX,SI
EXIT     POP  DX
         MOV  DS,DX
         POP  BP
         RETSEG
NONE     XOR  AX,AX
         JMPS EXIT
         END
;
; -------------------------------------------------------
;   farstrrev(string) - reverse a string
; -------------------------------------------------------
;
         IDT  farstrrev
         IF   LONGNAME
         LDEF farstrrev
         ENDIF
         IF   SHORTNAME
         DEF  Fstrrev
         ENDIF
;
farstrrev   equ  $
Fstrrev  PUSH BP
         MOV  BP,SP
         MOV  DX,DS
         MOV  DI,[BP][%PARM1]
         MOV  ES,[BP][%PARM2]
         MOV  CX,-1
         XOR  AL,AL
         CLD
         REPNZ                ; find end of string
         SCASB
         SUB  DI,%2
         MOV  SI,[BP][%PARM1]
         MOV  DS,[BP][%PARM2]
REV      CMP  SI,DI
         JAE  DONE
         MOV  AL,%[DI]
         XCHG AL,%[SI]
         MOV  %[DI],AL
         INC  SI
         DEC  DI
         JMPS REV
DONE     MOV  AX,[BP][%PARM1]
         MOV  DX,[BP][%PARM2]
         MOV  DS,DX
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;   farstrsave(string) - copy to heap, NULL if no space
;   farstrdup(string) - copy to heap, NULL if no space
; -------------------------------------------------------
;
         IDT  farstrdup
         IF   LONGNAME
         LDEF farstrdup
         LDEF farstrsave
         LFREF farmalloc
         ENDIF
         IF   SHORTNAME
         DEF  Fstrdup
         DEF  Fstrsave
         FREF Fmalloc
         ENDIF
farstrdup  equ  $
farstrsave equ  $
Fstrsave EQU  $
Fstrdup  PUSH BP
         MOV  BP,SP
         MOV  DI,[BP][%PARM1]
         TEST DI,DI
         JZ   NULL
         MOV  ES,[BP][%PARM2]
         MOV  CX,-1
         XOR  AX,AX
         CLD
         REPNZ                ; get length of string2
         SCASB
         NEG  CX
         PUSH CX
         PUSH AX
         PUSH CX
         IF   LONGNAME
         callfar farmalloc
         ENDIF
         IF   SHORTNAME&(~LONGNAME)
         callfar Fmalloc
         ENDIF
         ADD  SP,%4
         POP  CX
         TEST AX,AX           ; Null?
         JNZ  OK1
         TEST DX,DX
         JZ   NULL
OK1      MOV  DI,AX
         MOV  ES,DX
         MOV  SI,[BP][%PARM1]
         MOV  DX,DS
         MOV  DS,[BP][%PARM2]
         REP
         MOVSB
DONE     MOV  DS,DX
         MOV  DX,ES
         POP  BP
         RETSEG
NULL     XOR  AX,AX
         XOR  DX,DX
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;   farstrlwr(string) - convert all uppercase letters in
;       string to lower case
; -------------------------------------------------------
;
         IDT  farstrlwr
         IF   LONGNAME
         LDEF farstrlwr
         ENDIF
         IF   SHORTNAME
         DEF  Fstrlwr
         ENDIF
;
farstrlwr equ  $
Fstrlwr  PUSH BP
         MOV  BP,SP
         MOV  BX,DS
         MOV  SI,[BP][%PARM1]
         MOV  DX,[BP][%PARM2]
         MOV  DS,DX
         CLD
CHECK    MOV  AL,%[SI]
         TEST AL,AL
         JZ   DONE
         CMP  AL,'A'
         JB   OK
         CMP  AL,'Z'
         JA   OK
         ADD  AL,'a'-'A'
         MOV  %[SI],AL
OK       INC  SI
         JMPS CHECK
DONE     MOV  DS,BX
         MOV  AX,[BP][%PARM1]
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;   farstrupr(string) - convert all lower case letters in
;       string to upper case
; -------------------------------------------------------
;
         IDT  farstrupr
         IF   LONGNAME
         LDEF farstrupr
         ENDIF
         IF   SHORTNAME
         DEF  Fstrupr
         ENDIF
;
farstrupr equ  $
Fstrupr  PUSH BP
         MOV  BP,SP
         MOV  BX,DS
         MOV  SI,[BP][%PARM1]
         MOV  DX,[BP][%PARM2]
         MOV  DS,DX
CHECK    MOV  AL,%[SI]
         TEST AL,AL
         JZ   DONE
         CMP  AL,'a'
         JB   OK
         CMP  AL,'z'
         JA   OK
         ADD  AL,'A'-'a'
         MOV  %[SI],AL
OK       INC  SI
         JMPS CHECK
DONE     MOV  DS,BX
         MOV  AX,[BP][%PARM1]
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;   farstrset(string,c) - set all but '\0' to c
;   farstrnset(string,c,n) - set up to n or '\0' to c
; -------------------------------------------------------
;
         IDT  farstrset
         IF   LONGNAME
         LDEF farstrset
         LDEF farstrnset
         ENDIF
         IF   SHORTNAME
         DEF  Fstrset
         DEF  Fstrnset
         ENDIF
farstrset  equ  $
Fstrset  PUSH BP
         MOV  BP,SP
         MOV  CX,-1           ; no limit on length
SET      MOV  DX,DS
         MOV  SI,[BP][%PARM1]
         MOV  DS,[BP][%PARM2]
         MOV  BX,[BP][%PARM3]
NEXT     MOV  AL,%[SI]
         TEST AL,AL
         JZ   DONE
         MOV  %[SI],BL
         INC  SI
         LOOP NEXT
DONE     MOV  DS,DX
DONE1    MOV  AX,[BP][%PARM1] ; result is pointer to string1
         MOV  DX,[BP][%PARM2]
         POP  BP
         RETSEG
farstrnset equ  $
Fstrnset PUSH BP
         MOV  BP,SP
         MOV  CX,[BP][%PARM4] ; cx = limit on length
         JCXZ DONE1
         JMPS SET
         END
;
; -------------------------------------------------------
;       int farstrlen(s)
;       char *s;
;       Purpose: Returns the length of the string, not
;                including the NULL character
; -------------------------------------------------------
;
         IDT  farstrlen
         IF   LONGNAME
         LDEF farstrlen
         ENDIF
         IF   SHORTNAME
         DEF  Fstrlen
         ENDIF
farstrlen  equ  $
Fstrlen  MOV  BX,SP
         MOV  DI,[BX][%PARM1-2]
         MOV  ES,[BX][%PARM2-2]
         MOV  CX,-1
         XOR  AL,AL
         CLD
         REPNZ                ; get length of string2
         SCASB
         NOT  CX
         DEC  CX
         MOV  AX,CX
         RETSEG
         END
;
; -------------------------------------------------------
;       int farstrstr(s1, s2)
;       char *s1, *s2;
;
;       Purpose: Searches s1 for the first occurrence
;                of s2
;       Returns: pointer to substring if found,
;                NULL if not found
; -------------------------------------------------------
;
         IDT  farstrstr
         IF   LONGNAME
         LDEF farstrstr
         ENDIF
         IF   SHORTNAME
         DEF  Fstrstr
         ENDIF
;
farstrstr   equ  $
Fstrstr  PUSH BP
         MOV  BP,SP
         PUSH DS
         MOV  DI,[BP][%PARM1]
         MOV  ES,[BP][%PARM2]
         MOV  CX,-1
         XOR  AL,AL
         CLD
         REPNZ
         SCASB
         NOT  CX
         DEC  CX
         MOV  DX,CX           ; DX is length of s1
         MOV  DI,[BP][%PARM3]
         MOV  ES,[BP][%PARM4]
         MOV  CX,-1
         REPNZ
         SCASB
         NOT  CX
         DEC  CX              ; CX is length of s2
         CMP  CX,DX
         JA   NOFIND          ; s2 is longer than s1
         MOV  AX,[BP][%PARM1] ; initial s1 pointer
         MOV  ES,[BP][%PARM2]
         MOV  DS,[BP][%PARM4]
         JCXZ FOUND           ; length of s2 is zero
         MOV  BX,CX           ; save s2 length
         SUB  DX,BX           ; number of positions to try
         INC  DX
NEXTPOS  MOV  CX,BX           ; length of s2
         MOV  SI,[BP][%PARM3] ; start of s2
         MOV  DI,AX           ; current position in s1
         REPZ
         CMPSB                ; compare
         JZ   FOUND           ; strings match
         INC  AX              ; try next position
         DEC  DX
         JNZ  NEXTPOS
NOFIND   XOR  AX,AX
         XOR  DX,DX
FOUND    POP  CX
         MOV  DS,CX
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;       int farstristr(s1, s2)
;       char *s1, *s2;
;
;       Purpose: Searches s1 for the first occurrence
;                of s2 (case is ignored)
;       Returns: pointer to substring if found,
;                NULL if not found
; -------------------------------------------------------
;
         IDT  farstristr
         IF   LONGNAME
         LDEF farstristr
         ENDIF
         IF   SHORTNAME
         DEF  Fstristr
         ENDIF
;
farstristr  equ  $
Fstristr PUSH BP
         MOV  BP,SP
         SUB  SP,%2
         PUSH DS
         MOV  DI,[BP][%PARM1]
         MOV  ES,[BP][%PARM2]
         MOV  CX,-1
         XOR  AL,AL
         CLD
         REPNZ
         SCASB
         NOT  CX
         DEC  CX
         MOV  DX,CX           ; DX is length of s1
         MOV  DI,[BP][%PARM3]
         MOV  ES,[BP][%PARM4]
         MOV  CX,-1
         REPNZ
         SCASB
         NOT  CX
         DEC  CX              ; CX is length of s2
         CMP  CX,DX
         JA   NOFIND          ; s2 is longer than s1
         MOV  AX,[BP][%PARM1] ; initial s1 pointer
         MOV  ES,[BP][%PARM2]
         MOV  DS,[BP][%PARM4] ; s2 segment
         JCXZ FOUND           ; length of s2 is zero
         MOV  BX,CX           ; save s2 length
         SUB  DX,BX           ; number of positions to try
         INC  DX
         MOV  [BP][%-2],DX
NEXTPOS  MOV  CX,BX           ; length of s2
         MOV  SI,[BP][%PARM3] ; start of s2
         MOV  DI,AX           ; current position in s1
COMP     REPZ
         CMPSB                ; compare
         JZ   FOUND           ; strings match
         MOV  DL,[SI][%-1]
         SEGES
         MOV  DH,[DI][%-1]
         AND  DX,>DFDF
         CMP  DL,DH
         JNZ  TRYNXT
         CMP  DL,'A'
         JB   TRYNXT
         CMP  DL,'Z'
         JA   TRYNXT
         JCXZ FOUND
         JMPS COMP
TRYNXT   INC  AX              ; try next position
         DEC  [BP][%-2]
         JNZ  NEXTPOS
NOFIND   XOR  AX,AX
         XOR  DX,DX
FOUND    POP  CX
         MOV  DS,CX
         MOV  SP,BP
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;       char *farstrtok(s1, s2)
;       char far *s1, far *s2;
;
;       Purpose: Searches for the beginning of the next token
;                in s1.  A token is a sequence of one or more
;                characters in s1 separated from the next token
;                by a sequence of one or more characters contained
;                in s2.  S1 must point to a string of tokens for
;                the first call to strtok.  Subsequent calls
;                can specify a NULL value for s1 to return the next
;                token in the string.
;
;       Returns: Pointer to next token in s1
;                NULL if there are no more tokens in s1
; -------------------------------------------------------
;
         IDT  farstrtok
         IF   LONGNAME
         LDEF farstrtok
         ENDIF
         IF   SHORTNAME
         DEF  Fstrtok
         ENDIF
;
         DORG 0
STRPTR   DW   0-0
STRSEG   DW   0-0
         ORG  $
farstrtok equ  $
Fstrtok  PUSH BP
         MOV  BP,SP
         MOV  DI,[BP][%PARM3]
         MOV  ES,[BP][%PARM4]
         CLD
         MOV  CX,-1
         XOR  AL,AL
         REPNZ
         SCASB                ; Find length of s2
         NOT  CX
         JCXZ NOS2            ; Return null if s2 is empty
         MOV  DX,CX           ; save length of s2
         PUSH DS
         MOV  SI,[BP][%PARM1]
         MOV  AX,[BP][%PARM2]
         TEST SI,SI           ; is s1 null?
         JNZ  NOTNULL
         TEST AX,AX
         JNZ  NOTNULL
         MOV  SI,[STRPTR]
         TEST SI,SI
         JZ   EMPTY           ; no previous string
         MOV  AX,[STRSEG]
         JZ   EMPTY
NOTNULL  MOV  DS,AX
NEXTCH   LODSB                ; get s1 character
         TEST AL,AL
         JZ   EMPTY           ; end of s1
         MOV  CX,DX
         MOV  DI,[BP][%PARM3]
         REPNZ
         SCASB                ; check in delimiter set
         JZ   NEXTCH
         MOV  BX,SI           ; address of first non-delimiter
         DEC  BX
TOKCH    LODSB
         TEST AL,AL
         JZ   ENDS1
         MOV  CX,DX
         MOV  DI,[BP][%PARM3]
         REPNZ
         SCASB
         JNZ  TOKCH           ; not a delimiter
         MOV  [STRPTR],SI
         MOV  [STRSEG],DS
         MOV  %[SI][%-1],%0   ; terminate token
         MOV  AX,BX
         MOV  DX,DS
         POP  CX
         MOV  DS,CX
         POP  BP
         RETSEG
EMPTY    XOR  AX,AX
         MOV  [STRPTR],AX
         XOR  DX,DX
         MOV  [STRSEG],AX
         POP  CX
         MOV  DS,CX
         POP  BP
         RETSEG
NOS2     MOV  CX,[BP][%PARM1]
         MOV  [STRPTR],CX
         MOV  CX,[BP][%PARM2]
         MOV  [STRSEG],CX
         XOR  AX,AX
         XOR  DX,DX
         POP  BP
         RETSEG
ENDS1    MOV  AX,BX
         MOV  DX,DS
         MOV  [STRPTR],0
         MOV  [STRSEG],0
         POP  CX
         MOV  DS,CX
         POP  BP
         RETSEG
         END
