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
        libpath = cats("&output_dir./", subdir);
        Put "Library " subdir +(-1) ": " libpath;
        rc_lib = libname(lib, libpath);
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
PROC DELETE data = Work.Functions (alter = &data_password.);
Run;

%Include "sas/functions/create_function_dataset.sas";


 /*----------------------------------------------------------------------------
    Distribute the products
 ----------------------------------------------------------------------------*/
PROC DATASETS library = Work nodetails nolist;
    Modify Functions (
        alter = &data_password.
        write = &data_password.
        label =
"Compiled routines for handling arrays, dates, and other utility uses. Write and
alter passwords are both '&data_password.'"
    );
    Copy outlib = Function;
        Select Functions / memtype = data alter = &data_password.;
Run;


 /*----------------------------------------------------------------------------
    Copy documentation to the output directory
 ----------------------------------------------------------------------------*/
 /*
SAS server might not allow system commands for copying files.
Argument "outfile" is the file path and name for the copy. It's relative to
output_dir. If either "infile" or "outfile" have spaces, wrap it in quotes.
 */
%MACRO copy_file(infile, outfile);
    %Let infile = %sysfunc(dequote(&infile.));
    %Let outfile = %sysfunc(dequote(&outfile.));
    DATA _NULL_;
        Infile "&infile." truncover;
        File "&output_dir./&outfile.";
        Input;
        Put _infile_;
    Run;
%Mend copy_file;

%copy_file(README.md, README.md);
%copy_file(sas/functions/README.md, Functions/README.md);
%copy_file(sas/macros/add_unpathed_members.sas,
           Macros/add_unpathed_members.sas);
%copy_file(sas/macros/clear_package_definitions.sas,
           Macros/clear_package_definitions.sas);
