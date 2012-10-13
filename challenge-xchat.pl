#!/usr/bin/env perl
#
# challenge-xchat.pl
# Copyright (C) 2006 Lee Hardy <lee -at- leeh.co.uk>
# Copyright (C) 2006 ircd-ratbox development team
# Copyright (C) 2012 David Murdoch <Fersure -at- freenode>
# 
# $Id$

package IRC::XChat::operchallenge;

use IPC::Open2;
use FileHandle;

#########################
# Configuration Variables
#########################

# respond_path: The absolute path to the "ratbox-respond" program.
my $respond_path = "/home/user/respond/ratbox-respond/ratbox-respond";

# private key path: The absolute path to your private key.
my $private_key_path = "/home/user/respond/ratbox-respond/private.key";

###################
# END CONFIGURATION
###################

my $script_name = "oper-challenge";
my $script_version = "1.1";
my $script_descr = "CHALLENGE opering script for use with ratbox/charybdis based ircds.";

Xchat::register($script_name, $script_version, $script_descr, "");
Xchat::print("Loading $script_name $script_version - $script_descr\n");

my $challenge;
my $keyphrase = "";

Xchat::hook_server("740", "handle_rpl_rsachallenge2");
Xchat::hook_server("741", "handle_rpl_endofrsachallenge2");

my $challenge_options = {
	help_text => "Usage: /challenge <opername> [keyphrase]\n"
};

Xchat::hook_command("CHALLENGE", "handle_challenge", $challenge_options);

sub handle_challenge
{
	my $opername = $_[0][1];

	if(!$opername)
	{
		Xchat::print("Usage: /challenge <opername> [keyphrase]\n");
		return Xchat::EAT_ALL;
	}

	$challenge = "";

	$keyphrase = $_[0][2]
		if($_[0][2]);

	Xchat::command("QUOTE CHALLENGE $opername\n");
	return Xchat::EAT_ALL;
}

sub handle_rpl_rsachallenge2
{
	my $reply = $_[0][3];

	# remove the initial ':'
	$reply =~ s/^://;

	$challenge .= $reply;
	return Xchat::EAT_ALL;
}

sub handle_rpl_endofrsachallenge2
{
	Xchat::print("oper-challenge: Received challenge, generating response..\n");

	if(! -x $respond_path)
	{
		Xchat::print("oper-challenge: Unable to execute respond from $respond_path\n");
		return Xchat::EAT_ALL;
	}

	if(! -r $private_key_path)
	{
		Xchat::print("oper-challenge: Unable to open $private_key_path\n");
	}
	unless(open2(*Reader, *Writer, "$respond_path $private_key_path"))
	{
		Xchat::print("oper-challenge: Unable to execute respond from $respond_path\n");
		return Xchat::EAT_ALL;
	}

	print Writer "$keyphrase\n";
	print Writer "$challenge\n";

	# done for safety.. this may be irrelevant in perl!
	$keyphrase =~ s/./0/g;
	$keyphrase = "";

	$challenge =~ s/./0/g;
	$challenge = "";

	my $output = scalar <Reader>;
	chomp($output);

	close(RESPOND);

	if($output =~ /^Error:/)
	{
		Xchat::print("oper-challenge: $output\n");
		return Xchat::EAT_ALL;
	}

	Xchat::print("oper-challenge: Received response, opering..\n");

	Xchat::command("QUOTE CHALLENGE +$output");

	return Xchat::EAT_ALL;
}

1;
