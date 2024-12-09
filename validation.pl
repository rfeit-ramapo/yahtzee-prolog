/* *********************************************
 Source Code to handle validation of user input
 ********************************************* */

/* *********************************************************************
 Function Name: validate_yes_no
 Purpose: Validates input as 'y' or 'n'
 Reference: None
 ********************************************************************* */

/* *************************************************
validate_yes_no/1
Parameters:
    -Choice: the player's decision with true for 'y' 
        and false for 'n'.
 ************************************************ */

 validate_yes_no(Choice) :-
    get_single_char(CharCode),
    char_code(Char, CharCode),
    validate_yes_no(Char, Choice).

/* *************************************************
validate_yes_no/2
Parameters:
    +Char: the character the player entered.
    -Choice: the player's decision with true for 'y' 
        and false for 'n'.
 ************************************************ */

validate_yes_no(Char, true) :-
    (Char = 'y' ; Char = 'Y').

validate_yes_no(Char, false) :-
    (Char = 'n' ; Char = 'N').

% If the user entered something other than 'y' or 'n', prompt again
validate_yes_no(_, Choice) :-
    write("Invalid input. Please enter 'y' or 'n'."),
    nl,
    validate_yes_no(Choice).

/* *********************************************************************
 Function Name: validate_game_data
 Purpose: Validates the raw data from the file
 Reference: None
 ********************************************************************* */

/* *************************************************
validate_game_data/2
Parameters:
    +RawData: the raw data from the file.
    -IsValid: true if the data is valid.
 ************************************************ */

validate_game_data([Round, Scorecard | []], true) :-
    integer(Round),
    is_list(Scorecard),
    validate_categories(Scorecard).

validate_game_data(_, false).

/* *********************************************************************
 Function Name: validate_categories
 Purpose: Validates a list of categories within the scorecard
 Reference: None
 ********************************************************************* */

/* *************************************************
validate_categories/1
Parameters:
    +Scorecard: a list of categories from the loaded file.
 ************************************************ */

% Kick off the validation process with initial scorecard
validate_categories(Scorecard) :-
    validate_categories(Scorecard, 0).

/* *************************************************
validate_categories/2
Parameters:
    +Scorecard: a list of categories from the loaded file.
    +Index: the current category being validated.
 ************************************************ */

% Base cases: all categories were checked
validate_categories([], 12).
validate_categories([], _) :- fail.

% Recursive case: validate the current category and move to the next
validate_categories([Category | Rest], Index) :-
    validate_category(Category),
    NextIndex is Index + 1,
    validate_categories(Rest, NextIndex).

/* *********************************************************************
 Function Name: validate_category
 Purpose: Validates a single category
 Reference: None
 ********************************************************************* */

/* *************************************************
validate_category/1
Parameters:
    +Category: a single category from the loaded file.
 ************************************************ */
    
% Category is [0] if not filled.
validate_category([0]). 

% Category is [Points, Winner, Rounds] if filled.
validate_category([Points, Winner, Rounds]) :-
    integer(Points),
    (Winner = human; Winner = computer),
    integer(Rounds).

/* *********************************************************************
 Function Name: valid_die_face
 Purpose: Validates an input to confirm it is a valid die face
 Reference: None
 ********************************************************************* */

/* *************************************************
valid_die_face/1
Parameters:
    +Die: the face of the die rolled.
 ************************************************ */

valid_die_face(Die) :-
    integer(Die),               % Check that Die is an integer
    between(1, 6, Die).         % Check that Die is in the range 1 to 6
    
/* *********************************************************************
 Function Name: validate_dice_faces
 Purpose: Validates input of multiple dice faces [1-6]
 Reference: None
********************************************************************* */

/* *************************************************
validate_dice_faces/2
Parameters:
    +NumToRoll: the number of dice to roll.
    -NewRolls: the list of input dice faces.
 ************************************************ */

% Case of valid input.
validate_dice_faces(NumToRoll, NewRolls) :-
    read_line_to_string(user_input, UserInput),
    read_term_from_atom(UserInput, DiceList, []),
    valid_dice_list(DiceList, NumToRoll),
    NewRolls = DiceList.

% Invalid input for multiple dice.
validate_dice_faces(NumToRoll, NewRolls) :-
    write("Error: Input must be a list of dice faces (e.g. [1, 2, 3].). Please try again."), nl,
    validate_dice_faces(NumToRoll, NewRolls).

% Invalid input for one die.
validate_dice_faces(1, NewRolls) :-
    write("Error: Input must be a list with one dice face (e.g. [1].). Please try again."), nl,
    validate_dice_faces(1, NewRolls).

/* *************************************************
validate_dice_faces/2
Parameters:
    +NumToRoll: the number of dice to roll.
    -Result: the list of input dice faces, or "h" if help was requested.
    +HelpAllowed: true if the user can ask for help.
 ************************************************ */

% Valid input
 validate_dice_faces(NumToRoll, Result, true) :-
    read_line_to_string(user_input, UserInput),
    % If the user asks for help, return "h"
    (UserInput = "h", Result = "h" ; 
     UserInput = "H", Result = "h" ;

     % Otherwise, validate and return the dice list
     read_term_from_atom(UserInput, DiceList, []),
     valid_dice_list(DiceList, NumToRoll),
     Result = DiceList).

% Invalid input for multiple dice.
validate_dice_faces(NumToRoll, NewRolls, true) :-
    write("Error: Input must be a list of dice faces (e.g. [1, 2, 3].). Please try again."), nl,
    validate_dice_faces(NumToRoll, NewRolls, true).

% Invalid input for one die.
validate_dice_faces(1, NewRolls, true) :-
    write("Error: Input must be a list with one dice face (e.g. [1].). Please try again."), nl,
    validate_dice_faces(1, NewRolls, true).

/* *********************************************************************
 Function Name: valid_dice_list
 Purpose: Checks if a list of dice is valid
 Reference: None
********************************************************************* */

/* *************************************************
valid_dice_list/2
Parameters:
    +DiceList: the list of dice faces.
    +NumToRoll: the number of dice to roll.
 ************************************************ */

% Check if the length of the list matches the number of dice to roll
valid_dice_list(DiceList, NumToRoll) :-
    is_list(DiceList),
    length(DiceList, NumInput),
    NumInput = NumToRoll,
    valid_dice_list(DiceList).

/* *************************************************
valid_dice_list/1
Parameters:
    +DiceList: the list of dice faces.
 ************************************************ */

 % Base case: only one die to check
 valid_dice_list([Die | []]) :-
    valid_die_face(Die).

% Recursive case: check the current die and move to the next
valid_dice_list([Die | Rest]) :-
    valid_die_face(Die),
    valid_dice_list(Rest).

/* *********************************************************************
 Function Name: validate_available_categories
 Purpose: Validates that the user input all available categories correctly
 Reference: None
********************************************************************* */

/* *************************************************
validate_available_categories/1
Parameters:
    +AvailableCategories: the list of available categories.
************************************************ */

validate_available_categories(AvailableCategories) :-
    read_line_to_string(user_input, UserInput),
    % If the user asks for help, give it and prompt again.
    ((UserInput = "h" ; UserInput = "H"), 
    write("The available categories are: "), write(AvailableCategories), nl,
    validate_available_categories(AvailableCategories) ; 

     % Otherwise, end recursion only if valid
     read_term_from_atom(UserInput, InputCategories, []),
     InputCategories = AvailableCategories ;
     write("Error: Input must be a list of available categories that have at least one contributing die (e.g. [1,2,3]). Please try again."), nl,
     validate_available_categories(AvailableCategories)).

/* *********************************************************************
 Function Name: validate_pursue_categories
 Purpose: Validates that the user input a valid subset of available categories
 Reference: None
********************************************************************* */

/* *************************************************
validate_pursue_categories/2
Parameters:
    +AvailableCategories: the list of available categories.
    +BestStrategy: the strategy to recommend if the
        user asks for help.
************************************************ */

validate_pursue_categories(AvailableCategories, BestStrategy) :-
    read_line_to_string(user_input, UserInput),
    % If the user asks for help, give it and prompt again.
    ((UserInput = "h" ; UserInput = "H"), 
    print_strategy(BestStrategy, human),
    validate_pursue_categories(AvailableCategories, BestStrategy) ; 

     % Otherwise, end recursion only if valid
     read_term_from_atom(UserInput, InputCategories, []),
     is_subset(InputCategories, AvailableCategories) ;
     write("Error: Input must be a subset of available categories that have at least one contributing die (e.g. [11, 12]). Please try again."), nl,
     validate_pursue_categories(AvailableCategories, BestStrategy)).

/* *********************************************************************
 Function Name: validate_stand_reroll
 Purpose: Validates that the user input is either 'stand' or 'reroll'
 Reference: None
********************************************************************* */

/* *************************************************
validate_pursue_categories/2
Parameters:
    +Strategy: the strategy to recommend if the
        user asks for help.
    -Choice: the player's decision to stand or reroll.
************************************************ */

validate_stand_reroll(Strategy, Choice) :-
    read_line_to_string(user_input, UserInput),
    % If the user asks for help, give it and prompt again.
    ((UserInput = "h" ; UserInput = "H"), 
    print_strategy(Strategy, human),
    validate_stand_reroll(Strategy, Choice) ; 
    (UserInput = "stand" ; UserInput = "reroll"),
    read_term_from_atom(UserInput, Choice, [])).

validate_stand_reroll(Strategy, Choice) :-
    write("Error: Input must be either 'stand' or 'reroll'. Please try again."), nl,
    validate_stand_reroll(Strategy, Choice).

/* *********************************************************************
Function Name: validate_reroll
Purpose: Validates that the user inputs a valid list of dice to reroll
Reference: None
********************************************************************* */

/* *************************************************
validate_reroll/3
Parameters:
    +Strategy: the strategy to recommend if the
        user asks for help.
    +FreeCounts: the list of free dice faces.
    -ToReroll: the list of dice faces to reroll.
************************************************ */

validate_reroll(Strategy, FreeCounts, RerollCounts) :-
    read_line_to_string(user_input, UserInput),
    % If the user asks for help, give it and prompt again.
    ((UserInput = "h" ; UserInput = "H"), 
    print_strategy(Strategy, human),
    validate_reroll(Strategy, FreeCounts, RerollCounts) ; 

    read_term_from_atom(UserInput, ToReroll, []),
    faces_to_dice(ToReroll, RerollDice),
    count_dice_faces(RerollDice, RerollCounts),
    valid_reroll_counts(FreeCounts, RerollCounts) ;

    write("Error: Input must be a list of free dice by their face values (e.g. [3, 3, 2]). Please try again."), nl,
    validate_reroll(Strategy, FreeCounts, RerollCounts)).

/* *********************************************************************
Function Name: valid_reroll_counts
Purpose: Checks if user-inputted reroll counts are valid
Reference: None
********************************************************************* */

/* *************************************************
valid_reroll_counts/2
Parameters:
    +FreeCounts: the list of free dice faces.
    +RerollCounts: the list of dice faces to reroll.
************************************************ */

% Base case: all dice checked and are valid
valid_reroll_counts([], []).

% Recursive case: check the current face and move to the next
valid_reroll_counts([FirstFree | RestFree], [FirstReroll | RestReroll]) :-
    FirstReroll =< FirstFree,
    valid_reroll_counts(RestFree, RestReroll).

/* *********************************************************************
Function Name: validate_choose_category
Purpose: Validates that the user inputs a valid category index
Reference: None
********************************************************************* */

/* *************************************************
validate_choose_category/3
Parameters:
    +AvailableCategories: the list of available categories.
    +Strategy: the strategy to recommend if the
        user asks for help.
    -ChosenCategory: the category index the player chose.
************************************************ */

validate_choose_category(AvailableCategories, Strategy, ChosenCategory) :-
    read_line_to_string(user_input, UserInput),
    % If the user asks for help, give it and prompt again.
    ((UserInput = "h" ; UserInput = "H"), 
    write("The available categories are: "), write(AvailableCategories), nl,
    print_strategy(Strategy, human, true),
    validate_choose_category(AvailableCategories, Strategy, ChosenCategory) ; 

    read_term_from_atom(UserInput, ChosenCategory, []),
    member(ChosenCategory, AvailableCategories)).

validate_choose_category(AvailableCategories, Strategy, ChosenCategory) :-
    write("Error: Input must be valid category index (e.g. '12' for Yahtzee). Please try again."), nl,
    validate_choose_category(AvailableCategories, Strategy, ChosenCategory).

/* *********************************************************************
Function Name: validate_points
Purpose: Validates that the user inputs a valid point total
Reference: None
********************************************************************* */

/* *************************************************
validate_points/1
Parameters:
    +Points: the point total the player earned.
************************************************ */

validate_points(Points) :-
    read_line_to_string(user_input, UserInput),
    % If the user asks for help, give it and prompt again.
    ((UserInput = "h" ; UserInput = "H"), 
    write("You have earned "), write(Points), write(" points in this category."), nl,
    validate_points(Points) ; 

    read_term_from_atom(UserInput, Points, [])).

validate_points(Points) :-
    write("Error: Incorrect point total. Please try again."), nl,
    validate_points(Points).

/* *********************************************************************
Function Name: validate_round
Purpose: Validates that the user inputs a valid round number
Reference: None
********************************************************************* */

/* *************************************************
validate_round/1
Parameters:
    +Round: the point total the player earned.
************************************************ */

validate_round(Round) :-
    read_line_to_string(user_input, UserInput),
    % If the user asks for help, give it and prompt again.
    ((UserInput = "h" ; UserInput = "H"), 
    write("The current round is: "), write(Round), write("."), nl,
    validate_round(Round) ; 

    read_term_from_atom(UserInput, Round, [])).

validate_round(Round) :-
    write("Error: Incorrect round number. Please try again."), nl,
    validate_round(Round).