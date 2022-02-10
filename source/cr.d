//   ---------------------------------------------------
//   File          : cr.d
//   Authors       : ccmywish <ccmywish@qq.com>
//   Created on    : <2021-1-9>
//   Last modified : <2022-2-10>
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


// Can't use `enum`
//    so that we can assign it in runtime
//
// MUST USE __gshared(equivalent to C's static)
//    so that our threads can know it
__gshared string CRYPTIC_RESOLVER_HOME;


enum CRYPTIC_DEFAULT_DICTS = [
	"computer": "https://github.com/cryptic-resolver/cryptic_computer.git",
	"common":   "https://github.com/cryptic-resolver/cryptic_common.git",
	"science":  "https://github.com/cryptic-resolver/cryptic_science.git",
	"economy":  "https://github.com/cryptic-resolver/cryptic_economy.git",
	"medicine": "https://github.com/cryptic-resolver/cryptic_medicine.git"
];

enum CRYPTIC_VERSION = "3.0";


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

bool is_there_any_dict()
{
	// import just be valid in this function scope
	import std.file;

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
	// assert(is_there_any_dict()==true);
}

import std.concurrency;
void _pull_repos(string name, string repo, Tid parentTid){
  writeln("cr: Pulling cryptic_" ~ name ~ "...");
  auto gitcl = executeShell(
		"git -C " ~ CRYPTIC_RESOLVER_HOME ~ " clone " ~ repo ~ " -q");
	if (gitcl.status != 0)
    writeln(gitcl.output);
  else
    send(parentTid, true);
}

void add_default_dicts_if_none_exists()
{
  if (!is_there_any_dict()) {
	  writeln("cr: Adding default dictionaries...");

	  foreach(key, value; CRYPTIC_DEFAULT_DICTS) { // parallel can't apply to aa
      spawn(&_pull_repos, key, value, thisTid);
    }
    auto results = CRYPTIC_DEFAULT_DICTS.length;
    int i = 0;
    while(i<results){
      receive((bool b){
        if( b == true)
          i++;
      } );
    }
    if(results == i){
      writeln("cr: Add done");
    }
	}
}


void _update_repo(string repo, Tid parentTid){
  writefln("cr: Wait to update %s...", repo);
  auto gitcl = executeShell(
			"git -C " ~ CRYPTIC_RESOLVER_HOME ~ "/" ~ repo ~ " pull -q");

  if (gitcl.status != 0)
    writeln(gitcl.output);
  else
    send(parentTid, true);
}

void update_dicts()
{
	add_default_dicts_if_none_exists();
	writeln("cr: Updating all dictionaries...");

	import std.file;
	auto dir = dirEntries(CRYPTIC_RESOLVER_HOME, SpanMode.shallow);

  foreach(file; dir) {
    string dict = file.baseName;
    spawn(&_update_repo, dict, thisTid);
  }

  // NOTE:!!! Here can't use dir.array.length!!!
  auto results = dirEntries(CRYPTIC_RESOLVER_HOME, SpanMode.shallow).array.length;
  int i = 0;
  while(i<results){
    receive((bool b){
      if( b == true)
        i++;
    });
  }
  if(results == i){
    writeln("cr: Update done");
  }
}


void add_dict(string repo)
{
	writeln("cr: Adding new dictionary...");
	auto gitcl = executeShell(
			"git -C " ~ CRYPTIC_RESOLVER_HOME ~ " clone " ~ repo ~ " -q");
	if (gitcl.status != 0) writeln(gitcl.output);
	writeln("cr: Add new dictionary done");
}


void del_dict(string repo)
{
  import std.file : rmdirRecurse;
  auto file = CRYPTIC_RESOLVER_HOME ~ '/' ~ repo;
  try {
    // rmdir can't delete filled dir
    rmdirRecurse(file);
    writefln("cr: Delete dictionary %s done", bold(green(repo)));
  } catch (Exception e) {
    auto err = format("%s", e.message); // e.msg, e.file, e.line
    writefln("%s", bold(red("cr: " ~ err)));
    list_dictionaries;
  }
}


//
// dict: 			 	dict name, eg. cryptic_computer
// sheet_name: 	dict(file) name, eg. a,b,c,d
// piece: 			the concrete of the sheet
//
bool load_sheet(string dict, string sheet_name, TOMLDocument* piece)
{
	string toml_file = CRYPTIC_RESOLVER_HOME ~ format("/%s/%s.toml", dict, sheet_name);

	import std.file;

	if (! exists(toml_file)) {
		return false;
	} else {
		*piece = parseTOML(cast(string)read(toml_file));
		return true;
	}
}



// Pretty print the info of the given word
void pp_info(TOMLValue* infodoc )
{
	auto info = *infodoc;
	// We should convert disp, desc, full into string

	auto p = "disp" in info;
	string disp;
	if (p is null ){
		disp = red("No name!");
	}else {
		disp = info["disp"].str;
	}

	writef("\n  %s: %s\n", disp, info["desc"].str);

	p = "full" in info;
	if (p !is null ){
		writef("\n  %s\n", info["full"].str);
	}

	// see is string[]
	p = "see" in info;
	if (p !is null ){
		auto see = info["see"].array;

		writef("\n%s ", purple("SEE ALSO"));

		foreach(index, val ; see) {
			write(underline(val.str),' ');
		}

		writeln();
	}
	writeln();
}


// Print default cryptic_ dictionaries
void pp_dict(string dict) {
	writeln(green("From: " ~ dict));
}


//
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
//
bool directly_lookup(string dict, string sheet_name, string word)
{
	import core.stdc.stdlib : exit;

	TOMLDocument piece;

	// std.string: toLower
	bool status = load_sheet(dict, toLower(sheet_name), &piece);

	if(status == false) {
		writeln("WARN: Synonym jumps to a wrong place");
		exit(0);
	}

	string[] words = word.split("."); 		// [XDG Download]
	string dictword = toLower(words[0]);  // XDG [Download]

	TOMLValue info;

	if (words.length == 1) { // [HEHE]
		info = piece[dictword];

	} else { //  [XDG Download]
		string explain = words[1];
		TOMLValue indirect_info = piece[dictword];
		info = indirect_info[explain];
	}

	// Warn user this is the toml maintainer's fault
	// the info map is empty
	if (info == null) {
		string str = "WARN: Synonym jumps to a wrong place at `%s` \n
	Please consider fixing this in `%s.toml` of the dictionary `%s`";

		string redstr = red(format(str, word, toLower(sheet_name), dict));

		writeln(redstr);
		exit(0);
	}

	pp_info(&info);
	return true; // always true
}


//
//  Lookup the given word in a sheet (a toml file) and also print.
//  The core idea is that:
//
//  1. if the word is `same` with another synonym, it will directly jump to
//    a word in this sheet, but maybe a different dictionary
//
//  2. load the toml file and check whether it has the only one meaning.
//    2.1 If yes, then just print it using `pp_info`
//    2.2 If not, then collect all the meanings of the word, and use `pp_info`
//
bool lookup(string dict, string sheet_name, string word)
{
	import core.stdc.stdlib : exit;

	TOMLDocument piece;

	bool status = load_sheet(dict, sheet_name, &piece);

	if (status == false) {
		return false;
	}

	// 'disp' will display the word in its traditional form.
	// Then, all the keywords can be downcase.
	TOMLValue info;

	// check whether the key is in aa
	auto p = (word in piece);
	if (p is null){
		return false;
	} else {
		info = piece[word];
	}

	// Warn if the info is empty. For example:
	//   emacs = { }
	if (info.table.keys.length == 0) {
		string str = format("WARN: Lack of everything of the given word. \n
	Please consider fixing this in the dictionary `%s`", dict);
		writeln(red(str));
		exit(0);
	}

	// Check whether it's a synonym for anther word
	// If yes, we should lookup into this dictionary again, but maybe with a different file

	// writeln(info.table); //DEBUG

	string same;
	p = ("same" in info);
	if(p !is null){
		same = info["same"].str;
		pp_dict(dict);
		// This is a jump
		writeln(blue(bold(word)) ~ " redirects to " ~ blue(bold(same)));

		// Explicitly convert it to downcase.
		// In case the dictionary maintainer redirects to an uppercase word by mistake.
		same = toLower(same);

		// no need to load dictionary again
		if (toLower(word[0]) == same[0]) {	// same is just "a" "b" "c" "d" , etc ...

			TOMLValue same_info = piece[same];

			if (same_info == null) { // Need repair
				string str = "WARN: Synonym jumps to the wrong place at `" ~ same ~ "`\n" ~
					"	Please consider fixing this in " ~ same[0] ~
					".toml of the dictionary `" ~ dict ~ "`";

				writeln(red(str));
				return false;
			} else {
				pp_info(&same_info);
				return true;
			}
		} else {
			import std.conv;
			return directly_lookup(dict, to!string(same[0]) , same);
		}
	}

  // Single meaning with no category specifier
  // We call this meaning as type 1
  bool type_1_exist_flag = false;
	p = "desc" in info;
	if(p != null) {
		pp_dict(dict);
		pp_info(&info);
		type_1_exist_flag = true;
	}

  // Meanings with category specifier
  // We call this meaning as type 2
	string[] categories_raw;
	foreach( k, v; info.table.keys) {	//  info is TOMLValue and can transformed to a table(aa)
		categories_raw ~= v;
	}

	string[] cryptic_keywords = ["disp", "desc", "full", "same", "see"];
	string[] categories;

	import std.algorithm: canFind;
	foreach(_,v; categories_raw){
		if( !cryptic_keywords.canFind(v) )
			categories ~= v;
	}

	// DEBUG
	// writeln(categories);

	if (categories.length != 0) {
		if(type_1_exist_flag)
      write(blue(bold("OR")), "\n");
    else
      pp_dict(dict);

		foreach(_, meaning; categories) {
			TOMLValue multi_ref = piece[word];
			TOMLValue reference = multi_ref[meaning];
			pp_info(&reference);
			// last meaning doesn't show this separate line
			if (categories[categories.length - 1] != meaning ){
				write(blue(bold("OR")), "\n");
			}
		}
		return true;
	} else if(type_1_exist_flag){
		return true;
	} else {
		return false;
	}
}


//
//  The main logic of `cr`
//    1. Search the default's first dictionary first
//    2. Search the rest dictionaries in the cryptic dictionaries default dir
//
//  The `search` procedure is done via the `lookup` function. It
//  will print the info while finding. If `lookup` always return
//  false then means lacking of this word in our dictionaries. So a wel-
//  comed contribution is prinetd on the screen.
//
void solve_word(string word_2_solve)
{
	add_default_dicts_if_none_exists();

	string word = toLower(word_2_solve);
	// The index is the toml file we'll look into
	import std.conv;
	string index = to!string(word[0]);

	import std.regex;
	if(matchFirst(index, `\d`)) {
		index = "0123456789";
	}

	// Default's first should be 1st to consider
	string first_dict = "cryptic_computer";

	// cache lookup results
	bool[] results;
	results ~= lookup(first_dict, index, word);

	import std.file;
	auto rest = dirEntries(CRYPTIC_RESOLVER_HOME, SpanMode.shallow);
	foreach(file; rest){
		string dict = file.baseName;
		if(dict != first_dict) {
			results ~= lookup(dict, index, word);
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
			"You may use `cr -u` to update all dictionaries.\n" ~
			"Or you could contribute to: \n");

		writefln("    1. computer:  %s", CRYPTIC_DEFAULT_DICTS["computer"]);
		writefln("    2. common:    %s", CRYPTIC_DEFAULT_DICTS["common"]);
		writefln("    3. science:	  %s",   CRYPTIC_DEFAULT_DICTS["science"]);
		writefln("    4. economy:   %s", CRYPTIC_DEFAULT_DICTS["economy"]);
		writefln("    5. medicine:  %s", CRYPTIC_DEFAULT_DICTS["medicine"]);
		writeln();

	} else {
		return;
	}

}


// 'usage' should type with space!! not tab!!
void help()
{
    string help = "cr: Cryptic Resolver version %s in D

usage:
    cr -v                  => Print version
    cr -h                  => Print this help
    cr -l                  => List local dictionaries
    cr -u                  => Update all dictionaries
    cr -a xx.com/repo.git  => Add a new dictionary
    cr -d cryptic_xx       => Delete a dictionary
    cr emacs               => Edit macros: a feature-rich editor
		";

    writefln(help, CRYPTIC_VERSION);
}


void print_version()
{
    string help = "cr: Cryptic Resolver version %s in D";
    writefln(help, CRYPTIC_VERSION);
}


void list_dictionaries()
{
	import std.file;

	auto path = CRYPTIC_RESOLVER_HOME;
	auto dirs = dirEntries(path, SpanMode.shallow).array; // DirEntry[]

	import std.conv : to;
	foreach(i, dict; dirs){
		writefln("%s. %s", blue(to!string(i+1)), bold(green(dict.baseName)) );
	}
}



void main(string[] args)
{

	version(Windows) {
		CRYPTIC_RESOLVER_HOME = `C:\Users\` ~ environment["USERNAME"] ~ `\.cryptic-resolver`;
	} else {
		CRYPTIC_RESOLVER_HOME = expandTilde("~/.cryptic-resolver");
	}


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
		add_default_dicts_if_none_exists();
		break;
	case "-v":
		print_version();
		break;
	case "-h":
		help();
		break;
	case "-l":
		list_dictionaries();
		break;
	case "-u":
		update_dicts();
		break;
	case "-a":
		if (arg_num > 2) {
			add_dict(args[2]);
		} else {
      writeln(bold(red("cr: Need an argument!")));
    }
		break;
	case "-d":
		if (arg_num > 2) {
			del_dict(args[2]);
		} else {
      writeln(bold(red("cr: Need an argument!")));
    }
		break;
	default:
		solve_word(arg);
	}
}
