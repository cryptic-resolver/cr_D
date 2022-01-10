//   ---------------------------------------------------
//   File          : cr.d
//   Authors       : ccmywish <ccmywish@qq.com>
//   Created on    : <2021-1-9>
//   Last modified : <2022-1-10>
//
//   This file is used to explain a CRyptic command
//   or an acronym's real meaning in computer world or
//   orther fileds.
//
//  ---------------------------------------------------

import std.stdio;
import std.path;
import std.format;
import std.process;
import std.array;

import toml;


// Use this declaration rather than `enum`
// so that we can assign it in runtime
static string CRYPTIC_RESOLVER_HOME;


enum CRYPTIC_DEFAULT_SHEETS = [
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


//
// core: logic
//

bool is_there_any_sheet() {

	// import just be valid in this function scope
	import std.file;
	import std.array;

	string path = CRYPTIC_RESOLVER_HOME;

	if (! exists(path)) {
		mkdir(path);
	}

	// .array property must use import std.array
	auto dirnum = dirEntries(path, SpanMode.shallow).array.length ;

	// writeln(dirnum); // DEBUG 
	if (dirnum == 0)
		return false;
	else 
		return true;
	
}

unittest {
	// can't test it
	// assert(is_there_any_sheet()==true);
}


void add_default_sheet_if_none_exist() {

    if (!is_there_any_sheet()) {
		writeln("cr: Adding default sheets...");

		foreach(key, value; CRYPTIC_DEFAULT_SHEETS) {
			writeln("cr: Pulling cryptic_" ~ key ~ "...");
			auto gitcl = executeShell(
				"git -C " ~ CRYPTIC_RESOLVER_HOME ~ " clone " ~ value ~ " -q");
			if (gitcl.status != 0) writeln(gitcl.output);
		}

		writeln("cr: Add done");
	}
}

unittest {
	// add_default_sheet_if_none_exist();
}


void update_sheets(string sheet_repo) {

	add_default_sheet_if_none_exist();

	if(sheet_repo == "") {
		writeln("cr: Updating all sheets...");

		import std.file;
		auto dir = dirEntries(CRYPTIC_RESOLVER_HOME, SpanMode.shallow);
		// https://dlang.org/library/std/file/dir_entries.html
		foreach(file; dir){

			string sheet = file.baseName;
			writefln("cr: Wait to update %s...", sheet);

			auto gitcl = executeShell(
				"git -C " ~ CRYPTIC_RESOLVER_HOME ~ "/" ~ sheet ~ " pull -q");
			if (gitcl.status != 0) writeln(gitcl.output);
		}
		writeln("cr: Update done");
	
	} else {
		writeln("cr: Adding new sheet...");
		auto gitcl = executeShell(
				"git -C " ~ CRYPTIC_RESOLVER_HOME ~ " clone " ~ sheet_repo ~ " -q");
		if (gitcl.status != 0) writeln(gitcl.output);
		writeln("cr: Add new sheet done");
	}

}




// path: sheet name, eg. cryptic_computer
// file: dict(file) name, eg. a,b,c,d
// dict: the concrete dict
// 		 var dict map[string]interface{}
// 
bool load_dictionary(string path, string file, TOMLDocument* doc) {

	string toml_file = CRYPTIC_RESOLVER_HOME ~ format("/%s/%s.toml", path, file);

	import std.file;

	if (! exists(toml_file)) {
		return false;
	} else {
		*doc = parseTOML(cast(string)read(toml_file));
		return true;
	}

}




// Pretty print the info of the given word
void pp_info(TOMLValue* infodoc ){
	auto info = *infodoc;
	// We should convert disp, desc, full into string

	// can't directly cast TOMLValue to string
	string disp = info["disp"].str;
	
	if (disp == "") {
		disp = red("No name!");
	}

	writefln("\n  %s: %s\n", disp, info["desc"].str);

	string full = info["full"].str ;

	if (full != "") {
		format("\n  %s\n", full);
	}

	// see is string[]
	auto see = info["see"].array; 
	// writeln(see.type); // ARRAY
	

	writeln(see);
	if (see.length != 0 ) {
		writef("\n%s ", purple("SEE ALSO "));

		foreach(index, val ; see) {
			write(underline(val.str) );
		}

		writeln();
	}
	writeln();
}


// Print default cryptic_ sheets
void pp_sheet(string sheet) {
	writeln(green("From: " ~ sheet));
}


//  Used for synonym jump
//  Because we absolutely jump to a must-have word
//  So we can directly lookup to it
//
//  Notice that, we must jump to a specific word definition
//  So in the toml file, you must specify the precise word.
//  If it has multiple meanings, for example
//
//    [blah]
//    same = "XDG"  # this is wrong
//
//    [blah]
//    same = "XDG.Download" # this is right
bool directly_lookup(string sheet, string file, string word) {

	import std.ascii : toLower;	
	import core.stdc.stdlib : exit;

	TOMLDocument dict;

	bool dict_status = load_dictionary(sheet, ""~toLower(file[0]), &dict);

	if(dict_status == false) {
		writeln("WARN: Synonym jumps to a wrong place");
		exit(0);
	}

	string[] words = word.split("."); // [XDG Download]
	string dictword = words[0];       // XDG [Download]

	TOMLValue info;

	if (words.length == 1) { // [HEHE]

		info = dict[dictword];

	} else { //  [XDG Download]
		string explain = words[1];
		TOMLValue indirect_info = dict[dictword];
		info = indirect_info[explain];
	}

	// Warn user this is the toml maintainer's fault
	// the info map is empty
	if (info == null) {
		string str = "WARN: Synonym jumps to a wrong place at `%s` \n" ~
			"Please consider fixing this in `%s.toml` of the sheet `%s`";

		string redstr = red(format(str, word, ""~toLower(file[0]), sheet));

		writeln(redstr);
		exit(0);
	}

	pp_info(&info);
	return true; // always true
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
	
	// TOMLDocument doc;
	// bool status = load_dictionary("cryptic_computer","e",&doc);
	// if (status) {
	// 	writeln("OK");
	// 	// writeln(doc);
	// }
	// else
	// 	writeln("Failed");
	
	// auto emacs = doc["emacs"];

	// pp_info(&emacs);



	string arg;
	int arg_num = cast(int)args.length;	// ulong to int

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