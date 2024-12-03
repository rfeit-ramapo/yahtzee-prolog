/* *********************************************
 Source Code to handle and print game data
 ********************************************* */

/* *********************************************************************
 Function Name: print_instructions
 Purpose: Print the initial instructions for the game
 Reference: Found 'get_single_char' in the SWI-Prolog documentation
 ********************************************************************* */

% print_instructions
print_instructions :-
    % Basic instruction string
    write("Welcome to Yahtzee! Below you will find the scorecard categories. When asked to input dice, please use face values. When asked for multiple values (dice or categories), please separate each by a space. All categories should be specified by index. To help visualize the dice, all 'locked' dice (those that have been set aside and cannot be rerolled) are displayed in red. If you need help, enter 'h' to get a recommendation.\n\n"),

    % Print default scorecard
    print_scorecard,

    % Await user confirmation
    write("To begin the game, press any key to continue.\n"),
    get_single_char(_).

/* *********************************************************************
 Function Name: print_scorecard
 Purpose: Print the current scorecard
 Reference: None
 ********************************************************************* */

% print_scorecard
print_scorecard :-
    get_default_game_data(GameData),
    print_scorecard(GameData).

% print_scorecard(+GameData)
    % GameData is a game/4 structure containing the current game state.
print_scorecard(GameData) :-
    get_scorecard(GameData, Scorecard),

    % Header
    write("Current Scorecard:\n"),
    format('~w~t~7|~w~t~25|~w~t~65|~w~t~97|~w~t~107|~w~t~115|~w~t~122|', 
           ['Index', 'Category', 'Description', 'Score', 'Winner', 'Points', 'Round']),
    nl,
    write("========================================================================================================================\n"),

    % Print each category
    print_categories(Scorecard).

/* *********************************************************************
 Function Name: get_default_game_data
 Purpose: Get default (empty) game data
 Reference: None
 ********************************************************************* */

% get_default_game_data(-GameData)
    % GameData is a game/4 structure containing the default game state.
get_default_game_data(GameData) :-
    Round = 1,
    Scorecard = [[0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0]],
    Dice = [[1, unlocked], [1, unlocked], [1, unlocked], [1, unlocked], [1, unlocked]],
    Strategy = [],
    GameData = game(Round, Scorecard, Dice, Strategy).

/* *********************************************************************
 Function Name: get_scorecard
 Purpose: Get the scorecard from the game data
 Reference: None
 ********************************************************************* */

% get_scorecard(+GameData, -Scorecard)
    % GameData is a game/4 structure containing the current game state.
    % Scorecard is a list of categories, each containing a list of 
        % [Winner, Points, Round] or [0] if not filled.
get_scorecard(game(_, Scorecard, _, _), Scorecard).

/* *********************************************************************
 Function Name: print_categories
 Purpose: Format and print the categories of a scorecard
 Reference: None
 ********************************************************************* */

% print_categories(+Scorecard)
    % Scorecard is a list of categories, each containing a list of 
        % [Winner, Points, Round] or [0] if not filled.
print_categories(Scorecard) :- print_categories(Scorecard, 1).

% print_categories(+ScoreData, +StartAt)
    % ScoreData is a list of categories, each containing a list of 
        % [Winner, Points, Round] or [0] if not filled.
    % StartAt is the category index to start printing at.
% Base case: If the ScoreData list is empty, print a newline.
print_categories([], _) :-
    nl.

% print_categories(+ScoreData, +StartAt)
    % ScoreData is a list of categories, each containing a list of 
        % [Winner, Points, Round] or [0] if not filled.
    % StartAt is the category index to start printing at.
% Recursive case: Print the first category and recursively process the rest.
print_categories([FirstCategory | Rest], StartAt) :-
    print_category(FirstCategory, StartAt),
    NextIndex is StartAt + 1,
    print_categories(Rest, NextIndex).

/* *********************************************************************
 Category Information Facts
 ********************************************************************* */

% category_info(+CategoryNum, -Info)
% Maps a category number to its details.
category_info(1, ['Aces', 'Any combination', 'Sum of dice with the number 1']).
category_info(2, ['Twos', 'Any combination', 'Sum of dice with the number 2']).
category_info(3, ['Threes', 'Any combination', 'Sum of dice with the number 3']).
category_info(4, ['Fours', 'Any combination', 'Sum of dice with the number 4']).
category_info(5, ['Fives', 'Any combination', 'Sum of dice with the number 5']).
category_info(6, ['Sixes', 'Any combination', 'Sum of dice with the number 6']).
category_info(7, ['Three of a Kind', 'At least three dice the same', 'Sum of all dice']).
category_info(8, ['Four of a Kind', 'At least four dice the same', 'Sum of all dice']).
category_info(9, ['Full House', 'Three of one number and two of another', '25']).
category_info(10, ['Four Straight', 'Four sequential dice', '30']).
category_info(11, ['Five Straight', 'Five sequential dice', '40']).
category_info(12, ['Yahtzee', 'All five dice the same', '50']).

/* *********************************************************************
 Function Name: print_category
 Purpose: Print a category's details and score information
 Reference: None
 ********************************************************************* */

% print_category(+ScoreData, +CategoryNum)
    % ScoreData is a list of [Winner, Points, Round] or [0] if not filled.
    % CategoryNum is the index of the category.
% Case where the category has not been filled.
print_category([0], CategoryNum) :-
    % Fetch category information.
    category_info(CategoryNum, [Name, Description, Score]),
    % Print the category details with proper spacing.
    format('~w~t~7|~w~t~25|~w~t~65|~w~t~97|', 
           [CategoryNum, Name, Description, Score]),
    nl.

% print_category(+ScoreData, +CategoryNum)
    % ScoreData is a list of [Winner, Points, Round] or [0] if not filled.
    % CategoryNum is the index of the category.
% Case where the category has been filled.
print_category([Winner, Points, Round], CategoryNum) :-
    % Fetch category information.
    category_info(CategoryNum, [Name, Description, Score]),
    % Print the category details with proper spacing.
    format('~w~t~7|~w~t~25|~w~t~65|~w~t~97|~w~t~107|~w~t~115|~w~t~122|', 
           [CategoryNum, Name, Description, Score, Winner, Points, Round]),
    nl.

/* *********************************************************************
 Function Name: initialize_game_data
 Purpose: Adds game state information onto serialized information, or create it from scratch
 Reference: None
 ********************************************************************* */



/*
get_round(game(Round, _, _, _), Round).
get_dice(game(_, _, Dice, _), Dice).
get_strategy(game(_, _, _, Strategy), Strategy).

update_round(game(_, Scorecard, Dice, Strategy), NewRound, game(NewRound, Scorecard, Dice, Strategy)).
update_scorecard(game(Round, _, Dice, Strategy), NewScorecard, game(Round, NewScorecard, Dice, Strategy)).
update_dice(game(Round, Scorecard, _, Strategy), NewDice, game(Round, Scorecard, NewDice, Strategy)).
update_strategy(game(Round, Scorecard, Dice, _), NewStrategy, game(Round, Scorecard, Dice, NewStrategy)).
*/
