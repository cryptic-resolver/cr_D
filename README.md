<div align="center">

**Cryptic Resolver in D**

[![GitHub version](https://badge.fury.io/gh/cryptic-resolver%2Fcr_D.svg)](https://badge.fury.io/gh/cryptic-resolver%2Fcr_D)

</div>

This command line tool `cr` is used to **record and explain cryptic commands, acronyms and so forth** in daily life.
The effort is to study etymology and know of naming conventions.

Not only can it be used in the computer filed, but also you can use this to manage your own knowledge base easily.


<br>


<a name="default-dictionaries"></a> 
## Default Dictionaries

- [cryptic_computer]
- [cryptic_common]
- [cryptic_science]
- [cryptic_economy]
- [cryptic_medicine]

<br>


## Install

On Windows

```bash
scoop install "https://raw.githubusercontent.com/cryptic-resolver/cr_D/main/install/cryptic-resolver.json"
```

On Linux
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/cryptic-resolver/cr_D/main/install/i.sh)"
```

<br>

Or just manually install from the [releases](https://github.com/cryptic-resolver/cr_D/releases) page.

Tested well on `Windows 11` and `Ubuntu`.

Note: You can build it for yourself on macOS

<br>

## Why

The aim of this project is to:

1. make cryptic things clear
2. help maintain your own personal knowledge base

rather than

1. record the use of a command, for this you can refer to [tldr], [cheat] and so on. 

<br>

# Usage

```bash
$ cr emacs
# -> Emacs: Edit macros
# ->
# ->   a feature-rich editor
# ->
# -> SEE ALSO Vim 

$ cr -u 
# -> update all dictionaries

$ cr -u https://github.com/ccmywish/d_things.git
# -> Add your own knowledge base! 

$ cr -h
# -> show help
```


<br>

## Implementation

`cr` is written in pure **D**. You can implement this tool in any other language you like(name your projects as `cr_Python` for example), just remember to reuse our [cryptic_computer] or other dictionaries which are the core parts anyone can contribute to.

For dictionary and sheet layout, you can always refer to [cr] in Ruby, the reference implementation.



## cr in D development

This is built in D v2.098(You need Visual Studio on Windows first)

maybe you need `sudo` access
- `dub init`
- `dub add toml` to add dependency
- `dub` to install all dependecies and build then run
- `dub -- emacs` to test with arguments
- `dub --force -- emacs` to force rebuild
- `rdmd source/cr.d`
- `./unittest.ps1`  
- `./build.ps1`



<br>

# LICENSE
`cr` itself is under MIT

Official [default sheets](#default-sheets) are all under CC-BY-4.0


[cr]: https://github.com/cryptic-resolver/cr
[cryptic_computer]: https://github.com/cryptic-resolver/cryptic_computer
[cryptic_common]: https://github.com/cryptic-resolver/cryptic_common
[cryptic_science]: https://github.com/cryptic-resolver/cryptic_science
[cryptic_economy]: https://github.com/cryptic-resolver/cryptic_economy
[cryptic_medicine]: https://github.com/cryptic-resolver/cryptic_medicine
[tldr]: https://github.com/tldr-pages/tldr
[cheat]: https://github.com/cheat/cheat
