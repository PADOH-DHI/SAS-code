 /*----------------------------------------------------------------------------
Tests for routines dealing with arrays. If any test fails, then the program is
aborted. Meant to be run by a unified test program.
 ----------------------------------------------------------------------------*/

DATA test_identicalc;
    Input
        @1 expected 1.
        @2 array_value_01 2.
        @4 array_value_02 2.
        @6 array_value_03 2.
        @8 array_value_04 2.
        @10 array_value_05 2.;    
    Array input_array [5] array_value_01-array_value_05;
    result = identicaln(input_array);
    If result ^= expected then abort;
    Datalines;
1 3 3 3 3 3
0 3 3 3 0 3
0   3 3 3 3
1          
;
Run;


DATA test_identicalc;
    Input
        @1 expected 1.
        @2 array_value_01 $Char1.
        @3 array_value_02 $Char1.
        @4 array_value_03 $Char1.
        @5 array_value_04 $Char1.
        @6 array_value_05 $Char1.;    
    Array input_array [5] $ array_value_01-array_value_05;
    result = identicalc(input_array);
    If result ^= expected then abort;
    Datalines;
1AAAAA
0BAAAA
0 AAAA
1     
;
Run;


DATA test_reducen;
    Input
        @1 x1 2.
        @4 x2 2.
        @7 x3 2.
        @10 x4 2.
        @13 funcname $Char32.
        @46 expected 4.;

    Array xarray [4] _temporary_;
    Array singleton [1] _temporary_;
    Array duo [2] _temporary_;
    xarray[1] = x1;
    xarray[2] = x2;
    xarray[3] = x3;
    xarray[4] = x4;
    singleton[1] = x1;
    duo[1] = x1;
    duo[2] = x2;

    result = reducen(funcname, xarray);
    result_singleton = reducen(funcname, singleton);
    result_duo = reducen(funcname, duo);

    Length expected_duo_text $ 200;
    expected_duo_text = resolve(cats(
        '%sysfunc(', funcname, '(', xarray[1], ',', xarray[2], '))'
    ));
    expected_duo = input(expected_duo_text, 12.);

    /* Allow some fuzz for floating values */
    If abs(result - expected) > 0.01 then abort;
    If result_singleton ^= xarray[1] then abort;
    If abs(result_duo - expected_duo) > 0.01 then abort;
    Datalines;
 1  1  1  1 sum                                 4
30 16  8  5 mod                                 1
 4  3  2  1 atan2                            0.41
;
Run;
