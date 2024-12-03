/* *********************************************
 Source Code to handle validation of user input
 ********************************************* */

/* *********************************************************************
 Function Name: validate_yes_no
 Purpose: Validates input as 'y' or 'n'
 Reference: None
 ********************************************************************* */

% validate_yes_no(-Choice)
    % Choice is true if the user entered 'y', false if 'n'
 validate_yes_no(Choice) :-
    get_single_char(CharCode),
    char_code(Char, CharCode),
    validate_yes_no(Choice, Char).

% validate_yes_no(-Choice, +Char)
    % Choice is true if the user entered 'y'
    % Char is the character the user entered
validate_yes_no(true, Char) :-
    (Char = 'y' ; Char = 'Y').

% validate_yes_no(-Choice, +Char)
    % Choice is false if the user entered 'n'
    % Char is the character the user entered
validate_yes_no(false, Char) :-
    (Char = 'n' ; Char = 'N').

% validate_yes_no(+Choice, +Char)
    % Choice is the user's new input
    % Char is the character the user previously entered
    % If the user entered something other than 'y' or 'n', prompt again
validate_yes_no(Choice, _) :-
    write("Invalid input. Please enter 'y' or 'n'."),
    nl,
    validate_yes_no(Choice).

/* *********************************************************************
 Function Name: get_file_contents
 Purpose: Gets a user-provided file until contents are valid
 Reference: Used ChatGPT to learn about Prolog file & exception handling
 ********************************************************************* */

% get_file_contents(-GameData)
    % GameData is a game/4 structure loaded from the file.
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

% get_file_contents(+RawData, +IsValid, -GameData)
    % RawData is the raw data from the file.
    % IsValid is true if the file contents are valid.
    % GameData is a game/4 structure loaded from the file.
% If the file contents are valid, set the game data.
get_file_contents([Round, Scorecard], true, GameData) :-
    Dice = [[1, unlocked], [1, unlocked], [1, unlocked], [1, unlocked], [1, unlocked]],
    Strategy = [],
    GameData = game(Round, Scorecard, Dice, Strategy).

% get_file_contents(+RawData, +IsValid, -GameData)
    % RawData is the raw data from the file.
    % IsValid is false if the file contents are invalid.
    % GameData is a game/4 structure loaded from a newly attempted file.
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

% validate_game_data(+RawData, -IsValid)
    % RawData is the raw data from the file.
    % IsValid is true in this case, since data properly validated.
validate_game_data([Round, Scorecard | []], true) :-
    integer(Round),
    is_list(Scorecard),
    validate_categories(Scorecard).

% validate_game_data(+RawData, -IsValid)
    % RawData is the raw data from the file.
    % IsValid is false if the data is not properly validated.
validate_game_data(_, false).

/* *********************************************************************
 Function Name: validate_categories
 Purpose: Validates a list of categories within the scorecard
 Reference: None
 ********************************************************************* */

% validate_categories(+Scorecard, -IsValid)
    % Scorecard is a list of categories from the loaded file.
% Kick off the validation process with initial scorecard
validate_categories(Scorecard) :-
    validate_categories(Scorecard, 0).

% validate_categories(+Scorecard, +Index)
    % Scorecard is a list of categories from the loaded file.
    % Index is the number of categories that were validated.
% Base cases: all categories were checked
validate_categories([], 12).
validate_categories([], _) :- fail.

% validate_categories(+Scorecard, +Index)
    % Scorecard is a list of categories from the loaded file.
    % Index is the current category being validated.
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

% validate_category(+Category)
    % Category is [0] if not filled.
validate_category([0]). 

% validate_category(+Category)
    % Category is [Points, Winner, Rounds] if filled.
validate_category([Points, Winner, Rounds]) :-
    integer(Points),
    (Winner = human; Winner = computer),
    integer(Rounds).
