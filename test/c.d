import std.stdio;
import std.ascii;

void main(){
    // cannot cast char to string;
    string a = "" ~ toLower('H');
    writeln(a);
}