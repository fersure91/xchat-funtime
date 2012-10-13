#!/usr/bin/env perl

# EDIT: Fersure@IrCQnet: Changed usage to /np - Changed colours - Less verbose output on fail
IRC::register("Audacious-Info", "1.0", "", "");
IRC::print "Loaded Audacious 1.0";
IRC::print "Usage: /np";
IRC::add_command_handler("np", "show_audacious_info");
sub show_audacious_info
{
chomp ($TITLE=`audtool current-song`);
$OUT = "/say np: $TITLE";
IRC::command($OUT);
return 1;
}
