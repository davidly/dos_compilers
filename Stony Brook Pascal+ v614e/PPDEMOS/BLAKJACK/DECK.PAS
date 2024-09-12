Unit Deck;

{This unit implements a deck of cards.  You call shuffle to initalize}
{the deck in random order, then call GetCard to get the next card from}
{the deck, when dealing or drawing for instance.}

Interface

Type
    Suit   = (Clubs, Diamonds, Hearts, Spades);

    Rank   = (Two, Three, Four, Five, Six, Seven,
              Eight, Nine, Ten, Jack, Queen, King, Ace);   

    Card =
	record
	s	: Suit;
	r	: Rank;
	end;

Var
    DeckOfCards : array [1..51] of card;
    NextCard	: integer;
    
Procedure Shuffle;

Procedure GetCard(var c : card);

Procedure ShowCard(c : card; x, y : integer);

Procedure another;

Implementation

Uses crt;

{This procedure shuffles the deck of cards}

Procedure Shuffle;
    var
        position 	: array [1..52] of real;
	s 		: suit;
	r 		: rank;
	i, j 		: integer;
	tempreal	: real;
	tempcard	: card;
    begin
        
	{first construct a deck in order}
	
	i := 1;
	for s := clubs to spades do
	    for r := two to ace do
	        begin
	        DeckOfCards[i].s := s;
		DeckOfCards[i].r := r;
		i := i + 1;
		end;	
	
	{now assign a random number for each card in the deck}
	
	for i := 1 to 52 do
	    position[i] := random;
	    
	{and sort the deck based on the random numbers, thereby}
	{putting it in random order.  This is a maximally slow sort,}
	{but then, how fast do we need to shuffle?}
	
	for i := 1 to 51 do
	    for j := i+1 to 52 do
	        if position[j] < position[i] then
		    begin
		    tempreal := position[j];
		    position[j] := position[i];
		    position[i] := tempreal;
		    tempcard := DeckOfCards[j];
		    DeckOfCards[j] := DeckOfCards[i];
		    DeckOfCards[i] := tempcard;
		    end;

	{set the next card index to 1}
	
	NextCard := 1;
	
    end;
    
Procedure GetCard(var c : card);
    begin
        if NextCard > 52 then
	    begin
	    WriteLn;
	    WriteLn('Too many cards drawn');
	    halt;
	    end;
	
	c := DeckOfCards[NextCard];
	inc(NextCard);
    end;

Const
    RankChar : array [Rank] of char = 
	('2','3','4','5','6','7','8','9','T','J','Q','K','A');
	
    SuitChar : array [Suit] of char = (#5, #4, #3, #6);
    
Procedure ShowCard(c : card; x, y : integer);
    begin
        GotoXY(x, y);
	Write(RankChar[c.r], SuitChar[c.s]);
    end;

Procedure Another;
    begin
    end;
    
begin
    
    {Randomize so we don't get the same cards every time we play!}
    
    Randomize;
end.
