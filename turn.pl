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
    roll_all(Dice, RollResult),
    write("Roll Result: "), print_dice(RollResult),
    update_dice(GameData, RollResult, UpdatedGameData),

    % Update the dice by determining what to reroll.
    determine_dice(UpdatedGameData, Player, NewSet), % TODO
    stand_or_reroll(UpdatedGameData, Player, RollNumber, NewSet, AfterRolls). % TODO

% todo: handle after roll 3

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

/* *********************************************************************
 Function Name: determine_dice
 Purpose: Completes post-roll questions and has the player decide what to 
          stand, or what to reroll
 Reference: None
********************************************************************* */

/* *************************************************
determine_dice/3
Parameters:
    +GameData: game/4 structure containing the 
        current game state.
    +Player: The player whose turn it is.
    -NewSet: The new set of dice after the player 
        decides what to reroll.
 ************************************************ */

 determine_dice(GameData, Player, NewSet) :-
    list_available_categories(GameData, Player), % TODO
    pursue_categories(GameData, Player, UpdatedGameData), % TODO
    handle_rerolls(UpdatedGameData, Player, NewSet). % TODO

/* *********************************************************************
 Function Name: list_available_categories
 Purpose: To list or validate player-input list of available categories
 Reference: None
********************************************************************* */

/* *************************************************
list_available_categories/2
Parameters:
    +GameData: game/4 structure containing the 
        current game state.
    +Player: The player whose turn it is.
 ************************************************ */

% Computer lists available categories
list_available_categories(GameData, computer) :-
    get_available_categories(GameData, AvailableCategories), % TODO
    nl, write("Listing all available categories, given the dice set so far..."), nl,
    write(AvailableCategories), nl.

% Player lists available categories
list_available_categories(GameData, human) :-
    get_available_categories(GameData, AvailableCategories),
    write("Please list all available scorecard categories, given your current dice set."), nl,
    validate_available_categories(AvailableCategories). % TODO