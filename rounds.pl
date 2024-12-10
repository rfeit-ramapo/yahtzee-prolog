/* *********************************************
 Source Code to handle rounds of the game
    -> Relies on:
        game_data.pl
        dice.pl
        turn.pl
 ********************************************* */

/* *********************************************************************
 Function Name: run_rounds
 Purpose: Run the rounds of the game
 Reference: None
********************************************************************* */

/* *************************************************
run_rounds/2
Parameters:
    +GameData: game/4 structure containing the 
        current game state.
    -FinalData: game/4 structure containing the 
        final game state.
 ************************************************ */

% Base case: If the scorecard is filled, the game is over.
run_rounds(GameData, FinalData) :-
    scorecard_filled(GameData, true),
    FinalData = GameData.

% Recursive case: If scorecard not filled, run another round.
run_rounds(GameData, FinalData) :-
    run_round(GameData, GameData2),
    increment_round(GameData2, GameData3),
    run_rounds(GameData3, FinalData).

/* *********************************************************************
 Function Name: run_round
 Purpose: Run a single round of the game
 Reference: None
********************************************************************* */

/* *************************************************
run_round/2
Parameters:
    +GameData: game/4 structure containing the 
        current game state.
    -FinalData: game/4 structure containing the 
        final game state.
 ************************************************ */

run_round(GameData, FinalData) :-
    get_round(GameData, RoundNum),
    print_round_header(RoundNum),
    get_player_order(GameData, Player1, Player2),
    run_turn(GameData, Player1, AfterTurn1),
    scorecard_filled(AfterTurn1, Filled),
    run_turn(AfterTurn1, Player2, Filled, FinalData),
    print_scores(FinalData),
    increment_round(FinalData, NewRoundData),
    serialize_save(NewRoundData).

/* *********************************************************************
 Function Name: print_round_header
 Purpose: Print the header for the current round
 Reference: None
********************************************************************* */

/* *************************************************
print_round_header/1
Parameters:
    +RoundNum: the current round number.
 ************************************************ */

print_round_header(RoundNum) :-
    write("================================="),
    nl, nl,
    write("Round "), write(RoundNum), write(":"),
    nl, nl,
    write("================================="),
    nl.

/* *********************************************************************
 Function Name: get_player_order
 Purpose: Get the order of the players for the current round
 Reference: None
********************************************************************* */

/* *************************************************
get_player_order/3
Parameters:
    +GameData: game/4 structure containing the 
        current game state.
    -Player1: the first player for this round.
    -Player2: the second player for this round.
 ************************************************ */

get_player_order(GameData, Player1, Player2) :-
    write("Determining who will go first..."), nl,
    get_player_scores(GameData, HumanScore, ComputerScore),
    order_players(HumanScore, ComputerScore, Player1, Player2).

/* *********************************************************************
 Function Name: order_players
 Purpose: Order the players based on their scores
 Reference: None
********************************************************************* */

/* *************************************************
order_players/4
Parameters:
    +HumanScore: the score of the human player.
    +ComputerScore: the score of the computer player.
    -Player1: the first player for this round.
    -Player2: the second player for this round.
 ************************************************ */

% If the human player has a lower score, they go first.
order_players(HumanScore, ComputerScore, Player1, Player2) :-
    HumanScore < ComputerScore,
    Player1 = human,
    Player2 = computer.

% If the computer player has a lower score, they go first.
order_players(HumanScore, ComputerScore, Player1, Player2) :-
    HumanScore > ComputerScore,
    Player1 = computer,
    Player2 = human.

% If the scores are tied, randomly determine who goes first.
order_players(HumanScore, ComputerScore, Player1, Player2) :-
    HumanScore = ComputerScore,
    randomize_player_order(Player1, Player2).

/* *********************************************************************
 Function Name: randomize_player_order
 Purpose: Randomly determine the order of the players
 Reference: None
********************************************************************* */

/* *************************************************
randomize_player_order/2
Parameters:
    -Player1: the first player for this round.
    -Player2: the second player for this round.
 ************************************************ */

randomize_player_order(Player1, Player2) :-
    write("You will roll first, followed by the computer."), nl,
    roll_one(HumanRoll),
    roll_one(ComputerRoll),

    write("You rolled a "), write(HumanRoll), nl,
    write("The computer rolled a "), write(ComputerRoll), nl,

    randomize_player_order(HumanRoll, ComputerRoll, Player1, Player2).

/* *************************************************
randomize_player_order/4
Parameters:
    +HumanRoll: the roll of the human player.
    +ComputerRoll: the roll of the computer player.
    -Player1: the first player for this round.
    -Player2: the second player for this round.
************************************************ */

% If the human player rolled higher, they go first.
randomize_player_order(HumanRoll, ComputerRoll, human, computer) :-
    HumanRoll > ComputerRoll.

% If the computer player rolled higher, they go first.
randomize_player_order(HumanRoll, ComputerRoll, computer, human) :-
    HumanRoll < ComputerRoll.

% If the rolls are tied, reroll.
randomize_player_order(HumanRoll, ComputerRoll, Player1, Player2) :-
    HumanRoll = ComputerRoll,
    write("Rerolling due to a tie..."), nl,
    randomize_player_order(Player1, Player2).
    