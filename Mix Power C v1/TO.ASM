;
;   Copyright (c) Mix Software 1988
;
; -------------------------------------------------------
;  toupper() - convert character to upper case
;  #define toupper(c) ((c >= 'a' && c <= 'z') ? c - 0x20 : c)
; -------------------------------------------------------
;
         IDT  toupper
         DEF  toupper
         IF   UPPER
         DEF  TOUPPER
         ENDIF
         ENDIF
;
toupper  equ  $
TOUPPER  MOV  BX,SP
         MOV  AX,[BX][%PARM1-2]
         CMP  AX,'a'
         JB   OK
         CMP  AX,'z'
         JA   OK
         SUB  AX,>20
OK       RETSEG
         END
;
; -------------------------------------------------------
;  tolower() - convert character to lower case
;  #define tolower(c) ((c >= 'A' && c <= 'Z') ? c + 0x20 : c)
; -------------------------------------------------------
;
         IDT  tolower
         DEF  tolower
         IF   UPPER
         DEF  TOLOWER
         ENDIF
;
tolower  equ  $
TOLOWER  MOV  BX,SP
         MOV  AX,[BX][%PARM1-2]
         CMP  AX,'A'
         JB   OK
         CMP  AX,'Z'
         JA   OK
         ADD  AX,>20
OK       RETSEG
         END
;
; -------------------------------------------------------
;  toascii() - convert character to ascii
;  #define toascii(c) (c & 0x007f)
; -------------------------------------------------------
;
         IDT  toascii
         DEF  toascii
         IF   UPPER
         DEF  TOASCII
         ENDIF
;
toascii  equ  $
TOASCII  MOV  BX,SP
         MOV  AX,[BX][%PARM1-2]
         AND  AX,>007F
         RETSEG
         END
;
; -------------------------------------------------------
;  _toupper() - convert character to upper case
;  #define _toupper(c) (c - 0x20)
; -------------------------------------------------------
;
         IDT  _toupper
         DEF  _toupper
         IF   UPPER
         DEF  _TOUPPER
         ENDIF
;
_toupper equ  $
_TOUPPER MOV  BX,SP
         MOV  AX,[BX][%PARM1-2]
         SUB  AX,>0020
         RETSEG
         END
;
; -------------------------------------------------------
;  _tolower() - convert character to lower case
;  #define tolower(c) (C + 0x20)
; -------------------------------------------------------
;
         IDT  _tolower
         DEF  _tolower
         IF   UPPER
         DEF  _TOLOWER
         ENDIF
;
_tolower equ  $
_TOLOWER MOV  BX,SP
         MOV  AX,[BX][%PARM1-2]
         ADD  AX,>0020
         RETSEG
         END
;
;
; -------------------------------------------------------
;  isalpha() - returns 1 if c is alphabetic else 0
;  #define isalpha ((c >= 'a' && c <= 'z' || c >= 'A' && c <= 'Z') ? 1 : 0)
; -------------------------------------------------------
;
         IDT  isalpha
         DEF  isalpha
         IF   UPPER
         DEF  ISALPHA
         ENDIF
;
isalpha  equ  $
ISALPHA  MOV  BX,SP
         MOV  AX,[BX][%PARM1-2]
         CMP  AX,'a'
         JB   TRYUPPER
         CMP  AX,'z'
         JBE  YES
TRYUPPER CMP  AX,'A'
         JB   NO
         CMP  AX,'Z'
         JA   NO
YES      MOV  AX,1
         RETSEG
NO       XOR  AX,AX
         RETSEG
         END
;
; -------------------------------------------------------
;  isdigit() - returns 1 if c is a digit else 0
;  #define isdigit ((c >= '0' && c <= '9') ? 1 : 0)
; -------------------------------------------------------
;
         IDT  isdigit
         DEF  isdigit
         IF   UPPER
         DEF  ISDIGIT
         ENDIF
;
isdigit  equ  $
ISDIGIT  MOV  BX,SP
         MOV  AX,[BX][%PARM1-2]
         CMP  AX,'0'
         JB   NO
         CMP  AX,'9'
         JA   NO
         MOV  AX,1
         RETSEG
NO       XOR  AX,AX
         RETSEG
         END
;
; -------------------------------------------------------
;  isspace() - returns 1 if c is white space else 0
;  #define isspace ((c == ' ' || c >= '0x09' && c <= '0x0d') ? 1 : 0)
; -------------------------------------------------------
;
         IDT  isspace
         DEF  isspace
         IF   UPPER
         DEF  ISSPACE
         ENDIF
;
isspace  equ  $
ISSPACE  MOV  BX,SP
         MOV  AX,[BX][%PARM1-2]
         CMP  AX,' '
         JZ   YES
         CMP  AX,>0009
         JB   NO
         CMP  AX,>000D
         JA   NO
YES      MOV  AX,1
         RETSEG
NO       XOR  AX,AX
         RETSEG
         END
;
; -------------------------------------------------------
;  islower() - returns 1 if c is lower case else 0
;  #define islower ((c >= 'a' && c <= 'z') ? 1 : 0)
; -------------------------------------------------------
;
         IDT  islower
         DEF  islower
         IF   UPPER
         DEF  ISLOWER
         ENDIF
;
islower  equ  $
ISLOWER  MOV  BX,SP
         MOV  AX,[BX][%PARM1-2]
         CMP  AX,'a'
         JB   NO
         CMP  AX,'z'
         JA   NO
         MOV  AX,1
         RETSEG
NO       XOR  AX,AX
         RETSEG
         END
;
; -------------------------------------------------------
;  isupper() - returns 1 if c is upper case else 0
;  #define islower ((c >= 'A' && c <= 'Z') ? 1 : 0)
; -------------------------------------------------------
;
         IDT  isupper
         DEF  isupper
         IF   UPPER
         DEF  ISUPPER
         ENDIF
;
isupper  equ  $
ISUPPER  MOV  BX,SP
         MOV  AX,[BX][%PARM1-2]
         CMP  AX,'A'
         JB   NO
         CMP  AX,'Z'
         JA   NO
         MOV  AX,1
         RETSEG
NO       XOR  AX,AX
         RETSEG
         END
;
; -------------------------------------------------------
;  isalnum() - returns 1 if c is a letter or a digit
;  #define isalnum ((c >= 'A' && c <= 'Z' || c >= 'a' && c <= 'z'
;                  || c >= '0' && c <= '9') ? 1 : 0)
; -------------------------------------------------------
;
         IDT  isalnum
         DEF  isalnum
         IF   UPPER
         DEF  ISALNUM
         ENDIF
;
isalnum  equ  $
ISALNUM  MOV  BX,SP
         MOV  AX,[BX][%PARM1-2]
         CMP  AX,'a'
         JB   TRYUPPER
         CMP  AX,'z'
         JBE  YES
TRYUPPER CMP  AX,'A'
         JB   TRYDIGIT
         CMP  AX,'Z'
         JBE  YES
TRYDIGIT CMP  AX,'0'
         JB   NO
         CMP  AX,'9'
         JA   NO
YES      MOV  AX,1
         RETSEG
NO       XOR  AX,AX
         RETSEG
         END
;
; -------------------------------------------------------
;  isascii() - returns 1 if c is ascii else 0
;  #define isascii ((c >= 0 && c <= 0x7f) ? 1 : 0)
; -------------------------------------------------------
;
         IDT  isascii
         DEF  isascii
         IF   UPPER
         DEF  ISASCII
         ENDIF
;
isascii  equ  $
ISASCII  MOV  BX,SP
         MOV  AX,[BX][%PARM1-2]
         CMP  AX,>007F
         JA   NO
         MOV  AX,1
         RETSEG
NO       XOR  AX,AX
         RETSEG
         END
;
; -------------------------------------------------------
;  iscntrl() - returns 1 if c 0..0x1f or 0x7f else 0
;  #define iscntrl ((c < 32 || c == 0x7f) ? 1 : 0)
; -------------------------------------------------------
;
         IDT  iscntrl
         DEF  iscntrl
         IF   UPPER
         DEF  ISCNTRL
         ENDIF
;
iscntrl  equ  $
ISCNTRL  MOV  BX,SP
         MOV  AX,[BX][%PARM1-2]
         CMP  AX,>0020
         JB   YES
         CMP  AX,>007F
         JNZ  NO
YES      MOV  AX,1
         RETSEG
NO       XOR  AX,AX
         RETSEG
         END
;
; -------------------------------------------------------
;  isprint() - returns 1 if c 0x20..0x7e else 0
;  #define isprint ((c < 32 || c > 0x7e) ? 0 : 1)
; -------------------------------------------------------
;
         IDT  isprint
         DEF  isprint
         IF   UPPER
         DEF  ISPRINT
         ENDIF
;
isprint  equ  $
ISPRINT  MOV  BX,SP
         MOV  AX,[BX][%PARM1-2]
         CMP  AX,>0020
         JB   NO
         CMP  AX,>007E
         JA   NO
YES      MOV  AX,1
         RETSEG
NO       XOR  AX,AX
         RETSEG
         END
;
; -------------------------------------------------------
;  isgraph() - returns 1 if c 0x20..0x7e else 0
;  #define isgraph ((c <= 32 || c > 0x7e) ? 0 : 1)
; -------------------------------------------------------
;
         IDT  isgraph
         DEF  isgraph
;
isgraph  MOV  BX,SP
         MOV  AX,[BX][%PARM1-2]
         CMP  AX,>0020
         JBE  NO
         CMP  AX,>007E
         JA   NO
YES      MOV  AX,1
         RETSEG
NO       XOR  AX,AX
         RETSEG
         END
;
; -------------------------------------------------------
;  ispunct() - returns 1 if c is punctuation (both isalnum
;        and iscntrl are false
;  #define ispunct(c) (!isalnum(c) && !iscntrl(c))
; -------------------------------------------------------
;
         IDT  ispunct
         DEF  ispunct
         IF   UPPER
         DEF  ISPUNCT
         ENDIF
;
ispunct  equ  $
ISPUNCT  MOV  BX,SP
         MOV  AX,[BX][%PARM1-2]
         CMP  AX,'a'
         JB   TRYUPPER
         CMP  AX,'z'
         JBE  NO
TRYUPPER CMP  AX,'A'
         JB   TRYDIGIT
         CMP  AX,'Z'
         JBE  NO
TRYDIGIT CMP  AX,'0'
         JB   TRYCTRL
         CMP  AX,'9'
         JBE  NO
TRYCTRL  CMP  AX,>0020
         JB   NO
         CMP  AX,>007F
         JZ   NO
YES      MOV  AX,1
         RETSEG
NO       XOR  AX,AX
         RETSEG
         END
;
; -------------------------------------------------------
;  isxdigit() - returns 1 if c is a hex digit
;  #define isxdigit(c) ((c >= 'A' && c <= 'F' || c >= 'a' && c <= 'f'
;                  || c >= '0' && c <= '9') ? 1 : 0)
; -------------------------------------------------------
;
         IDT  isxdigit
         DEF  isxdigit
         IF   UPPER
         DEF  ISXDIGIT
         ENDIF
;
isxdigit equ  $
ISXDIGIT MOV  BX,SP
         MOV  AX,[BX][%PARM1-2]
         CMP  AX,'0'
         JB   TRYUPPER
         CMP  AX,'9'
         JBE  YES
TRYUPPER CMP  AX,'A'
         JB   TRYLOWER
         CMP  AX,'F'
         JBE  YES
TRYLOWER CMP  AX,'a'
         JB   NO
         CMP  AX,'f'
         JA   NO
YES      MOV  AX,1
         RETSEG
NO       XOR  AX,AX
         RETSEG
         END
