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
 Function Name: get_file_contents
 Purpose: Gets a user-provided file until contents are valid
 Reference: Used ChatGPT to learn about Prolog file & exception handling
 ********************************************************************* */

/* *************************************************
get_file_contents/1
Parameters:
    -GameData: game/4 structure loaded from the file.
 ************************************************ */

% Get the file name from the user and attempt to load it.
get_file_contents(GameData) :-
    read_line_to_string(user_input, FileName),
    catch((
        open(FileName, read, FileStream),
        read(FileStream, RawData),
        validate_game_data(RawData, IsValid),
        get_file_contents(RawData, IsValid, GameData),
        close(FileStream),
        !
       ),
      _,
      (write("Error: Invalid file. Please try again."), nl, get_file_contents(GameData))).

/* *************************************************
get_file_contents/3
Parameters:
    +RawData: the raw data from the file.
    +IsValid: true if the file contents are valid.
    -GameData: game/4 structure loaded from the file.
 ************************************************ */

% If the file contents are valid, set the game data.
get_file_contents([Round, Scorecard], true, GameData) :-
    Dice = [[1, unlocked], [1, unlocked], [1, unlocked], [1, unlocked], [1, unlocked]],
    Strategy = [],
    GameData = game(Round, Scorecard, Dice, Strategy).

% If the file contents are invalid, prompt the user to try again.
get_file_contents(_, false, GameData) :-
    write("Error: Invalid file contents. Please try again."),
    nl,
    get_file_contents(GameData).

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