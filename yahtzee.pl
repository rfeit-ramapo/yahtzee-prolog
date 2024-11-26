/************************************************************
 * Name:  Rebecca Feit                                      *
 * Project:  Yahtzee - Prolog Implementation                *
 * Class:  OPL (CMPS 366 01)                                *
 * Date:                                                    *
 ************************************************************/

% Consult all required files, in order.
:- consult('utility.pl').
%:- consult('validation.pl')
:- consult('game_data.pl').
%:- consult('dice.pl')
%:- consult('strategy.pl')
%:- consult('validation2.pl')
%:- consult('turn.pl')
%:- consult('serialize.pl')
%:- consult('rounds.pl')


/* *********************************************************************
 Function Name: run_tournament
 Purpose: The main function to kick off and run the tournament
 Parameters: None
 Return Value: None
 Reference: None
********************************************************************* */
run_tournament :-
    print_instructions.
    %serialize_load(InitialGameData),
    %initialize_game_data(InitialGameData, GameData),
    %print_scorecard(GameData),
    %run_rounds(GameData, FinalData),
    %print_final(FinalData).

% Automatically start running the program when loaded.
:- run_tournament.
