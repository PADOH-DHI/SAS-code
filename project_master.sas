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

 /*----------------------------------------------------------------------------
If this program is run using a GUI, change the system working directory to the
project path.
 ----------------------------------------------------------------------------*/
%MACRO change_directory_if_gui;
    /* Get the filepath if running from SAS EG */
    %Let execpath = %sysfunc(dequote(&_SASPROGRAMFILE.));
    /* Get the filepath if running from base SAS */
    %If %length(&execpath.) = 0 %then
        %Let execpath = %sysget(SAS_EXECFILEPATH);
    %If %length(&execpath.) > 0 %then %do;
        %Let execname = %scan(&execpath., -1, \/);
        %Let execdir_length = %eval(%length(&execpath.) - %length(&execname.) - 1);
        %Let execdir = %substr(&execpath., 1, &execdir_length.);
        DATA _NULL_;
            rc = system("cd ""&execdir.""");
        Run;

        %Put Current directory changed to "&execdir.";
    %End;
%Mend change_directory_if_gui;

%change_directory_if_gui;


 /*----------------------------------------------------------------------------
    Execute a configuration file and use it to set up connections
 ----------------------------------------------------------------------------*/
%Include "config.sas";


 /* Use this until everyone has SAS 9.3 or higher:
    Create the librefs, adding the directories if they don't exist. */
DATA _NULL_;
    Length subdir $ 100;
    Do subdir = "Functions", "Macros";
        If not fileexist(subdir) then
            rc_dir = dcreate(subdir, "&output_dir.");
        lib = substr(subdir, 1, 8);
        rc_lib = libname(lib, subdir);
    End;
Run;


 /*
    After 9.3 is ubiquitous, use this instead

Options dlcreatedir;
Libname Function "Functions";
Libname Macros "Macros";
*/



 /*----------------------------------------------------------------------------
    Create the project products in the WORK library
 ----------------------------------------------------------------------------*/
%Include "sas/functions/create_function_dataset.sas";


 /*----------------------------------------------------------------------------
    Distribute the products
 ----------------------------------------------------------------------------*/
PROC DATASETS library = Work nodetails nolist;
    Modify Functions (
        alter = DHI
        write = DHI
        label =
'Compiled routines for handling arrays, dates, and other utility uses. Write and
alter passwords are both "DHI"'
    );
    Copy outlib = Function;
        Select Functions / memtype = data;
Run;

 /*----------------------------------------------------------------------------
    Copy documentation to the output directory
 ----------------------------------------------------------------------------*/
DATA _NULL_;
    Length
        document_text $ 5000;
    Input document_text;

    Infile 'README.md' end = last_line stopover;
    File "&output_dir./README.md";
    Do while (not _last_line);
        Put document_text;
    End;

    Infile 'sas/functions/README.md' end = last_line stopover;
    File "&output_dir./functions/README.md";
    Do while (not last_line);
        Put document_text;
    End;
Run;
