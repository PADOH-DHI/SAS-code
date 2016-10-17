 /*----------------------------------------------------------------------------
Adds a package of functions for array processing to a data set of compiled SAS
routines.

Output
    Work.Functions.Array
        Package of compiled custom SAS routines.

Additonal notes
    The compiled function data set will ultimately be copied to a directory
    where all DHI staff have access.
 ----------------------------------------------------------------------------*/
 
 /*----------------------------------------------------------------
    These macros are meant to be used with the run_macro function
 ----------------------------------------------------------------*/

/* Calls a function with two arguments and stores the result */
%MACRO call_binary_function; 
    /* Remove any punctuation or spaces from the function name */
    %Let function_ = %sysfunc(compress(&function., , PS));
    /* Remove quotation marks around character value arguments */
    %Let a = %sysfunc(dequote(&a.));
    %Let b = %sysfunc(dequote(&b.));
    %Let result = %sysfunc(&function_.(&&a., &&b.));
%Mend call_binary_function;


PROC FCMP outlib = Work.Functions.Utility;
    /*------------------------------------------------------------------------
    Check if all numeric values in an array are equal.

    Arguments
        num_array
            Name of the numeric array containing the values to check.

    Return
        Numeric value: 0 if any two values given are not equal, otherwise 1.
        If less than two values are given, then 1 is returned.
    */
    Function identicaln(num_array[*]);
        If dim(num_array) > 1 then do i = 2 to dim(num_array);
            If num_array{i} ^= num_array{1} then return(0);
        End;
        Return(1);
    Endsub;

    /*------------------------------------------------------------------------
    Check if all character values in an array are equal.

    Arguments
        char_array
            Name of the character array containing the values to check.

    Return
        Numeric value: 0 if any two values given are not equal, otherwise 1.
        If less than two values are given, then 1 is returned.
    */
    Function identicalc(char_array[*] $);
        If dim(char_array) > 1 then do i = 2 to dim(char_array);
            If char_array{i} ^= char_array{1} then return(0);
        End;
        Return(1);
    Endsub;

    /*------------------------------------------------------------------------
    Collapse a numeric array to a single value by cumulatively applying a
    binary function to its values, from left to right.

    Arguments
        function
            (character value) Name of a function which takes two numeric
            arguments.
        narray
            (numeric array) Array of numeric values to collapse

    Return
        (numeric) The final value from the cumulative application of the
        function.

    Example

    DATA _NULL_;
        Array myarray[4] (30 16 8 5);
        sum_result = reducen("sum", myarray);
        Put sum_result = "= ((30 + 16) + 8) + 5 [should be 59]";
        mod_result = reducen("mod", myarray);
        Put mod_result = "= mod(mod(mod(30, 16), 8), 5) [should be 1]";
    Run;
    */
    Function reducen(function $, narray[*]);
        Length result 8;
        If dim(narray) = 0 then return(.);
        If dim(narray) = 1 then return(narray[1]);
        result = narray[1];
        Do i = 2 to dim(narray);
            a = result;
            b = narray[i];
            rc = run_macro('call_binary_function', function, a, b, result);
        End;
        Return(result);
    Endsub;

    /*------------------------------------------------------------------------
    Collapse a character array to a single value by cumulatively applying a
    binary function to its values, from left to right.

    Arguments
        function
            (character value) Name of a function which takes two character
            arguments.
        carray
            (character array) Array of character values to collapse

    Return
        (character) The final value from the cumulative application of
        the function. The default length in 2048.

    Example

    DATA _NULL_;
        Array myarray[4] $ ("my" "name" "is" "John");
        sum_result = reducec("sum", myarray);
        Put sum_result = "= ((30 + 16) + 8) + 5 [should be 59]";
        mod_result = reducen("mod", myarray);
        Put mod_result = "= mod(mod(mod(30, 16), 8), 5) [should be 1]";
    Run;
    */
    Function reducec(function $, carray[*] $) $ 2048;
        Length result $ 2048;
        If dim(carray) = 0 then return('');
        If dim(carray) = 1 then return(carray[1]);
        result = carray[1];
        Do i = 2 to dim(carray);
            a = result;
            b = carray[i];
            rc = run_macro('call_binary_function', function, a, b, result);
        End;
        Return(result);
    Endsub;
Run;
