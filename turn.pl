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
    handle_rolls(GameData, PlayerName, UpdatedGameData),
    UpdatedGameData = [Round, Scorecard, Dice, _],
    toggle_dice_lock(Dice, unlocked, UnlockedDice),
    AfterTurn = [Round, Scorecard, UnlockedDice, none],
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
    RollNumber =< 3,
    print_roll_header(RollNumber),

    % Update game data with the new roll.
    get_dice(GameData, Dice),
    roll_all(Dice, RollResult),
    write("Roll Result: "), print_dice(RollResult),
    update_dice(GameData, RollResult, UpdatedGameData),

    % Update the dice by determining what to reroll.
    determine_dice(UpdatedGameData, Player, NewSet),
    stand_or_reroll(UpdatedGameData, Player, RollNumber, NewSet, AfterRolls).

% Automatically lock dice and proceed to choose category on third roll.
handle_rolls(GameData, Player, 3, AfterRolls) :-
    print_roll_header(3),
    get_dice(GameData, Dice),
    roll_all(Dice, RollResult),
    write("Roll Result: "), print_dice(RollResult),

    toggle_dice_lock(RollResult, locked, UpdatedDice),
    update_dice(GameData, UpdatedDice, UpdatedGameData),
    choose_category(UpdatedGameData, Player, AfterRolls).

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
    list_available_categories(GameData, Player),
    pursue_categories(GameData, Player, UpdatedGameData),
    handle_rerolls(UpdatedGameData, Player, NewSet).

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
    get_available_categories(GameData, AvailableCategories),
    nl, write("Listing all available categories, given the dice set so far..."), nl,
    write(AvailableCategories), nl.

% Player lists available categories
list_available_categories(GameData, human) :-
    get_available_categories(GameData, AvailableCategories),
    write("Please list all available scorecard categories, given your current dice set."), nl,
    validate_available_categories(AvailableCategories).

/* *********************************************************************
 Function Name: pursue_categories
 Purpose: To list the category or categories the player wants to pursue
 Reference: None
********************************************************************* */

/* *************************************************
pursue_categories/3
Parameters:
    +GameData: game/4 structure containing the 
        current game state.
    +Player: The player whose turn it is.
    -UpdatedGameData: game/4 structure containing the 
        game state after the player chooses a category.
 ************************************************ */

 pursue_categories(GameData, computer, UpdatedGameData) :-
    pick_strategy(GameData, BestStrategy),
    get_available_categories(GameData, _, false),
    print_strategy(BestStrategy, computer),
    update_strategy(GameData, BestStrategy, UpdatedGameData).

pursue_categories(GameData, human, UpdatedGameData) :-
    pick_strategy(GameData, BestStrategy),
    get_available_categories(GameData, PossibleCategories, false),
    write("Please input a list of categories you would like to pursue."), nl,
    validate_pursue_categories(PossibleCategories, BestStrategy),
    update_strategy(GameData, BestStrategy, UpdatedGameData).

/* *********************************************************************
Function Name: handle_rerolls
Purpose: To handle locking dice based on what the player chooses to reroll
Reference: None
********************************************************************* */

/* *************************************************
handle_rerolls/3
Parameters:
    +GameData: game/4 structure containing the 
        current game state.
    +Player: The player whose turn it is.
    -NewSet: The updated diceset.
 ************************************************ */

% Lock all dice if no strategy, or if best strategy is to stand
 handle_rerolls(game(_, _, Dice, BestStrategy), computer, NewSet) :-
    BestStrategy = none,
    toggle_dice_lock(Dice, locked, NewSet).
handle_rerolls(game(_, _, Dice, [CurrScore, MaxScore | _]), computer, NewSet) :-
    CurrScore = MaxScore,
    toggle_dice_lock(Dice, locked, NewSet).

% Lock any dice not being rerolled for the computer.
handle_rerolls(game(_, _, Dice, [_, _, ToReroll, _, _]), computer, NewSet) :-
    lock_other_dice(Dice, ToReroll, NewSet).

% If the player chooses to reroll.
handle_rerolls(game(_, _, Dice, BestStrategy), human, NewSet) :-
    write("Would you like to stand or reroll?"), nl,
    validate_stand_reroll(BestStrategy, reroll),
    write("Please input a list of dice faces to reroll."), nl,
    filter_free_dice(Dice, FreeDice),
    count_dice_faces(FreeDice, FreeCounts),
    validate_reroll(BestStrategy, FreeCounts, ToReroll),
    lock_other_dice(Dice, ToReroll, NewSet).


% If the player chooses to stand, lock all dice.
handle_rerolls(game(_, _, Dice, _), human, NewSet) :-
    toggle_dice_lock(Dice, locked, NewSet).
    
/* *********************************************************************
Function Name: stand_or_reroll
Purpose: To control flow after a roll to either reroll or choosing a category
Reference: None
********************************************************************* */

/* *************************************************
stand_or_reroll/5
Parameters:
    +GameData: game/4 structure containing the 
        current game state.
    +Player: The player whose turn it is.
    +RollNumber: The current roll number.
    +NewSet: The updated diceset.
    -AfterRolls: game/4 structure containing the 
        game state after the rolls.
 ************************************************ */

% If all dice are locked, move on to choose_category.
stand_or_reroll(GameData, Player, _, NewSet, FinalGameData) :-
    filter_locked_dice(NewSet, LockedDice),
    length(LockedDice, LockedCount),
    LockedCount = 5,
    update_dice(GameData, NewSet, AfterRolls),
    choose_category(AfterRolls, Player, FinalGameData).

% If not all dice are locked, reroll.
stand_or_reroll(GameData, Player, RollNumber, NewSet, AfterRolls) :-
    update_dice(GameData, NewSet, UpdatedGameData),
    NextRoll is RollNumber + 1,
    handle_rolls(UpdatedGameData, Player, NextRoll, AfterRolls).

/* *********************************************************************
Function Name: choose_category
Purpose: Chooses a category to fill based on the player's input or the best strategy.
Reference: None
********************************************************************* */

/* *************************************************
choose_category/3
Parameters:
    +GameData: game/4 structure containing the 
        current game state.
    +Player: The player whose turn it is.
    -AfterCategory: game/4 structure containing the 
        game state after the player chooses a category.
 ************************************************ */

% Skip turn if no categories can be filled.
choose_category(GameData, _, GameData) :-
    get_available_categories(GameData, PossibleCategories, false),
    PossibleCategories = [],
    write("No categories can be filled with the current dice set. Skipping turn."), nl.

% Computer chooses a category based on the best strategy.
choose_category(GameData, computer, AfterTurn) :-
    pick_strategy(GameData, BestStrategy),
    BestStrategy = [CurrScore, _, _, _, Name],
    get_category_index(Name, ChosenCategory),
    print_strategy(BestStrategy, computer, true),
    fill_category(GameData, computer, ChosenCategory, CurrScore, AfterTurn).

% Player chooses a category.
choose_category(GameData, human, AfterTurn) :-
    GameData = [Round, _, Dice, _],
    pick_strategy(GameData, BestStrategy),
    write("Please choose a category to fill by its index."), nl,
    get_available_categories(GameData, AvailableCategories, false),
    validate_choose_category(AvailableCategories, BestStrategy, ChosenCategory),
    check_category_strategy([0], Dice, ChosenCategory, ChosenStrategy),
    ChosenStrategy = [PointsEarned | _],
    write("Please input the points scored for this category."), nl,
    validate_points(PointsEarned),
    write("Please input the current round."), nl,
    validate_round(Round),
    fill_category(GameData, human, ChosenCategory, PointsEarned, AfterTurn).

    

% major things to do
% print strategy functions [2]
% handle rerolls [3]
    % stand or reroll
    % pick dice
    % lock others
% stand or reroll: based on if everything is locked! [1]
    % simply redoes the handle_rolls function or moves on to choose_category
% choose_category [2]
    % computer and player version
    % skipping turn functionality
    % validate and/or print choice
% finish up run_rounds [1]
    % serialize save
    % print scores
% finish tournament [1]
    % print final
    % test everything

% rough schedule for today
% 1 - 2 handle rerolls (start)
% 2 - 4 senior project class + finish handle rerolls
    % try to sit in the back and work on this
% 4 - 5 go to work and do stand or reroll
% 5 - 6:30 choose category
% 6:30 - 7:45 finish up run_rounds and tournament
% go home
% dinner & prep for other classes & tomorrow