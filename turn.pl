/* *********************************************
 Source Code to handle turns of the game
    -> Relies on:
        validation.pl
        dice.pl
        strategy.pl
        validation2.pl
 ********************************************* */

/* *********************************************************************
 Function Name: run_turn
 Purpose: Run a single turn for a player
 Reference: None
********************************************************************* */

/* *************************************************
run_turn/3
Parameters:
    +GameData: game/4 structure containing the 
        current game state.
    +Player: The player whose turn it is.
    -AfterTurn: game/4 structure containing the 
        game state after the turn.
 ************************************************ */

run_turn(GameData, PlayerName, AfterTurn) :-
    print_turn_header(PlayerName), % TODO
    handle_rolls(GameData, PlayerName, UpdatedGameData), % TODO
    choose_category(UpdatedGameData, PlayerName, AfterTurn), % TODO
    print_scorecard(AfterTurn).

/* *************************************************
run_turn/4
Parameters:
    +GameData: game/4 structure containing the 
        current game state.
    +Player: The player whose turn it is.
    +IsGameOver: true if the game is over.
    -FinalData: game/4 structure containing the 
        final game state.
 ************************************************ */

 % Game is over so return the final game state.
run_turn(GameData, _, true, FinalData) :-
    FinalData = GameData.

% Game is not over so run the turn.
run_turn(GameData, Player, false, AfterTurn) :-
    run_turn(GameData, Player, AfterTurn).