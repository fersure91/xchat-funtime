#!/usr/bin/env perl

# A simple (he)xchat script that shows what you are currently listening to in audacious. Enjoy!
# Copyright (C) Fersure@freenode 2012
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
