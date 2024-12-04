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
