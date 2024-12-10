/* *********************************************
 Source Code to handle strategizing functions
    -> Relies on:
        dice.pl
        utility.pl
        game_data.pl
 ********************************************* */

/* *********************************************************************
 Function Name: get_available_categories
 Purpose: To get a list of available categories given the game data
 Reference: None
********************************************************************* */

/* *************************************************
get_available_categories/2
Parameters:
    +GameData: game/4 structure containing the 
        current game state.
    -AvailableCategories: The list of available categories.
 ************************************************ */

 % Filter is on by default
get_available_categories(GameData, AvailableCategories) :-
    get_available_categories(GameData, AvailableCategories, true).

/* *************************************************
get_available_categories/2
Parameters:
    +GameData: game/4 structure containing the 
        current game state.
    -AvailableCategories: The list of available categories.
    +FilterRelevant: true if only categories with at least
        one contributing die should be included.
 ************************************************ */

get_available_categories(game(_, Scorecard, Dice, _), AvailableCategories, FilterRelevant) :-
    check_category_strategies(Scorecard, Dice, StrategyList),
    filter_available_strategies(StrategyList, FilterRelevant, AvailableCategories), !.

/* *********************************************************************
 Function Name: check_category_strategies
 Purpose: To get a list of available categories given the game data
 Reference: None
********************************************************************* */

/* *************************************************
check_category_strategies/3
Parameters:
    +Scorecard: The current scorecard.
    +Dice: The current dice.
    -StrategyList: The list of available strategies.
 ************************************************ */

check_category_strategies(Scorecard, Dice, StrategyList) :-
    check_category_strategies(Scorecard, Dice, StrategyList, 1).

/* *************************************************
check_category_strategies/4
Parameters:
    +Scorecard: The current scorecard.
    +Dice: The current dice.
    -StrategyList: The list of available strategies.
    +CategoryNum: The index of the category being checked [1-12].
 ************************************************ */

% Base case: no more scorecard categories, so empty list.
check_category_strategies([], _, [], _).

% Recursive case: Add first category strategy onto the rest of them.
check_category_strategies([Category | RestCategories], Dice, [Strategy | RestStrategies], CategoryNum) :-
    check_category_strategy(Category, Dice, CategoryNum, Strategy),
    NextCategoryNum is CategoryNum + 1,
    check_category_strategies(RestCategories, Dice, RestStrategies, NextCategoryNum).

/* *********************************************************************
 Function Name: check_category_strategy
 Purpose: To get a strategy for a particular dice set and category
 Reference: None
********************************************************************* */

/* *************************************************
check_category_strategy/4
Parameters:
    +ScoreData: The scorecard data for this category.
    +Dice: The current dice.
    +CategoryNum: The index of the category being checked [1-12].
    -Strategy: The strategy for the category, or the atom 'none' if impossible.
 ************************************************ */

% Strategy is impossible if the category is already filled.
 check_category_strategy(ScoreData, _, _, none) :-
    length(ScoreData, 3).

% Multiples
check_category_strategy(_, Dice, 1, Strategy) :-
    strategize_multiples(Dice, 1, "Aces", Strategy).
check_category_strategy(_, Dice, 2, Strategy) :-
    strategize_multiples(Dice, 2, "Twos", Strategy).
check_category_strategy(_, Dice, 3, Strategy) :-
    strategize_multiples(Dice, 3, "Threes", Strategy).
check_category_strategy(_, Dice, 4, Strategy) :-
    strategize_multiples(Dice, 4, "Fours", Strategy).
check_category_strategy(_, Dice, 5, Strategy) :-
    strategize_multiples(Dice, 5, "Fives", Strategy).
check_category_strategy(_, Dice, 6, Strategy) :-
    strategize_multiples(Dice, 6, "Sixes", Strategy).

% Kind
check_category_strategy(_, Dice, 7, Strategy) :-
    strategize_kind(Dice, 3, "Three of a Kind", Strategy).
check_category_strategy(_, Dice, 8, Strategy) :-
    strategize_kind(Dice, 4, "Four of a Kind", Strategy).

% Full House
check_category_strategy(_, Dice, 9, Strategy) :-
    strategize_full_house(Dice, Strategy).

% Straight
check_category_strategy(_, Dice, 10, Strategy) :-
    strategize_straight(Dice, 4, Strategy).
check_category_strategy(_, Dice, 11, Strategy) :-
    strategize_straight(Dice, 5, Strategy).

% Yahtzee
check_category_strategy(_, Dice, 12, Strategy) :-
    strategize_yahtzee(Dice, Strategy).

/* *********************************************************************
 Function Name: strategize_multiples
 Purpose: To create a strategy for a multiples category
 Reference: None
********************************************************************* */

/* *************************************************
strategize_multiples/4
Parameters:
    +Dice: The dice set to strategize for.
    +MultipleNum: The face value of multiples to score.
    +Name: The name of the category.
    -Strategy: The strategy determined for this category.
 ************************************************ */

strategize_multiples(Dice, MultipleNum, Name, Strategy) :-
    % Get the score given the current dice set.
    score_multiples(Dice, MultipleNum, CurrentScore),

    % Determine what should be rerolled based on free, unscoring dice and best dice set.
    get_multiples_scoring_dice(MultipleNum, MultiplesScoringDice),
    count_dice_faces(MultiplesScoringDice, IdealScoringCounts),
    count_free_unscored_dice(Dice, IdealScoringCounts, ToReroll),

    % Determine what dice set the player should aim for.
    get_multiples_scoring_dice(MultipleNum, Dice, TargetList), 
    count_dice_faces(TargetList, Target),

    % Determine the max score from target dice.
    score_multiples(TargetList, MultipleNum, MaxScore),

    % Return a list representing the strategy.
    strategize_multiples(CurrentScore, MaxScore, ToReroll, Target, Name, Strategy).

/* *************************************************
strategize_multiples/6
Parameters:
    +CurrentScore: The current score for this category.
    +MaxScore: The maximum score possible for this category.
    +ToReroll: The list of dice to reroll.
    +Target: The target dice set to aim for.
    +Name: The name of the category.
    -Strategy: The strategy determined for this category.
 ************************************************ */

 % If nothing can be scored, there is no viable strategy.
 strategize_multiples(_, 0, _, _, _, none).

% Otherwise, return a strategy in a list.
strategize_multiples(CurrentScore, MaxScore, ToReroll, Target, Name, 
    [CurrentScore, MaxScore, ToReroll, Target, Name]).


/* *********************************************************************
 Function Name: score_multiples
 Purpose: To score a dice set for a Multiples category (aces, twos, etc.)
 Reference: None
********************************************************************* */

/* *************************************************
score_multiples/3
Parameters:
    +Dice: The dice set to score.
    +MultipleNum: The face value of multiples to score.
    -Score: The score for this dice set.
 ************************************************ */

score_multiples(Dice, MultipleNum, Score) :-
    count_dice_face(Dice, MultipleNum, Count),
    Score is Count * MultipleNum.

/* *********************************************************************
 Function Name: get_multiples_scoring_dice
 Purpose: Get a perfect scoring dice set for a multiples category
 Reference: None
********************************************************************* */

/* *************************************************
get_multiples_scoring_dice/2
Parameters:
    +MultipleNum: The face value of multiples to score.
    -ScoringDice: The perfect scoring dice set.
 ************************************************ */

 get_multiples_scoring_dice(MultipleNum, ScoringDice) :-
    get_multiples_scoring_dice(MultipleNum, [], ScoringDice), !.

/* *************************************************
get_multiples_scoring_dice/3
Parameters:
    +MultipleNum: The face value of multiples to score.
    +Dice: An optional parameter indicating the current 
        dice set
    -ScoringDice: The list of dice that would score 
        maximum points for this category.
 ************************************************ */

 get_multiples_scoring_dice(MultipleNum, Dice, ScoringDice) :-
    replace_free_dice(Dice, [[MultipleNum, 5]], ScoringDice).

/* *********************************************************************
 Function Name: strategize_kind
 Purpose: To create a strategy for a kind category
 Reference: None
********************************************************************* */

/* *************************************************
strategize_kind/4
Parameters:
    +Dice: The dice set to strategize for.
    +KindNum: The number "of a kind" for this category.
    +Name: The name of the category.
    -Strategy: The strategy determined for this category.
 ************************************************ */

strategize_kind(Dice, KindNum, Name, Strategy) :-
    % Get the score given the current dice set.
    score_kind(Dice, KindNum, CurrentScore),
    % Determine what dice set the player should aim for.
    get_best_kind_scoring_dice(KindNum, Dice, TargetList),
    TargetList \= none,
    count_dice_faces(TargetList, Target),
    % Determine what should be rerolled based on free, unscoring dice and target values.
    count_free_unscored_dice(Dice, Target, ToReroll),
    % Determine the max score from target dice.
    score_kind(TargetList, KindNum, MaxScore),

    % Return a list representing the strategy.
    strategize_kind(CurrentScore, MaxScore, ToReroll, Target, Name, Strategy).

% If no scoring dice set was found, return 'none'.
strategize_kind(_, _, _, none).

/* *************************************************
strategize_kind/6
Parameters:
    +CurrentScore: The current score for this category.
    +MaxScore: The maximum score possible for this category.
    +ToReroll: The list of dice to reroll.
    +Target: The target dice set to aim for.
    +Name: The name of the category.
    -Strategy: The strategy determined for this category.
 ************************************************ */

 % If nothing can be scored, there is no viable strategy.
 strategize_kind(_, 0, _, _, _, none).

% Otherwise, return a strategy in a list.
strategize_kind(CurrentScore, MaxScore, ToReroll, Target, Name, 
    [CurrentScore, MaxScore, ToReroll, Target, Name]).

/* *********************************************************************
 Function Name: score_kind
 Purpose: To score a dice set for a Kind category (3 or 4 of a Kind)
 Reference: None
********************************************************************* */

/* *************************************************
score_kind/3
Parameters:
    +Dice: The dice set to score.
    +KindNum: The number "of a kind" for this category.
    -Score: The score for this dice set.
 ************************************************ */

% If this meets the criteria for the kind, score it.
score_kind(Dice, KindNum, Score) :-
    count_dice_faces(Dice, DiceCounts),
    max_list(DiceCounts, MaxCount),
    sum_dice(Dice, Score),
    MaxCount >= KindNum.

% Otherwise, score 0.
score_kind(_, _, 0).

/* *********************************************************************
 Function Name: get_best_kind_scoring_dice
 Purpose: Get the best possible dice set for scoring for a kind category
 Reference: None
********************************************************************* */

/* *************************************************
get_best_kind_scoring_dice/2
Parameters:
    +KindNum: The number "of a kind" for this category
    -ScoringDice: The list of dice that would score 
        maximum points for this category
 ************************************************ */

% Find the ideal dice set for the given kind.
 get_best_kind_scoring_dice(KindNum, ScoringDice) :-
    get_best_kind_scoring_dice(KindNum, [], 6, ScoringDice), !.

/* *************************************************
get_best_kind_scoring_dice/3
Parameters:
    +KindNum: The number "of a kind" for this category
    +Dice: The current dice set
    -ScoringDice: The list of dice that would score 
        maximum points for this category
 ************************************************ */

get_best_kind_scoring_dice(KindNum, Dice, ScoringDice) :-
    get_best_kind_scoring_dice(KindNum, Dice, 6, ScoringDice), !.

/* *************************************************
get_best_kind_scoring_dice/4
Parameters:
    +KindNum: The number "of a kind" for this category
    +Dice: The current dice set
    +Repeated: The face value repeated to make up the "kind"
    -ScoringDice: The list of dice that would score 
        maximum points for this category
 ************************************************ */

% Base case: If repeated reached 0, category is impossible so return 'none'.
 get_best_kind_scoring_dice(_, _, 0, none).

% Recursive case: get ideal target dice for current value of "repeated"
get_best_kind_scoring_dice(KindNum, Dice, Repeated, ScoringDice) :-
    get_kind_scoring_dice(KindNum, Repeated, Dice, Target),
    % If this scored, return the dice set.
    score_kind(Target, KindNum, Score),
    Score > 0,
    ScoringDice = Target.

% If last value of repeated did not score, try the next value.
get_best_kind_scoring_dice(KindNum, Dice, Repeated, ScoringDice) :-
    NextRepated is Repeated - 1,
    get_best_kind_scoring_dice(KindNum, Dice, NextRepated, ScoringDice).

/* *********************************************************************
 Function Name: get_kind_scoring_dice
 Purpose: Get a perfect scoring dice set for a kind category
 Reference: None
********************************************************************* */

/* *************************************************
get_best_kind_scoring_dice/4
Parameters:
    +KindNum: The number "of a kind" for this category
    +Repeated: The face value repeated to make up the "kind"
    +Dice: The current dice set
    -ScoringDice: The list of dice that would score 
        maximum points for this category
 ************************************************ */

get_kind_scoring_dice(KindNum, Repeated, Dice, ScoringDice) :-
    replace_free_dice(Dice, [[Repeated, KindNum], [6, 5]], ScoringDice).

/* *********************************************************************
 Function Name: strategize_full_house
 Purpose: To create a strategy for a full house category
 Reference: None
********************************************************************* */

/* *************************************************
strategize_full_house/2
Parameters:
    +Dice: The dice set to strategize for.
    -Strategy: The strategy determined for this category.
 ************************************************ */

strategize_full_house(Dice, Strategy) :-
    % Get the score given the current dice set.
    score_full_house(Dice, CurrentScore),
    % Determine the target list and counts.
    get_full_house_target_list(Dice, TargetList),
    filter_locked_dice(Dice, LockedDice),
    % Stop early if no target list was found and there are locked dice.
    (TargetList \= none ; LockedDice = none),
    count_dice_faces(TargetList, Target),
    % Extract data from the best config found.
    count_free_unscored_dice(Dice, Target, ToReroll),

    % Return a list representing the strategy.
    strategize_full_house(CurrentScore, 25, ToReroll, Target, "Full House", Strategy).

strategize_full_house(_, none).

/* *************************************************
strategize_full_house/6
Parameters:
    +CurrentScore: The current score for this category.
    +MaxScore: The maximum score possible for this category.
    +ToReroll: The list of dice to reroll.
    +Target: The target dice set to aim for.
    +Name: The name of the category.
    -Strategy: The strategy determined for this category.
 ************************************************ */

strategize_full_house(CurrentScore, MaxScore, ToReroll, Target, Name, 
    [CurrentScore, MaxScore, ToReroll, Target, Name]).

/* *********************************************************************
 Function Name: score_full_house
 Purpose: To score a dice set for a Full House category
 Reference: None
********************************************************************* */

/* *************************************************
score_full_house/2
Parameters:
    +Dice: The dice set to score.
    -Score: The score for this dice set.
 ************************************************ */

score_full_house(Dice, 25) :-
    count_dice_faces(Dice, DiceCounts),
    max_dice_faces(DiceCounts, [_, MaxCount1], [_, MaxCount2]),
    MaxCount1 = 3,
    MaxCount2 = 2.

score_full_house(_, 0).

/* *********************************************************************
 Function Name: get_full_house_target_list
 Purpose: To generate a list of target dice for achieving a full house 
          (three of one face and two of another).
 Reference: None
********************************************************************* */

/* *************************************************
get_full_house_target_list/2
Parameters:
    +Dice: The current dice set.
    -TargetList: The list of dice that would score 
        maximum points for this category.
 ************************************************ */

get_full_house_target_list(Dice, TargetList) :-
    count_dice_faces(Dice, DiceCounts),
    % Get the first and second max dice faces.
    max_dice_faces(DiceCounts, Max1, Max2),
    % Get locked dice and face counts for them.
    filter_locked_dice(Dice, LockedDice),
    count_dice_faces(LockedDice, LockedCounts),
    % Get max faces for locked dice.
    max_dice_faces(LockedCounts, LockedMax1, LockedMax2),
    
    count_num_faces(LockedCounts, NumFaces),

    % Determine target list based on determined values.
    get_full_house_target_list(Max1, Max2, LockedMax1, LockedMax2, NumFaces, TargetList), !.

/* *************************************************
get_full_house_target_list/6
Parameters:
    +Max1: The face of the first max dice.
    +Max2: The face of the second max dice.
    +LockedMax1: The face of the first max locked dice.
    +LockedMax2: The face of the second max locked dice.
    +NumFaces: The number of unique faces in the locked dice set.
    -TargetList: The list of dice that would score 
        maximum points for this category.
 ************************************************ */

% If there are more than 2 locked faces, return 'none'.
get_full_house_target_list(_, _, _, _, NumFaces, none) :-
    NumFaces > 2.
% If there are more than 3 locked of one face, return 'none'.
get_full_house_target_list(_, _, [_, LockedCount], _, _, none) :-
    LockedCount > 3.

% If no dice are locked, use the mode of the dice set.
get_full_house_target_list([MaxFace1, MaxCount1], [MaxFace2, MaxCount2], [_, 0], _, _, TargetList) :-
    MaxCount1 > 1, MaxCount2 > 1,
    add_dice([], [[MaxFace1, 3], [MaxFace2, 2]], TargetList).
get_full_house_target_list([MaxFace1, MaxCount1], _, [_, 0], _, _, TargetList) :-
    MaxCount1 > 1,
    add_dice([], [[MaxFace1, 3]], TargetList).
get_full_house_target_list(_, _, [_, 0], _, _, []).

% If there is one locked face, use that face and the mode of the dice set.
get_full_house_target_list([MaxFace1, MaxCount1], _, [LockedMax1, _], [_, 0], _, TargetList) :-
    MaxCount1 > 1,
    MaxFace1 \= LockedMax1,
    add_dice([], [[MaxFace1, 3], [LockedMax1, 2]], TargetList).
% Case where the locked face is the mode of the dice set.
get_full_house_target_list([MaxFace1, _], [MaxFace2, MaxCount2], _, [_, 0], _, TargetList) :-
    MaxCount2 > 1,
    add_dice([], [[MaxFace1, 3], [MaxFace2, 2]], TargetList).
% Case where there is only one mode and it is the locked face.
get_full_house_target_list(_, _, [LockedMax1, _], [_, 0], _, TargetList) :-
    add_dice([], [[LockedMax1, 3]], TargetList).

% If there are two locked faces, use those faces.
get_full_house_target_list(_, _, [LockedMax1, _], [LockedMax2, _], _, TargetList) :-
    add_dice([], [[LockedMax1, 3], [LockedMax2, 2]], TargetList).

/* *********************************************************************
 Function Name: strategize_straight
 Purpose: To create a strategy for a straight category
 Reference: None
********************************************************************* */

/* *************************************************
strategize_straight/3
Parameters:
    +Dice: The dice set to strategize for.
    +StraightNum: The number of dice in the straight.
    -Strategy: The strategy determined for this category.
 ************************************************ */

% Four Straight
strategize_straight(Dice, 4, Strategy) :-
    % Get the score given the current dice set.
    score_straight(Dice, 4, 30, CurrentScore),
    % Determine what should be rerolled based on free, unscoring dice and target values.
    check_straight_configs(Dice, 4, ToReroll, Target),

    % Return a list representing the strategy.
    strategize_straight(CurrentScore, 30, ToReroll, Target, "Four Straight", Strategy).

% Five Straight
strategize_straight(Dice, 5, Strategy) :-
    % Get the score given the current dice set.
    score_straight(Dice, 5, 40, CurrentScore),
    % Determine what should be rerolled based on free, unscoring dice and target values.
    check_straight_configs(Dice, 5, ToReroll, Target),

    % Return a list representing the strategy.
    strategize_straight(CurrentScore, 40, ToReroll, Target, "Five Straight", Strategy).

/* *************************************************
strategize_straight/6
Parameters:
    +CurrentScore: The current score for this category.
    +MaxScore: The maximum score possible for this category.
    +ToReroll: The list of dice to reroll.
    +Target: The target dice set to aim for.
    +Name: The name of the category.
    -Strategy: The strategy determined for this category.
 ************************************************ */

strategize_straight(_, _, _, none, _, none).

strategize_straight(CurrentScore, MaxScore, ToReroll, Target, Name, 
    [CurrentScore, MaxScore, ToReroll, Target, Name]).

/* *********************************************************************
 Function Name: score_straight
 Purpose: To score a dice set for a Straight category
 Reference: None
********************************************************************* */

/* *************************************************
score_straight/4
Parameters:
    +Dice: The dice set to score.
    +StraightNum: The number of dice in the straight.
    +Value: The point value of this category.
    -Score: The score for this dice set.
 ************************************************ */

score_straight(Dice, StraightNum, Value, Value) :-
    count_dice_faces(Dice, DiceCounts),
    has_streak(DiceCounts, StraightNum), !.

score_straight(_, _, _, 0).

/* *********************************************************************
 Function Name: has_streak
 Purpose: To determine whether a set of dice has a requisite "streak" 
          (face values in a row)
 Reference: None
********************************************************************* */

/* *************************************************
has_streak/2
Parameters:
    +DiceCounts: The counts of each face in the dice set.
    +StraightNum: The number of dice in the straight.
 ************************************************ */

has_streak(DiceCounts, StraightNum) :-
    has_streak(DiceCounts, 0, StraightNum).

/* *************************************************
has_streak/3
Parameters:
    +DiceCounts: The counts of each face in the dice set.
    +CurrentStreak: The current streak length.
    +StraightNum: The number of dice in the straight.
 ************************************************ */

% Base case: If the streak has reached the required length, return true.
has_streak(_, StraightNum, StraightNum).
% Base case: If no streak and checked all dice, fail.
has_streak([], _, _) :- fail.

% Recursive case: If the current face has a count of 1, increment the streak.
has_streak([CurrCount | RestCounts], CurrentStreak, StraightNum) :-
    CurrCount > 0,
    NextStreak is CurrentStreak + 1,
    has_streak(RestCounts, NextStreak, StraightNum).
% Recursive case: If the current face has a count of 0, reset the streak.
has_streak([0 | RestCounts], _, StraightNum) :-
    has_streak(RestCounts, 0, StraightNum).

/* *********************************************************************
 Function Name: check_straight_configs
 Purpose: To evaluate the current dice configuration for completing
          a straight category
 Reference: None
********************************************************************* */

/* *************************************************
check_straight_configs/4
Parameters:
    +Dice: The current dice set.
    +StraightNum: The number of dice in the straight.
    -ToReroll: The list of dice to reroll.
    -Target: The target dice set to aim for.
 ************************************************ */

% Four Straight
check_straight_configs(Dice, 4, ToReroll, Target) :-
    Config1 = [1, 1, 1, 1, 0, 0],
    Config2 = [0, 1, 1, 1, 1, 0],
    Config3 = [0, 0, 1, 1, 1, 1],
    check_straight_config(Dice, 4, 30, Config1, ConfigResult1),
    check_straight_config(Dice, 4, 30, Config2, ConfigResult2),
    check_straight_config(Dice, 4, 30, Config3, ConfigResult3),
    check_straight_configs(Dice, ConfigResult1, ConfigResult2, ConfigResult3, ToReroll, Target).

% Five Straight
check_straight_configs(Dice, 5, ToReroll, Target) :-
    Config1 = [1, 1, 1, 1, 1, 0],
    Config2 = [0, 1, 1, 1, 1, 1],
    check_straight_config(Dice, 5, 40, Config1, ConfigResult1),
    check_straight_config(Dice, 5, 40, Config2, ConfigResult2),
    check_straight_configs(Dice, ConfigResult1, ConfigResult2, ToReroll, Target).

/* *************************************************
check_straight_configs/5
Parameters:
    +Dice: The current dice set.
    +ConfigResult1: The result of the first configuration.
    +ConfigResult2: The result of the second configuration.
    -ToReroll: The list of dice to reroll.
    -Target: The target dice set to aim for.
 ************************************************ */

% Return config 1 if it is the only possible or has the least dice to reroll.
check_straight_configs(_, ConfigResult1, ConfigResult2, ToReroll, Target) :-
    ConfigResult1 = [_, ToReroll, Target],
    ConfigResult2 = none.
check_straight_configs(_, ConfigResult1, ConfigResult2, ToReroll, Target) :-
    ConfigResult1 = [NumRerolls1, ToReroll, Target],
    ConfigResult2 = [NumRerolls2, _, _],
    NumRerolls1 < NumRerolls2.

% Otherwise return config 2 if it worked.
check_straight_configs(_, _, ConfigResult2, ToReroll, Target) :-
    ConfigResult2 = [_, ToReroll, Target].

% Otherwise, return 'none'.
check_straight_configs(_, _, _, none, none).
    

/* *************************************************
check_straight_configs/6
Parameters:
    +Dice: The current dice set.
    +ConfigResult1: The result of the first configuration.
    +ConfigResult2: The result of the second configuration.
    +ConfigResult3: The result of the third configuration.
    -ToReroll: The list of dice to reroll.
    -Target: The target dice set to aim for.
 ************************************************ */

% Return config 1 if it is the only possible or has the least dice to reroll.
check_straight_configs(_, ConfigResult1, ConfigResult2, ConfigResult3, ToReroll, Target) :-
    ConfigResult1 = [_, ToReroll, Target],
    ConfigResult2 = none,
    ConfigResult3 = none.
check_straight_configs(_, ConfigResult1, ConfigResult2, ConfigResult3, ToReroll, Target) :-
    ConfigResult1 = [NumRerolls1, ToReroll, Target],
    ConfigResult2 = [NumRerolls2, _, _],
    ConfigResult3 = none,
    NumRerolls1 < NumRerolls2.
check_straight_configs(_, ConfigResult1, ConfigResult2, ConfigResult3, ToReroll, Target) :-
    ConfigResult1 = [NumRerolls1, ToReroll, Target],
    ConfigResult2 = none,
    ConfigResult3 = [NumRerolls3, _, _],
    NumRerolls1 < NumRerolls3.
check_straight_configs(_, ConfigResult1, ConfigResult2, ConfigResult3, ToReroll, Target) :-
    ConfigResult1 = [NumRerolls1, ToReroll, Target],
    ConfigResult2 = [NumRerolls2, _, _],
    ConfigResult3 = [NumRerolls3, _, _],
    NumRerolls1 < NumRerolls2,
    NumRerolls1 < NumRerolls3.

% Return config 2 if it is the only possible or has the least dice to reroll.
check_straight_configs(_, _, ConfigResult2, ConfigResult3, ToReroll, Target) :-
    ConfigResult2 = [_, ToReroll, Target],
    ConfigResult3 = none.
check_straight_configs(_, _, ConfigResult2, ConfigResult3, ToReroll, Target) :-
    ConfigResult2 = [NumRerolls2, ToReroll, Target],
    ConfigResult3 = [NumRerolls3, _, _],
    NumRerolls2 < NumRerolls3.

% Return config 3 if it is the only possible or has the least dice to reroll.
check_straight_configs(_, _, _, ConfigResult3, ToReroll, Target) :-
    ConfigResult3 = [_, ToReroll, Target].

% Otherwise, return 'none'.
check_straight_configs(_, _, _, _, none, none).

/* *********************************************************************
 Function Name: check_straight_config
 Purpose: To evaluate if the current dice configuration can complete a 
          straight category
 Reference: None
********************************************************************* */

/* *************************************************
check_straight_config/5
Parameters:
    +Dice: The current dice set.
    +StraightNum: The number of dice in the straight.
    +Value: The point value of this category.
    +Config: The configuration to check.
    -ConfigResult: The result of the configuration.
 ************************************************ */

check_straight_config(Dice, StraightNum, Value, Config, ConfigResult) :-
    count_free_unscored_dice(Dice, Config, ToReroll),

    % Find counts of which dice are either already scoring, or are locked.
    count_dice_faces(Dice, DiceCounts),
    filter_locked_dice(Dice, LockedDice),
    count_dice_faces(LockedDice, LockedCounts),
    count_scored_locked_dice(DiceCounts, LockedCounts, Config, ScoringOrLocked),

    % Turn scoring-or-locked into a list of dice that cannot be altered.
    counts_to_dice(ScoringOrLocked, SetList),
    % Rerolls required is 5 (total dice) - length of the set list.
    length(SetList, LengthSetList),
    NumRerolls is 5 - LengthSetList,
    % Find which dice need to be added to complete the configuration.
    match_counts(DiceCounts, Config, Replacements),
    % Add the required dice to the list if possible.
    add_dice(SetList, Replacements, Target),

    % Return the result in a list.
    check_straight_config(StraightNum, Value, Target, ToReroll, NumRerolls, ConfigResult).

/* *************************************************
check_straight_config/6
Parameters:
    +StraightNum: The number of dice in the straight.
    +Value: The point value of this category.
    +TargetList: The target dice set to aim for.
    +ToReroll: The list of dice to reroll.
    +NumRerolls: The number of dice to reroll.
    -ConfigResult: The result of the configuration.
 ************************************************ */

% If target does not score, return 'none'.
check_straight_config(StraightNum, Value, TargetList, _, _, none) :-
    score_straight(TargetList, StraightNum, Value, Score),
    Score = 0.

% Otherwise, return the target and reroll lists.
check_straight_config(_, _, TargetList, ToReroll, NumRerolls, [NumRerolls, ToReroll, Target]) :-
    count_dice_faces(TargetList, Target).

/* *********************************************************************
 Function Name: strategize_yahtzee
 Purpose: To create a strategy for the Yahtzee category
 Reference: None
********************************************************************* */

/* *************************************************
strategize_yahtzee/2
Parameters:
    +Dice: The dice set to strategize for.
    -Strategy: The strategy determined for this category.
 ************************************************ */

strategize_yahtzee(Dice, Strategy) :-
    % Get the score given the current dice set.
    score_yahtzee(Dice, CurrentScore),
    % Determine the target list and counts.
    get_yahtzee_target_list(Dice, TargetList),
    count_dice_faces(TargetList, Target),

    % Extract data from the best config found.
    count_free_unscored_dice(Dice, Target, ToReroll),

    % Return a list representing the strategy.
    strategize_yahtzee(CurrentScore, 50, ToReroll, TargetList, "Yahtzee", Strategy).

/* *************************************************
strategize_yahtzee/6
Parameters:
    +CurrentScore: The current score for this category.
    +MaxScore: The maximum score possible for this category.
    +ToReroll: The list of dice to reroll.
    +Target: The target dice set to aim for.
    +Name: The name of the category.
    -Strategy: The strategy determined for this category.
 ************************************************ */

strategize_yahtzee(_, _, _, none, _, none).

strategize_yahtzee(CurrentScore, MaxScore, ToReroll, TargetList, Name, 
    [CurrentScore, MaxScore, ToReroll, Target, Name]) :-
    count_dice_faces(TargetList, Target).

/* *********************************************************************
 Function Name: score_yahtzee
 Purpose: To score a dice set for the Yahtzee category
 Reference: None
********************************************************************* */

score_yahtzee(Dice, Score) :-
    count_dice_faces(Dice, DiceCounts),
    count_num_faces(DiceCounts, NumFaces),
    score_yahtzee_helper(NumFaces, Score).

score_yahtzee_helper(NumFaces, 50) :-
    NumFaces = 1.
score_yahtzee_helper(_, 0).

/* *********************************************************************
 Function Name: get_yahtzee_target_list
 Purpose: To generate a list of target dice for achieving Yahtzee
 Reference: None
********************************************************************* */

/* *************************************************
get_yahtzee_target_list/2
Parameters:
    +Dice: The current dice set.
    -TargetList: The list of dice that would score 
        maximum points for this category.
 ************************************************ */

get_yahtzee_target_list(Dice, TargetList) :-
    count_dice_faces(Dice, DiceCounts),
    % Get the first and second max dice faces.
    max_dice_face(DiceCounts, Max),
    % Get locked dice and face counts for them.
    filter_locked_dice(Dice, LockedDice),
    count_dice_faces(LockedDice, LockedCounts),
    % Get max faces for locked dice.
    max_dice_face(LockedCounts, LockedMax),
    
    count_num_faces(LockedCounts, NumFaces),

    % Determine target list based on determined values.
    get_yahtzee_target_list(Max, LockedMax, NumFaces, TargetList), !.

/* *************************************************
get_yahtzee_target_list/5
Parameters:
    +Max: The face of the max dice.
    +LockedMax: The face of the max locked dice.
    +NumFaces: The number of unique faces in the locked dice set.
    -TargetList: The list of dice that would score 
        maximum points for this category.
 ************************************************ */

% If there is more than one locked face, return 'none'.
get_yahtzee_target_list(_, _, NumFaces, none) :-
    NumFaces > 1.

% If there is a locked face, use that.
get_yahtzee_target_list(_, [LockedFace, LockedCount], _, TargetList) :-
    LockedCount > 0,
    add_dice([], [[LockedFace, 5]], TargetList).

% Otherwise, use the mode of the dice set.
get_yahtzee_target_list([MaxFace, MaxCount], _, _, TargetList) :-
    MaxCount > 1,
    add_dice([], [[MaxFace, 5]], TargetList).

% If there is no mode, use an empty target list.
get_yahtzee_target_list(_, _, _, []).

/* *********************************************************************
 Function Name: filter_available_strategies
 Purpose: To filter out strategies that are unavailable or have 0 contributing dice.
          Creates a list of category indices based on the list.
 Reference: None
********************************************************************* */


/* *************************************************
filter_available_strategies/3
Parameters:
    +Strategies: The list of strategies to filter.
    +FilterRelevant: true if only counting categories
        that have at least one contributing die.
    -AvailableStrategies: The list of available strategies.
 ************************************************ */

% Base case: start with an empty list of strategies.
filter_available_strategies([], _, []).

% Recursive case: if the strategy is 'none', skip it and filter the rest.
filter_available_strategies([none | RestStrategies], false, AvailableStrategies) :-
    filter_available_strategies(RestStrategies, false, AvailableStrategies).
% Recursive case: add the category index to the list of available strategies.
filter_available_strategies([CurrStrategy | RestStrategies], false, AvailableStrategies) :-
    CurrStrategy = [_, _, _, _, Name],
    get_category_index(Name, Index),
    filter_available_strategies(RestStrategies, false, RestAvailableStrategies),
    append([Index], RestAvailableStrategies, AvailableStrategies).

% Recursive case: add the strategy to the list of available strategies if it is relevant.
filter_available_strategies([CurrStrategy | RestStrategies], true, AvailableStrategies) :-
    CurrStrategy = [CurrScore, _, _, _, Name],
    get_category_index(Name, Index),
    (Index > 6 ; CurrScore > 0),
    filter_available_strategies(RestStrategies, true, RestAvailableStrategies),
    append([Index], RestAvailableStrategies, AvailableStrategies).
% Recursive case: skip the category otherwise.
filter_available_strategies([_ | RestStrategies], true, AvailableStrategies) :-
    filter_available_strategies(RestStrategies, true, AvailableStrategies).

/* *********************************************************************
 Function Name: pick_strategy
 Purpose: To find the best strategy based on current game state
 Reference: None
********************************************************************* */

/* *************************************************
pick_strategy/2
Parameters:
    +GameData: The current game state.
    -Strategy: The best strategy determined from the 
        scorecard and dice.
 ************************************************ */

pick_strategy(game(_, Scorecard, Dice, _), Strategy) :-
    check_category_strategies(Scorecard, Dice, Strategies),
    find_best_strategy(Strategies, Strategy).

/* *********************************************************************
Function Name: find_best_strategy
Purpose: To find the best strategy from a list of strategies
Reference: None
********************************************************************* */

/* *************************************************
find_best_strategy/2
Parameters:
    +Strategies: The list of strategies to evaluate.
    -BestStrategy: The best strategy determined from the list.
 ************************************************ */

% Base cases: handle empty and single-element lists.
find_best_strategy([], none).
find_best_strategy([Strategy], Strategy).

find_best_strategy([CurrStrategy, NextStrategy | RestStrategies], BestStrategy) :-
    select_better_strategy(CurrStrategy, NextStrategy, BetterStrategy),
    find_best_strategy([BetterStrategy | RestStrategies], BestStrategy).

/* *********************************************************************
Function Name: select_better_strategy
Purpose: To select the better of two strategies based on their scores
Reference: None
********************************************************************* */

/* *************************************************
select_better_strategy/3
Parameters:
    +Strategy1: The first strategy to compare.
    +Strategy2: The second strategy to compare.
    -BetterStrategy: The better of the two strategies.
 ************************************************ */

% If one strategy is 'none', return the other.
select_better_strategy(none, Strategy2, Strategy2).
select_better_strategy(Strategy1, none, Strategy1).

% Otherwise, compare the scores of the two strategies.
select_better_strategy(Strategy1, Strategy2, Strategy1) :-
    Strategy1 = [_, MaxScore1, _, _, _],
    Strategy2 = [_, MaxScore2, _, _, _],
    MaxScore1 > MaxScore2.
select_better_strategy(_, Strategy2, Strategy2).

/* *********************************************************************
Function Name: print_strategy
Purpose: To print the strategy recommendation for a player or computer 
         based on the provided strategy and dice configuration.
Reference: None
********************************************************************* */

/* *************************************************
print_strategy/2
Parameters:
    +Strategy: The strategy to print.
    +Player: The player to print the strategy for.
 ************************************************ */

% If the strategy is 'none', recommend standing.
print_strategy(none, human) :-
    write("I recommend that you stand because there are no fillable categories given your current dice set."), nl.
print_strategy(none, computer) :-
    write("The computer plans to stand because there are no fillable categories given its current dice set."), nl.

% If max score is the same as current score, recommend standing.
print_strategy([Score, Score, _, _, Name], human) :-
    write("I recommend that you stand and fill the "), write(Name),
    write(" category because it gives the maximum possible points ("), write(Score), write(") "), 
    write("among all the options."), nl.
print_strategy([Score, Score, _, _, Name], computer) :-
    write("The computer plans to stand and fill the "), write(Name),
    write(" category because it gives the maximum possible points ("), write(Score), write(") "), 
    write("among all the options."), nl.

% Recommend rerolling and trying for the best category.
print_strategy([_, MaxScore, ToReroll, Target, Name], human) :-
    write("I recommend that you reroll and try for the "), write(Name),
    write(" category "), print_target_dice(Target, true),
    write("because it gives the maximum possible points ("), write(MaxScore), write(") "), 
    write("among all the options."), nl,
    write("Therefore, "), print_target_dice(ToReroll, false), write("should be rerolled."), nl.
print_strategy([_, MaxScore, ToReroll, Target, Name], computer) :-
    write("The computer plans to reroll and try for the "), write(Name),
    write(" category "), print_target_dice(Target, true),
    write("because it gives the maximum possible points ("), write(MaxScore), write(") "), 
    write("among all the options."), nl,
    write("Therefore, "), print_target_dice(ToReroll, false), write("will be rerolled."), nl.

/* *************************************************
print_strategy/3
Parameters:
    +Strategy: The strategy to print.
    +Player: The player to print the strategy for.
    +IsSelecting: true if the player is choosing a category.
 ************************************************ */

% If IsSelecting is false, use default print_strategy.
print_strategy(Strategy, Player, false) :-
    print_strategy(Strategy, Player).

% If the strategy is 'none', nothing can be done.
print_strategy(none, human, true) :-
    write("There are no fillable categories given your current dice set."), nl.
print_strategy(none, computer, true) :-
    write("There are no fillable categories given the current dice set."), nl.

% Recommend what to fill.
print_strategy([Score, Score, _, _, Name], human, true) :-
    write("I recommend that you fill the "), write(Name),
    write(" category because it gives the maximum possible points ("), write(Score), write(") "), 
    write("among all the options."), nl.
print_strategy([Score, Score, _, _, Name], computer, true) :-
    write("The computer plans to fill the "), write(Name),
    write(" category because it gives the maximum possible points ("), write(Score), write(") "), 
    write("among all the options."), nl.

/* *********************************************************************
Function Name: print_target_dice
Purpose: To print the target dice set for a strategy
Reference: None
********************************************************************* */

/* *************************************************
print_target_dice/2
Parameters:
    +Target: The target dice set to print.
    +PrintWith: Whether to print "with" beforehand.
 ************************************************ */

print_target_dice(Target, _) :-
    (Target = [] ; Target = none ; Target = [0,0,0,0,0,0]).

print_target_dice(Target, true) :-
    sum_list(Target, ToPrint),
    write("with "), print_target_dice(Target, 1, 0, ToPrint).

print_target_dice(Target, false) :-
    sum_list(Target, ToPrint),
    print_target_dice(Target, 1, 0, ToPrint).

/* *************************************************
print_target_dice/4
Parameters:
    +Target: The target dice set to print.
    +CurrFace: The current face being printed.
    +TotalPrinted: The total number of dice faces printed.
    +ToPrint: The total number of dice faces to print.
 ************************************************ */

% If no dice for this face, skip it.
print_target_dice([0 | RestCount], CurrFace, TotalPrinted, ToPrint) :-
    NextFace is CurrFace + 1,
    print_target_dice(RestCount, NextFace, TotalPrinted, ToPrint).
% Add "and" before the last die if there is more than 1 face.
print_target_dice([FirstCount | _], CurrFace, TotalPrinted, ToPrint) :-
    NextPrinted is FirstCount + TotalPrinted,
    TotalPrinted \= 0,
    NextPrinted = ToPrint,
    write("and " ), print_target_die(CurrFace, FirstCount), write(" ").
% If this is not the only face, print a comma.
print_target_dice([FirstCount | RestCount], CurrFace, TotalPrinted, ToPrint) :-
    FirstCount \= ToPrint,
    print_target_die(CurrFace, FirstCount), write(", "), 
    NextFace is CurrFace + 1,
    NextPrinted is FirstCount + TotalPrinted,
    print_target_dice(RestCount, NextFace, NextPrinted, ToPrint).
% Fallback for only one dice face to print.
print_target_dice([FirstCount | _], CurrFace, _, _) :-
    print_target_die(CurrFace, FirstCount), write(" ").

/* *********************************************************************
Function Name: print_target_die
Purpose: To print a string for a single target face
Reference: None
********************************************************************* */

/* *************************************************
print_target_die/2
Parameters:
    +Face: The face value to print.
    +Count: The number of dice with this face.
 ************************************************ */

print_target_die(1, 1) :-
    write("1 Ace").
print_target_die(1, Count) :-
    write(Count), write(" Aces").

print_target_die(2, 1) :-
    write("1 Two").
print_target_die(2, Count) :-  
    write(Count), write(" Twos").

print_target_die(3, 1) :-
    write("1 Three").
print_target_die(3, Count) :-
    write(Count), write(" Threes").

print_target_die(4, 1) :-
    write("1 Four").
print_target_die(4, Count) :-
    write(Count), write(" Fours").

print_target_die(5, 1) :-
    write("1 Five").
print_target_die(5, Count) :-  
    write(Count), write(" Fives").

print_target_die(6, 1) :-
    write("1 Six").
print_target_die(6, Count) :-
    write(Count), write(" Sixes").
