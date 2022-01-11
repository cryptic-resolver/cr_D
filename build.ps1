#   ---------------------------------------------------
#   File          : build.ps1
#   Authors       : ccmywish <ccmywish@qq.com>
#   Created on    : <2022-1-11>
#   Last modified : <2022-1-11>
#
#   Build cr on Windows via PowerShell
#   ---------------------------------------------------

Write-Host "Building for Windows x64"
dub build 

$version = (Get-Content .\source\cr.d | Select-String "enum CRYPTIC_VERSION" ).
            ToString().
            TrimStart("enum CRYPTIC_VERSION = ").
            Trim("`";")  # should remove double quotes

Write-Host
Write-Host "cr version: $version"

$binname = ".\build\cr-${version}-amd64-pc-windows.exe"

mv .\build\cr.exe $binname

Write-Host "Generate Windows binary in ./build"

# Auto generate scoop manifest
$windows_bin_sha256 = (Get-FileHash "build/cr-${version}-amd64-pc-windows.exe").hash

Write-Host "Windows bin SHA256: $windows_bin_sha256"


$scoop_manifest = '{
    "version": "' + "$version" + '",
    "description": "Cryptic-Resolver (cr) is a fast command line tool used to record and explain cryptic commands, acronyms and so forth in every field, including your own knowledge base.",
    "homepage": "https://github.com/cryptic-resolver/cr_D",
    "license": "MIT",
    "architecture": {
        "64bit": {
            "url": "https://github.com/cryptic-resolver/cr_D/releases/download/v' + "$version" + '/cr-' + "$version" + '-amd64-pc-windows.exe",
            "hash": "' + "$windows_bin_sha256" + '"
        }
    },
    "bin": [ ["cr-' + "$version" + '-amd64-pc-windows.exe","cr"] ] ,
    "checkver": "github",
    "autoupdate": {
        "architecture": {
            "64bit": {
                "url": "https://github.com/cryptic-resolver/cr_D/releases/download/v$version/cr-$version-amd64-pc-windows.exe"
            }
        }
    }
}

'

Set-Content -Path "install/cryptic-resolver.json" -Value $scoop_manifest
Write-Host "Generate cryptic-resolver.json in ./build/"


$nix_install =  (Get-Content -Path "install/i-template.sh").Replace("cr_ver=`"1.0.0`"","cr_ver=`"${version}`"")
Set-Content -Path "install/i.sh" -Value $nix_install
Write-Host "Generate i.sh in ./build/"


