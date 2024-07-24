      *******************************************************************
      *                                                                 *
      *                                                                 *
      *                  (C) Micro Focus Ltd. 1990                      *
      *                                                                 *
      *                         BATTLE.CPY                              *
      *                                                                 *
      *    Common procedure division code for both player programs      *
      *                                                                 *
      *******************************************************************

       Battle-Ships.
           Perform Start-Ships
           Perform Play-Ships
           Perform End-Ships
           STOP RUN.

       Start-Ships.
           Move all "01" to Grid-Att-Table
      *-----------------------------------------------------------------
      *    the following procedures calls have been commented to show
      *    possible enhancements you may like to make to allow players
      *    to define grids dynamically and validate grids.
      *
      *-----------------------------------------------------------------
      *    Perform Setup-Grid-Coords
      *    Perform Validate-Grid-Coords
           Display Battle-Screen
           Perform Connect-Opponent.

       Play-Ships.
      *-----------------------------------------------------------------
      *    Battleship is played by taking turns.  Player 1 always starts
      *    first.  So while player 1 has its turn,  player 2 is
      *    servicing player 1's turn eg. receiving coordinates,
      *    assessing damage and reporting back.
      *    When it is player 2's turn, the roles are reversed, such
      *    that player 2 is now sending coordinates and player 1 is
      *    servicing player 2.  This continues until one of the players
      *    has sunk all the ships of the other player.
      *
      *-----------------------------------------------------------------
           Perform Until Game-Over
               If Player-Id = "PLAYER1"
                   Perform Local-Turn
                   If not Game-Over
                       Perform Remote-Turn
                   End-If
               Else
                   Perform Remote-Turn
                   If not Game-Over
                       Perform Local-Turn
                   End-If
               End-If
           End-Perform.

       End-Ships.
           Perform Disconnect-Opponent
           Perform Display-Game-Outcome
           Perform Get-Keystroke.

      *-----------------------------------------------------------------
      *    Each turn consists of getting grid coordinates, sending the
      *    coordinates to the opponent, waiting for a damage report and
      *    assessing that damage.  The opponents turn acts in reverse
      *    to your turn - so while you send grid coordinates it is
      *    waiting to receive them at the remote end and when you wait
      *    for a damage report it is assessing the damage caused and
      *    then it sends the damage report to you etc.
      *
      *-----------------------------------------------------------------
       Local-Turn.
           Perform Get-Coords
           Perform Send-Grid-Coords
           Perform Receive-Opponent-Damage
           Perform Assess-Opponent-Damage
           Display Battle-Damage
           Display Battle-Field.

      *-----------------------------------------------------------------
      *    The remote turn consists of receiving grid coordinates from
      *    the opponent, assessing the damage caused and returning a
      *    damage report to the opponent.  While this procedure is
      *    running on this machine, the remote machine is running the
      *    Local-Turn procedure.
      *
      *-----------------------------------------------------------------
       Remote-Turn.
           Perform Opponents-Turn
           Perform Receive-Grid-Coords
           Perform Assess-Own-Damage
           Display Battle-Damage
           Display Battle-Field
           Perform Send-Own-Damage.


       Get-Coords.
           Move "YOUR TURN" to Screen-Msg-1
           Display Battle-Turn
           Move spaces to Grid-Coordinates
           Accept Battle-Coords
           If Not (Grid-1 = "Q" OR Grid-1 = "q")
               Perform until (Grid-1 >="A" AND Grid-1 <= "M" AND
                              Grid-2 >="1" AND Grid-2 <= "9")
                   If Grid-1 >= 'a' AND Grid-1 <= 'z'
      *                fold to upper case
                       Subtract 32 from Grid-1-Asc
                   Else
                       Move "Invalid Coordinates" to Screen-Msg-4
                       Display Battle-Msg
                       Accept Battle-Coords
                       Move spaces to Screen-Msg-4
                       Display Battle-Msg
                   End-If
               End-Perform
           End-if
           Move "AWAITING REPORT" to Screen-Msg-1
           Move spaces to Screen-Msg-2
           Display Battle-Msg-1-2.

       Opponents-Turn.
           Move "OPPONENTS TURN" to Screen-Msg-1
           Display Battle-Turn.

       Assess-Opponent-Damage.
           Perform Evaluate-Grid-Position
           Evaluate Damage-Msg
               When "MISS"  Perform Miss-Ship
               When "HIT"   Perform Hit-Ship
               When "SINK"  Perform Sink-Ship
               When "WIN"   Perform Win-Battle
           End-Evaluate.

       Miss-Ship.
           Move 3 to Grid-Att-Array(Grid-Row,Grid-Col)
           Move "YOU MISSED" to Screen-Msg-2.
       Hit-Ship.
           Move 4 to Grid-Att-Array(Grid-Row,Grid-Col)
           Move "YOU HIT SHIP" to Screen-Msg-2.
       Sink-Ship.
           Perform Display-Sunk-Ship
           Move "YOU SUNK SHIP" to Screen-Msg-2.
       Win-Battle.
           Perform Display-Sunk-Ship
           Move "YOU SUNK SHIPS" to Screen-Msg-2
           Set Win-Game to True.

       Display-Sunk-Ship.
           Move Sink-Coords to Sunk-Ship-Locations
           Perform varying Ship-Sector from 1 by 1 until Ship-Sector > 4
               Move Sunk-Ship-Row of Sunk-Ship(Ship-Sector) to Temp-Row
               Move Sunk-Ship-Col of Sunk-Ship(Ship-Sector) to Temp-Col
               If Temp-Row not = 0 AND Temp-Col not = 0
                   Move 0 to Grid-Att-Array(Temp-Row,Temp-Col)
               End-If
           End-Perform.

       Assess-Own-Damage.
           Perform Evaluate-Grid-Position
           Move Grid-Array(Grid-Row,Grid-Col) to Target-Object
           If Target-Object = space
      *            a miss
               Move "MISS" to Damage-Msg
               Move "OPPONENT MISSED SHIP" to Screen-Msg-2
           Else
      *            a hit
               Move "HIT" to Damage-Msg
               Move "OPPONENT HIT SHIP" to Screen-Msg-2
               Evaluate Target-Object
                   When "B"
                   When "A"
                   When "F"
                   When "G"
                   When "*"   Perform Check-Ship-Sunk
                   When other Move "MISS" to Damage-Msg
                              Move "OPPONENT MISSED SHIP"
                              to Screen-Msg-2
               End-Evaluate
           End-If.


       Evaluate-Grid-Position.
           Move Grid-1 to Grid-Chr
           Subtract 64 from Grid-Asc
           Move Grid-Asc to Grid-Col
           Move Grid-2 to Grid-Chr
           Subtract 48 from Grid-Asc
           Move Grid-Asc to Grid-Row.

       Check-Ship-Sunk.
           Move Grid-Array(Grid-Row,Grid-Col) to Target-Object
           Move "*" to Grid-Array(Grid-Row,Grid-Col)
      *        assume sunk unless we can prove otherwise
           Set Ship-Sunk to True
           Move low-values to Sunk-Ship-Locations
           Perform Check-Horizontal-Axis
           If Ship-Sunk
               Perform Check-Vertical-Axis
               If Ship-Sunk
                   Move "SINK" to Damage-Msg
                   Move "OPPONENT SUNK SHIP" to Screen-Msg-2
                   Perform varying Ship-Sector from 1 by 1
                           until Ship-Sector > 4
                       Move Sunk-Ship-Row of Sunk-Ship(Ship-Sector)
                                   to Temp-Row
                       Move Sunk-Ship-Col of Sunk-Ship(Ship-Sector)
                                   to Temp-Col
                       If Temp-Row not = 0 AND Temp-Col not = 0
                           Move space to Grid-Array(Temp-Row,Temp-Col)
                       End-If
                   End-Perform
                   Move Sunk-Ship-Locations to Sink-Coords
                   Perform Check-All-Sunk
               End-If
           End-If.

       Check-Horizontal-Axis.
           Set Not-End-of-Ship to true
      *        go to far left of ship
           Move Grid-Col to Temp-Col
           Perform until Temp-Col= 0 OR
                  (Grid-Array(Grid-Row,Temp-Col) not = "*" AND
                   Grid-Array(Grid-Row,Temp-Col) not = Target-Object)
               Subtract 1 from Temp-Col
           End-Perform
           Add 1 to Temp-Col
      *        start scanning right
           Move 1 to Ship-Sector
           Perform until End-Of-Ship or Ship-Not-Sunk
               Evaluate Grid-Array(Grid-Row,Temp-Col)
                   When Target-Object  Set Ship-Not-Sunk to True
                   When "*"
                       Move Temp-Col to Sunk-Ship-Col of
                                                  Sunk-Ship(Ship-Sector)
                       If Sunk-Ship-Row of Sunk-Ship(Ship-Sector) = zero
                           Move Grid-Row to Sunk-Ship-Row of
                                                  Sunk-Ship(Ship-Sector)
                       End-If
                   When other Set End-Of-Ship to true
               End-Evaluate
               Add 1 to Ship-Sector
               If Temp-Col = Max-Col
                   Set End-Of-Ship to true
               End-If
               Add 1 to Temp-Col
           End-Perform.

       Check-Vertical-Axis.
           Set Not-End-of-Ship to true
      *        go to top of ship
           Move Grid-Row to Temp-Row
           Perform until Temp-Row = 0 OR
                  (Grid-Array(Temp-Row,Grid-Col) not = "*" AND
                   Grid-Array(Temp-Row,Grid-Col) not = Target-Object)
               Subtract 1 from Temp-Row
           End-Perform
           Add 1 to Temp-Row
      *        start scanning down
           Move 1 to Ship-Sector
           Perform until End-Of-Ship or Ship-Not-Sunk
               Evaluate Grid-Array(Temp-Row,Grid-Col)
                   When Target-Object  Set Ship-Not-Sunk to True
                   When "*"
                       Move Temp-Row to Sunk-Ship-Row(Ship-Sector)
                       If Sunk-Ship-Col(Ship-Sector) = zero
                           Move Grid-Col to Sunk-Ship-Col(Ship-Sector)
                       End-If
                   When other Set End-Of-Ship to true
               End-Evaluate
               Add 1 to Ship-Sector
               If Temp-Row = Max-Row
                   Set End-Of-Ship to true
               End-If
               Add 1 to Temp-Row
           End-Perform.

       Check-All-Sunk.
           If No-Ships-Left
               Move "OPPONENT SUNK SHIPS" to Screen-Msg-2
               Move "WIN " to Damage-Msg
               Set Lose-Game to True
           End-If.

       Display-Game-Outcome.
           If Win-Game
               Move "YOU WIN!   G A M E   O V E R" to Screen-Msg-3
           Else
               Move "YOU LOSE!  G A M E   O V E R" to Screen-Msg-3
           End-If
           Display Battle-Over.

       Game-Quit.
           Move "         QUIT GAME          " to Screen-Msg-3
           Display Battle-Over
           Stop Run.

       Get-keystroke.
           Call x"83" using key-char
           Call x"e4".


      *-----------------------------------------------------------------
      * Routines to communicate with opponent
      *-----------------------------------------------------------------

      *-----------------------------------------------------------------
       Connect-Opponent.
      *    This sets up a conversation with the opponent
      *
      *-----------------------------------------------------------------
           Move Connect-Code to Battle-Op-Code
           Move Player-Id to Battle-Buffer
           Perform Communicate-Opponent.

      *-----------------------------------------------------------------
       Disconnect-Opponent.
      *    This brings down a conversation with the opponent at the end
      *    of a game
      *
      *-----------------------------------------------------------------
           Move Disconnect-Code to Battle-Op-Code
           Perform Communicate-Opponent.

      *-----------------------------------------------------------------
       Send-Own-Damage.
      *    Send damage report to opponent - the damage is contained
      *    in the call parameter Battle-Buffer it contains either:
      *        "MISS" - indicating opponent missed
      *        "HIT"  - indicating opponent hit part of a ship
      *        "SINK" - indicating opponent hit and sunk a ship
      *        "WIN"  - indicating opponent hit and sunk last remaining
      *                 ship and has won the game
      *    the coordinates for a sunk ship are also provided so that
      *    the opponent can mark the position on their screen.
      *
      *    You may like to enhance the program so that more information
      *    is sent regarding the type of ship that was sunk or hit -
      *    this information could then be displayed on the opponent's
      *    screen.
      *
      *-----------------------------------------------------------------
           Move Send-Report-Code to Battle-Op-Code
           If Ship-Sunk or Lose-Game
               Move Damage-Msg to Battle-Buffer(1:4)
               Move Sink-Coords to Battle-Buffer(5:8)
           Else
               Move Damage-Msg to Battle-Buffer
           End-If
           Perform Communicate-Opponent.

      *-----------------------------------------------------------------
       Receive-Opponent-Damage.
      *    The damage report received is the same as that sent above.
      *
      *-----------------------------------------------------------------
           Move Receive-Report-Code to Battle-Op-Code
           Perform Communicate-Opponent
           If Battle-Buffer(1:4) = "SINK" or Battle-Buffer(1:4) = "WIN "
               Move Battle-Buffer(1:4) to Damage-Msg
               Move Battle-Buffer(5:8) to Sink-Coords
           Else
               Move Battle-Buffer to Damage-Msg
           End-If.

      *-----------------------------------------------------------------
       Send-Grid-Coords.
      *    Send coordinates in Battle-Buffer to opponent
      *
      *-----------------------------------------------------------------
           Move Send-Coords-Code to Battle-Op-Code
           Move Grid-Coordinates to Battle-Buffer
           Perform Communicate-Opponent
           If Battle-Buffer(1:1) = "Q" or Battle-Buffer(1:1) = "q"
               Perform Game-Quit
           End-If.

      *-----------------------------------------------------------------
       Receive-Grid-Coords.
      *    receive coordinates in Battle-Buffer from opponent
      *
      *-----------------------------------------------------------------
           Move Receive-Coords-Code to Battle-Op-Code
           Perform Communicate-Opponent
           If Battle-Buffer(1:1) = "Q" or Battle-Buffer(1:1) = "q"
               Perform Game-Quit
           End-If.
           Move Battle-Buffer to Grid-Coordinates.

      *-----------------------------------------------------------------
       Communicate-Opponent.
      *    Call communications module.
      *    The communications module is treated as a black box - this
      *    program is not concerned with how the communication is
      *    achieved - It only understands several high level
      *    operations that can be called to talk between itself and the
      *    remote program.  You could conceivably change the
      *    communications module to use some other protocol - this
      *    program should not have to change.
      *
      *-----------------------------------------------------------------
           Call "BATTAPPC" using
                                by value Battle-Op-Code
                                by reference Battle-Buffer
           If Return-Code > 0
      *            Error handling here is very simple.
      *            You may like to enhance this area by implementing
      *            some sort of recovery routine
               STOP RUN
           End-If.
