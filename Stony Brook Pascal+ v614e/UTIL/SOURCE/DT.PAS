PROGRAM dt;
{$M 4096, 0, 0}

USES Dos;

CONST
    Days : ARRAY [0..6] OF STRING[9] =
	(
	'Sunday ',
	'Monday ',
	'Tuesday ',
	'Wednesay ',
	'Thursday ',
	'Friday ',
	'Saturday '
	);
    Months : ARRAY [1..12] OF STRING[4] =
	(
	'Jan.',
	'Feb.',
	'Mar.',
	'Apr.',
	'May',
	'Jun.',
	'Jul.',
	'Aug.',
	'Sep.',
	'Oct.',
	'Nov.',
	'Dec.'
	);
    Afternoon : ARRAY [0..1] OF STRING[2] =
	('am', 'pm');

VAR
    Year	: WORD;
    Month	: WORD;
    Day		: WORD;
    DayOfWeek	: WORD;

    Hour	: WORD;
    Minute	: WORD;
    Seconds	: WORD;
    Hundreths	: WORD;

    Hour12	: WORD;
BEGIN
    GetDate(Year, Month, Day, DayOfWeek);
    GetTime(Hour, Minute, Seconds, Hundreths);
    
    Hour12 := Hour;
    IF Hour12 > 12 THEN
	Hour12 := Hour12 - 12;
    
    WriteLn;
    Write(Days[DayOfWeek], Months[Month], ' ', Day, ', ');
    WriteLn(Hour12, ':', Minute DIV 10, Minute MOD 10, Afternoon[Hour DIV 12]);
END.
