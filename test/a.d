import std.string;

string trimQuotes(string str) {
	// can't use '"'
	return strip(str,"\"");
}

string getInfoStr(TOMLValue v) {
	string s = format("%s",v);
	return trimQuotes(s);
}

void main(){
	getInfoStr (info["disp"]);
}