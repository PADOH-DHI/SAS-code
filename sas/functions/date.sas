 /*----------------------------------------------------------------------------
Adds a package of date management functions to a data set of compiled SAS
routines.

Input
    Work.Functions.Utility
        Package of date routines. Specifically, the `randsequence` function is
        needed.
    Work.Functions.Array
        Package of array routines. Specifically, the `sortn_dynamic` subroutine
        is required.

Output
    Work.Functions.Date
        Package of compiled custom SAS date routines.

Additonal notes
    The compiled function data set will ultimately be copied to a directory
    where all DHI staff have access.
 ----------------------------------------------------------------------------*/

 /* Extremes of SAS date values */
%Let min_sas_date = %sysfunc(mdy(1, 1, 1582));
%Let max_sas_date = %sysfunc(mdy(12, 31, 20000));


PROC FCMP inlib = Work.Functions outlib = Work.Functions.Date;
    /*-------------------------------------------------------------------------
    Verify that the month, day, and year values are for a valid date.
    Arguments
        month_var : Numeric value giving the month
        day_var : Numeric value giving the day of the month
        year_var : Numeric value giving the year
    Return
        1 if the date is valid, otherwise 0.
    Examples
        validate_date(12, 31, 2000) = 1
        validate_date(2, 30, 2000) = 0
    */
    Function validate_date(month_var, day_var, year_var);
        If month_var <= 0 | day_var <= 0 | year_var <= 0 then return(0);
        If not (1 <= month_var <= 12) then return(0);
        origin = mdy(1, 1, year_var);
        month_shifted = intnx('month', origin, month_var - 1, 'BEGINNING');
        day_shifted = intnx('day', month_shifted, day_var - 1, 'SAME');
        If year(day_shifted) = year_var &
                month(day_shifted) = month_var &
                day(day_shifted) = day_var then
            return(1);
        Else return(0);
    Endsub;

    /*-------------------------------------------------------------------------
    Return a date value from values for the month, day, and year. If the day
    value is greater than the number of days in the month, carry over the
    difference into the next month.
    Arguments
        month_var : Numeric value giving the month
        day_var : Numeric value giving the day of the month
        year_var : Numeric value giving the year
    Return
        SAS date variable
    Example
        mdy_carryover(11, 31, 1984) = "01dec1984"d
    */
    Function mdy_carryover(month_var, day_var, year_var);
        /* Return missing if any part is missing */
        If nmiss(month_var, day_var, year_var) > 0 then return(.);
        /* Return missing for invalid month */
        If not (1 <= month_var <= 12) then return(.);
        /* If day_var is greater than the days in the month, carry over */
        given_month_start = mdy(month_var, 1, year_var);
        output_date = intnx('day', given_month_start, day_var - 1, 'SAME');
        Return(output_date);
    Endsub;

    /*-------------------------------------------------------------------------
    Pick a date within a range using known information

    Arguments
        lower
            (numeric) Lower bound of the range of possible dates
        upper
            (numeric) Upper bound of the range of possible dates
        dmonth
            (numeric) Month for the date; missing if unknown
        dday
            (numeric) Day of the month for the date; missing if unknown
        dyear
            (numeric) Year for the date; missing if unknown

    Return
        A numeric value:
            - If lower is missing, then a missing value (.)
            - Else if upper is missing, then the maximum SAS date value
              (6589335, which is 20,000-12-31).
            - Else a date between lower and upper that is consistent with
              dmonth, dday, and dyear.
    */
    Function pick_bounded_date(lower, upper, dmonth, dday, dyear);
        If nmiss(dmonth, dday, dyear) = 0 then return(mdy(dmonth, dday, dyear));
        Else if missing(lower) then return(.);
        /* No upper bound -> maximum SAS date value */
        Else if missing(upper) then return(&max_sas_date.);
        Else if lower = upper then
            return(lower);
        Array valid_date [1] / nosymbols;
        Call dynamic_array(valid_date, upper - lower + 1);
        valid_count = 0;
        Do date_value = lower to upper;
            If (missing(dmonth) | dmonth = month(date_value)) &
                    (missing(dday) | dday = day(date_value)) &
                    (missing(dyear) | dyear = year(date_value)) then do;
                valid_count = valid_count + 1;
                valid_date[valid_count] = date_value;
            End;
        End;
        If valid_count = 0 then return(.);
        Else do;
            valid_index = randsequence(1, valid_count, 1);
            return(valid_date[valid_index]);
        End;
    Endsub;

    /*-------------------------------------------------------------------------
    Impute an ordered sequence of dates from partial data.

    Arguments
        date_var
            (numeric array) Variables to be assigned the imputed dates
        date_month
            (numeric array) Month values for the dates, where date_month[i] is
            for the ith date.
        date_day
            (numeric array) Day of the month values for the dates, where
            date_day[i] is for the ith date.
        date_year
            (numeric array) Year values for the dates, where date_year[i] is
            for the ith date.

    Return
        The variables in date_var will be assigned date values such that, for
        i < j, if date_var[j] is not missing, then date_var[i] <= date_var[j].

    Details
        This CALL routine takes date data broken into parts: month, day, and
        year. Unknown parts are set to missing, and a sequence of dates is
        given through arrays of these parts.

        Imputation is done by using the known date parts and the sequence order
        to determine the set of possible values for each date. Each date is
        assigned a random value from this range, and then all the dates are
        sorted so that the sequence order is maintained.

        If a date is first or last in the sequence and has an unknown year,
        then it will be set to missing.

        WARNING: The correct ordering of dates cannot be guaranteed when one is
        missing the year but not the month or day. This routine will always
        work if each date's range of possible values is not disconnected.
    */
    Subroutine impute_date_sequence(date_var[*], date_month[*], date_day[*],
                                    date_year[*]);
        Outargs date_var;
        /*                ______date_var[1]_______date_var[2] ...
        date_bound: low  | date_bound[1, 1], date_bound[1, 2], ...
                    high | date_bound[2, 1], date_bound[2, 2], ... */
        Array date_bound [2, 1] / nosymbols;
        Call dynamic_array(date_bound, 2, dim(date_var));
        Array set_missing [1] / nosymbols;
        Call dynamic_array(set_missing, dim(date_var));
        Do a = 1 to dim(set_missing);
            set_missing[a] = 0;
        End;
        /* Use given date parts to determine each date's possible range */
        bound2 = dim2(date_bound);
        Do i = 1 to bound2;
            If missing(date_year[i]) then do;
                date_bound[1, i] = .;
                date_bound[2, i] = &max_sas_date.;
                If i = 1 | i = bound2 then set_missing[i] = 1;
            End;
            Else if missing(date_month[i]) & missing(date_day[i]) then do;
                date_bound[1, i] = mdy(1, 1, date_year[i]);
                date_bound[2, i] = mdy(12, 31, date_year[i]);
            End;
            Else if missing(date_day[i]) then do;
                date_bound[1, i] = mdy(date_month[i], 1, date_year[i]);
                next_month = intnx('month', date_bound[1, i], 1);
                date_bound[2, i] = next_month - 1;
            End;
            Else if missing(date_month) then do;
                date_bound[1, i] = mdy(1, date_day[i], date_year[i]);
                date_bound[2, i] = mdy(12, date_day[i], date_year[i]);
            End;
            Else do;
                date_bound[1, i] = mdy(date_month[i], date_day[i], date_year[i]);
                date_bound[2, i] = date_bound[1, i];
            End;
        End;
        /* Each date's boundaries are constrained by the boundaries of
           neighboring dates:
           - Each lower bound is greater than or equal to the previous
           - Each upper bound is less than or equal to the subsequent */
        If bound2 > 1 then do;
            Do j = 2 to bound2;
                If missing(date_bound[1, j]) |
                        date_bound[1, j] < date_bound[1, j - 1] then
                    date_bound[1, j] = date_bound[1, j - 1];
            End;
            Do k = (bound2 - 1) to 1 by -1;
                If missing(date_bound[2, k]) |
                        date_bound[2, k] > date_bound[2, k + 1] then
                    date_bound[2, k] = date_bound[2, k + 1];
            End;
        End;
        /* If any of the constrained ranges are empty, that means the dates
           were not in the specified order. Set them all to missing. */
        is_ordered = 1;
        Do a = 1 to dim2(date_bound) while(is_ordered);
            If date_bound[1, a] > date_bound[2, a] then is_ordered = 0;
        End;
        If is_ordered then do m = 1 to dim(date_var);
            date_var[m] = pick_bounded_date(date_bound[1, m], date_bound[2, m],
                                            date_month[m], date_day[m],
                                            date_year[m]);
        End;
        Else do m = 1 to dim(date_var);
            date_var[m] = .;
        End;
        Call sortn_dynamic(date_var);
        Do n = 1 to dim(date_var);
            If set_missing[n] then date_var[n] = .;
        End;
    Endsub;
Run;
