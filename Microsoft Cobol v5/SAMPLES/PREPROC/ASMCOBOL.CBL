      $Set preprocess(preproc)

      * ASMCOBOL.CBL - Example program for use with the example
      * integrated preprocessor.
      *
      * The preprocessor PREPROC will process MOV, DIS, COPY, CPY, WARN
      * and ERROR verbs.  The preprocessor PREPROX will process the
      * PRINT verb.  As it stands, this program only uses the PREPROC
      * preprocessor; to demonstrate the effect of using stacked
      * preprocessors, change the first line to
      *
      * $Set preprocess(preproc) preprocess(preprox)
      *
      * (note that this line MUST be the first in the source)
      *
      * and un-comment the penultimate line of this program.
      *
      * Note:  The processing of COPY and CPY is not as described in
      * the preprocessor documentation.  CPY is expanded to COPY by the
      * and then processed by the Checker (it receives the original CPY
      * statement - which is ignored - followed by a valid COPY
      * statement that the preprocessor has generated. It then opens the
      * file and compiles the contents.  The contents of the copybook
      * are not preprocessed.)  COPY statements are here handled by the
      * preprocessor - it opens the file and sends each line to the
      * Checker, preprocessing the contents. The COPY statement must be
      * valid COBOL *in the original source* as the Checker will parse
      * it in order to decide whether to do REPLACING on the
      * preprocessed input.

       working-storage section.
       cpy "working.cbl".
       cpy "working.cbl" replacing file-stat by file-stat-2.
       01 data-item1   pic 99.
       01 data-item2   pic 99.
       01 data-item3   pic 99.
       copy "working.cbl".
       copy "working.cbl" replacing file-stat by file-stat-3.
       procedure division.
       start-para section.
           mov 1 to data-item1. dis data-item1.
           MOV  1  to    data-item1.
           MOV  2  to    data-item2.
           mov  3  to    data-item3.
      *    print data-item1. print data-item2. print data-item3.
           STOP      RUN.
