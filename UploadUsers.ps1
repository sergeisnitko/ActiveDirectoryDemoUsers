Import-Module ./core/Spf.Common.ps1
cls

$CurrentFolder = Get-ScriptDirectory;

$UserRows = GetUsersFromCSV("$CurrentFolder/adusers.csv")

echo $UserRows


