 /*----------------------------------------------------------------------------
Tests for routines dealing with dates. If any test fails, then the program is
aborted. Meant to be run by a unified test program.
 ----------------------------------------------------------------------------*/
 
DATA test_mdy_carryover;
    Input
        @1 Month_Value 2.
        @4 Day_Value 2.
        @7 Year_Value 4.
        @12 Expected $Char9.;
    Result = put(mdy_carryover(Month_Value, Day_Value, Year_Value), Date9.);
    If Result ^= Expected then abort;
    Datalines;
11 31 1984 01DEC1984
02 30 2000 01MAR2000
02 30 1999 02MAR1999
01 17 2004 17JAN2004
01 33 2004 02FEB2004
12 31 1987 31DEC1987
12 32 1987 01JAN1988
;
Run;
