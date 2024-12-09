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
    check_category_strategies(Scorecard, Dice, StrategyList), % TODO
    filter_available_strategies(StrategyList, FilterRelevant, AvailableCategories). % TODO

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
    strategize_straight(Dice, 4, 30, "Four Straight", Strategy). % TODO
check_category_strategy(_, Dice, 11, Strategy) :-
    strategize_straight(Dice, 5, 40, "Five Straight", Strategy).

% Yahtzee
check_category_strategy(_, Dice, 12, Strategy) :-
    strategize_yahtzee(Dice, Strategy). % TODO

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
get_full_house_target_list(_, _, [0, 0], _, _, TargetList) :-
    TargetList = [].

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

