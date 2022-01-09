//   ---------------------------------------------------
//   File          : cr.d
//   Authors       : ccmywish <ccmywish@qq.com>
//   Created on    : <2021-1-9>
//   Last modified : <2022-1-9>
//
//   This file is used to explain a CRyptic command
//   or an acronym's real meaning in computer world or
//   orther fileds.
//
//  ---------------------------------------------------

import std.stdio;

const CRYPTIC_VERSION = "1.0.0";


void add_default_sheet_if_none_exist()
{
    writeln("TODO: add default sheet");
}


void update_sheets(string sheet_repo)
{
    writeln("TODO: update sheets");
}


void solve_word(string word_2_solve)
{
    writeln("TODO: solve word");
}



void help() 
{
    string help = "cr: Cryptic Resolver version %s in D

usage:
    cr -h                     => print this help
    cr -u (xx.com//repo.git)  => update default sheet or add sheet from a git repo
    cr emacs                  => Edit macros: a feature-rich editor";
	
    writefln(help, CRYPTIC_VERSION);
}




void main(string[] args)
{
	string arg;
	int arg_num = len(args.length);

	if(arg_num < 2) {
		arg = ""
	} else {
		arg = args[1]
	}

	switch (arg) {
	case "":
		help()
		add_default_sheet_if_none_exist()
	case "-h":
		help()
	case "-u":
		if (arg_num > 2) {
			update_sheets(args[2])
		} else {
			update_sheets("")
		}

	default:
		solve_word(arg)
	}
}