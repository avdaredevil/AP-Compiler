<#
|==============================================================================>|
   AP-Compiler by APoorv Verma [AP] on 4/21/2014
|==============================================================================>|
      $) Compiles AP-Programs Independent of the AP-Modules file
      $) Reads And Calculates all the Modules needed!
      $) Adds code with comment in a neat BASE64 Code
      $) Has a blacklisting system
      $) Code layout detection
      $) Inject Point Detection
|==============================================================================>|
#>
param([Parameter(Mandatory=$True)][String]$File,[String]$OutputFolder = '.',[Switch]$Dbg,[Switch]$PassThru)
# =======================================START=OF=COMPILER==========================================================|
#    The Following Code was added by AP-Compiler Version [1.1] To Make this program independent of AP-Core Engine
# ==================================================================================================================|
iex ([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("JFBTSGVsbD0kKGlmKCRQU0hlbGwpeyRQU0hlbGx9ZWxzZXskUFNTY3JpcHRSb290fSkKZnVuY3Rpb24gUHJvY2Vzcy1UcmFuc3BhcmVuY3kge3BhcmFtKFtBbGlhcygiVHJhbnNwYXJlbmN5IiwiSW52aXNpYmlsaXR5IiwiaSIsInQiKV1bVmFsaWRhdGVSYW5nZSgwLDEwMCldW2ludF0kVHJhbnM9MCwgW1BhcmFtZXRlcihNYW5kYXRvcnk9JFRydWUpXSRQcm9jZXNzKQ0KDQogICAgaWYgKCRQcm9jZXNzIC1tYXRjaCAiXC5leGUkIikgeyRQcm9jZXNzID0gJFByb2Nlc3MucmVwbGFjZSgiLmV4ZSIsIiIpfQ0KICAgIFRyeSB7DQogICAgICAgIGlmICgkUHJvY2Vzcy5uYW1lKSB7JFByb2MgPSAkUHJvY2Vzcy5uYW1lfSBlbHNlIHskUHJvYyA9IChHZXQtUHJvY2VzcyAkUHJvY2VzcyAtRXJyb3JBY3Rpb24gU3RvcClbMF0ubmFtZX0NCiAgICB9IGNhdGNoIHsNCiAgICAgICAgaWYgKFtJbnRdOjpUcnlQYXJzZSgkUHJvY2VzcywgW3JlZl0zKSkgeyRQcm9jID0gKChHZXQtUHJvY2VzcyB8ID8geyRfLklEIC1lcSAkUHJvY2Vzc30pWzBdKS5uYW1lfQ0KICAgIH0NCiAgICBpZiAoJFByb2MgLW5vdE1hdGNoICJcLmV4ZSQiKSB7JFByb2MgPSAiJFByb2MuZXhlIn0NCiAgICBuaXJjbWQgd2luIHRyYW5zIHByb2Nlc3MgIiRQcm9jIiAoKDEwMC0kVHJhbnMpKjI1NS8xMDApIHwgT3V0LU51bGwNCn0KCmZ1bmN0aW9uIEtleVByZXNzZWRDb2RlIHtwYXJhbShbUGFyYW1ldGVyKE1hbmRhdG9yeT0kVHJ1ZSldW0ludF0kS2V5LCAkU3RvcmU9Il5eXiIpDQoNCiAgICBpZiAoISRIb3N0LlVJLlJhd1VJLktleUF2YWlsYWJsZSAtYW5kICRTdG9yZSAtZXEgIl5eXiIpIHtSZXR1cm4gJEZhbHNlfQ0KICAgIGlmICgkU3RvcmUgLWVxICJeXl4iKSB7JFN0b3JlID0gJEhvc3QuVUkuUmF3VUkuUmVhZEtleSgiSW5jbHVkZUtleVVwLE5vRWNobyIpfQ0KICAgIHJldHVybiAoJEtleSAtaW4gJFN0b3JlLlZpcnR1YWxLZXlDb2RlKQ0KfQoKZnVuY3Rpb24gUHJpbnQtTGlzdCB7cGFyYW0oJHgsIFtTd2l0Y2hdJEluUmVjdXJzZSkNCg0KICAgIGlmICgkeC5jb3VudCAtbGUgMSkge3JldHVybiA/OigkSW5SZWN1cnNlKXskeH17IlskeF0ifX0gZWxzZSB7DQogICAgICAgIHJldHVybiAiWyQoKCR4IHwgJSB7UHJpbnQtTGlzdCAkXyAtSW5SZWN1cnNlfSkgLWpvaW4gJywgJyldIg0KICAgIH0NCn0KCmZ1bmN0aW9uIEJhY2t1cCB7V3JpdGUtSG9zdCAtZiB5ZWxsb3cgJ1tBUC1DT01QSUxFUl0gTW9kdWxlIFtCYWNrdXBdIGRpc2FibGVkIGZvciB0aGlzIHByb2dyYW0nfQoKZnVuY3Rpb24gQVAtUmVxdWlyZSB7cGFyYW0oW1BhcmFtZXRlcihNYW5kYXRvcnk9JFRydWUpXVtBbGlhcygiRnVuY3Rpb25hbGl0eSIsIkxpYnJhcnkiKV1bU3RyaW5nXSRMaWIsIFtTY3JpcHRCbG9ja10kT25GYWlsPXt9LCBbU3dpdGNoXSRQYXNzVGhydSkNCg0KICAgIFtib29sXSRTdGF0ID0gJChzd2l0Y2ggLXJlZ2V4ICgkTGliLnRyaW0oKSkgew0KICAgICAgICAiXkludGVybmV0IiAge3Rlc3QtY29ubmVjdGlvbiBnb29nbGUuY29tIC1Db3VudCAxIC1RdWlldH0NCiAgICAgICAgIl5kZXA6KC4qKSIgIHtpZiAoJE1hdGNoZXNbMV0gLW5lICJ3aGVyZSIpe0FQLVJlcXVpcmUgImRlcDp3aGVyZSIgeyRNT0RFPTJ9fWVsc2V7JE1PREU9Mn07aWYgKCRNT0RFLTIpe0dldC1XaGVyZSAkTWF0Y2hlc1sxXX1lbHNle3RyeXsmICRNYXRjaGVzWzFdICIvZmpmZGpmZHMgLS1kc2phaGRocyAtZHNqYWRqIiAyPiRudWxsOyJzdWNjIn1jYXRjaHt9fX0NCiAgICAgICAgIl5saWI6KC4qKSIgIHskRmlsZT0kTWF0Y2hlc1sxXTskTGliPUFQLUNvbnZlcnRQYXRoICI8TElCPiI7KHRlc3QtcGF0aCAtdCBsZWFmICIkTGliXCRGaWxlIikgLW9yICh0ZXN0LXBhdGggLXQgbGVhZiAiJExpYlwkRmlsZS5kbGwiKX0NCiAgICAgICAgIl5mdW5jdGlvbjooLiopIiAge2djbSAkTWF0Y2hlc1sxXSAtZWEgU2lsZW50bHlDb250aW51ZX0NCiAgICAgICAgIl5zdHJpY3RfZnVuY3Rpb246KC4qKSIgIHtUZXN0LVBhdGggIkZ1bmN0aW9uOlwkKCRNYXRjaGVzWzFdKSJ9DQogICAgfSkNCiAgICBpZiAoISRTdGF0KSB7JE9uRmFpbC5JbnZva2UoKX0NCiAgICBpZiAoJFBhc3NUaHJ1KSB7cmV0dXJuICRTdGF0fQ0KfQoKZnVuY3Rpb24gV3JpdGUtQVAge3BhcmFtKFtQYXJhbWV0ZXIoTWFuZGF0b3J5PSRUcnVlKV0kVGV4dCwgW1N3aXRjaF0kTm9TaWduLCBbU3dpdGNoXSRQbGFpblRleHQsIFtWYWxpZGF0ZVNldCgiQ2VudGVyIiwiUmlnaHQiLCJMZWZ0IildW1N0cmluZ10kQWxpZ249J0xlZnQnLCBbU3dpdGNoXSRQYXNzVGhydSkNCg0KICAgIGlmICgkdGV4dC5jb3VudCAtZ3QgMSAtb3IgJHRleHQuR2V0VHlwZSgpLk5hbWUgLW1hdGNoICJcW1xdJCIpIHtyZXR1cm4gJFRleHQgfD97IiRfIn18ICUge1dyaXRlLUFQICRfIC1Ob1NpZ246JE5vU2lnbiAtUGxhaW5UZXh0OiRQbGFpblRleHQgLUFsaWduICRBbGlnbn19DQogICAgaWYgKCEkdGV4dCAtb3IgJHRleHQgLW5vdG1hdGNoICJeKCg/PE5OTD54KXwoPzxOUz5ucz8pKXswLDJ9KD88dD5cPiopKD88cz5bK1wtIVwqXCNdKSg/PHc+LiopIikge1dyaXRlLUFQICRUZXh0OyRUZXh0fQ0KICAgICR0YiAgPSAiICAgICIqJE1hdGNoZXMudC5sZW5ndGg7DQogICAgJENvbCA9IEB7JysnPScyJzsnLSc9JzEyJzsnISc9JzE0JzsnKic9JzMnOycjJz0nRGFya0dyYXknfVsoJFNpZ24gPSAkTWF0Y2hlcy5TKV0NCiAgICBpZiAoISRDb2wpIHtUaHJvdyAiSW5jb3JyZWN0IFNpZ24gWyRTaWduXSBQYXNzZWQhIn0NCiAgICAkU2lnbiA9ICQoaWYgKCROb1NpZ24gLW9yICRNYXRjaGVzLk5TKSB7IiJ9IGVsc2UgeyJbJFNpZ25dICJ9KQ0KICAgIEFQLVJlcXVpcmUgImZ1bmN0aW9uOkFsaWduLVRleHQiIHtmdW5jdGlvbiBHbG9iYWw6QWxpZ24tVGV4dCgkYWxpZ24sJHRleHQpIHskdGV4dH19DQogICAgJERhdGEgPSAiJHRiJFNpZ24kKCRNYXRjaGVzLlcpIjtpZiAoISREYXRhKSB7cmV0dXJufQ0KICAgICREYXRhID0gQWxpZ24tVGV4dCAtQWxpZ24gJEFsaWduICIkdGIkU2lnbiQoJE1hdGNoZXMuVykiDQogICAgaWYgKCRQbGFpblRleHQpIHtyZXR1cm4gJERhdGF9DQogICAgV3JpdGUtSG9zdCAtTm9OZXdMaW5lOiQoW2Jvb2xdJE1hdGNoZXMuTk5MKSAtZiAkQ29sICREYXRhDQogICAgaWYgKCRQYXNzVGhydSkgeyREYXRhfQ0KfQoKZnVuY3Rpb24gR2V0LUdNQUlMIHtXcml0ZS1Ib3N0IC1mIHllbGxvdyAnW0FQLUNPTVBJTEVSXSBNb2R1bGUgW0dldC1HTUFJTF0gZGlzYWJsZWQgZm9yIHRoaXMgcHJvZ3JhbSd9CgpmdW5jdGlvbiBLZXlUcmFuc2xhdGUge3BhcmFtKFtQYXJhbWV0ZXIoTWFuZGF0b3J5PSRUcnVlKV1bU3RyaW5nXSRLZXkpDQoNCiAgICAkSGFzaEtleSA9IEB7DQogICAgICAgICJ+flNwYWNlfn4iPTMyDQogICAgICAgICJ+fkVTQ0FQRX5+Ij0yNw0KICAgICAgICAifn5FbnRlcn5+Ij0xMw0KICAgICAgICAifn5TaGlmdH5+Ij0xNg0KICAgICAgICAifn5Db250cm9sfn4iPTE3DQogICAgICAgICJ+fkFsdH5+Ij0xOA0KICAgICAgICAifn5CYWNrU3BhY2V+fiI9OA0KICAgICAgICAifn5EZWxldGV+fiI9NDYNCiAgICAgICAgIn5+ZjF+fiI9MTEyDQogICAgICAgICJ+fmYyfn4iPTExMw0KICAgICAgICAifn5mM35+Ij0xMTQNCiAgICAgICAgIn5+ZjR+fiI9MTE1DQogICAgICAgICJ+fmY1fn4iPTExNg0KICAgICAgICAifn5mNn5+Ij0xMTcNCiAgICAgICAgIn5+Zjd+fiI9MTE4DQogICAgICAgICJ+fmY4fn4iPTExOQ0KICAgICAgICAifn5mOX5+Ij0xMjANCiAgICAgICAgIn5+ZjEwfn4iPTEyMQ0KICAgICAgICAifn5mMTF+fiI9MTIyDQogICAgICAgICJ+fmYxMn5+Ij0xMjMNCiAgICAgICAgIn5+TXV0ZX5+Ij0xNzMNCiAgICAgICAgIn5+SW5zZXJ0fn4iPTQ1DQogICAgICAgICJ+flBhZ2VVcH5+Ij0zMw0KICAgICAgICAifn5QYWdlRG93bn5+Ij0zNA0KICAgICAgICAifn5FTkR+fiI9MzUNCiAgICAgICAgIn5+SE9NRX5+Ij0zNg0KICAgICAgICAifn50YWJ+fiI9OQ0KICAgICAgICAifn5DYXBzTG9ja35+Ij0yMA0KICAgICAgICAifn5OdW1Mb2Nrfn4iPTE0NA0KICAgICAgICAifn5XaW5kb3dzfn4iPTkxDQogICAgICAgICJ+fkxlZnR+fiI9MzcNCiAgICAgICAgIn5+VXB+fiI9MzgNCiAgICAgICAgIn5+UmlnaHR+fiI9MzkNCiAgICAgICAgIn5+RG93bn5+Ij00MA0KICAgICAgICAifn5LUDB+fiI9OTYNCiAgICAgICAgIn5+S1Axfn4iPTk3DQogICAgICAgICJ+fktQMn5+Ij05OA0KICAgICAgICAifn5LUDN+fiI9OTkNCiAgICAgICAgIn5+S1A0fn4iPTEwMA0KICAgICAgICAifn5LUDV+fiI9MTAxDQogICAgICAgICJ+fktQNn5+Ij0xMDINCiAgICAgICAgIn5+S1A3fn4iPTEwMw0KICAgICAgICAifn5LUDh+fiI9MTA0DQogICAgICAgICJ+fktQOX5+Ij0xMDUNCiAgICB9DQogICAgaWYgKFtpbnRdJENvbnZlcnQgPSAkSGFzaEtleS4kS2V5KSB7cmV0dXJuICRDb252ZXJ0fQ0KICAgIFRocm93ICJJbnZhbGlkIFNwZWNpYWwgS2V5IENvbnZlcnNpb24iDQp9CgpmdW5jdGlvbiBDb252ZXJ0LVRvQmFzZTY0IHtwYXJhbShbU3RyaW5nXSRUZXh0LCBbVmFsaWRhdGVTZXQoIlVURjgiLCJVbmljb2RlIildW1N0cmluZ10kRW5jb2RpbmcgPSAiVVRGOCIpDQoNCiAgICBbU3lzdGVtLkNvbnZlcnRdOjpUb0Jhc2U2NFN0cmluZyhbU3lzdGVtLlRleHQuRW5jb2RpbmddOjokRW5jb2RpbmcuR2V0Qnl0ZXMoJFRleHQpKQ0KfQoKZnVuY3Rpb24gR2V0LVdoZXJlIHtwYXJhbShbUGFyYW1ldGVyKE1hbmRhdG9yeT0kdHJ1ZSldW3N0cmluZ10kRmlsZSwgW1N3aXRjaF0kQWxsKQ0KDQogICAgQVAtUmVxdWlyZSAiZGVwOndoZXJlIiB7dGhyb3cgIk5lZWQgU3lzMzJcd2hlcmUgdG8gd29yayEiO3JldHVybn0NCiAgICAkT3V0ID0gd2hlcmUuZXhlICRmaWxlIDI+JG51bGwNCiAgICBpZiAoISRPdXQpIHtyZXR1cm59DQogICAgaWYgKCRBbGwpIHtyZXR1cm4gJE91dH0NCiAgICByZXR1cm4gQCgkT3V0KVswXQ0KfQoKZnVuY3Rpb24gR2V0LUFQSUtleSB7V3JpdGUtSG9zdCAtZiB5ZWxsb3cgJ1tBUC1DT01QSUxFUl0gTW9kdWxlIFtHZXQtQVBJS2V5XSBkaXNhYmxlZCBmb3IgdGhpcyBwcm9ncmFtJ30KCmZ1bmN0aW9uIElOLUNvZGUtRGVidWctQ29uc29sZSB7V3JpdGUtSG9zdCAtZiB5ZWxsb3cgJ1tBUC1DT01QSUxFUl0gTW9kdWxlIFtJTi1Db2RlLURlYnVnLUNvbnNvbGVdIGRpc2FibGVkIGZvciB0aGlzIHByb2dyYW0nfQoKZnVuY3Rpb24gS2V5UHJlc3NlZCB7cGFyYW0oW1BhcmFtZXRlcihNYW5kYXRvcnk9JFRydWUpXVtTdHJpbmdbXV0kS2V5LCAkU3RvcmU9Il5eXiIpDQoNCiAgICBpZiAoJFN0b3JlIC1lcSAiXl5eIiAtYW5kICRIb3N0LlVJLlJhd1VJLktleUF2YWlsYWJsZSkgeyRTdG9yZSA9ICRIb3N0LlVJLlJhd1VJLlJlYWRLZXkoIkluY2x1ZGVLZXlVcCxOb0VjaG8iKX0gZWxzZSB7aWYgKCRTdG9yZSAtZXEgIl5eXiIpIHtyZXR1cm4gJEZhbHNlfX0NCiAgICAkQW5zID0gJEZhbHNlDQogICAgJEtleSB8ICUgew0KICAgICAgICAkU09VUkNFID0gJF8NCiAgICAgICAgdHJ5IHsNCiAgICAgICAgICAgICRBbnMgPSAkQW5zIC1vciAoS2V5UHJlc3NlZENvZGUgJFNPVVJDRSAkU3RvcmUpDQogICAgICAgIH0gY2F0Y2ggew0KICAgICAgICAgICAgRm9yZWFjaCAoJEsgaW4gJFNPVVJDRSkgew0KICAgICAgICAgICAgICAgIFtTdHJpbmddJEsgPSAkSw0KICAgICAgICAgICAgICAgIGlmICgkSy5sZW5ndGggLWd0IDQgLWFuZCAoJEtbMCwxLC0xLC0yXSAtam9pbigiIikpIC1lcSAifn5+fiIpIHsNCiAgICAgICAgICAgICAgICAgICAgJEFucyA9ICRBTlMgLW9yIChLZXlQcmVzc2VkQ29kZSAoS2V5VHJhbnNsYXRlKCRLKSkgJFN0b3JlKQ0KICAgICAgICAgICAgICAgIH0gZWxzZSB7DQogICAgICAgICAgICAgICAgICAgICRBbnMgPSAkQU5TIC1vciAoJEsuY2hhcnMoMCkgLWluICRTdG9yZS5DaGFyYWN0ZXIpDQogICAgICAgICAgICAgICAgfQ0KICAgICAgICAgICAgfQ0KICAgICAgICB9DQogICAgfQ0KICAgIHJldHVybiAkQW5zDQp9CgpTZXQtQWxpYXMgaW52IFByb2Nlc3MtVHJhbnNwYXJlbmN5")))
# ========================================END=OF=COMPILER===========================================================|

$Ver = '1.1'
if (!$File -or !(Test-Path -type Leaf $File)) {Throw "Invalid File";exit}
if (!(Test-Path -type Container $OutputFolder)) {Throw "Invalid Folder";exit}
$File = "{0}" -f (Resolve-Path $File)
$OutputFolder = "{0}" -f (Resolve-Path $OutputFolder)
$Modules = $Dep | % {$_[0]};$TmpHash = @{};$Modules | % {$TmpHash.$_ = $_}
$Aliases = Get-Alias | ? {$TmpHash.($_.Definition)} | % {"$_"}
$Data = [IO.File]::ReadAllLines($File)
$Script:OtroFunc = @{}
$Script:Need2Import = @{}
$Script:Need2ImportAL = @{}
$Script:BlackListFunctions = @{"IN-Code-Debug-Console"=1;"Get-APIKey"=1;"Get-GMAIL"=1;"Backup"=1}
#$BEG = "((^|[\(;\=])( ?)+)";$END = "( ?)+((\S+ )+(\S+))?([;\)\(""]|$)"  | "$BEG$([Regex]::Escape($_))$END"
foreach ($Ln in $Data) {
    if ($LN -match "^ +function.+\b(?<Name>\w+)\b( ?)+{") {$OtroFunc += @{$Matches.Name = "Added"};continue}
    $Modules | ? {$LN -match "\b$([Regex]::Escape($_))\b"} | % {$Need2Import.$_++}
    $Aliases | ? {$LN -match "$([Regex]::Escape($_))"} | % {$Need2ImportAL.$_++;$Need2Import.((Get-Alias $_).Definition)++}
}
if ($Need2Import.KeyPressed) {"KeyTranslate","KeyPressedCode" | % {$Need2Import.$_++};Write-AP "+Added AP-KeyPress Support"}
$Need2Import."AP-Require"++
$Need2Import."Get-Where"++
$FinalSet = @($Need2Import.Keys) | ? {!$OtroFunc.$_}
$FinalAlSet = @($Need2ImportAL.Keys) | select -unique
$Code = $FinalSet | % {"function $_ {1}{0}{2}" -f $(if ($BlackListFunctions.$_) {"Write-Host -f yellow '[AP-COMPILER] Module [$_] disabled for this program'"} else {iex "`${Function:$_}"}),"{","}`n"}
$Code += $FinalAlSet | % {"Set-Alias $_ {0}" -f ((Get-Alias $_).Definition)}
if ($Code) {
    $Code = @('$PSHell=$(if($PSHell){$PSHell}else{$PSScriptRoot})')+$Code
    if ($FinalSet) {Write-AP "*Adding Functions $(Print-List $FinalSet)"}
    if ($FinalALSet) {Write-AP "*Adding Aliases   $(Print-List $FinalALSet)"}
    $Injecter = "",
    "# =======================================START=OF=COMPILER==========================================================|",
    "#    The Following Code was added by AP-Compiler Version [$Ver] To Make this program independent of AP-Core Engine",
    "# ==================================================================================================================|",
    "iex ([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String(""$(Convert-ToBase64 ($Code -join "`n"))"")))",
    "# ========================================END=OF=COMPILER===========================================================|",
    "" -join "`n"
}
$Data = $Data -join "`n"
if ($Data -match "`n\[CmdletBinding\(\)\] *`n") {Write-AP "*Detected Procedural Layout"
    $M = [Regex]::Match($Data,"(Begin|Process|End) *\{")
    if (!$M.success) {Write-AP ">!No Begin/Process/End Tags found... Please check that your code is runnable?"}
    else {$Data = $Data.insert($M.Index+$M.Length,$Injecter)}
}else{Write-AP "*Detected Linear Layout"
    $M = [Regex]::Match($Data,"(`n|^)param *\(")
    if (!$M.success) {$Data = "$Injecter$Data"} else {
        $i = 1;$dex=0;$InString=0
        foreach ($c in $Data[($M.Index+$M.Length)..$Data.Length]) {$dex++
            if ($Dbg) {Write-AP ">*Explored $c [Stack: $i |$Dex :: $InString -> $(('Code','Dbl-Quot','Single-Quot')[$InString])]"}
            if ($InString -ne 2 -and $c -eq """") {$InString=(1,0)[$InString]}
            elseif ($InString -ne 1 -and $c -eq "'") {$InString=(2,-1,0)[$InString]}
            elseif ($InString) {continue}
            if ($c -eq "(") {$i++}
            elseif ($c -eq ")") {if (!(--$i)) {break}}
        }
        $Data = $Data.insert($M.Index+$M.Length+$dex,$Injecter)
    }
}
if ((Split-Path $File) -eq $OutputFolder) {
    $Outfile = "$((Split-Path -leaf $File).replace('.ps1','-Compiled.ps1'))"
} else {$Outfile = "$(Split-Path -leaf $File)"}
Write-AP "+Compiled [$OutFile]"
$Data | Out-File -Encoding Unicode "$OutputFolder\$OutFile"
if ($PassThru) {return $code}
