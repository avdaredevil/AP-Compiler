<#
|==============================================================================>|
   AP-Compiler by APoorv Verma [AP] on 4/21/2014
|==============================================================================>|
      $) Compiles AP-Programs Independent of the AP-Modules file
      $) Reads And Calculates all the Modules needed!
      $) Adds code with comment in a neat BASE64 Code
      $) Has a blacklisting system
|==============================================================================>|
#>
param([Parameter(Mandatory=$True)][String]$File,[String]$OutputFolder = '.',[Switch]$PassThru)
# =======================================START=OF=COMPILER==========================================================|
#    The Following Code was added by AP-Compiler Version [1.0] To Make this program independent of AP-Core Engine
# ==================================================================================================================|
iex ([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("ZnVuY3Rpb24gRmxhdHRlbiB7cGFyYW0oW29iamVjdFtdXSR4KQ0KaWYgKCRYLmNvdW50IC1lcSAxKSB7cmV0dXJuICR4IHwgJSB7JF99fSBlbHNlIHskeCB8ICUge0ZsYXR0ZW4gJF99fX0KCmZ1bmN0aW9uIENvbnZlcnQtVG9CYXNlNjQge3BhcmFtKFtTdHJpbmddJFRleHQsIFtWYWxpZGF0ZVNldCgiVVRGOCIsIlVuaWNvZGUiKV1bU3RyaW5nXSRFbmNvZGluZyA9ICJVVEY4IikNCg0KICAgIFtTeXN0ZW0uQ29udmVydF06OlRvQmFzZTY0U3RyaW5nKFtTeXN0ZW0uVGV4dC5FbmNvZGluZ106OiRFbmNvZGluZy5HZXRCeXRlcygkVGV4dCkpDQp9CgpmdW5jdGlvbiBHZXQtQVBJS2V5IHtXcml0ZS1Ib3N0IC1mIHllbGxvdyAnW0FQLUNPTVBJTEVSXSBNb2R1bGUgW0dldC1BUElLZXldIGRpc2FibGVkIGZvciB0aGlzIHByb2dyYW0nfQoKZnVuY3Rpb24gUHJpbnQtTGlzdCB7cGFyYW0oJHgsIFtTd2l0Y2hdJEluUmVjdXJzZSkNCg0KICAgIGlmICgkeC5jb3VudCAtbGUgMSkge3JldHVybiA/OigkSW5SZWN1cnNlKXskeH17IlskeF0ifX0gZWxzZSB7DQogICAgICAgIHJldHVybiAiWyQoKCR4IHwgJSB7UHJpbnQtTGlzdCAkXyAtSW5SZWN1cnNlfSkgLWpvaW4gJywgJyldIg0KICAgIH0NCn0KCmZ1bmN0aW9uIEFQLVJlcXVpcmUge3BhcmFtKFtQYXJhbWV0ZXIoTWFuZGF0b3J5PSRUcnVlKV1bQWxpYXMoIkZ1bmN0aW9uYWxpdHkiLCJMaWJyYXJ5IildW1N0cmluZ10kTGliLCBbU2NyaXB0QmxvY2tdJE9uRmFpbD17fSwgW1N3aXRjaF0kUGFzc3RocnUpDQoNCiAgICBbYm9vbF0kU3RhdCA9ICQoc3dpdGNoIC1yZWdleCAoJExpYi50cmltKCkpIHsNCiAgICAgICAgIl5JbnRlcm5ldCIgIHt0ZXN0LWNvbm5lY3Rpb24gZ29vZ2xlLmNvbSAtQ291bnQgMSAtUXVpZXR9DQogICAgICAgICJeZGVwOiguKikiICB7aWYgKCRNYXRjaGVzWzFdIC1uZSAid2hlcmUiKXtBUC1SZXF1aXJlICJkZXA6d2hlcmUiIHskTU9ERT0yfX1lbHNleyRNT0RFPTJ9O2lmICgkTU9ERS0yKXtHZXQtV2hlcmUgJE1hdGNoZXNbMV19ZWxzZXt0cnl7JiAkTWF0Y2hlc1sxXSAiL2ZqZmRqZmRzIC0tZHNqYWhkaHMgLWRzamFkaiIgMj4kbnVsbDsic3VjYyJ9Y2F0Y2h7fX19DQogICAgICAgICJeZnVuY3Rpb246KC4qKSIgIHtnY20gJE1hdGNoZXNbMV0gLWVhIFNpbGVudGx5Q29udGludWV9DQogICAgICAgICJec3RyaWN0X2Z1bmN0aW9uOiguKikiICB7VGVzdC1QYXRoICJGdW5jdGlvbjpcJCgkTWF0Y2hlc1sxXSkifQ0KICAgIH0pDQogICAgaWYgKCEkU3RhdCkgeyRPbkZhaWwuSW52b2tlKCl9DQogICAgaWYgKCRQYXNzdGhydSkge3JldHVybiAkU3RhdH0NCn0KCmZ1bmN0aW9uIFdyaXRlLUFQIHtwYXJhbShbUGFyYW1ldGVyKE1hbmRhdG9yeT0kVHJ1ZSldW1N0cmluZ10kVGV4dCwgW1N3aXRjaF0kTm9TaWduLCBbU3dpdGNoXSRQbGFpblRleHQsIFtWYWxpZGF0ZVNldCgiQ2VudGVyIiwiUmlnaHQiLCJMZWZ0IildW1N0cmluZ10kQWxpZ249J0xlZnQnKQ0KDQogICAgaWYgKCEkdGV4dCAtb3IgJHRleHQgLW1hdGNoICJeW1wrXC1cIVwqeFw+IF0rJCIpIHtyZXR1cm59DQogICAgJGFjYyAgPSBAKCgnKycsJzInKSwoJy0nLCcxMicpLCgnIScsJzE0JyksKCcqJywnMycpKQ0KICAgICR0YiAgID0gJyc7JGZ1bmMgICA9ICRmYWxzZQ0KICAgIHdoaWxlICgkVGV4dC5jaGFycygwKSAtZXEgJ3gnKSB7JGZ1bmMgPSAkdHJ1ZTsgJFRleHQgPSAkVGV4dC5zdWJzdHJpbmcoMSkudHJpbSgpfQ0KICAgIHdoaWxlICgkVGV4dC5jaGFycygwKSAtZXEgJz4nKSB7JHRiICs9ICIgICAgIjsgJFRleHQgPSAkVGV4dC5zdWJzdHJpbmcoMSkudHJpbSgpfQ0KICAgICRTaWduID0gJFRleHQuY2hhcnMoMCkNCiAgICAkVGV4dCA9ICRUZXh0LnN1YnN0cmluZygxKS50cmltKCkucmVwbGFjZSgnL3hcJywnJykucmVwbGFjZSgnWy5dJywnW0N1cnJlbnQgRGlyZWN0b3J5XScpDQogICAgJHZlcnMgPSAkZmFsc2UNCiAgICBmb3JlYWNoICgkYXIgaW4gJGFjYykge2lmICgkYXJbMF0gLWVxICRzaWduKSB7JHZlcnMgPSAkdHJ1ZTsgJGNsciA9ICRhclsxXTsgJFNpZ24gPSAiWyR7U2lnbn1dICJ9fQ0KICAgIGlmICghJHZlcnMpIHtUaHJvdyAiSW5jb3JyZWN0IFNpZ24gWyRTaWduXSBQYXNzZWQhIn0NCiAgICBBUC1SZXF1aXJlICJmdW5jdGlvbjpBbGlnbi1UZXh0IiB7ZnVuY3Rpb24gR2xvYmFsOkFsaWduLVRleHQoJGFsaWduLCR0ZXh0KSB7JHRleHR9fQ0KICAgICREYXRhID0gQWxpZ24tVGV4dCAtQWxpZ24gJEFsaWduICR0YiQoaWYgKCEkTm9TaWduKSB7JFNpZ259KSRUZXh0DQogICAgaWYgKCRQbGFpblRleHQpIHtyZXR1cm4gJERhdGF9DQogICAgV3JpdGUtSG9zdCAtTm9OZXdMaW5lOiRmdW5jIC1mICRjbHIgJERhdGENCn0KCmZ1bmN0aW9uIEdldC1HTUFJTCB7V3JpdGUtSG9zdCAtZiB5ZWxsb3cgJ1tBUC1DT01QSUxFUl0gTW9kdWxlIFtHZXQtR01BSUxdIGRpc2FibGVkIGZvciB0aGlzIHByb2dyYW0nfQoKZnVuY3Rpb24gSU4tQ29kZS1EZWJ1Zy1Db25zb2xlIHtXcml0ZS1Ib3N0IC1mIHllbGxvdyAnW0FQLUNPTVBJTEVSXSBNb2R1bGUgW0lOLUNvZGUtRGVidWctQ29uc29sZV0gZGlzYWJsZWQgZm9yIHRoaXMgcHJvZ3JhbSd9CgpmdW5jdGlvbiBQcm9jZXNzLVRyYW5zcGFyZW5jeSB7cGFyYW0oW0FsaWFzKCJUcmFuc3BhcmVuY3kiLCJJbnZpc2liaWxpdHkiLCJpIiwidCIpXVtWYWxpZGF0ZVJhbmdlKDAsMTAwKV1baW50XSRUcmFucz0wLCBbUGFyYW1ldGVyKE1hbmRhdG9yeT0kVHJ1ZSldJFByb2Nlc3MpDQoNCiAgICBpZiAoJFByb2Nlc3MgLW1hdGNoICJcLmV4ZSQiKSB7JFByb2Nlc3MgPSAkUHJvY2Vzcy5yZXBsYWNlKCIuZXhlIiwiIil9DQogICAgVHJ5IHsNCiAgICAgICAgaWYgKCRQcm9jZXNzLm5hbWUpIHskUHJvYyA9ICRQcm9jZXNzLm5hbWV9IGVsc2UgeyRQcm9jID0gKEdldC1Qcm9jZXNzICRQcm9jZXNzIC1FcnJvckFjdGlvbiBTdG9wKVswXS5uYW1lfQ0KICAgIH0gY2F0Y2ggew0KICAgICAgICBpZiAoW0ludF06OlRyeVBhcnNlKCRQcm9jZXNzLCBbcmVmXTMpKSB7JFByb2MgPSAoKEdldC1Qcm9jZXNzIHwgPyB7JF8uSUQgLWVxICRQcm9jZXNzfSlbMF0pLm5hbWV9DQogICAgfQ0KICAgIGlmICgkUHJvYyAtbm90TWF0Y2ggIlwuZXhlJCIpIHskUHJvYyA9ICIkUHJvYy5leGUifQ0KICAgIG5pcmNtZCB3aW4gdHJhbnMgcHJvY2VzcyAiJFByb2MiICgoMTAwLSRUcmFucykqMjU1LzEwMCkgfCBPdXQtTnVsbA0KfQoKZnVuY3Rpb24gQVAtUmVxdWlyZSB7cGFyYW0oW1BhcmFtZXRlcihNYW5kYXRvcnk9JFRydWUpXVtBbGlhcygiRnVuY3Rpb25hbGl0eSIsIkxpYnJhcnkiKV1bU3RyaW5nXSRMaWIsIFtTY3JpcHRCbG9ja10kT25GYWlsPXt9LCBbU3dpdGNoXSRQYXNzdGhydSkNCg0KICAgIFtib29sXSRTdGF0ID0gJChzd2l0Y2ggLXJlZ2V4ICgkTGliLnRyaW0oKSkgew0KICAgICAgICAiXkludGVybmV0IiAge3Rlc3QtY29ubmVjdGlvbiBnb29nbGUuY29tIC1Db3VudCAxIC1RdWlldH0NCiAgICAgICAgIl5kZXA6KC4qKSIgIHtpZiAoJE1hdGNoZXNbMV0gLW5lICJ3aGVyZSIpe0FQLVJlcXVpcmUgImRlcDp3aGVyZSIgeyRNT0RFPTJ9fWVsc2V7JE1PREU9Mn07aWYgKCRNT0RFLTIpe0dldC1XaGVyZSAkTWF0Y2hlc1sxXX1lbHNle3RyeXsmICRNYXRjaGVzWzFdICIvZmpmZGpmZHMgLS1kc2phaGRocyAtZHNqYWRqIiAyPiRudWxsOyJzdWNjIn1jYXRjaHt9fX0NCiAgICAgICAgIl5mdW5jdGlvbjooLiopIiAge2djbSAkTWF0Y2hlc1sxXSAtZWEgU2lsZW50bHlDb250aW51ZX0NCiAgICAgICAgIl5zdHJpY3RfZnVuY3Rpb246KC4qKSIgIHtUZXN0LVBhdGggIkZ1bmN0aW9uOlwkKCRNYXRjaGVzWzFdKSJ9DQogICAgfSkNCiAgICBpZiAoISRTdGF0KSB7JE9uRmFpbC5JbnZva2UoKX0NCiAgICBpZiAoJFBhc3N0aHJ1KSB7cmV0dXJuICRTdGF0fQ0KfQoKU2V0LUFsaWFzIGludiBQcm9jZXNzLVRyYW5zcGFyZW5jeQ==")))
# ========================================END=OF=COMPILER===========================================================|
$Ver = '1.0'
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
$Script:BlackListFunctions = @{"IN-Code-Debug-Console"=1;"Get-APIKey"=1;"Get-GMAIL"="1"}
#$BEG = "((^|[\(;\=])( ?)+)";$END = "( ?)+((\S+ )+(\S+))?([;\)\(""]|$)"  | "$BEG$([Regex]::Escape($_))$END"
foreach ($Ln in $Data) {
    if ($LN -match "^ +function.+\b(?<Name>\w+)\b( ?)+{") {$OtroFunc += @{$Matches.Name = "Added"};continue}
    $Modules | ? {$LN -match "\b$([Regex]::Escape($_))\b"} | % {$Need2Import.$_++}
    $Aliases | ? {$LN -match "$([Regex]::Escape($_))"} | % {$Need2ImportAL.$_++;$Need2Import.((Get-Alias $_).Definition)++}
}
$FinalSet = @($Need2Import.Keys) | ? {!$OtroFunc.$_}
$FinalSet+= "AP-Require"
$FinalAlSet = @($Need2ImportAL.Keys) | select -unique
$Code = $FinalSet | % {"function $_ {1}{0}{2}" -f $(if ($BlackListFunctions.$_) {"Write-Host -f yellow '[AP-COMPILER] Module [$_] disabled for this program'"} else {iex "`${Function:$_}"}),"{","}`n"}
$Code += $FinalAlSet | % {"Set-Alias $_ {0}" -f ((Get-Alias $_).Definition)}
if ($Code) {
if ($FinalSet) {Write-AP "*Adding Functions $(Print-List $FinalSet)"}
if ($FinalALSet) {Write-AP "*Adding Aliases   $(Print-List $FinalALSet)"}
$Injecter = @"
# =======================================START=OF=COMPILER==========================================================|
#    The Following Code was added by AP-Compiler Version [$Ver] To Make this program independent of AP-Core Engine
# ==================================================================================================================|
iex ([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("$(Convert-ToBase64 ($Code -join "`n"))")))
# ========================================END=OF=COMPILER===========================================================|
"@}
$Data = $Data -join "`n"
if ($Data -match "`n(?<ParamCode>Param( ?)+\(.*$Symb\)$Symb)") {
    $Data=$Data.replace($Matches['ParamCode'],"$($Matches['ParamCode'])`n$Injecter")
} elseif ($Data -match "`n(?<ParamCode>Param( ?)+\(.*\))") {
#    @($Data -match "(?<ParamCode>Param\(.*\))")[0] -match "(?<ParamCode>Param\(.*\))" | Out-Null;$Data=$Data.replace($Matches['ParamCode'],"$($Matches['ParamCode'])`n$Injecter")
    $Data=$Data.replace($Matches['ParamCode'],"$($Matches['ParamCode'])`n$Injecter")
} else {
    $Data = "$Injecter",$Data
}
$APStructure = (Flatten $Data) -join "`n"
if ((Split-Path $File) -eq $OutputFolder) {
    $Outfile = "$((Split-Path -leaf $File).replace('.ps1','-Compiled.ps1'))"
} else {$Outfile = "$(Split-Path -leaf $File)"}
Write-AP "+Compiled [$OutFile]"
$APStructure | Out-File -Encoding Unicode "$OutputFolder\$OutFile"
if ($PassThru) {return $code}
