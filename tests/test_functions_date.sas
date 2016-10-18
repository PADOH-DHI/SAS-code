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


DATA test_impute_date_sequence;
    Length
        date1-date4
        year1-year4
        month1-month4
        day1-day4 8;
    Input
        @1 year1 4.
        @5 month1 2.
        @7 day1 2.
        @10 year2 4.
        @14 month2 2.
        @16 day2 2.
        @19 year3 4.
        @23 month3 2.
        @25 day3 2.
        @28 year4 4.
        @32 month4 2.
        @34 day4 2.;
    Array sas_date [4] date1-date4;
    Array month_given [4] month1-month4;
    Array day_given [4] day1-day4;
    Array year_given [4] year1-year4;
    Array month_temp [4] _temporary_;
    Array day_temp [4] _temporary_;
    Array year_temp [4] _temporary_;

    Do i = 1 to dim(sas_date);
        month_temp[i] = month_given[i];
        day_temp[i] = day_given[i];
        year_temp[i] = year_given[i];
    End;

    Call impute_date_sequence(sas_date, month_temp, day_temp, year_temp);
    Do j = 1 to dim(sas_date);
        /* A date's missing if and only if it's an end date with unknown year */
        If j = 1 | j = dim(sas_date) then do;
            If not missing(year_temp[j]) &
                    missing(sas_date[j]) then
                abort;
            If missing(year_temp[j]) &
                    not missing(sas_date[j]) then
                abort;
        End;
        /* Check order */
        If j > 1 then do;
            If not missing(sas_date[j]) &
                    sas_date[j] < sas_date[j - 1] then
                abort;
        End;
        /* Known date parts should match */
        If not missing(sas_date[j]) then do;
            If not missing(month_temp[j]) &
                    month(sas_date[j]) ^= month_temp[j] then
                abort;
            If not missing(day_temp[j]) &
                    day(sas_date[j]) ^= day_temp[j] then
                abort;
            If not missing(year_temp[j]) &
                    year(sas_date[j]) ^= year_temp[j] then
                abort;
        End;
    End;
    Format date1-date4 YYMMDD10.;
    Datalines;
19920101 199201   199201   199201  
199001   199201   199301   199401  
199201   199201       01   199201  
    01   19920222 19930313 19940404
19920222 19930313 19940404     01  
;
Run;
