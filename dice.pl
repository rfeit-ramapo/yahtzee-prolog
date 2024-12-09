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
    roll_one(Die, Choice).

/* *************************************************
roll_one/2
Parameters:
    -Die: The value of the die rolled
    +Choice: The user's choice to manually input the roll
 ************************************************ */

% Manual input
roll_one(Die, true) :-
    write("Input the result of your roll."), nl,
    read_line_to_string(user_input, DieInput),
    number_string(Die, DieInput),
    valid_die_face(Die).

% Error fallback for manual input
roll_one(Die, true) :-
    write("Error: Input must be a single die face (1-6). Please try again."), nl,
    roll_one(Die, true).

% Automatic roll
roll_one(Die, false) :-
    random_between(1, 6, Die).

/* *********************************************************************
 Function Name: roll_all
 Purpose: Rolls all free dice
 Reference: None
********************************************************************* */

/* *************************************************
roll_all/2
Parameters:
    +Dice: The list of dice to roll
    -NewDice: The list of dice after rolling
 ************************************************ */

roll_all(Dice, NewDice) :-
    write("Would you like to manually input this dice roll? (y/n)"), nl,
    filter_free_dice(Dice, FreeDice),
    length(FreeDice, NumToRoll),
    validate_yes_no(Choice),
    roll_all(Dice, NewDice, NumToRoll, Choice).

/* *************************************************
roll_all/4
Parameters:
    +Dice: The list of dice to roll
    -NewDice: The list of dice after rolling
    +NumToRoll: The number of dice to roll
    +Choice: The user's choice to manually input the roll
 ************************************************ */

 % Manual input
 roll_all(Dice, NewDice, NumToRoll, true) :-
    write("Input the result of your roll."), nl,
    validate_dice_faces(NumToRoll, NewRolls),
    filter_locked_dice(Dice, LockedDice),
    combine_dice(NewRolls, LockedDice, NewDice).

% Automatic roll
roll_all(Dice, NewDice, NumToRoll, false) :-
    auto_roll(NumToRoll, NewRolls),
    filter_locked_dice(Dice, LockedDice),
    combine_dice(NewRolls, LockedDice, NewDice).

/* *********************************************************************
 Function Name: filter_free_dice
 Purpose: Filter out the free dice from the list of dice
 Reference: None
********************************************************************* */

/* *************************************************
filter_free_dice/2
Parameters:
    +Dice: The list of dice
    -FreeDice: The list of free dice
 ************************************************ */

% Base case: no dice left to check
 filter_free_dice([], []).

% Add the first die if it is free
filter_free_dice([ Die | RestDice], FreeDice) :-
    Die = die(_, unlocked),
    filter_free_dice(RestDice, RestFreeDice),
    append([Die], RestFreeDice, FreeDice).

% Skip the first die if it is locked
filter_free_dice([ _ | RestDice], FreeDice) :-
    filter_free_dice(RestDice, FreeDice).

/* *********************************************************************
 Function Name: filter_locked_dice
 Purpose: Filter out the locked dice from the list of dice
 Reference: None
********************************************************************* */

/* *************************************************
filter_free_dice/2
Parameters:
    +Dice: The list of dice
    -LockedDice: The list of locked dice
 ************************************************ */

% Base case: no dice left to check
 filter_locked_dice([], []).

% Add the first die if it is free
filter_locked_dice([ Die | RestDice], LockedDice) :-
    Die = die(_, locked),
    filter_locked_dice(RestDice, RestLockedDice),
    append([Die], RestLockedDice, LockedDice).

% Skip the first die if it is locked
filter_locked_dice([ _ | RestDice], LockedDice) :-
    filter_locked_dice(RestDice, LockedDice).

/* *********************************************************************
 Function Name: combine_dice
 Purpose: Adds a list of dice faces onto an existing list of dice
 Reference: None
********************************************************************* */

/* *************************************************
combine_dice/3
Parameters:
    +ToAdd: The list of dice faces to add
    +BaseDice: The list of dice to add to
    -NewDice: A dice set combining both sets of values
 ************************************************ */

% Base case: no dice to add
combine_dice([], BaseDice, BaseDice).

% Recursively add the first die
combine_dice([DieFace | RestDice], BaseDice, FinalDice) :-
    combine_dice(RestDice, BaseDice, NewDice),
    append([die(DieFace, unlocked)], NewDice, FinalDice).

/* *********************************************************************
 Function Name: auto_roll
 Purpose: Rolls a specified number of dice automatically (no player input)
 Reference: None
********************************************************************* */

/* *************************************************
auto_roll/2
Parameters:
    +NumToRoll: The number of dice to roll
    -NewRolls: The list of dice faces after rolling
 ************************************************ */

 % Base case: no more dice to roll
auto_roll(0, []).

% Recursive case - add a randomly generated die onto the list
auto_roll(NumToRoll, [DieFace | RestDice]) :-
    random_between(1, 6, DieFace),
    NextNum is NumToRoll - 1,
    auto_roll(NextNum, RestDice).

/* *********************************************************************
 Function Name: print_dice
 Purpose: Prints the dice set that is passed in
 Reference: None
********************************************************************* */

/* *************************************************
print_dice/1
Parameters:
    +Dice: The list of dice to print
 ************************************************ */

% Base case - no more dice, so print a newline.
print_dice([]) :- nl.

% Recursive case - print the first die and move to the next.
print_dice([Die | RestDice]) :-
    print_die(Die),
    print_dice(RestDice).

/* *********************************************************************
 Function Name: print_die
 Purpose: Prints a single die face; if locked, prints face in red.
 Reference: Received help from ChatGPT on how to print in color.
********************************************************************* */

/* *************************************************
print_die/1
Parameters:
    +Die: The die to print
 ************************************************ */

% Print locked in red
print_die(die(DieFace, locked)) :-
    ansi_format([fg(red)], "~w", [DieFace]), write(" ").

% Print unlocked normally
print_die(die(DieFace, unlocked)) :-
    write(DieFace), write(" ").

/* *********************************************************************
 Function Name: count_dice_face
 Purpose: Count the number of dice of a given face value
 Reference: None
********************************************************************* */

/* *************************************************
count_dice_face/3
Parameters:
    +Dice: The list of dice to count
    +Face: The face value to count
    -Count: The number of dice with the given face
 ************************************************ */

% Base case: no more dice to count
count_dice_face([], _, 0).

% Recursive case: count the first die if it matches the face
count_dice_face([die(Face, _) | RestDice], Face, Count) :-
    count_dice_face(RestDice, Face, RestCount),
    Count is RestCount + 1.

% Recursive case: skip the first die if it doesn't match the face
count_dice_face([die(OtherFace, _) | RestDice], Face, Count) :-
    OtherFace \= Face,
    count_dice_face(RestDice, Face, Count).

/* *********************************************************************
 Function Name: replace_free_dice
 Purpose: Replaces free dice in a list with new dice
 Reference: None
********************************************************************* */

/* *************************************************
replace_free_dice/3
Parameters:
    +Dice: The list of dice to replace
    +Replacements: A list of holding lists that contain 
        a face value and number of dice to add. For 
        example, [5 4] indicates add 4 Fives.
    -FinalDice: The list of dice after replacement
 ************************************************ */

replace_free_dice(Dice, Replacements, FinalDice) :-
    filter_locked_dice(Dice, LockedDice),
    add_dice(LockedDice, Replacements, FinalDice), !.

/* *********************************************************************
 Function Name: add_dice
 Purpose: Add dice to a list until there are none left or the list is full
 Reference: None
********************************************************************* */

/* *************************************************
add_dice/3
Parameters:
    +Dice: The list of dice to add to
    +Replacements: A list of holding lists that contain 
        a face value and number of dice to add. For 
        example, [5 4] indicates add 4 Fives.
    -FinalDice: An updated list of dice with added values
 ************************************************ */

% Base cases: no more replacement dice, or the dice list hit its max (5).
add_dice(Dice, [], Dice).
add_dice(Dice, _, Dice) :- length(Dice, 5), !.

% If the next replacement value has none left, use the next one.
add_dice(Dice, [ [_, 0] | RestReplacements], FinalDice) :-
    add_dice(Dice, RestReplacements, FinalDice).

% Add the next face to the dice list
add_dice(Dice, [ [Face, NumToAdd] | RestReplacements], FinalDice) :-
    % Add the face to the dice list
    append(Dice, [die(Face, unlocked)], NewDice),
    % Decrement the number of dice to add
    NewNumToAdd is NumToAdd - 1,
    % Recurse with the new dice list and the updated replacement list
    add_dice(NewDice, [ [Face, NewNumToAdd] | RestReplacements], FinalDice).

/* *********************************************************************
 Function Name: count_dice_faces
 Purpose: Get a count of how many dice of each face are in a list of dice
 Reference: None
********************************************************************* */

/* *************************************************
count_dice_faces/2
Parameters:
    +Dice: The list of dice to count
    -Counts: A list of counts for each face value
 ************************************************ */

count_dice_faces(none, [0,0,0,0,0,0]).

count_dice_faces(Dice, Counts) :-
    count_dice_face(Dice, 1, Count1),
    count_dice_face(Dice, 2, Count2),
    count_dice_face(Dice, 3, Count3),
    count_dice_face(Dice, 4, Count4),
    count_dice_face(Dice, 5, Count5),
    count_dice_face(Dice, 6, Count6),
    Counts = [Count1, Count2, Count3, Count4, Count5, Count6].

/* *********************************************************************
 Function Name: count_free_unscored_dice
 Purpose: Get the dice that would score from a list of dice
 Reference: None
********************************************************************* */

/* *************************************************
count_free_unscored_dice/3
Parameters:
    +CurrDice: A list of dice
    +ScoringCounts: A list of integers for each die 
        face that represent what would score
    -FreeUnscored: A list of dice counts for each face 
        that contribute to a score
 ************************************************ */

 count_free_unscored_dice(CurrDice, ScoringCounts, FreeUnscored) :-
    count_dice_faces(CurrDice, CurrCounts),
    filter_locked_dice(CurrDice, CurrLocked),
    count_dice_faces(CurrLocked, LockedCounts),
    count_unscored_dice(CurrCounts, ScoringCounts, LockedCounts, FreeUnscored).

/* *********************************************************************
 Function Name: count_unscored_dice
 Purpose: Get the dice that would NOT score from counts of each face
 Reference: None
********************************************************************* */

/* *************************************************
count_unscored_dice/3
Parameters:
    +DiceCounts: A list of integers for each die face
        that represent the total dice of that face
    +ScoringCounts: A list of integers for each die
        that represent what would score
    -UnscoredCounts: A list of dice counts for each face
        that do not contribute to a score
************************************************ */

count_unscored_dice(DiceCounts, ScoringCounts, UnscoredCounts) :-
    count_unscored_dice(DiceCounts, ScoringCounts, [0,0,0,0,0,0], UnscoredCounts).

/* *************************************************
count_unscored_dice/4
Parameters:
    +DiceCounts: A list of integers for each die face
        that represent the total dice of that face
    +ScoringCounts: A list of integers for each die
        that represent what would score
    +LockedCounts: A list of integers for each die face
        that are locked. If supplied, only returns free
        unscored dice
    -UnscoredCounts: A list of dice counts for each face
        that do not contribute to a score
************************************************ */

% Base case: no more dice to check
count_unscored_dice([], [], [], []).

% Recursive case: check the first face and append to the rest
count_unscored_dice(
    [CurrCount | RestCounts], 
    [ScoringCount | RestScoring], 
    [LockedCount | RestLocked], Unscored) :-
    total_unscored_dice(CurrCount, ScoringCount, LockedCount, CurrUnscored),
    count_unscored_dice(RestCounts, RestScoring, RestLocked, RestUnscored),
    append([CurrUnscored], RestUnscored, Unscored).

/* *********************************************************************
 Function Name: total_unscored_dice
 Purpose: Count how many dice are unscored for a single face
 Reference: None
********************************************************************* */

/* *************************************************
total_unscored_dice/4
Parameters:
    +CurrCount: The total number of dice of this face
    +ScoringCount: The number of dice of this face 
        that score
    +LockedCount: The number of dice of this face 
        that are locked
    -Unscored: An integer representing how many dice 
        of this face are unscored
 ************************************************ */

total_unscored_dice(CurrCount, ScoringCount, LockedCount, Unscored) :-
    MaxScoredOrLocked is max(ScoringCount, LockedCount),
    Unscored is max(CurrCount - MaxScoredOrLocked, 0).

/* *********************************************************************
 Function Name: sum_dice
 Purpose: Sum a list of dice
 Reference: None
********************************************************************* */

/* *************************************************
sum_dice/2
Parameters:
    +Dice: The list of dice to sum
    -Sum: The total sum of the dice
 ************************************************ */

 % Base case: no more dice to sum
sum_dice([], 0).

% Recursive case: sum the first die and move to the next
sum_dice([die(Face, _) | RestDice], Sum) :-
    sum_dice(RestDice, RestSum),
    Sum is Face + RestSum.

/* *********************************************************************
 Function Name: max_dice_faces
 Purpose: Get the dice faces with the maximum count
 Reference: None
********************************************************************* */

/* *************************************************
max_dice_faces/3
Parameters:
    +DiceCounts: A list of counts for each die face
    -Max1: A list containing the MaxFace1 and MaxCount1
    -Max2: A list containing the MaxFace2 and MaxCount2
 ************************************************ */

 max_dice_faces(DiceCounts, Max1, Max2) :-
    max_dice_face(DiceCounts, [MaxFace1, MaxCount1]),
    remove_face(DiceCounts, MaxFace1, NewCounts),
    max_dice_face(NewCounts, [MaxFace2, MaxCount2]),
    Max1 = [MaxFace1, MaxCount1],
    Max2 = [MaxFace2, MaxCount2].

/* *********************************************************************
 Function Name: max_dice_face
 Purpose: Get the dice face with the maximum count
 Reference: None
********************************************************************* */

/* *************************************************
max_dice_face/2
Parameters:
    +DiceCounts: A list of counts for each die face
    -Max: A list containing the MaxFace and MaxCount
 ************************************************ */

max_dice_face([], [0, 0]).

max_dice_face(DiceCounts, Max) :-
    max_list(DiceCounts, MaxCount),
    nth1(MaxFace, DiceCounts, MaxCount),
    Max = [MaxFace, MaxCount].

/* *********************************************************************
 Function Name: remove_face
 Purpose: Remove a face from a list of counts
 Reference: None
********************************************************************* */

/* *************************************************
remove_face/3
Parameters:
    +DiceCounts: A list of counts for each die face
    +Face: The face to remove
    -NewCounts: The list of counts with the face removed
************************************************ */

remove_face(DiceCounts, Face, NewCounts) :-
    remove_face(DiceCounts, Face, NewCounts, 1).

/* *************************************************
remove_face/4
Parameters:
    +DiceCounts: A list of counts for each die face
    +Face: The face to remove
    -NewCounts: The list of counts with
    +Index: The current face index (starting from 1) in the list
************************************************ */

remove_face([_ | RestCounts], Face, [0 | RestCounts], Face).

remove_face([CurrCount | RestCounts], Face, NewCounts, Index) :-
    Index \= Face,
    NextIndex is Index + 1,
    remove_face(RestCounts, Face, NewRestCounts, NextIndex),
    append([CurrCount], NewRestCounts, NewCounts).

/* *********************************************************************
 Function Name: count_num_faces
 Purpose: Count the number of unique faces in a list of dice
 Reference: None
********************************************************************* */

/* *************************************************
count_num_faces/2
Parameters:
    +DiceCounts: A list of counts for each die face
    -NumFaces: The number of unique faces in the list
 ************************************************ */

count_num_faces(DiceCounts, NumFaces) :-
    count_num_faces(DiceCounts, NumFaces, 0).

/* *************************************************
count_num_faces/3
Parameters:
    +DiceCounts: A list of counts for each die face
    -NumFaces: The number of unique faces in the list
    +Count: Accumulator for counting
 ************************************************ */

% Base case: empty list returns accumulated value
count_num_faces([], Count, Count).

% Skip faces with count 0
count_num_faces([0 | RestCounts], NumFaces, Count) :-
    count_num_faces(RestCounts, NumFaces, Count).

% Count faces with non-zero count
count_num_faces([_ | Rest], NumFaces, Count) :-
    NewCount is Count + 1,
    count_num_faces(Rest, NumFaces, NewCount).

/* *********************************************************************
 Function Name: count_scored_locked_dice
 Purpose: Get the dice that would score, or are locked from a set of dice counts
 Reference: None
********************************************************************* */

/* *************************************************
count_scored_locked_dice/4
Parameters:
    +DiceCounts: A list of counts for each die face
    +LockedCounts: A list of locked counts for each 
        die face
    +ScoringCounts: A list of counts for each die face 
        that score
    -ScoredLocked: A list of dice counts for each face
        that contribute to a score, or are locked
 ************************************************ */

count_scored_locked_dice([], [], [], []).

count_scored_locked_dice([DiceCount | RestDiceCounts],
                         [LockedCount | RestLockedCounts],
                         [ScoringCount | RestScoringCounts],
                         [ScoredLocked | RestScoredLocked]) :-
    total_scored_dice(DiceCount, ScoringCount, TotalScored),
    ScoredLocked is max(LockedCount, TotalScored),
    count_scored_locked_dice(RestDiceCounts, RestLockedCounts, RestScoringCounts, RestScoredLocked).

/* *********************************************************************
 Function Name: total_scored_dice
 Purpose: Count how many dice are scored for a single face
 Reference: None
********************************************************************* */

/* *************************************************
total_scored_dice/3
Parameters:
    +DiceCount: The total number of dice of this face
    +ScoringCount: The number of dice of this face 
        that score
    -TotalScored: An integer representing how many dice 
        of this face are scored
 ************************************************ */

total_scored_dice(DiceCount, ScoringCount, TotalScored) :-
    TotalScored is min(DiceCount, ScoringCount).

/* *********************************************************************
 Function Name: counts_to_dice
 Purpose: Convert a list of dice counts into a list of individual dice
 Reference: None
********************************************************************* */

/* *************************************************
counts_to_dice/2
Parameters:
    +Counts: A list of integers representing the counts of each die face.
    -Dice: A list of individual dice.
 ************************************************ */

counts_to_dice(Counts, Dice) :-
    counts_to_dice(Counts, 1, Dice).

/* *************************************************
counts_to_dice/3
Parameters:
    +Counts: A list of integers representing the counts 
        of each die face.
    +Face: The current face being processed.
    -Dice: A list of individual dice for the current 
        and remaining counts.
 ************************************************ */

% Base case: When no counts are left, the result is an empty list.
counts_to_dice([], _, []).

% Recursive case: Expand the current face count and continue processing.
counts_to_dice([Count | RestCounts], Face, Dice) :-
    expand_dice_face(Count, Face, ExpandedDice),
    NextFace is Face + 1,
    counts_to_dice(RestCounts, NextFace, RemainingDice),
    append(ExpandedDice, RemainingDice, Dice).

/* *********************************************************************
 Function Name: expand_dice_face
 Purpose: Expand a given face into a list of individual dice based on the count.
 Reference: None
********************************************************************* */

/* *************************************************
expand_dice_face/3
Parameters:
    +Count: An integer representing how many dice of this face exist.
    +Face: The value of the face to expand.
    -Dice: The resulting list of dice
 ************************************************ */

% Base case: When count is 0, no dice are added.
expand_dice_face(0, _, []).

% Recursive case: Add a die with the given face and process the remaining count.
expand_dice_face(Count, Face, [die(Face, unlocked) | RestDice]) :-
    Count > 0,
    NextCount is Count - 1,
    expand_dice_face(NextCount, Face, RestDice).

/* *********************************************************************
 Function Name: match_counts
 Purpose: Match the current dice counts to the target, determining which dice are needed
 Reference: None
********************************************************************* */

/* *************************************************
match_counts/3
Parameters:
    +DiceCounts: The current dice counts.
    +TargetCounts: The target dice counts.
    -NeededDice: A list of dice needed, with 
        sublists specifying the face and number required
 ************************************************ */

match_counts(DiceCounts, TargetCounts, NeededDice) :-
    match_counts(DiceCounts, TargetCounts, [], 1, NeededDice), !.

/* *************************************************
match_counts/5
Parameters:
    +DiceCounts: The current dice counts.
    +TargetCounts: The target dice counts.
    +NeededDice: The current list of needed dice.
    +Face: The current face being processed.
    -FinalNeededDice: The final list of needed dice.
 ************************************************ */

% Base case: When no more faces are left, the result is the current list of needed dice.
match_counts([], _, NeededDice, _, NeededDice).

% Recursive case: Process the current face and continue with the remaining faces.
match_counts([CurrCount | RestCounts], [TargetCount | RestTargets], NeededDice, Face, FinalNeededDice) :-
    NumRerolls is TargetCount - CurrCount,
    NumRerolls > 0,
    append(NeededDice, [[Face, NumRerolls]], NewNeededDice),
    NextFace is Face + 1,
    match_counts(RestCounts, RestTargets, NewNeededDice, NextFace, FinalNeededDice).
match_counts([_ | RestCounts], [_ | RestTargets], NeededDice, Face, FinalNeededDice) :-
    NextFace is Face + 1,
    match_counts(RestCounts, RestTargets, NeededDice, NextFace, FinalNeededDice).

/* *********************************************************************
Function Name: lock_other_dice
Purpose: Locks all dice that are not to be rerolled.
Reference: None
********************************************************************* */

/* *************************************************
lock_other_dice/3
Parameters:
    +Dice: The list of dice to lock
    +RerollCounts: Counts of how many of each face to
        reroll
    -FinalDice: The list of dice after locking
 ************************************************ */

 lock_other_dice(Dice, RerollCounts, FinalDice) :-
    count_dice_faces(Dice, DiceCounts),
    dice_difference(DiceCounts, RerollCounts, ToLock),
    % Unlock all dice, then lock the required number.
    toggle_dice_lock(Dice, unlocked, UnlockedDice),
    lock_dice(UnlockedDice, ToLock, FinalDice).

/* *********************************************************************
Function Name: dice_difference
Purpose: Gets the difference of two dice counts (counts1 - counts2) for each face
Reference: None
********************************************************************* */

/* *************************************************
dice_difference/3
Parameters:
    +Counts1: The dice counts to subtract from
    +Counts2: The dice counts to subtract
    -Difference: The difference of the two lists
 ************************************************ */

 dice_difference([], [], []).

dice_difference([Count1 | Rest1], [Count2 | Rest2], [Diff | RestDiff]) :-
    Diff is Count1 - Count2,
    dice_difference(Rest1, Rest2, RestDiff).

/* *********************************************************************
Function Name: toggle_dice_lock
Purpose: Toggles all dice to be locked or unlocked
Reference: None
********************************************************************* */

/* *************************************************
toggle_dice_lock/3
Parameters:
    +Dice: The list of dice to toggle
    +Toggle: The state to toggle to
    -FinalDice: The list of dice after toggling
 ************************************************ */

toggle_dice_lock([], _, []).

toggle_dice_lock([die(Face, _) | RestDice], Toggle, [die(Face, Toggle) | RestFinalDice]) :-
    toggle_dice_lock(RestDice, Toggle, RestFinalDice).

/* *********************************************************************
Function Name: lock_dice
Purpose: Locks dice in a set according to specified counts
Reference: None
********************************************************************* */

/* *************************************************
lock_dice/3
Parameters:
    +Dice: The list of dice to modify
    +LockCounts: The counts of how many of each face to lock
    -FinalDice: The list of dice after locking
 ************************************************ */

lock_dice(Dice, LockCounts, FinalDice) :-
    lock_dice(Dice, LockCounts, 1, FinalDice).

/* *************************************************
lock_dice/4
Parameters:
    +Dice: The list of dice to modify
    +LockCounts: The counts of how many of each face to lock
    +Face: The current face being processed
    -FinalDice: The list of dice after locking
 ************************************************ */

% Base case: no more faces to lock
lock_dice(Dice, [], _, Dice).

% If none of the current face need to be locked, move to the next face.
lock_dice(Dice, [0 | RestLocks], Face, FinalDice) :-
    NextFace is Face + 1,
    lock_dice(Dice, RestLocks, NextFace, FinalDice).

% Lock a die of the current face if required
lock_dice(Dice, [LockCount | RestLocks], Face, FinalDice) :-
    lock_die(Dice, Face, NewDice),
    NextLock is LockCount - 1,
    lock_dice(NewDice, [NextLock | RestLocks], Face, FinalDice).

/* *********************************************************************
Function Name: lock_die
Purpose: Locks the first die found of a particular face value
Reference: None
********************************************************************* */

/* *************************************************
lock_die/3
Parameters:
    +Dice: The list of dice to modify
    +Face: The face value to lock
    -FinalDice: The list of dice after locking
 ************************************************ */

% Base case: no more dice to check
lock_die([], _, []).

% If the first dice face is correct, and unlocked
lock_die([die(Face, unlocked) | RestDice], Face, [die(Face, locked) | RestDice]).

% Otherwise, keep iterating through the dice set
lock_die([Die | RestDice], Face, [Die | FinalDice]) :-
    lock_die(RestDice, Face, FinalDice).

/* *********************************************************************
Function Name: faces_to_dice
Purpose: Converts a list of dice faces to a set of dice
Reference: None
********************************************************************* */

/* *************************************************
faces_to_dice/2
Parameters:
    +Faces: The list of dice faces
    -Dice: The list of dice
 ************************************************ */

faces_to_dice([], []).

faces_to_dice([Face | RestFaces], [die(Face, unlocked) | RestDice]) :-
    integer(Face),
    faces_to_dice(RestFaces, RestDice).