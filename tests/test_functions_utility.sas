 /*----------------------------------------------------------------------------
Tests for routines that do general utility tasks. If any test fails, then the
program is aborted. Meant to be run by a unified test program.
 ----------------------------------------------------------------------------*/

DATA test_capitalize_first;
    Length
        unchanged_input input_string expected $ 40;
    Input
        @1 input_string $Char40.
        @41 expected $Char40.;
    unchanged_input = input_string;
    Call capitalize_first(input_string);
    If input_string ^= expected then abort;
    Datalines;
non-empty string                        Non-empty string                        
    starting with blanks                    Starting with blanks                
11223n start with number = no change    11223n start with number = no change    
...ellipses                             ...Ellipses                             
keep the UPPERCASE                      Keep the UPPERCASE                      
Not changed at all                      Not changed at all                      
                                                                                
;
Run;


DATA test_pad_beginning;
    Length
        result_total result_01-result_05 8
        original_length_01 padded_length_01 expected_length_01 $ 1
        original_length_02 padded_length_02 expected_length_02 $ 2
        original_length_03 padded_length_03 expected_length_03 $ 3
        original_length_04 padded_length_04 expected_length_04 $ 4
        original_length_05 padded_length_05 expected_length_05 $ 5;
    Input
        @5 original_length_01 $Char1.
        @4 original_length_02 $Char2.
        @3 original_length_03 $Char3.
        @2 original_length_04 $Char4.
        @1 original_length_05 $Char5.
        @10 expected_length_01 $Char1.
        @9 expected_length_02 $Char2.
        @8 expected_length_03 $Char3.
        @7 expected_length_04 $Char4.
        @6 expected_length_05 $Char5.;

    Array original_var [5] $ original_length_01-original_length_05;
    Array padded_var [5] $ padded_length_01-padded_length_05;
    Array expected_var [5] $ expected_length_01-expected_length_05;
    Array result_var [5] result_01-result_05;
    Do i = 1 to dim(original_var);
        padded_var[i] = original_var[i];
        Call pad_beginning(padded_var[i], '0');
        result_var[i] = (padded_var[i] = expected_var[i]);
    End;
    passed_test = (result_var[1] and identicaln(result_var));
    If not passed_test then abort;
    Datalines;
          
    500005
   4500045
  34500345
 234502345
1234512345
;
Run;


DATA test_randsequence;
    Call streaminit(8118);
    Length
        lower upper stepby 8
        expected_sequence $ 50
        result_character $ 8
        value_j $ 8;
    Input
        @1 lower 8.
        @10 upper 8.
        @19 stepby 8.
        @28 expected_sequence $Char50.;
    Do i = 1 to 10;
        result = randsequence(lower, upper, stepby);
        result_character = strip(put(result, 8.1));
        matched_value = 0;
        Do j = 1 to countw(expected_sequence, ',') while(matched_value = 0);
            value_j = strip(scan(expected_sequence, j, ','));
            If result_character = value_j then
                matched_value = 1;
        End;
        If not matched_value then abort;
    End;
    Datalines;
       1        5        1                                1.0,2.0,3.0,4.0,5.0
       4        8        1                                4.0,5.0,6.0,7.0,8.0
      10       25        5                                10.0,15.0,20.0,25.0
      -2       -2        1                              -2.0,-1.0,0.0,1.0,2.0
       1       -5        1                   -5.0,-4.0,-3.0,-2.0,-1.0,0.0,1.0
       1      5.5        1                                1.0,2.0,3.0,4.0,5.0
       1        2      0.1        1.0,1.1,1.2,1.3,1.4,1.5,1.6,1.7,1.8,1.9,2.0
;
Run;


DATA test_basename;
    Length
        inpath $ 50
        expected $ 20
        result $ 260;
    Input
        @1 inpath $Char50.
        @52 expected $Char20.;
    expected = strip(expected);
    result = basename(inpath);
    If result ^= expected then abort;
    Datalines;
C:/users/username/documents/readfruit.sas          readfruit.sas       
C:\program files\sashome\sasfoundation\9.4         9.4                 
This\is\totally fake\but hey.txt                   but hey.txt         
;
Run;
