;
;   Copyright (c) Mix Software 1988
;
; -------------------------------------------------------
;   strcat(string1, string2) - concatenate strings
;   strncat(string1, string2, n) - concatenate strings
; -------------------------------------------------------
;
         IDT  strcat
         DEF  strcat
         DEF  strncat
         IF   UPPER
         DEF  STRCAT
         DEF  STRNCAT
         ENDIF
;
strcat   equ  $
STRCAT   PUSH BP
         MOV  BP,SP
         MOV  CX,-1           ; no limit on length
CAT      MOV  DI,[BP][%PARM1]
         MOV  SI,[BP][%PARM2]
         MOV  AX,DS
         MOV  ES,AX
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
DONE     MOV  AX,[BP][%PARM1] ; result is pointer to string1
         POP  BP
         RETSEG
strncat  equ  $
STRNCAT  PUSH BP
         MOV  BP,SP
         MOV  CX,[BP][%PARM3] ; cx = limit on length
         JCXZ DONE
         JMPS CAT
         END
;
; -------------------------------------------------------
;   strchr(string1, c) - search string for character
; -------------------------------------------------------
;       char *strchr(s, c)
;       char *s;
;       int  c;
;
;       Purpose: Searches for first occurrence of c in s
;       Returns: Pointer to c if s contains c
;                NULL if s does not contain c
;
;
         IDT  strchr
         DEF  strchr
         IF   UPPER
         DEF  STRCHR
         ENDIF
;
strchr   equ  $
STRCHR   PUSH BP
         MOV  BP,SP
         MOV  AX,DS
         MOV  ES,AX
         MOV  DI,[BP][%PARM1]
         MOV  CX,-1
         XOR  AL,AL
         CLD
         REPNZ
         SCASB
         NOT  CX              ; CX = length including '\0'
         MOV  DI,[BP][%PARM1]
         MOV  AL,[BP][%PARM2]
         REPNZ
         SCASB
         JNZ  NOFIND
         DEC  DI
         MOV  AX,DI
         POP  BP
         RETSEG
NOFIND   XOR  AX,AX
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;   index(string1, c) - search string for character
; -------------------------------------------------------
;       char *index(s, c)
;       char *s;
;       int  c;
;
;       Purpose: Searches for first occurrence of c in s
;       Returns: Pointer to c if s contains c
;                NULL if s does not contain c
;
;
         IDT  index
         IF   UPPER
         DEF  INDEX
         ENDIF
         DEF  index
;
index    equ  $
INDEX    PUSH BP
         MOV  BP,SP
         MOV  SI,[BP][%PARM1]
         MOV  DX,[BP][%PARM2]
         CLD
CMP      LODSB
         CMP  AL,DL
         JZ   FOUND
         TEST AL,AL
         JNZ  CMP
         XOR  AX,AX           ; Not found
         POP  BP
         RETSEG
FOUND    DEC  SI              ; Return pointer to c
         MOV  AX,SI
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;   strrchr(string, c) - search string for last occurance of c
; -------------------------------------------------------
;
         IDT  strrchr
         DEF  strrchr
         IF   UPPER
         DEF  STRRCHR
         ENDIF
;
strrchr  equ  $
STRRCHR  PUSH BP
         MOV  BP,SP
         MOV  DI,[BP][%PARM1]
         CLD
         MOV  AX,DS
         MOV  ES,AX
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
         MOV  AX,[BP][%PARM2]
         REPNZ
         SCASB
         CLD
         JZ   FOUND
         XOR  AX,AX
         POP  BP
         RETSEG
FOUND    INC  DI              ; Return pointer to c
         MOV  AX,DI
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;   rindex(string, c) - search string for last occurance of c
; -------------------------------------------------------
;
         IDT  rindex
         IF   UPPER
         DEF  RINDEX
         ENDIF
         DEF  rindex
;
rindex   equ  $
RINDEX   PUSH BP
         MOV  BP,SP
         MOV  DI,[BP][%PARM1]
         CLD
         MOV  AX,DS
         MOV  ES,AX
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
         MOV  AX,[BP][%PARM2]
         REPNZ
         SCASB
         CLD
         JZ   FOUND
         XOR  AX,AX
         POP  BP
         RETSEG
FOUND    INC  DI              ; Return pointer to c
         MOV  AX,DI
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;   strcmp(string1, string2) - compare strings
;   strncmp(string1, string2,n) - compare strings
; -------------------------------------------------------
;
         IDT  strncmp
         DEF  strncmp
         IF   UPPER
         DEF  STRNCMP
         ENDIF
;
strncmp  equ  $
STRNCMP  MOV  BX,SP
         MOV  CX,[BX][%PARM3-2]
         JCXZ EQUAL
         MOV  SI,[BX][%PARM1-2]
         MOV  DI,[BX][%PARM2-2]
         MOV  AX,DS
         MOV  ES,AX
         MOV  DX,DI
         XOR  AX,AX
         MOV  BX,CX
         REPNZ                ; search for zero on string 1
         SCASB
         NEG  CX
         ADD  CX,BX
         MOV  DI,DX
         REPZ
         CMPSB
         MOV  AL,%[SI][%-1]
         SUB  AL,%[DI][%-1]
         CBW
         RETSEG
EQUAL    XOR  AX,AX
         RETSEG
         END
;
         IDT  strcmp
         DEF  strcmp
         IF   UPPER
         DEF  STRCMP
         ENDIF
strcmp   equ  $
STRCMP   MOV  BX,SP
         MOV  SI,[BX][%PARM1-2]
         MOV  DI,[BX][%PARM2-2]
         MOV  AX,DS
         MOV  ES,AX
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
         SUB  AL,%[DI][%-1]
         CBW
         RETSEG
         END
;
; -------------------------------------------------------
;   strcmpi(string1, string2) - compare strings, ignore case
; -------------------------------------------------------
;
         IDT  strcmpi
         DEF  strcmpi
         DEF  stricmp
         DEF  strnicmp
         IF   UPPER
         DEF  STRCMPI
         DEF  STRICMP
         DEF  STRNICMP
         ENDIF
;
strcmpi  EQU  $
stricmp  EQU  $
STRICMP  EQU  $
STRCMPI  PUSH BP
         MOV  BP,SP
         MOV  SI,[BP][%PARM1]
         MOV  DI,[BP][%PARM2]
         MOV  CX,-1
CMP      LODSB
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
         POP  BP
         RETSEG
END1     XOR  AH,AH           ; end of both?
         XOR  BH,BH
         SUB  AX,BX
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
         MOV  BL,[DI][%-1]
         JMPS END1
strnicmp equ  $
STRNICMP PUSH BP
         MOV  BP,SP
         MOV  SI,[BP][%PARM1]
         MOV  DI,[BP][%PARM2]
         MOV  CX,[BP][%PARM3]
         JCXZ EQUAL
         JMPS CMP
         END
;
; -------------------------------------------------------
;   strcpy(string1, string2) - copy strings
; -------------------------------------------------------
;
         IDT  strcpy
         IF   UPPER
         DEF  STRCPY
         ENDIF
         DEF  strcpy
;
strcpy   equ  $
STRCPY   MOV  BX,SP
         MOV  SI,[BX][%PARM2-2]
         MOV  DI,SI
         MOV  AX,DS
         MOV  ES,AX
         MOV  CX,-1
         XOR  AX,AX
         CLD
         REPNZ
         SCASB
         NOT  CX
         MOV  DI,[BX][%PARM1-2]
         MOV  AX,DI
         REP
         MOVSB
         RETSEG
         END
;
         IDT  stpcpy
         DEF  stpcpy
stpcpy   MOV  BX,SP
         MOV  SI,[BX][%PARM2-2]
         MOV  DI,SI
         MOV  AX,DS
         MOV  ES,AX
         MOV  CX,-1
         XOR  AX,AX
         CLD
         REPNZ
         SCASB
         NOT  CX
         MOV  DI,[BX][%PARM1-2]
         MOV  AX,DI
         ADD  AX,CX
         DEC  AX
         REP
         MOVSB
         RETSEG
         END
;
; -------------------------------------------------------
;   strncpy(string1, string2, n) - copy string
;       copy exactly n characters from string2 to string1
;       if n < length of string2, no null is appended
;       if n > length of string2, string1 padded with '\0'
; -------------------------------------------------------
;
         IDT  strncpy
         DEF  strncpy
         IF   UPPER
         DEF  STRNCPY
         ENDIF
;
strncpy  equ  $
STRNCPY  PUSH BP
         MOV  BP,SP
         MOV  DI,[BP][%PARM1]
         MOV  SI,[BP][%PARM2]
         MOV  CX,[BP][%PARM3]
         JCXZ DONE
         MOV  AX,DS
         MOV  ES,AX
         CLD
COPY     LODSB
         STOSB
         TEST AL,AL
         JZ   ENDSTR
         LOOP COPY
DONE     MOV  AX,[BP][%PARM1]
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
;       int strspn(s1, s2)
;       char *s1, *s2;
;
;       Purpose: Searches from beginning of s1
;                until a character NOT in s2 is found
;       Returns: Length of string segment in s1 consisting
;                entirely of characters contained in s2
; -------------------------------------------------------
;
         IDT  strspn
         DEF  strspn
         IF   UPPER
         DEF  STRSPN
         ENDIF
;
strspn   equ  $
STRSPN   PUSH BP
         MOV  BP,SP
         MOV  SI,[BP][%PARM1]
         MOV  DI,[BP][%PARM2]
         MOV  AX,DS
         MOV  ES,AX
         MOV  CX,-1
         XOR  AL,AL
         CLD
         REPNZ                ; get length of string2
         SCASB
         NEG  CX
         DEC  CX
         MOV  BX,CX
         XOR  DX,DX           ; initial index
         JCXZ DONE
NEXTCH   LODSB
         TEST AL,AL
         JZ   DONE
         MOV  CX,BX
         MOV  DI,[BP][%PARM2]
         REPNZ
         SCASB
         JNZ  DONE
         INC  DX
         JMPS NEXTCH
DONE     MOV  AX,DX
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;       int strcspn(s1, s2)
;       char *s1, *s2;
;
;       Purpose: Searches from beginning of s1
;                until a character in s2 is found
;       Returns: Length of string segment in s1 consisting
;                entirely of characters NOT contained in s2
; -------------------------------------------------------
;
         IDT  strcspn
         IF   UPPER
         DEF  STRCSPN
         ENDIF
         DEF  strcspn
;
strcspn  equ  $
STRCSPN  PUSH BP
         MOV  BP,SP
         MOV  SI,[BP][%PARM1]
         MOV  DI,[BP][%PARM2]
         MOV  AX,DS
         MOV  ES,AX
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
         MOV  DI,[BP][%PARM2]
         REPNZ
         SCASB
         JZ   DONE
         INC  DX
         JMPS NEXTCH
DONE     MOV  AX,DX
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;       int strpbrk(s1, s2)
;       char *s1, *s2;
;
;       Purpose: Searches from beginning of s1
;                until a character in s2 is found
;       Returns: pointer to first character found
; -------------------------------------------------------
;
         IDT  strpbrk
         IF   UPPER
         DEF  STRPBRK
         ENDIF
         DEF  strpbrk
;
strpbrk  equ  $
STRPBRK  PUSH BP
         MOV  BP,SP
         MOV  SI,[BP][%PARM1]
         MOV  DI,[BP][%PARM2]
         MOV  AX,DS
         MOV  ES,AX
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
         MOV  DI,[BP][%PARM2]
         REPNZ
         SCASB
         JZ   DONE
         JMPS NEXTCH
DONE     DEC  SI
         MOV  AX,SI
         POP  BP
         RETSEG
NONE     XOR  AX,AX
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;   strrev(string) - reverse a string
; -------------------------------------------------------
;
         IDT  strrev
         DEF  strrev
         IF   UPPER
         DEF  STRREV
         ENDIF
;
strrev   equ  $
STRREV   PUSH BP
         MOV  BP,SP
         MOV  DI,[BP][%PARM1]
         CLD
         MOV  AX,DS
         MOV  ES,AX
         MOV  CX,-1
         XOR  AL,AL
         CLD
         REPNZ                ; find end of string
         SCASB
         SUB  DI,%2
         MOV  SI,[BP][%PARM1]
REV      CMP  SI,DI
         JAE  DONE
         MOV  AL,%[DI]
         XCHG AL,%[SI]
         MOV  %[DI],AL
         INC  SI
         DEC  DI
         JMPS REV
DONE     MOV  AX,[BP][%PARM1]
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;   strsave(string) - copy to heap, NULL if no space
;   strdup(string) - copy to heap, NULL if no space
; -------------------------------------------------------
;
         IDT  strdup
         DEF  strdup
         DEF  strsave
         IF   UPPER
         DEF  STRDUP
         DEF  STRSAVE
         ENDIF
         FREF malloc
strsave  equ  $
strdup   equ  $
STRSAVE  EQU  $
STRDUP   PUSH BP
         MOV  BP,SP
         MOV  DI,[BP][%PARM1]
         TEST DI,DI
         JZ   NULL
         MOV  AX,DS
         MOV  ES,AX
         MOV  CX,-1
         XOR  AL,AL
         CLD
         REPNZ                ; get length of string2
         SCASB
         NEG  CX
         PUSH CX
         PUSH CX
         CALLFAR malloc
         ADD  SP,%2
         POP  CX
         TEST AX,AX           ; Null?
         JZ   DONE
         MOV  DI,AX
         MOV  SI,[BP][%PARM1]
         REP
         MOVSB
DONE     POP  BP
         RETSEG
NULL     XOR  AX,AX
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;   strlwr(string) - convert all uppercase letters in
;       string to lower case
; -------------------------------------------------------
;
         IDT  strlwr
         DEF  strlwr
         IF   UPPER
         DEF  STRLWR
         ENDIF
;
strlwr   equ  $
STRLWR   PUSH BP
         MOV  BP,SP
         MOV  SI,[BP][%PARM1]
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
DONE     MOV  AX,[BP][%PARM1]
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;   strupr(string) - convert all lower case letters in
;       string to upper case
; -------------------------------------------------------
;
         IDT  strupr
         DEF  strupr
         IF   UPPER
         DEF  STRUPR
         ENDIF
;
strupr   equ  $
STRUPR   PUSH BP
         MOV  BP,SP
         MOV  SI,[BP][%PARM1]
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
DONE     MOV  AX,[BP][%PARM1]
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;   strset(string,c) - set all but '\0' to c
;   strnset(string,c,n) - set up to n or '\0' to c
; -------------------------------------------------------
;
         IDT  strset
         DEF  strset
         DEF  strnset
         IF   UPPER
         DEF  STRSET
         DEF  STRNSET
         ENDIF
;
strset   equ  $
STRSET   PUSH BP
         MOV  BP,SP
         MOV  CX,-1           ; no limit on length
SET      MOV  SI,[BP][%PARM1]
         MOV  BX,[BP][%PARM2]
NEXT     MOV  AL,%[SI]
         TEST AL,AL
         JZ   DONE
         MOV  %[SI],BL
         INC  SI
         LOOP NEXT
DONE     MOV  AX,[BP][%PARM1] ; result is pointer to string1
         POP  BP
         RETSEG
strnset  equ  $
STRNSET  PUSH BP
         MOV  BP,SP
         MOV  CX,[BP][%PARM3] ; cx = limit on length
         JCXZ DONE
         JMPS SET
         END
;
; -------------------------------------------------------
;       int strlen(s)
;       char *s;
;       Purpose: Returns the length of the string, not
;                including the NULL character
; -------------------------------------------------------
;
         IDT  strlen
         DEF  strlen
         IF   UPPER
         DEF  STRLEN
         ENDIF
;
strlen   equ  $
STRLEN   MOV  BX,SP
         MOV  DI,[BX][%PARM1-2]
         CMP  DI,%0
         JZ   NULL
         MOV  AX,DS
         MOV  ES,AX
         MOV  CX,-1
         XOR  AL,AL
         CLD
         REPNZ
         SCASB
         NOT  CX
         DEC  CX
         MOV  AX,CX
         RETFAR
NULL     XOR  AX,AX
         RETFAR
         END
;
; -------------------------------------------------------
;       int strstr(s1, s2)
;       char *s1, *s2;
;
;       Purpose: Searches s1 for the first occurrence
;                of s2
;       Returns: pointer to substring if found,
;                NULL if not found
; -------------------------------------------------------
;
         IDT  strstr
         DEF  strstr
         IF   UPPER
         DEF  STRSTR
         ENDIF
;
strstr   equ  $
STRSTR   PUSH BP
         MOV  BP,SP
         MOV  DI,[BP][%PARM1]
         MOV  AX,DS
         MOV  ES,AX
         MOV  CX,-1
         XOR  AL,AL
         CLD
         REPNZ
         SCASB
         NOT  CX
         DEC  CX
         MOV  DX,CX           ; DX is length of s1
         MOV  DI,[BP][%PARM2]
         MOV  CX,-1
         REPNZ
         SCASB
         NOT  CX
         DEC  CX              ; CX is length of s2
         CMP  CX,DX
         JA   NOFIND          ; s2 is longer than s1
         MOV  AX,[BP][%PARM1] ; initial s1 pointer
         JCXZ FOUND           ; length of s2 is zero
         MOV  BX,CX           ; save s2 length
         SUB  DX,BX           ; number of positions to try
         INC  DX
NEXTPOS  MOV  CX,BX           ; length of s2
         MOV  SI,[BP][%PARM2] ; start of s2
         MOV  DI,AX           ; current position in s1
         REPZ
         CMPSB                ; compare
         JZ   FOUND           ; strings match
         INC  AX              ; try next position
         DEC  DX
         JNZ  NEXTPOS
NOFIND   XOR  AX,AX
FOUND    POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;       int stristr(s1, s2)
;       char *s1, *s2;
;
;       Purpose: Searches s1 for the first occurrence
;                of s2 (case is ignored)
;       Returns: pointer to substring if found,
;                NULL if not found
; -------------------------------------------------------
;
         IDT  stristr
         DEF  stristr
         IF   UPPER
         DEF  STRISTR
         ENDIF
;
stristr  equ  $
STRISTR  PUSH BP
         MOV  BP,SP
         SUB  SP,%2
         MOV  DI,[BP][%PARM1]
         MOV  AX,DS
         MOV  ES,AX
         MOV  CX,-1
         XOR  AL,AL
         CLD
         REPNZ
         SCASB
         NOT  CX
         DEC  CX
         MOV  DX,CX           ; DX is length of s1
         MOV  DI,[BP][%PARM2]
         MOV  CX,-1
         REPNZ
         SCASB
         NOT  CX
         DEC  CX              ; CX is length of s2
         CMP  CX,DX
         JA   NOFIND          ; s2 is longer than s1
         MOV  AX,[BP][%PARM1] ; initial s1 pointer
         JCXZ FOUND           ; length of s2 is zero
         MOV  BX,CX           ; save s2 length
         SUB  DX,BX           ; number of positions to try
         INC  DX
         MOV  [BP][%-2],DX
NEXTPOS  MOV  CX,BX           ; length of s2
         MOV  SI,[BP][%PARM2] ; start of s2
         MOV  DI,AX           ; current position in s1
COMP     REPZ
         CMPSB                ; compare
         JZ   FOUND           ; strings match
         MOV  DL,[SI][%-1]
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
FOUND    MOV  SP,BP
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;       char *strtok(s1, s2)
;       char *s1, *s2;
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
         IDT  strtok
         IF   UPPER
         DEF  STRTOK
         ENDIF
         DEF  strtok
;
         DORG 0
STRPTR   DW      0
         ORG  $
strtok   equ  $
STRTOK   PUSH BP
         MOV  BP,SP
         MOV  DI,[BP][%PARM2]
         MOV  AX,DS
         MOV  ES,AX
         CLD
         MOV  CX,-1
         XOR  AL,AL
         REPNZ
         SCASB                ; Find length of s2
         NOT  CX
         JCXZ NOS2            ; Return null if s2 is empty
         MOV  DX,CX           ; save length of s2
         MOV  SI,[BP][%PARM1]
         TEST SI,SI           ; is s1 null?
         JNZ  NEXTCH
         MOV  SI,[STRPTR]
         TEST SI,SI
         JZ   EMPTY           ; no previous string
NEXTCH   LODSB                ; get s1 character
         TEST AL,AL
         JZ   EMPTY           ; end of s1
         MOV  CX,DX
         MOV  DI,[BP][%PARM2]
         REPNZ
         SCASB                ; check in delimiter set
         JZ   NEXTCH
         MOV  BX,SI           ; address of first non-delimiter
         DEC  BX
TOKCH    LODSB
         TEST AL,AL
         JZ   ENDS1
         MOV  CX,DX
         MOV  DI,[BP][%PARM2]
         REPNZ
         SCASB
         JNZ  TOKCH           ; not a delimiter
         MOV  [STRPTR],SI
         MOV  %[SI][%-1],%0   ; terminate token
         MOV  AX,BX
         POP  BP
         RETSEG
EMPTY    XOR  AX,AX
         MOV  [STRPTR],AX
         POP  BP
         RETSEG
NOS2     MOV  CX,[BP][%PARM1]
         MOV  [STRPTR],CX
         XOR  AX,AX
         POP  BP
         RETSEG
ENDS1    MOV  AX,BX
         MOV  [STRPTR],0
         POP  BP
         RETSEG
         END
