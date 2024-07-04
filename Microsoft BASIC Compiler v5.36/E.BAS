100 DIGITS% = 200
110 DIM A%( 200 )
120 HIGH% = DIGITS%
130 X% = 0
140 N% = HIGH% - 1
150 IF N% <= 0 GOTO 200
160 A%[ N% ] = 1
170 N% = N% - 1
180 GOTO 150
200 A%[ 1 ] = 2
210 A%[ 0 ] = 0
220 IF HIGH% <= 9 GOTO 400
230 HIGH% = HIGH% - 1
235 N% = HIGH%
240 IF N% = 0 GOTO 300
250 A%[ N% ] = X% MOD N%
255 rem PRINT "a[n-1]"; A%[ N% - 1 ]
260 X% = ( 10 * A%[ N% - 1 ] ) + ( X% \ N% )
265 rem PRINT "x: "; X%, "n: "; N%
270 N% = N% - 1
280 GOTO 240
300 IF X% >= 10 GOTO 330
310 PRINT USING "#"; X%;
320 GOTO 220
330 PRINT USING "##"; X%;
340 GOTO 220
400 PRINT ""
410 PRINT "done"
420 SYSTEM


