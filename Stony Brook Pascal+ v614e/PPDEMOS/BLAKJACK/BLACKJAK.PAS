Program BlackJak;

{//optimize:s}

{This program plays blackjack}

Uses 
    Deck, Crt;

Var
    DealerWins,
    PlayerWins	: integer;

{Display the score}

Procedure ShowScore;
    begin
        GotoXY(37, 1);
	Write('Score');
	GotoXY(30, 3);
	Write('You: ', PlayerWins:3);
	Write('  Me:  ', DealerWins:3);
    end;
    
{Display the result}

Procedure Result(message : string; var winner : integer);
    begin
        GotoXY(20, 15);
	HighVideo;
	WriteLn(message);
	NormVideo;
	inc(winner);
	ShowScore;
    end;

{Add a new card to the total count for a player, also set a boolean}
{if the card is an ace}

Procedure AddCard(c : card; total : integer; var HasAce : boolean);
    begin
        case c.r of
	    two..ten:
		total := total + ord(c.r) + 2;
	    jack..king:
		total := total + 10;
	    ace:
	        begin
		total := total + 1;
		HasAce := true;
		end;
	end;
    end;

{Play one round of blackjack}

Procedure PlayOneRound;
    var
	DealersFirst	: card;		{dealers first card}	
        dealer		: card;		{dealers card}
	player		: card;		{players card}
	DealerTotal 	: integer;	{sum of dealers cards}
	PlayerTotal 	: integer;	{sum of players cards}
	PlayerHolds 	: boolean;	{player is holding}
	Dealt		: integer;	{number of rounds dealt}
	PlayerAce,			{Does player have an ace?}
	DealerAce	: boolean;	{Does dealer have an ace?}

    const
        PlayerLine	= 11;
	DealerLine	= 13;
	FirstCardPos	= 33;
	
    begin

	{Initialize the screen}

	ClrScr;	    
	GotoXY(20, PlayerLine);
	Write('Your cards:    ');
	GotoXY(20, DealerLine);
	Write('Dealer''s cards: ');
	ShowScore;
	
	{So far, our cards add up to nothing}
	
	DealerTotal := 0;
	PlayerTotal := 0;
	
	{And neither player has an Ace}
	
	PlayerAce := FALSE;
	DealerAce := FALSE;
	
	{Deal the first two cards}
	
        for dealt := 1 to 2 do
	    begin
		
	    {Delay a little to add to the suspense}
	    
	    Delay(500);
	    
	    {Deal the player his next card}
	    
	    GetCard(player);
	    
	    {Add to his total count}
	    
	    AddCard(player, PlayerTotal, PlayerAce);
	    
	    {And show the card}
	    
	    ShowCard(player, FirstCardPos + 3 * Dealt, PlayerLine);

	    {Delay again}
	    	    
	    Delay(500);

	    {Deal a card for the dealer}
	    	    
	    GetCard(dealer);
	    
	    {Add to his total}
	    
	    AddCard(dealer, DealerTotal, DealerAce);
		
	    {Don't show the dealers first card}
	
	    if dealt = 1 then
		begin
		
		{First card, show as ??}
		
		GotoXY(FirstCardPos+3, DealerLine);
		Write('??');
		DealersFirst := dealer;
		end
	    else
		ShowCard(dealer, FirstCardPos + 3 * Dealt, DealerLine);	    
	    end;
	    
	{Now deal the player as many cards as he wants}

	PlayerHolds := FALSE;
	dealt := 2;
	REPEAT
	    
	    {Ask the player if he wants another card}
	    
	    GotoXY(1, 25);
	    Write('Take another card? ');
	    if upcase(ReadKey) <> 'Y' then
		PlayerHolds := true
	    else
		begin
		
		{Deal him a card}
	
		Delay(500);	
		GetCard(Player);
		dealt := dealt + 1;
		
		{Add to his total}
		
		AddCard(Player, PlayerTotal, PlayerAce); 
		ShowCard(player, FirstCardPos + 3 * Dealt, PlayerLine);
		end;
	    
	    {Clear the prompt line}
				
	    GotoXY(1, 25); ClrEol;
	
	UNTIL PlayerHolds OR (PlayerTotal > 21);
	
	{See if he went bust}
	
	if PlayerTotal > 21 then
	    begin
	    Result('You went bust, dealer wins', DealerWins);
	    exit;
	    end;

	{Now play out the dealers hand}

	dealt := 2;	
	While DealerTotal < 16 do
	    begin
	    
	    {Give him another card}
	    
	    Delay(500);
	    GetCard(dealer);
	    Dealt := Dealt + 1;
	    
	    {And add it to the total}
	    
	    AddCard(dealer, DealerTotal, DealerAce);
	    ShowCard(dealer, FirstCardPos + 3 * Dealt, DealerLine);	    
	    
	    end;

	{See if the dealer went bust}

	if DealerTotal > 21 then
	    begin
	    ShowCard(DealersFirst, FirstCardPos+3, DealerLine);
	    Result('Dealer went bust', PlayerWins);
	    exit;
	    end;
	
	{See if the player has an ace he should count as 10}
	
	if PlayerAce AND (PlayerTotal <= 11) then
	    inc(PlayerTotal, 10);
	    
	{Likewise for the dealer}
	
	if DealerAce AND (DealerTotal <= 11) then
	    inc(DealerTotal, 10);
	    
	{Show the dealers first card}
		
	ShowCard(DealersFirst, FirstCardPos+3, DealerLine);

	{Now determine who wins}
	
	if DealerTotal >= PlayerTotal then
	    Result('Sorry, dealer wins', DealerWins)
	else
	    Result('You win!!!', PlayerWins);
    end;

begin
    
    {Shuffle the deck}
    
    Shuffle;
    
    {Initalize the scores}
    
    DealerWins := 0;
    PlayerWins := 0;

    repeat
        PlayOneRound;
	GotoXY(1, 25);
	Write('Press Escape to quit, any other key to continue');
    until ReadKey = #27;
    
end.
