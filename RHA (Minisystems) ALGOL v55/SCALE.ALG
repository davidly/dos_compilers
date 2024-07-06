BEGIN ARRAY scale, freq, just[0:25], fifths[1:12];
INTEGER ARRAY major, minor[1:6], title[1:100];
INTEGER note, base, interval, char;
REAL ARRAY minorerror, majorerror[0:12];
REAL ARRAY lminorerror, lmajorerror[0:12];
REAL ARRAY tminorerror, tmajorerror[0:12];
REAL scalecents, justcents, cfreq;
REAL minorsum, majorsum, minorbigsum, majorbigsum;
REAL lminorsum, lmajorsum, lminorbigsum, lmajorbigsum;
REAL purefifth, pythag, syntonic, logmult;
INTEGER xcount, starcount, goodcount;
INTEGER outdev;

PROCEDURE format(n); VALUE n; INTEGER n; ioc(49);

PRODECURE circle heading;
BEGIN	text(1,
" C-G   G-D   D-A   A-E   E-B   B-F#  F#-C#  C#-G#  G#-D#  D#-A#  A#-F  F-C");
skip(1);
END circle heading;

PROCEDURE circle echo;
BEGIN	INTEGER f, c;
	text(outdev,
"   C-G    G-D    D-A    A-E    E-B    B-F#   F#-C#  C#-G#  G#-D#  D#-A#  A#-F   F-C*N   ");
	ioc(0); note := 0;
	FOR f := 1 STEP 1 UNTIL 12 DO
	BEGIN	WHILE note <= &*S AND note # 13 DO note := chin(7);
		FOR c := 1 STEP 1 UNTIL 7 DO
		BEGIN	IF note > &*S THEN
			BEGIN	chout(outdev, note); note := chin(7);
			END
			ELSE chout( outdev, &*S );
		END;
	END;
	skip(outdev);
	note := 0;
	FOR f := 1 STEP 1 UNTIL 12 DO
	BEGIN	scalecents := abs( 3.0*freq[note] - 2.0*freq[note+7] );
		rwrite( outdev, scalecents*60, 6, 0);
		note := note + 7; IF note > 11 THEN note := note - 12;
	END;
	skip(outdev);
	note := 0;
	FOR f := 1 STEP 1 UNTIL 12 DO
	BEGIN	scalecents := abs( 3.0*freq[note] - 2.0*freq[note+7] );
		rwrite( outdev, scalecents, 6, 2);
		note := note + 7; IF note > 11 THEN note := note - 12;
	END;
	skip(outdev);
END circle echo;

PROCEDURE write note( note );
INTEGER note;
BEGIN	IF note > 11 THEN note := note - 12;
CASE note OF
0:	text(outdev, "C " );
1:	text(outdev, "C#" );
2:	text(outdev, "D " );
3:	text(outdev, "D#" );
4:	text(outdev, "E " );
5:	text(outdev, "F " );
6:	text(outdev, "F#" );
7:	text(outdev, "G " );
8:	text(outdev, "G#" );
9:	text(outdev, "A " );
10:	text(outdev, "A#" );
11:	text(outdev, "B " )
ELSE    text(outdev, "??" );
END write note;

PROCEDURE set just scale;
BEGIN	logmult := 1200.00/ln(2);
	just[0] := 0; just[12] := 1200.00; just[24] := 2400.00;
	just[1] := 111.73; just[2] := logmult*ln(1.125);
	just[3] := logmult*ln(1.2); just[4] := logmult*ln(1.25);
	just[5] := logmult*ln(4.0/3.0); just[6] := 590.22;
	just[7] := logmult*ln(1.5); just[8] := logmult*ln(1.6);
	just[9] := logmult*ln(5.0/3.0); just[10] := logmult*ln(16.0/9.0);
	just[11] := logmult*ln(1.875);

	purefifth := just[7];
	pythag := 12.00 * purefifth - 8400.00;
	syntonic := 4.00 * purefifth - 2400.00 - just[4];

	FOR note := 1 STEP 1 UNTIL 11 DO
		just[note+12] := just[note]+1200.00;

	major[1] := 2; major[2] := 4; major[3] := 5;
	major[4] := 7; major[5] := 9; major[6] := 11;

	minor[1] := 2; minor[2] := 3; minor[3] := 5;
	minor[4] := 7; minor[5] := 8; minor[6] := 11;
END set just scale;

PROCEDURE ay38912( octave ); VALUE octave; REAL octave;
BEGIN

text(outdev, "*N  ");
FOR note := 0 STEP 1 UNTIL 11 DO
	rwrite( outdev, entier(125000.00/(freq[note]*octave) + 0.5), 8, 0 );

text(outdev, "*N  ");
FOR note := 0 STEP 1 UNTIL 11 DO
	rwrite( outdev, (freq[note]*octave), 8, 2 );

text(outdev, "*N  ");
FOR note := 0 STEP 1 UNTIL 11 DO
BEGIN	interval := entier(125000.00/(freq[note]*octave) + 0.5);
	rwrite( outdev, 125000.00/interval, 8, 2 );
END;

text(outdev, "*N  ");
cfreq := freq[0]*octave;
FOR note := 0 STEP 1 UNTIL 11 DO
BEGIN	interval := entier(125000.00/(freq[note]*octave) + 0.5);
	scalecents := 125000.00/interval;
	rwrite( outdev, logmult*ln(scalecents/cfreq) - scale[note], 8, 2 );
END;
END ay38912;

PROCEDURE write scale error( error, lerror );
VALUE error, lerror; REAL error, lerror;
BEGIN	IF error > 90.00 THEN format( 512+&X )
	ELSE IF error > 60.00 THEN format( 512+&** )
	ELSE IF error < 40.00 THEN format( 512+&= )
	ELSE IF (error < 48.80) OR (error < 48.90 AND lerror < 33.20)
		THEN format( 512+&E );
	rwrite(outdev, error, 8, 2);
	format( 512+&*S );
END;

PROCEDURE scale from fifths;
BEGIN	scale[0] := scalecents := 0; interval := 0;
	FOR note := 1 STEP 1 UNTIL 11 DO
	BEGIN	interval := interval + 7;
		scalecents := scalecents + fifths[note];
		IF interval > 11 THEN
		BEGIN	interval := interval - 12;
			scalecents := scalecents - 1200.00;
		END;
		scale[interval] := scalecents;
	END;
	FOR note := 0 STEP 1 UNTIL 11 DO
	BEGIN	scale[note+12] := scale[note]+1200.00;
		scalecents := scale[note] - scale[9];
		freq[note] := 440.0 * exp(scalecents/logmult);
		freq[note+12] := 2.0 * freq[note];
	END;

END scale from fifths;

PROCEDURE readcents;
BEGIN
	text( 1, "*NType 11 cent offsets from C*N" );
	scale[0] := 0;
	FOR note := 1 STEP 1 UNTIL 11 DO
	BEGIN	scale[note] := read(7);
	END;
	FOR note := 1 STEP 1 UNTIL 12 DO
		fifths[note] := scale[note+6] - scale[note-1];
	FOR note := 0 STEP 1 UNTIL 11 DO
	BEGIN	scale[note+12] := scale[note]+1200.00;
		scalecents := scale[note] - scale[9];
		freq[note] := 440.0 * exp(scalecents/logmult);
		freq[note+12] := 2.0 * freq[note];
	END;
END readcents;

PROCEDURE readfifths;
BEGIN	text( 1, "*NCircle of 11 fifths in cents from C*N" );

	circle heading;
	scalecents := 0;
	FOR note := 1 STEP 1 UNTIL 11 DO
	BEGIN	fifths[note] := read(7);
		scalecents := scalecents + fifths[note];
	END;
	fifths[12] := 8400.00 - scalecents;
	scale from fifths;
END readfifths;

PROCEDURE readcommas;
BEGIN INTEGER sign, num, den;
	text(1, "*NCircle of 12 fifths in commas commas from C");
	text(1, "*N0= pure, or <+|-><a/b><P|S>, e.g. +1P, -1/4P, +1/2S*N");

	circle heading;
	scalecents := 0;
	FOR note := 1 STEP 1 UNTIL 11 DO
	BEGIN
	next fifth:
		char := chin(7);
		IF char = &0 THEN sign := 0
		ELSE IF char = &- THEN sign := -1
		ELSE IF char = &+ THEN sign := 1
		ELSE GOTO next fifth;

		IF sign = 0 THEN fifths[note] := purefifth
		ELSE
		BEGIN	num := den := 0;
			char := chin(7);
			WHILE char >= &0 AND char <= &9 DO
			BEGIN num := 10*num + char - &0; char := chin(7);
			END;
			IF char = &/ THEN
			BEGIN	char := chin(7);
				WHILE char >= &0 AND char <= &9 DO
				BEGIN	den := 10*den + char - &0;
					char := chin(7);
				END;
				IF den = 0 THEN den := 1;
			END
			ELSE den := 1;

			interval := char MASK 223;
			IF interval = &P THEN fifths[note] := pythag
			ELSE fifths[note] := syntonic;
			fifths[note] :=	purefifth+fifths[note]*sign*num/den;
		END;
		scalecents := scalecents + fifths[note];
	END;
	fifths[12] := 8400.00 - scalecents;
	scale from fifths;
END readcommas;

{ Main program start }

set just scale;

outdev := 1;

get streams:
ioc(0); ioc(1); ioc(15); ioc(2);
outdev := output;
IF outdev < 0 THEN GOTO get streams;

skip(outdev);
text(1,"Title: ");
ioc(0); ioc(1); base := 1;
title char: char := chin(7);
IF char >= &*S THEN BEGIN title[base] := char; base := base+1; GOTO title char END;
title[base] := 0;

get input type:
ioc(0); ioc(1);
text(1, "*NNotes (cents), Fifths (cents) or fifths Commas N/F/C ? ");
note := chin(7) MASK 223;
IF note = &N THEN readcents
ELSE IF note = &F THEN readfifths
ELSE IF note = &C THEN readcommas
ELSE GOTO get input type;

base := 1;
WHILE title[base] # 0 DO
BEGIN	chout( outdev, title[base] ); base := base+1;
END;

skip( outdev );
circle echo;

text(outdev, "*NAY3 8912, True frequency, generated frequency, error in cents*N");
FOR note := 0 STEP 1 UNTIL 11 DO
BEGIN	text(outdev, "       "); write note( note );
END;
ay38912( 0.25 );
skip( outdev );
ay38912( 0.5 );
skip( outdev );
ay38912( 1.0 );
skip( outdev );
ay38912( 2.0 );
skip( outdev );
ay38912( 4.0 );

text(outdev, "*NPure fifth "); rwrite(outdev, purefifth, 8, 3);
text(outdev," Pythagorean comma "); rwrite(outdev, pythag, 8, 3);
text(outdev," Syntonic comma "); rwrite(outdev, syntonic, 8, 3);

text(outdev,
"*N*NKey: E equal tempered, = just, ** error greater than 10 cents, X syntonic comma error");
text(outdev,"*N");
text(outdev,"*NJust scale (cents), this one (cents, Hz)*N");
FOR note := 0 STEP 1 UNTIL 11 DO
BEGIN	text(outdev, "       "); write note( note );
END;

text(outdev,"*N  ");
FOR note := 0 STEP 1 UNTIL 11 DO
	rwrite( outdev, just[note], 8, 2 );
text(outdev,"*N  ");
FOR note := 0 STEP 1 UNTIL 11 DO
	rwrite( outdev, scale[note], 8, 2 );
text(outdev,"*N  ");
FOR note := 0 STEP 1 UNTIL 11 DO
	rwrite( outdev, freq[note], 8, 2 );

xcount := starcount := goodcount := 0;

text(outdev, "*NIntervals from each note*N" );
FOR note := 1 STEP 1 UNTIL 11 DO
BEGIN	text(outdev, "       "); write note( note );
END;

FOR note := 0 STEP 1 UNTIL 11 DO
BEGIN 	skip( outdev );	write note( note );
	FOR interval := 1 STEP 1 UNTIL 11 DO
	BEGIN	scalecents := scale[note+interval]-scale[note];
		justcents := just[interval];
		IF abs(scalecents-justcents) >= 21.49 THEN
			BEGIN	format( 512+&X );
				xcount := xcount + 1;
			END
		ELSE IF abs(scalecents-justcents) > 10.00 THEN
			BEGIN	format( 512+&** );
				starcount := starcount + 1;
			END
		ELSE IF abs(scalecents-justcents) < 1.00 THEN
			BEGIN	format( 512+&= );
				goodcount := goodcount + 1;
			END
		ELSE IF abs(scalecents-100.0*interval) < 1.00 THEN
			format( 512+&E );
		rwrite( outdev, scalecents, 8, 2 );
		format( 512+&*S);
	END;
END;

minorsum := majorsum := minorbigsum := majorbigsum := 0;
lminorsum := lmajorsum := lminorbigsum := lmajorbigsum := 0;

text(outdev, "*N*NAccumulated errors in each major and minor scale");
text(outdev,
"*NKey: = very good, E better than equal temperament, ** poor, X intolerable");
text(outdev, "*NEqual temp");
rwrite(outdev, 48.88, 8, 2); rwrite(outdev, 48.88, 8, 2);
text(outdev, "  3rd to 6th ");
rwrite(outdev, 33.24, 8, 2);
rwrite(outdev, 33.24, 8, 2);
text(outdev, " scale+internals ");
rwrite(outdev, 168.15, 8, 2); rwrite(outdev, 207.25, 8, 2);

FOR note := 0 STEP 1 UNTIL 11 DO
BEGIN	skip(outdev); write note( note );
	text(outdev, " scale  ");
	minorerror[note] := majorerror[note] := 0;
	lminorerror[note] := lmajorerror[note] := 0;
	FOR interval := 1 STEP 1 UNTIL 6 DO
	BEGIN
	scalecents := scale[note+minor[interval]] - scale[note];
	justcents := just[minor[interval]];
	minorerror[note] := minorerror[note] + abs(justcents - scalecents);
	IF interval > 1 AND interval < 6 THEN
		lminorerror[note] := lminorerror[note] +
			abs(justcents - scalecents);
	scalecents := scale[note+major[interval]] - scale[note];
	justcents := just[major[interval]];
	majorerror[note] := majorerror[note] + abs(justcents - scalecents);
	IF interval > 1 AND interval < 6 THEN
		lmajorerror[note] := lmajorerror[note] +
			abs(justcents - scalecents);
	END;

	minorsum := minorsum + minorerror[note];
	majorsum := majorsum + majorerror[note];
	write scale error( majorerror[note], lmajorerror[note] );
	write scale error( minorerror[note], lminorerror[note] );

	text(outdev, "  3rd to 6th ");
	lminorsum := lminorsum + lminorerror[note];
	lmajorsum := lmajorsum + lmajorerror[note];
	rwrite(outdev, lmajorerror[note], 8, 2);
	rwrite(outdev, lminorerror[note], 8, 2);

	text(outdev, " scale+internals ");
	tminorerror[note] := minorerror[note];
	tmajorerror[note] := majorerror[note];
	FOR base := 1 STEP 1 UNTIL 5 DO
	FOR interval := base+1 STEP 1 UNTIL 6 DO
	BEGIN
	scalecents := scale[note+minor[interval]] - scale[note+minor[base]];
	justcents := just[minor[interval]-minor[base]];
	tminorerror[note] := tminorerror[note] + abs(justcents - scalecents);
	scalecents := scale[note+major[interval]] - scale[note+major[base]];
	justcents := just[major[interval]-major[base]];
	tmajorerror[note] := tmajorerror[note] + abs(justcents - scalecents);
	END;

	minorbigsum := minorbigsum + tminorerror[note];
	majorbigsum := majorbigsum + tmajorerror[note];

	rwrite(outdev, tmajorerror[note], 8, 2);
	rwrite(outdev, tminorerror[note], 8, 2);
END;

text(outdev, "*N"); write(outdev, goodcount); text(outdev,"just intervals, ");
write(outdev, starcount); text(outdev,"errors > 10 cents, and ");
write(outdev, xcount); text(outdev,"syntonic comma errors");

text(outdev, "*NTotal errors. Equal temperament ");
rwrite(outdev, 586.58, 8, 2); rwrite(outdev, 586.54, 8, 2);
text(outdev,  " 3rd to 6th "); rwrite(outdev, 398.87, 8, 2);
rwrite(outdev, 398.83, 8, 2);
text(outdev, " with internal errors ");
rwrite(outdev, 2017.78, 8, 2); rwrite(outdev, 2487.04, 8, 2);
text(outdev, "*NTotal errors.  This temperament ");
rwrite(outdev, majorsum, 8, 2); rwrite(outdev, minorsum, 8, 2);
text(outdev, " 3rd to 6th ");
rwrite(outdev, lmajorsum, 8, 2); rwrite(outdev, lminorsum, 8, 2);
text(outdev, " with internal errors ");
rwrite(outdev, majorbigsum, 8, 2); rwrite(outdev, minorbigsum, 8, 2);

chout( outdev, &*P );

END FINISH
