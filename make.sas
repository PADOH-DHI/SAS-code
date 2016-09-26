 /*----------------------------------------------------------------------------
This program builds the final products for the project (mostly data sets) and
copies them to a specified directory. This should be the only program that needs
to be manually run.

Input
    project_dir
        Macro variable giving the project's directory path.
    output_dir
        Macro variable giving the directory to store the output. For a
        "production" run, this should be a shared directory.
 ----------------------------------------------------------------------------*/

 /* Have SAS abort if any error occurs */
Options errabend;


 /*----------------------------------------------------------------------------
If this program is run using a GUI, change the system working directory to the
project path.
 ----------------------------------------------------------------------------*/
%MACRO change_directory_if_gui;
	%Let execpath = %sysget(SAS_EXECFILEPATH);
	%If %length(&execpath.) > 0 %then %do;
		%Let execname = %sysget(SAS_EXECFILENAME);
		%Let execdir_length = %eval(%length(&execpath.) - %length(&execname.) - 1);
		%Let execdir = %substr(&execpath., 1, &execdir_length.);
		DATA _NULL_;
			rc = system("cd ""&execdir.""");
		Run;
	%End;
%Mend change_directory_if_gui;

%change_directory_if_gui;


 /*----------------------------------------------------------------------------
    Execute a configuration file and use it to set up connections
 ----------------------------------------------------------------------------*/
%Include "config.sas";

Libname DHI "&output_dir.";


 /* Create the project's products in the WORK library */
%Include "sas/functions/create_function_dataset.sas";


 /*----------------------------------------------------------------------------
    If all went well, distribute the products.
 ----------------------------------------------------------------------------*/
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
