/* *********************************************
 Source Code to handle and print game data
 ********************************************* */

/* *********************************************************************
 Function Name: print_instructions
 Purpose: Print the initial instructions for the game
 Reference: Found 'get_single_char' in the SWI-Prolog documentation
 ********************************************************************* */

/* *************************************************
print_instructions/0
Parameters: None
 ************************************************ */

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

/* *************************************************
print_scorecard/0
Parameters: None
 ************************************************ */

print_scorecard :-
    get_default_game_data(GameData),
    print_scorecard(GameData).

/* *************************************************
print_instructions/1
Parameters:
    +GameData: game/4 structure containing the current game state.
 ************************************************ */

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

/* *************************************************
get_default_game_data/1
Parameters:
    -GameData: game/4 structure containing the default game state.
 ************************************************ */

get_default_game_data(GameData) :-
    Round = 1,
    Scorecard = [[0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0]],
    Dice = [die(1, unlocked), die(1, unlocked), die(1, unlocked), die(1, unlocked), die(1, unlocked)],
    Strategy = [],
    GameData = game(Round, Scorecard, Dice, Strategy).

/* *********************************************************************
 Function Name: get_scorecard
 Purpose: Get the scorecard from the game data
 Reference: None
 ********************************************************************* */

/* *************************************************
get_scorecard/2
Parameters:
    +GameData: game/4 structure containing the current 
        game state.
    -Scorecard: list of categories, each containing a 
        list of [Winner, Points, Round] or [0] if 
        not filled.
 ************************************************ */

get_scorecard(game(_, Scorecard, _, _), Scorecard).

/* *********************************************************************
 Function Name: print_categories
 Purpose: Format and print the categories of a scorecard
 Reference: None
 ********************************************************************* */

/* *************************************************
print_categories/1
Parameters:
    +Scorecard: list of categories, each containing a 
        list of [Winner, Points, Round] or [0] if 
        not filled.
 ************************************************ */

print_categories(Scorecard) :- print_categories(Scorecard, 1).

/* *************************************************
print_categories/2
Parameters:
    +Scorecard: list of categories, each containing a 
        list of [Winner, Points, Round] or [0] if 
        not filled.
    +StartAt: the category index to start printing at.
 ************************************************ */

% Base case: If the ScoreData list is empty, print a newline.
print_categories([], _) :-
    nl.

% Recursive case: Print the first category and recursively process the rest.
print_categories([FirstCategory | Rest], StartAt) :-
    print_category(FirstCategory, StartAt),
    NextIndex is StartAt + 1,
    print_categories(Rest, NextIndex).

/* *********************************************************************
 Function Name: category_info
 Purpose: Maps a category number to its details
 Reference: None
 ********************************************************************* */

/* *************************************************
category_info/2
Parameters:
    +CategoryNum: the index of the category.
    -Info: a list containing the category name, description, 
        and score information.
 ************************************************ */

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

/* *************************************************
print_category/2
Parameters:
    +ScoreData: a list of [Winner, Points, Round] or [0] if 
        not filled.
    +CategoryNum: the index of the category.
 ************************************************ */

% Case where the category has not been filled.
print_category([0], CategoryNum) :-
    % Fetch category information.
    category_info(CategoryNum, [Name, Description, Score]),
    % Print the category details with proper spacing.
    format('~w~t~7|~w~t~25|~w~t~65|~w~t~97|', 
           [CategoryNum, Name, Description, Score]),
    nl.

% Case where the category has been filled.
print_category([Winner, Points, Round], CategoryNum) :-
    % Fetch category information.
    category_info(CategoryNum, [Name, Description, Score]),
    % Print the category details with proper spacing.
    format('~w~t~7|~w~t~25|~w~t~65|~w~t~97|~w~t~107|~w~t~115|~w~t~122|', 
           [CategoryNum, Name, Description, Score, Winner, Points, Round]),
    nl.

/* *********************************************************************
 Function Name: scorecard_filled
 Purpose: Check if the scorecard is filled (and thus the game is over)
 Reference: None
********************************************************************* */

/* *************************************************
scorecard_filled/1
Parameters:
    +GameData: game/4 structure containing the current 
        game state.
 ************************************************ */

scorecard_filled(GameData) :-
    get_scorecard(GameData, Scorecard),
    count_full_categories(Scorecard, Count),
    Count = 12.

/* *********************************************************************
 Function Name: count_full_categories
 Purpose: Count the number of filled categories in a scorecard
 Reference: None
 ********************************************************************* */

/* *************************************************
count_full_categories/2
Parameters:
    +Scorecard: list of categories, each containing a 
        list of [Winner, Points, Round] or [0] if 
        not filled.
    -Count: the number of categories that are filled.
 ************************************************ */

count_full_categories(Scorecard, Count) :- 
    count_full_categories(Scorecard, 0, Count).

/* *************************************************
count_full_categories/3
Parameters:
    +Scorecard: list of categories, each containing a 
        list of [Winner, Points, Round] or [0] if 
        not filled.
    +InCount: the current count of filled categories.
    -Count: the total number of categories that are filled.
 ************************************************ */

% Base case: If the Scorecard list is empty, return the current count.
count_full_categories([], InCount, InCount).

% Recursive case: If the current category is not filled, move to the next.
count_full_categories([[0] | Rest], InCount, Count) :-
    NextCount is InCount,
    count_full_categories(Rest, NextCount, Count).

% Recursive case: If the current category is filled, increment the count.
count_full_categories([[_, _, _] | Rest], InCount, Count) :-
    NextCount is InCount + 1,
    count_full_categories(Rest, NextCount, Count).

/* *********************************************************************
 Function Name: get_round
 Purpose: Get the current round number from the game data
 Reference: None
********************************************************************* */

/* *************************************************
get_round/2
Parameters:
    +GameData: game/4 structure containing the current 
        game state.
    -Round: the current round number.
 ************************************************ */

get_round(game(Round, _, _, _), Round).

/* *********************************************************************
 Function Name: get_player_scores
 Purpose: Get the scores of both players
 Reference: None
********************************************************************* */

/* *************************************************
get_player_scores/3
Parameters:
    +GameData: game/4 structure containing the current 
        game state.
    -HumanScore: the score of the human player.
    -ComputerScore: the score of the computer player.
 ************************************************ */

get_player_scores(GameData, HumanScore, ComputerScore) :-
    score_player(GameData, human, HumanScore),
    score_player(GameData, computer, ComputerScore).

/* *********************************************************************
 Function Name: score_player
 Purpose: Get the score of a player
 Reference: None
********************************************************************* */

/* *************************************************
score_player/3
Parameters:
    +GameData: game/4 structure containing the current 
        game state.
    +Player: the name of the player whose score is 
        being retrieved.
    -Score: the score of the player.
 ************************************************ */

score_player(game(_, Scorecard, _, _), Player, Score) :-
    score_player(Scorecard, Player, 0, Score).

/* *************************************************
score_player/4
Parameters:
    +Scorecard: list of categories, each containing a 
        list of [Winner, Points, Round] or [0] if 
        not filled.
    +Player: the name of the player whose score is being retrieved.
    +InScore: the current score of the player.
    -Score: the final score of the player.
 ************************************************ */

% Base case: If the Scorecard list is empty, return the current score.
score_player([], _, InScore, InScore).

% Recursive case: If the current category is filled by this player, add the points to the score.
score_player([[Points, Winner, _] | Rest], Player, InScore, Score) :-
    Winner = Player,
    NextScore is InScore + Points,
    score_player(Rest, Player, NextScore, Score).

% Recursive case: If the current category is not filled by this player, move to the next.
score_player([_ | Rest], Player, InScore, Score) :-
    score_player(Rest, Player, InScore, Score).

/* *********************************************************************
 Function Name: get_dice
 Purpose: Get the current dice set from the game data
 Reference: None
********************************************************************* */

/* *************************************************
get_dice/2
Parameters:
    +GameData: game/4 structure containing the current 
        game state.
    -Dice: the current dice set.
 ************************************************ */

get_round(game(_, _, Dice, _), Dice).

/* *********************************************************************
 Function Name: update_dice
 Purpose: Update the dice set in the game data
 Reference: None
********************************************************************* */

/* *************************************************
update_dice/3
Parameters:
    +GameData: game/4 structure containing the current 
        game state.
    +NewDice: the new dice set.
    -NewGameData: game/4 structure containing the updated 
        game state.
 ************************************************ */

update_dice(game(Round, Scorecard, _, Strategy), NewDice, NewGameData) :-
    NewGameData = game(Round, Scorecard, NewDice, Strategy).

/*
/* *********************************************************************
 Function Name: increment_round
 Purpose: Increment the round number in the game data
 Reference: None
 ********************************************************************* *\/

% increment_round(+GameData, -NewGameData)
    % GameData is a game/4 structure containing the current game state.
    % NewGameData is a game/4 structure containing the updated game state.
increment_round(game(Round, Scorecard, Dice, Strategy), NewGameData) :-
    NewRound is Round + 1,
    NewGameData = game(NewRound, Scorecard, Dice, Strategy).

/* *********************************************************************
 Function Name: print_scores
 Purpose: Print the scores for each player
 Reference: None
 ********************************************************************* *\/

% print_scores(+GameData)
    % GameData is a game/4 structure containing the current game state.
print_scores(GameData) :-
    get_player_scores(GameData, Player1, Player2), % TODO
    write("Player 1: "), write(Player1), nl,


get_dice(game(_, _, Dice, _), Dice).
get_strategy(game(_, _, _, Strategy), Strategy).

update_round(game(_, Scorecard, Dice, Strategy), NewRound, game(NewRound, Scorecard, Dice, Strategy)).
update_scorecard(game(Round, _, Dice, Strategy), NewScorecard, game(Round, NewScorecard, Dice, Strategy)).
update_dice(game(Round, Scorecard, _, Strategy), NewDice, game(Round, Scorecard, NewDice, Strategy)).
update_strategy(game(Round, Scorecard, Dice, _), NewStrategy, game(Round, Scorecard, Dice, NewStrategy)).
*/

% hi there
