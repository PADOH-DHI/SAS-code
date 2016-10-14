 /*----------------------------------------------------------------------------
This program compiles and tests function packages for the project.

Input
    &project_dir
        SAS macro variable that has the base directory for the project.
    sas/functions
        Directory of SAS programs which create specific packages for the
        compiled routine data set.
    tests/test_functions_*.sas
        Collection of SAS programs which test the custom functions.

Output
    data/Work.Functions
        Single dataset of all custom SAS routines. Has both write and alter
        protection. The password is DHI.
 ----------------------------------------------------------------------------*/

%Let old_cmplib = %sysfunc(getoption(cmplib));
Options cmplib = Work.Functions;


%MACRO delete_functions_if_exists;
    %If %sysfunc(exist(work.functions)) %then %do;
        PROC DELETE library = Work data = Functions;
        Run;
    %End;
%Mend delete_functions_if_exists;


%Include "sas/functions/utility.sas";
%Include "sas/functions/array.sas";
%Include "sas/functions/date.sas";

%Include "tests/test_functions_utility.sas";
%Include "tests/test_functions_array.sas";
%Include "tests/test_functions_date.sas";

Options cmplib = (&old_cmplib.);
