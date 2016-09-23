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

%Let project_dir = C:/users/&UserID./documents/github/SAS-code;
%Let output_dir = C:/users/&UserID./desktop/trial-output;

Libname DHI "&output_dir.";

%Include "&project_dir./functions/create_function_dataset.sas";

PROC DATASETS library = Work nodetails nolist;
    Copy outlib = DHI;
        Select Functions / memtype = data;
Run;
