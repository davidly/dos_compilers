      *************************************************************
      *                                                           *
      *               (C) Micro Focus Ltd. 1991                   *
      *                                                           *
      * You can use this program to understand:                   *
      *                                                           *
      * 1.  how COMP, COMP-X and COMP-5 data is stored and the    *
      *     basic concepts of these data types.                   *
      *     (Example A, B and C)                                  *
      *                                                           *
      * 2.  how the IBMCOMP directive impacts data storage        *
      *     (Example D)                                           *
      *                                                           *
      * 3.  the impact of using the COMP directive with COMP data *
      *                                                           *
      * 4.  how the ALIGN directive impacts data storage          *
      *     (Example E)                                           *
      *                                                           *
      * 5.  how the NOTRUNC, TRUNC and TRUNC"ANSI" impacts data   *
      *     storage (you will need to recheck for each directive  *
      *     (Example F)                                           *
      *                                                           *
      * 6.  how the COMP-5 directive impacts how COMP-5 negative  *
      *     numeric data gets handled at execution time.          *
      *                                                           *
      * Note you will need to recheck for each new directive      *
      * setting.                                                  *
      *                                                           *
      * To use the program, compile with the ANIM directive:      *
      *                                                           *
      *                 compile tstcomp anim;                     *
      *                                                           *
      * then animate using:                                       *
      *                                                           *
      *                 animate tstcomp                           *
      *                                                           *
      *************************************************************


      *************************************************************
      *  For Example C (COMP-5 storage using the COMP-5 directive)*
      *  select one of the following to see the impact of COMP-5  *
      *  directive on the variable "c3"                           *
      *************************************************************

      $SET COMP-5"1"
      *SET COMP-5"2"

      *************************************************************
      *  For Example F (COMP storage using TRUNC directive)       *
      *  select one of the following to see the impact of the     *
      *  TRUNC directive on the variable "g1"                     *
      *************************************************************

      *SET NOTRUNC
      *SET TRUNC
      $SET TRUNC"ANSI"

       working-storage section.
      *************************************************************
      *    Summary of COMP, COMP-X and COMP-5                     *
      *                                                           *
      *        Binary or  Support       Support      Impacted by  *
      *        Reversed   signed flds?  pic x flds?  directives   *
      *                                                           *
      *  COMP     B         Y             N          TRUNC, COMP  *
      *                                              IBMCOMP,     *
      *                                              ALIGN        *
      *                                                           *
      *  COMP-X   B         N             Y          N            *
      *                                                           *
      *  COMP-5   R         Y             Y          COMP-5       *
      *                                                           *
      *************************************************************

      *************************************************************
      * Example A - COMP storage                                  *
      *                                                           *
      * - stores numeric data in binary representation            *
      * - must be represented with a numeric picture clause       *
      * - data is stored in pure binary twos' complement          *
      *   representation                                          *
      * - impacted by IBMCOMP, TRUNC, COMP, ALIGN directives      *
      *                                                           *
      * Using the Query,Cursor option of animator, the data will  *
      * be reflected in hex as follows:                           *
      *  a1:  00 30 39  0000 0000 0011 0000 0011 1001 is 12345 in *
      *       binary                                              *
      *  a2:  FF CF C7  1111 1111 1100 1111 1100 0110 is twos'    *
      *       complement                                          *
      *                                                           *
      *************************************************************

       01  a1  pic 9(5) comp value 12345.
       01  a2  pic S9(5) comp value -12345.
      *01  a3  pic X(5) comp value 12345.  (Pic X is not legal for COMP)

      *************************************************************
      * Example B - COMP-X storage                                *
      * - stores numeric data in binary representation            *
      * - CAN NOT BE SIGNED (remove comments below to see syntax  *
      *   error)                                                  *
      * - can use an X picture to specify the number of bytes of  *
      *   storage                                                 *
      * - data is stored in pure binary twos' complement          *
      *   representation                                          *
      * - NOT impacted by IBMCOMP, TRUNC, COMP, ALIGN             *
      *                                                           *
      * Using Query,Cursor, the data will be reflected in hex as  *
      * follows:                                                  *
      *  b1:  00 30 39                                            *
      *  b2:  00 00 00 30 39                                      *
      *************************************************************

       01  b1  pic 9(5) comp-x value 12345.
      *01  b2  pic S9(5) comp-x value 12345. (Signed pic 9 is not legal
      * 				      for COMP-X)
       01  b3  pic X(5) comp-x value 12345.
      *01  b4  pic X(5) comp-x value -12345.  (Signed pic X is not legal
      * 				       for COMP-X)

      *************************************************************
      * Example C - COMP-5 storage                                *
      * - stores numeric data in reverse binary representation    *
      * - can be signed (remove comment below to see syntax error)*
      * - If an "X" is used in the picture clause, it is treated  *
      *   as unsigned data                                        *
      * - storage of data is operating system specific - on the   *
      *   PC data is stored in reverse binary twos' complement    *
      *   representation                                          *
      * - NOT impacted by IBMCOMP, TRUNC, COMP, ALIGN             *
      * - impacted by the COMP-5 directive                        *
      *                                                           *
      * Using Query, Cursor, the data will be reflected in hex as *
      * follows:                                                  *
      *  c1:  39 30 00                                            *
      *  c2:  C7 CF FF                                            *
      *  c3:  39 30 00 00 00                                      *
      *  c5:  39 30 00 00 00   (Using COMP-5"1")                  *
      *  c5:  C7 CF FF FF FF   (Using COMP-5"2" - this is the     *
      *       default)                                            *
      *************************************************************

       01  c1  pic 9(5) comp-5 value 12345.
       01  c2  pic S9(5) comp-5 value -12345.
       01  c3  pic X(5) comp-5 value 12345.
      *01  c4  pic X(5) comp-5 value -12345. (Signed pic X is not legal
      * 				      for COMP-X)
       01  c5  pic X(5) comp-5.

      *************************************************************
      * Example D - COMP storage using IBMCOMP                    *
      *  This demonstrates the impact of the IBMCOMP directive.   *
      *  This forces storage of all COMP fields to be in          *
      *  multiples of 2 or 4                                      *
      *************************************************************

      $SET IBMCOMP

      *************************************************************
      * Using Query,Cursor, the data will be reflected in hex as  *
      * follows:                                                  *
      *  d1:  00 00 30 39                                         *
      *  d2:  FF FF CF C7                                         *
      *************************************************************

       01  d1  pic 9(5) comp value 12345.
       01  d2  pic S9(5) comp value -12345.
      *01  d3  pic X(5) comp value 12345.  (Pic X is not legal for COMP)

      $SET NOIBMCOMP

      *************************************************************
      * Example E - COMP storage using ALIGN directive -          *
      *             ALIGN"integer"                                *
      * This demonstrates the impact of the ALIGN directive. The  *
      * distance from one 01 to the next 01 is a multiple of      *
      *  "integer".                                               *
      *                                                           *
      * Using Query,Cursor - notice the address of each 01 field  *
      * below and the difference between the address of a0 and b9 *
      * versus the difference between the address of a10 and b10  *
      *************************************************************

      $SET ALIGN"1"
       01  e1  pic 9(5) comp value 12345.
       01  e2  pic 9(5) comp value 12345.

      $SET ALIGN"8"
       01  e3  pic 9(5) comp value 12345.
       01  e4  pic 9(5) comp value 12345.


      *************************************************************
      * Example F - COMP storage using TRUNC directive            *
      *  This demonstrates the impact of the TRUNC directive.     *
      *   Using NOTRUNC - the full hex value is stored            *
      *   Using TRUNC - truncate in decimal to the number of      *
      *                 digits given by the picture clause on all *
      *                 COMP stores                               *
      *   Using TRUNC"ANSI"                                       *
      *               - truncate in decimal to the number of      *
      *                 digits given by the picture clause on     *
      *                 non-arithmetic stores into COMP items.    *
      * Query,Cursor this field before and after it is            *
      * incremented.                                              *
      *              f1     f1+1    f1+1+199     move 198 to f1   *
      *  NOTRUNC     09      0A        D1              C7         *
      *  TRUNC       09      00        09              08         *
      *  TRUNC"ANSI" 09      0A        D1              08         *
      *************************************************************

       01  f1  pic 9 comp value 9.

      *************************************************************
      * The impact of using the COMP directive                    *
      *                                                           *
      * The COMP directive makes the compiler produce very        *
      * compact and efficient code for some statements involving  *
      * COMP data items, by treating COMP data as COMP-X.  You    *
      * can not directly see the impact of using this directive.  *
      * On numeric overflow calculations, the compiler will       *
      * perform in a non-standard way.  Only use this directive   *
      * if you know your program does not lead to numeric         *
      * overflow or if you have programatically defined the       *
      * execution path on overflow.                               *
      *************************************************************

       procedure division.
	   move -12345 to c5.

	   add 1       to f1.
           add 199     to f1.
	   move 198    to f1.

	   stop run.
