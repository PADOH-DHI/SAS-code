 /*
This program builds the final products for the project (mostly data sets) and
copies them to a specified directory. This should be the only program that needs
to be manually run.

Input
    project_dir
        Macro variable giving the project's directory path.
    output_dir
        Macro variable giving the directory to store the output. For a
        "production" run, this should be a shared directory.
 */

 /* Have SAS abort if any error occurs */
Options errabend;

%Let project_dir = C:/users/&SysUserID./documents/github/SAS-code;
%Let output_dir = C:/users/&SysUserID./desktop/trial-output;

Libname DHI "&output_dir.";

%Include "&project_dir./sas/functions/create_function_dataset.sas";

DATA _NULL_;
    If _syserr_ then abort;
Run;

PROC DATASETS library = Work nodetails nolist;
    Modify Functions (
        alter = DHI
        write = DHI
        label =
'Compiled routines for handling arrays, dates, and other utility uses. Write and
alter passwords are both "DHI"'
    );
    Copy outlib = DHI;
        Select Functions / memtype = data;
Run;
