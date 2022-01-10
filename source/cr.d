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
import std.string;

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

	auto p = "full" in info;
	if (p !is null ){
		format("\n  %s\n", info["full"].str);
	}

	// see is string[]
	p = "see" in info;
	if (p !is null ){
		auto see = info["see"].array;

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

	import core.stdc.stdlib : exit;

	TOMLDocument dict;

	bool dict_status = load_dictionary(sheet, toLower(file), &dict); // std.string: toLower

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
		string str = "WARN: Synonym jumps to a wrong place at `%s` \n 
	Please consider fixing this in `%s.toml` of the sheet `%s`";

		string redstr = red(format(str, word, toLower(file), sheet));

		writeln(redstr);
		exit(0);
	}

	pp_info(&info);
	return true; // always true
}



//  Lookup the given word in a dictionary (a toml file in a sheet) and also print.
//  The core idea is that:
//
//  1. if the word is `same` with another synonym, it will directly jump to
//    a word in this sheet, but maybe a different dictionary
//
//  2. load the toml file and check whether it has the only one meaning.
//    2.1 If yes, then just print it using `pp_info`
//    2.2 If not, then collect all the meanings of the word, and use `pp_info`
//
bool lookup(string sheet, string file, string word) {

	// Only one meaning

	import core.stdc.stdlib : exit;

	TOMLDocument dict;

	bool dict_status = load_dictionary(sheet, file, &dict);

	if (dict_status == false) {
		return false;
	}

	//  We firstly want keys in toml be case-insenstive, but later in 2021/10/26 I found it caused problems.
	// So I decide to add a new must-have format member: `disp`
	// This will display the word in its traditional form.
	// Then, all the keywords can be downcase.

	TOMLValue info;

	// check whether the key is in aa
	auto p = (word in dict);
	if (p is null){
		return false;
	} else {
		info = dict[word]; // Directly hash it
	}

	// Warn user if the info is empty. For example:
	//   emacs = { }
	if (info.table.keys.length == 0) {
		string str = format("WARN: Lack of everything of the given word. \n
	Please consider fixing this in the sheet `%s`", sheet);
		writeln(red(str));
		exit(0);
	}

	// Check whether it's a synonym for anther word
	// If yes, we should lookup into this sheet again, but maybe with a different file
	
	// writeln(info.table); //DEBUG

	string same;
	p = ("same" in info);
	if(p !is null){
		same = info["same"].str;
		pp_sheet(sheet);
		// point out to user, this is a jump
		writeln(blue(bold(word)) ~ " redirects to " ~ blue(bold(same)));

		// no need to load dictionary again
		if (toLower(word[0]) == file[0]) {	// file is just "a" "b" "c" "d" "e"
			// Explicitly convert it to downcase.
			// In case the dictionary maintainer redirects to an uppercase word by mistake.
			same = toLower(same);
			TOMLValue same_info = dict[same];
			if (same_info == null) { // Need repair
				string str = "WARN: Synonym jumps to the wrong place at `" ~ same ~ "`\n" ~
					"	Please consider fixing this in " ~ toLower(file) ~
					".toml of the sheet `" ~ sheet ~ "`";

				writeln(red(str));
				return false;
			} else {
				pp_info(&same_info);
				return true;
			}
		} else {
			import std.conv;
			return directly_lookup(sheet, to!string(same[0]) , same);
		}
	}

	// Check if it's only one meaning

	p = "desc" in info;
	if(p != null) {
		pp_sheet(sheet);
		pp_info(&info);
		return true;
	}

	// Multiple meanings in one sheet

	string[] info_names;
	foreach( k, v; info.table.keys) {	// yes, info is TOMLValue and can transformed to a table(aa)
		info_names ~= v;
	}

	if (info_names.length != 0) {
		pp_sheet(sheet);

		foreach(_, meaning; info_names) {
			TOMLValue multi_ref = dict[word];
			TOMLValue reference = multi_ref[meaning];
			pp_info(&reference);
			// last meaning doesn't show this separate line
			if (info_names[info_names.length - 1] != meaning ){
				write(blue(bold("OR")), "\n");
			}
		}

		return true;

	} else {
		return false;
	}
}


//  The main logic of `cr`
//    1. Search the default's first sheet first
//    2. Search the rest sheets in the cryptic sheets default dir
//
//  The `search` procedure is done via the `lookup` function. It
//  will print the info while finding. If `lookup` always return
//  false then means lacking of this word in our sheets. So a wel-
//  comed contribution is prinetd on the screen.
void solve_word(string word_2_solve){

	add_default_sheet_if_none_exist();

	string word = toLower(word_2_solve);
	// The index is the toml file we'll look into
	import std.conv;
	string index = to!string(word[0]);

	import std.regex;
	if(matchFirst(index, `\d`)) {
		index = "0123456789";
	}

	// Default's first should be 1st to consider
	string first_sheet = "cryptic_computer";

	// cache lookup results
	// bool slice
	bool[] results;
	results ~= lookup(first_sheet, index, word);
	// return if result == true # We should consider all sheets

	// Then else
	import std.file;
	auto rest = dirEntries(CRYPTIC_RESOLVER_HOME, SpanMode.shallow);
	foreach(file; rest){
		string sheet = file.baseName;
		if(sheet != first_sheet) {
			results ~= lookup(sheet, index, word);
			// continue if result == false # We should consider all sheets
		}
	}


	bool result_flag;
	foreach(k,v; results) {
		if(v == true) {
			result_flag = true;
		}
	}

	if(result_flag != true) {
		writeln("cr: Not found anything.\n\n" ~
			"You may use `cr -u` to update the sheets.\n" ~
			"Or you could contribute to our sheets: Thanks!");

		writefln("    1. computer:  %s", CRYPTIC_DEFAULT_SHEETS["computer"]);
		writefln("    2. common:    %s", CRYPTIC_DEFAULT_SHEETS["common"]);
		writefln("    3. science:	%s", CRYPTIC_DEFAULT_SHEETS["science"]);
		writefln("    4. economy:   %s", CRYPTIC_DEFAULT_SHEETS["economy"]);
		writefln("    5. medicine:  %s", CRYPTIC_DEFAULT_SHEETS["medicine"]);
		writeln();

	} else {
		return;
	}

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

	writeln(lookup("cryptic_computer","j","jpg"));

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