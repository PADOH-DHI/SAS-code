 /*----------------------------------------------------------------------------
Configuration file template

Use this template to create your own configuration file. Save that file as
"config.sas" in the same directory (next to "project_master.sas").

Each statement has a description for what it does and how to set it.

All values which can change based on user, system, or other environmental
factors should be set here. Additionally, everything that should never be
publicly released (passwords, server paths, etc.) should be set here.
 ----------------------------------------------------------------------------*/

 /* Directory to store the output data sets. Do not quote. */
%Let output_dir = C:/users/&SysUserID./desktop/trial-output;
