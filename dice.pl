/* *********************************************
 Source Code to handle rounds of the game
    -> Relies on:
        utility.pl
        validation.pl
        game_data.pl
 ********************************************* */

/* *********************************************************************
 Function Name: roll_one
 Purpose: Roll a single die
 Reference: None
********************************************************************* */

/* *************************************************
roll_one/1
Parameters:
    -Die: The value of the die rolled
 ************************************************ */

roll_one(Die) :-
    write("Would you like to manually input this dice roll? (y/n)"), nl,
    validate_yes_no(Choice),
    roll_one(Die, Choice).

/* *************************************************
roll_one/2
Parameters:
    -Die: The value of the die rolled
    +Choice: The user's choice to manually input the roll
 ************************************************ */

% Manual input
roll_one(Die, true) :-
    write("Input the result of your roll."), nl,
    read_line_to_string(user_input, DieInput),
    number_string(Die, DieInput),
    valid_die_face(Die).

% Error fallback for manual input
roll_one(Die, true) :-
    write("Error: Input must be a single die face (1-6). Please try again."), nl,
    roll_one(Die, true).

% Automatic roll
roll_one(Die, false) :-
    random_between(1, 6, Die).

/* *********************************************************************
 Function Name: roll_all
 Purpose: Rolls all free dice
 Reference: None
********************************************************************* */

/* *************************************************
roll_all/2
Parameters:
    +Dice: The list of dice to roll
    -NewDice: The list of dice after rolling
 ************************************************ */

roll_all(Dice, NewDice) :-
    write("Would you like to manually input this dice roll? (y/n)"), nl,
    filter_free_dice(Dice, FreeDice),
    length(FreeDice, NumToRoll),
    validate_yes_no(Choice),
    roll_all(Dice, NewDice, NumToRoll, Choice).

/* *************************************************
roll_all/4
Parameters:
    +Dice: The list of dice to roll
    -NewDice: The list of dice after rolling
    +NumToRoll: The number of dice to roll
    +Choice: The user's choice to manually input the roll
 ************************************************ */

 % Manual input
 roll_all(Dice, NewDice, NumToRoll, true) :-
    write("Input the result of your roll."), nl,
    validate_dice_faces(NumToRoll, NewRolls),
    filter_locked_dice(Dice, LockedDice),
    combine_dice(NewRolls, LockedDice, NewDice).

% Automatic roll
roll_all(Dice, NewDice, NumToRoll, false) :-
    auto_roll(NumToRoll, NewRolls),
    filter_locked_dice(Dice, LockedDice),
    combine_dice(NewRolls, LockedDice, NewDice).

/* *********************************************************************
 Function Name: filter_free_dice
 Purpose: Filter out the free dice from the list of dice
 Reference: None
********************************************************************* */

/* *************************************************
filter_free_dice/2
Parameters:
    +Dice: The list of dice
    -FreeDice: The list of free dice
 ************************************************ */

% Base case: no dice left to check
 filter_free_dice([], []).

% Add the first die if it is free
filter_free_dice([ Die | RestDice], FreeDice) :-
    Die = die(_, unlocked),
    filter_free_dice(RestDice, RestFreeDice),
    append([Die], RestFreeDice, FreeDice).

% Skip the first die if it is locked
filter_free_dice([ _ | RestDice], FreeDice) :-
    filter_free_dice(RestDice, FreeDice).

/* *********************************************************************
 Function Name: filter_locked_dice
 Purpose: Filter out the locked dice from the list of dice
 Reference: None
********************************************************************* */

/* *************************************************
filter_free_dice/2
Parameters:
    +Dice: The list of dice
    -LockedDice: The list of locked dice
 ************************************************ */

% Base case: no dice left to check
 filter_locked_dice([], []).

% Add the first die if it is free
filter_locked_dice([ Die | RestDice], LockedDice) :-
    Die = die(_, locked),
    filter_locked_dice(RestDice, RestLockedDice),
    append([Die], RestLockedDice, LockedDice).

% Skip the first die if it is locked
filter_locked_dice([ _ | RestDice], LockedDice) :-
    filter_locked_dice(RestDice, LockedDice).

/* *********************************************************************
 Function Name: combine_dice
 Purpose: Adds a list of dice faces onto an existing list of dice
 Reference: None
********************************************************************* */

/* *************************************************
combine_dice/3
Parameters:
    +ToAdd: The list of dice faces to add
    +BaseDice: The list of dice to add to
    -NewDice: A dice set combining both sets of values
 ************************************************ */

% Base case: no dice to add
combine_dice([], BaseDice, BaseDice).

% Recursively add the first die
combine_dice([DieFace | RestDice], BaseDice, FinalDice) :-
    combine_dice(RestDice, BaseDice, NewDice),
    append([die(DieFace, unlocked)], NewDice, FinalDice).

/* *********************************************************************
 Function Name: auto_roll
 Purpose: Rolls a specified number of dice automatically (no player input)
 Reference: None
********************************************************************* */

/* *************************************************
auto_roll/2
Parameters:
    +NumToRoll: The number of dice to roll
    -NewRolls: The list of dice faces after rolling
 ************************************************ */

 % Base case: no more dice to roll
auto_roll(0, []).

% Recursive case - add a randomly generated die onto the list
auto_roll(NumToRoll, [DieFace | RestDice]) :-
    random_between(1, 6, DieFace),
    NextNum is NumToRoll - 1,
    auto_roll(NextNum, RestDice).