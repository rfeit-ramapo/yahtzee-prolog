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
    print_turn_header(PlayerName),
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

/* *********************************************************************
 Function Name: print_turn_header
 Purpose: Print the header for a player's turn
 Reference: None
********************************************************************* */

/* *************************************************
print_turn_header/1
Parameters:
    +Player: The player whose turn it is.
 ************************************************ */

 % Print the header for the player's turn.
print_turn_header(human) :-
    write("================================="), nl,
    write("-- Your Turn --"), nl.

% Print the header for the computer's turn.
print_turn_header(computer) :-
    write("================================="), nl,
    write("-- Computer's Turn"), nl.

/* *********************************************************************
Function Name: handle_rolls
Purpose: Handle the rolls for a player's turn
Reference: None
********************************************************************* */

/* *************************************************
handle_rolls/3
Parameters:
    +GameData: game/4 structure containing the 
        current game state.
    +Player: The player whose turn it is.
    -AfterRolls: game/4 structure containing the 
        game state after the rolls.
 ************************************************ */

% Initial roll handling.
handle_rolls(GameData, Player, AfterRolls) :-
    handle_rolls(GameData, Player, 1, AfterRolls).

/* *************************************************
handle_rolls/5
Parameters:
    +GameData: game/4 structure containing the 
        current game state.
    +Player: The player whose turn it is.
    +RollNumber: The current roll number.
    -AfterRolls: game/4 structure containing the 
        game state after the rolls.
 ************************************************ */
 handle_rolls(GameData, Player, RollNumber, AfterRolls) :-
    RollNumber <= 3,
    print_roll_header(RollNumber),

    % Update game data with the new roll.
    get_dice(GameData, Dice),
    roll_all(Dice, RollResult), % TODO
    write("Roll Result: "), print_dice(RollResult), % TODO
    update_dice(GameData, RollResult, UpdatedGameData). % TODO

    % Update the dice by determining what to reroll.
    % continue here later

/* *********************************************************************
 Function Name: print_roll_header
 Purpose: Print the header for a player's roll
 Reference: None
********************************************************************* */

/* *************************************************
print_roll_header/1
Parameters:
    +RollNumber: The current roll number.
 ************************************************ */

 print_roll_header(RollNumber) :-
    write("================================="), nl,
    write("Roll "), write(RollNumber), write(":"), nl, nl.