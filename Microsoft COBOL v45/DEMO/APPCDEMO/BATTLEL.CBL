      $set mf ans85 noosvs
      *******************************************************************
      *                                                                 *
      *                                                                 *
      *                  (C) Micro Focus Ltd. 1990                      *
      *                                                                 *
      *                         BATTLEL.CBL                             *
      *                                                                 *
      *      COBOL Advanced Program to Program (APPC) Demonstration     *
      *                                                                 *
      *                         Battleships                             *
      *                          player  1                              *
      *                                                                 *
      *******************************************************************

       WORKING-STORAGE SECTION.

       01 Player-Id            Pic x(7) value 'PLAYER1'.

      *-----------------------------------------------------------------
      *    Battle-Grid defines the grid positions of different ships
      *    on this side.  It is up to each player to specify these
      *    positions and follow certain requirements of the game.
      *
      *    The requirements are:
      *        - ships are identified by the following letters:
      *                 A for Aircraft Carrier
      *                 B for Battleship
      *                 F for Frigate
      *                 G for Gun Boat
      *
      *        - ships can be any length - it is up to the players to
      *          decide how long each ship is
      *
      *        - ships must not be located in adjacent grid locations
      *
      *        - ships can only be aligned vertically or horizontally
      *
      *    There is no verification done on the setup you choose - so
      *    it is quite possible to cheat.  You must also recompile this
      *    program when you want to change the battle grid.
      *
      *    A possible enhancement which you may like to make yourself
      *    would be to provide code which allows each player to define
      *    his/her own grid details and validate the grid dynamically -
      *    thus removing the need to recompile every time.
      *
      *-----------------------------------------------------------------

       01 Battle-Grid.
       88 No-Ships-Left        value spaces.
          03 filler            pic x(13) value 'BBB          '.
          03 filler            pic x(13) value '    AAAA     '.
          03 filler            pic x(13) value '             '.
          03 filler            pic x(13) value ' B  G   F    '.
          03 filler            pic x(13) value ' B      F    '.
          03 filler            pic x(13) value ' B          G'.
          03 filler            pic x(13) value '    G        '.
          03 filler            pic x(13) value '             '.
          03 filler            pic x(13) value '          FF '.


      *-----------------------------------------------------------------
       COPY "BATTLE.WKS".
      *    BATTLE.WKS is a copy file that contains common
      *    working-storage section items for PLAYER1 and PLAYER2
      *
      *-----------------------------------------------------------------

       SCREEN SECTION.
      *-----------------------------------------------------------------
       COPY "BATTLE.SS".
      *    BATTLE.SS is a copy file containing a screen section for
      *    displaying the battle field.  The screen section was designed
      *    using the SCREENS utility.
      *
      *-----------------------------------------------------------------

       PROCEDURE DIVISION.
      *-----------------------------------------------------------------
       COPY "BATTLE.CPY".
      *    BATTLE.CPY is a copy file containing the common procedure
      *    division code for both players
      *
      *-----------------------------------------------------------------



