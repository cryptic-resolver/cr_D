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


void update_sheets(string sheet_repo)
{
    writeln("TODO: update sheets");
}



//
// path: sheet name, eg. cryptic_computer
// file: dict(file) name, eg. a,b,c,d
// dict: the concrete dict
// 		 var dict map[string]interface{}
//
// bool load_dictionary(string path, string file, dictptr *map[string]interface{}) {

// 	string toml_file = CRYPTIC_RESOLVER_HOME ~ format("/%s/%s.toml", path, file);

// 	if _, err := os.Stat(toml_file); err == nil {
// 		// read file into data
// 		data, _ := ioutil.ReadFile(toml_file)
// 		datastr := string(data)

// 		if _, err := toml.Decode(datastr, dictptr); err != nil {
// 			log.Fatal(err)
// 		}
// 		return true
// 	} else {
// 		return false
// 	}
// }




// Pretty print the info of the given word
void pp_info(string info){

}


// Print default cryptic_ sheets
void pp_sheet(string sheet) {
	writeln(green("From: " ~ sheet));
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
	
	writeln(is_there_any_sheet());

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