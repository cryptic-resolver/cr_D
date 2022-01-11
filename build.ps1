Write-Host "Building for Windows x64"
dub build 

$version = (Get-Content .\source\cr.d | Select-String "enum CRYPTIC_VERSION" ).
            ToString().
            TrimStart("enum CRYPTIC_VERSION = ").
            Trim("`";")  # should remove double quotes
Write-Host "cr version: $version"

$binname = ".\build\cr-${version}-amd64-pc-windows.exe"

mv .\build\cr.exe $binname

Write-Host "Generate binary in ./build"
