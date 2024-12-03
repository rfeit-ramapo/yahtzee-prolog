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

% serialize_load(-GameData)
    % GameData is a game/4 structure loaded from the file, or freshly created.
serialize_load(GameData) :-
    write("Would you like to load the game from a file? (y/n)"),
    nl,
    validate_yes_no(Choice),
    load_file(Choice, GameData).


/* *********************************************************************
 Function Name: load_file
 Purpose: Asks the user for a file name and loads it
 Reference: None
 ********************************************************************* */

% load_file(+Choice, -GameData)
    % Choice is false if the user does not want to load a file.
    % GameData is a game/4 structure freshly created for this game.
load_file(false, GameData) :-
    get_default_game_data(GameData).

% load_file(+Choice, -GameData)
    % Choice is true if the user wants to load a file.
    % GameData is a game/4 structure loaded from the file.
load_file(true, GameData) :-
    write("Please input the name of the file to load from."),
    nl,
    get_file_contents(GameData),
    write("Successfully loaded file!"),
    nl, nl.
