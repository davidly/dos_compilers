'
' *** TYPE_EX.BAS -- TYPE statement programming example
'
TYPE Card
   Value AS INTEGER
   Suit AS STRING*9
END TYPE

DEFINT A-Z
' Define the Deck as a 52-element array of Cards.
DIM Deck(1 TO 52) AS Card

' Build, shuffle, and deal the top five cards.
CALL BuildDeck(Deck())
CALL Shuffle(Deck())
FOR I%=1 TO 5
   CALL ShowCard(Deck(I%))
NEXT I%

' Build the deck--fill the array of Cards with
' appropriate values.
SUB BuildDeck(Deck(1) AS Card) STATIC
DIM Suits(4) AS STRING*9

   Suits(1)="Hearts"
   Suits(2)="Clubs"
   Suits(3)="Diamonds"
   Suits(4)="Spades"
' This loop controls the suit.
   FOR I%=1 TO 4
    ' This loop controls the face value.
      FOR J%=1 TO 13
       ' Figure out which card (1...52) you're creating.
         CardNum%=J%+(I%-1)*13
       ' Place the face value and suit into the Card.
         Deck(CardNum%).Value=J%
         Deck(CardNum%).Suit=Suits(I%)
      NEXT J%
   NEXT I%

END SUB

' Shuffle a deck (an array containing Card elements).
SUB Shuffle(Deck(1) AS Card) STATIC

   RANDOMIZE TIMER
' Shuffle by transposing 1000 randomly selected pairs of cards.
   FOR I%=1 TO 1000
      CardOne%=INT(52*RND+1)
      CardTwo%=INT(52*RND+1)
   ' Notice that SWAP works on arrays of user types.
      SWAP Deck(CardOne%),Deck(CardTwo%)
   NEXT I%

END SUB

' Display a single card by converting and printing the
' face value and the suit.
SUB ShowCard (SingleCard AS Card) STATIC

   SELECT CASE SingleCard.Value
      CASE 13
         PRINT "King ";
      CASE 12
         PRINT "Queen";
      CASE 11
         PRINT "Jack ";
      CASE  1
         PRINT "Ace  ";
      CASE ELSE
         PRINT USING "  ## ";SingleCard.Value;
   END SELECT

   PRINT " ";SingleCard.Suit

END SUB
