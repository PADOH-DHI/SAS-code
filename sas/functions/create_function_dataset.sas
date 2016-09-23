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

Options cmplib = Work.Functions;

PROC DELETE library = Work data = Functions (alter = DHI);
Run;

%Include "&project_dir./sas/functions/utility.sas";
%Include "&project_dir./tests/test_functions_utility.sas";

%Include "&project_dir./sas/functions/arrat.sas";
%Include "&project_dir./tests/test_functions_array.sas";

%Include "&project_dir./sas/functions/date.sas";
%Include "&project_dir./tests/test_functions_date.sas";

PROC DATASETS library = Work nodetails nolist;
    Modify Functions (
        alter = DHI
        write = DHI
        label =
'Compiled routines for handling arrays, dates, and other utility uses. Write and
alter passwords are both "DHI"'
    );
Run;
