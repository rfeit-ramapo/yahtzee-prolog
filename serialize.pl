/* *********************************************
 Source Code to serialize (load and save) game data
    -> Relies on:
        validation.pl
        game_data.pl
 ********************************************* */

/* *********************************************************************
 Function Name: serialize_load
 Purpose: Asks the user if they want to serialize, and loads the file if they do
 Reference: None
 ********************************************************************* */

/* *************************************************
serialize_load/1
Parameters:
    -GameData: game/4 structure loaded from the file, 
        or freshly created.
************************************************ */

serialize_load(GameData) :-
    write("Would you like to load the game from a file? (y/n)"),
    nl,
    validate_yes_no(Choice),
    load_file(Choice, GameData).


/* *********************************************************************
 Function Name: load_file
 Purpose: Loads a file if the user requests, or creates a new game
 Reference: None
 ********************************************************************* */

/* *************************************************
load_file/2
Parameters:
    +Choice: true if the user wants to load a file, 
        false if they don't.
    -GameData: game/4 structure loaded from the file, 
        or freshly created.
************************************************ */

load_file(false, GameData) :-
    get_default_game_data(GameData).

load_file(true, GameData) :-
    write("Please input the name of the file to load from."),
    nl,
    get_file_contents(GameData),
    write("Successfully loaded file!"),
    nl, nl.

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
 Function Name: serialize_save
 Purpose: Asks the user if they want to serialize, and saves the file if they do
 Reference: None
 ********************************************************************* */

/* *************************************************
serialize_save/1
Parameters:
    +GameData: game/4 structure to save to a file.
************************************************ */

serialize_save(GameData) :-
    write("Would you like to save the game to a file? (y/n)"),
    nl,
    validate_yes_no(Choice),
    save_file(Choice, GameData).

/* *********************************************************************
Function Name: save_file
Purpose: Saves a file if the user requests
Reference: None
********************************************************************* */

/* *************************************************
save_file/2
Parameters:
    +Choice: true if the user wants to save a file, 
        false if they don't.
    +GameData: game/4 structure to save to a file.
************************************************ */

save_file(false, _).

save_file(true, GameData) :-
    write("Please input the name of the file to save to."),
    nl,
    read_line_to_string(user_input, FileName),
    open(FileName, write, FileStream),
    write(FileStream, GameData),
    close(FileStream),
    write("Successfully saved file!"),
    nl, nl.