 /*
clear_package_definitions.sas

This macro is used to remove all function and subroutine definitions from a
package in a dataset created by PROC FCMP. It should be used at the top of any
program creating a package for two reasons:
    1. Any functions not redefined in the creation program are likely
       undocumented and not intended to be used.
    2. SAS prints a warning any time an existing function or subroutine is
       redefined, and clean logs are nice logs.

Arguments:
    package_lib
        Three-level package name in the format: Library.Dataset.Package
        If a two-level name is given, they're assumed to be the dataset and
        package names, with WORK as the library.
 */

%MACRO clear_package_definitions(package_lib);
    %Local
        name_length
        library
        dataset
        package
        deletefunc_statement
        deletesubr_statement;
    %Let name_length = %sysfunc(countw(&package_lib., %str(.)));
    %If %eval(&name_length. ^= 2 & &name_length. ^= 3) %then
        %Put package_lib is a &name_length.-length name, but must be two- or three-length.;
    %Else %do;
        %If &name_length. = 3 %then %do;
            %Let library = %scan(&package_lib., 1, %str(.));
            %Let dataset = %scan(&package_lib., 2, %str(.));
            %Let package = %scan(&package_lib., 3, %str(.));
        %End;
        %Else %if &name_length. = 2 %then %do;
            %Let library = WORK;
            %Let dataset = %scan(&package_lib., 1, %str(.));
            %Let package = %scan(&package_lib., 2, %str(.));
        %End;

        %Let library = %upcase(&library.);
        %Let dataset = %upcase(&dataset.);
        %Let package = %upcase(&package.);

        %If %sysfunc(exist(&library..&dataset.)) = 0 %then
            %Put &library..&dataset. does not exist.;
        %Else %do;
            DATA _NULL_;
                Set &library..&dataset. end = last_record;
                Where countw(_Key_) = 3 &
                        scan(_Key_, 2) = "&package." &
                        Name in ('SUBROUTI', 'FUNCTION');
                Length
                    deletesubr_statement deletefunc_statement $ 5000
                    routine_name $ 32;
                Retain deletesubr_statement deletefunc_statement;
                If _N_ = 1 then do;
                    deletesubr_statement = '';
                    deletefunc_statement = '';
                End;
                routine_name = scan(_Key_, 3);
                If Name = 'SUBROUTI' then
                    deletesubr_statement = catx(' ', deletesubr_statement,
                                                'Deletesubr', routine_name,
                                                ';');
                Else if Name = 'FUNCTION' then
                    deletefunc_statement = catx(' ', deletefunc_statement,
                                                'Deletefunc', routine_name,
                                                ';');
                If last_record then do;
                    Call symput("deletesubr_statement",
                                strip(deletesubr_statement));
                    Call symput("deletefunc_statement",
                                strip(deletefunc_statement));
                End;
            Run;

            PROC FCMP outlib = &library..&dataset..&package.;
                &deletesubr_statement.;
                &deletefunc_statement.;
            Run;
        %End;
    %End;
%Mend clear_package_definitions;
