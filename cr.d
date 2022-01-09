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
import std.path;
import std.format;
import std.process : environment;


// Use this declaration rather than `enum`
// so that we can assign it in runtime
static string CRYPTIC_RESOLVER_HOME;


enum CRYPTIC_RESOLVER_SHEETS = [
	"computer": "https://github.com/cryptic-resolver/cryptic_computer.git",
	"common":   "https://github.com/cryptic-resolver/cryptic_common.git",
	"science":  "https://github.com/cryptic-resolver/cryptic_science.git",
	"economy":  "https://github.com/cryptic-resolver/cryptic_economy.git",
	"medicine": "https://github.com/cryptic-resolver/cryptic_medicine.git"
];

enum CRYPTIC_VERSION = "1.0.0";


//
// helper: for color
//

string bold(string str)       { return "\033[1m%s\033[0m".format(str); }
string underline(string str)  { return "\033[4m%s\033[0m".format(str); }
string red(string str)        { return "\033[31m%s\033[0m".format(str); }
string green(string str)      { return "\033[32m%s\033[0m".format(str); }
string yellow(string str)     { return "\033[33m%s\033[0m".format(str); }
string blue(string str)       { return "\033[34m%s\033[0m".format(str); }
string purple(string str)     { return format("\033[35m%s\033[0m", str); }
string cyan(string str)       { return format("\033[36m%s\033[0m", str); }


// dmd -unittest ./cr.d
unittest {
	// assert(1==3);
	writeln(bold("bold"));
	writeln(red("red"));
	writeln(purple("purple"));
}


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

	version(Windows) {
		CRYPTIC_RESOLVER_HOME = `C:\Users\` ~ environment["USERNAME"] ~ `\.cryptic-resolver`;
	} else {
		CRYPTIC_RESOLVER_HOME = expandTilde("~/.cryptic-resolver");
	}	
	
	// DEBUG
	// writeln(CRYPTIC_RESOLVER_HOME);

	string arg;
	int arg_num = args.length;

	// DEBUG
	// writefln("arg_num is %d\n",arg_num);

	if(arg_num < 2) {
		arg = "";
	} else {
		arg = args[1];
	}

	switch (arg) {
	case "":
		help();
		add_default_sheet_if_none_exist();
		break;
	case "-h":
		help();
		break;
	case "-u":
		if (arg_num > 2) {
			update_sheets(args[2]);
		} else {
			update_sheets("");
		}
		break;
	default:
		solve_word(arg);
	}
}