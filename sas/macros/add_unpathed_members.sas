 /*
add_unpathed_members.sas

Description
    Defines a macro function to take list of format catalogs and function
    libraries and add only those not already in the search paths.

Arguments
    formats
        Space-delimited list of format catalog names
    function_data
        Spa
 */
%MACRO add_unpathed_members(formats, function_data);
    %Local new_formats new_functions;
    %Let new_formats =;
    %Let new_functions =;

    /* For each added member, compare it to each member in the existing setting.
       If a match is found, move on to the next added member. Otherwise, append
       it to the search path. */
    DATA _NULL_;
        Set SASHelp.VOption;
        Where lowcase(OptName) in ("fmtsearch", "cmplib");
        Length add_list new_list $ 1000 out_macro_var $ 20;
        new_list = "";

        If lowcase(OptName) = "fmtsearch" then do;
            add_list = "&formats.";
            out_macro_var = "new_formats";
        End;
        Else if lowcase(OptName) = "cmplib" then do;
            add_list = "&function_data.";
            out_macro_var = "new_functions";
        End;

        /* Remove parenthesis from the setting value */
        setting = compress(setting, "()");

        Do i = 1 to countw(add_list);
            add_member_i = lowcase(scan(add_list, i, " "));
            has_match = 0;
            j = 1;
            Do while (j <= countw(setting) & not has_match );
                setting_j = lowcase(scan(setting, j, " "));
                If add_member_i = setting_j then has_match = 1;
                j = j + 1;
            End;
            If not has_match then new_list = catx(" ", new_list, add_member_i);
        End;

        Call symput(out_macro_var, cats(new_list));
    Run;

    %If %length(&new_formats.) %then
        Options append = (fmtsearch = (&new_formats.));
    %If %length(&new_functions.) %then
        Options insert = (cmplib = (&new_functions.));
%Mend add_unpathed_members;
