CC  SETROWS.FOR - Illustrates:settextrows

      INCLUDE  'FGRAPH.FI'
      INCLUDE  'FGRAPH.FD'

      INTEGER*2    rows
      CHARACTER*2  arg
C
C     Get command line argument: 25, 43, or 50.
C
      CALL GETARG( 1, arg, 2 )
      rows = 0
      IF( arg .EQ. '25' ) rows = 25
      IF( arg .EQ. '30' ) rows = 30
      IF( arg .EQ. '43' ) rows = 43
      IF( arg .EQ. '50' ) rows = 50
      IF( arg .EQ. '60' ) rows = 60
C
C     Make sure new rows are valid and the same as requested rows.
C
      IF( (rows .EQ. 0) .OR. (settextrows( rows ) .NE. rows) ) THEN
         WRITE (*,*) 'Syntax: SETROWS [ 25 | 30 | 43 | 50 | 60 ]'
         STOP 01
      END IF
C
C     Return 0 if successful
C
      STOP 00
      END
