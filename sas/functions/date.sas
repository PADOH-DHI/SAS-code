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
Run;
