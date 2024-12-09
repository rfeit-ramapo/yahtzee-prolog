/* *********************************************
 Source Code for basic utility functions used in other locations
 ********************************************* */

/* *********************************************************************
  Function Name: max_list
  Purpose: Get the maximum value in a list of positive numbers
  Reference: None
********************************************************************* */

/* *************************************************
max_list/2
Parameters:
    +List: The list of numbers to find the maximum of.
    -Max: The maximum value in the list.
 ************************************************ */

max_list([], 0).

max_list([First | Rest], Max) :-
    max_list(Rest, MaxRest),
    Max is max(First, MaxRest).

/* *********************************************************************
  Function Name: sum_list
  Purpose: Add a list of numbers together to get a sum
  Reference: None
********************************************************************* */

/* *************************************************
sum_list/2
Parameters:
    +List: The list of to sum.
    -Sum: The maximum value in the list.
 ************************************************ */

sum_list([], 0).

sum_list([First | Rest], Sum) :-
    sum_list(Rest, SumRest),
    Sum is First + SumRest.