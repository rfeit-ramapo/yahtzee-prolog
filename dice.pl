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
    random_between(1, 6, Die).

/* *************************************************
roll_one/2
Parameters:
    -Die: The value of the die rolled
    +Choice: The user's choice to manually input the roll
 ************************************************ */

roll_one(Die, true) :-
    write("Input the result of your roll."), nl,
    read_line_to_string(user_input, DieInput),
    number_string(Die, DieInput),
    valid_die_face(Die).