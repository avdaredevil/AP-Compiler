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
    $) AP-Compiler Forced Commands (ap-compiler: Write-AP,AP-Require)
    $) AST Based Function / Alias / Class Resolution (including forced commands)
    $) Remove Old Compiler Code
    $) AP-Compiler Debug Mode
    $) Highly performant lexical scanner
    $) Mini AP-Console Shim for AP-Console Functions
    $) Detailed Logging, verbose debugging
|==============================================================================>|
#>
[CmdletBinding(DefaultParameterSetName = 'Compile')]
param(
    [Parameter(Mandatory=$True, ParameterSetName='Compile', Position = 0)]
    [Parameter(Mandatory=$True, ParameterSetName='Uncompile', Position = 0)]
    [String]$File,
    [Parameter(ParameterSetName='Compile', Position = 1)][String]$OutputFolder = '.',
    [Parameter(ParameterSetName='Compile')][switch]$OverwriteSrc,
    [Parameter(ParameterSetName='Compile')][switch]$ForceLinearLayout,
    [Switch]$Dbg,
    [Parameter(ParameterSetName='Uncompile')][Alias('Uncompile')][Switch]$Strip,
    [Parameter(ParameterSetName='Compile')][Switch]$PassThru
)
# =======================================START=OF=COMPILER================================================================|
#    The Following Code was added by AP-Compiler 1.6 (APC: 1.3) To Make this program independent of AP-Core Engine
#    GitHub: https://github.com/avdaredevil/AP-Compiler
# ========================================================================================================================|
$Script:PSHell=$(if($PSHell){$PSHell}elseif($PSScriptRoot){$PSScriptRoot}else{"."});
if($AP_CONSOLE.mode -ne 'main' -or $AP_CONSOLE.customFlags.runAsCompiled) {
    $Script:AP_CONSOLE = [PsCustomObject]@{version=[version]'1.3'; mode = 'shim'; customFlags = @{}}
    function B64 {param([Parameter(ValueFromPipeline=$true)][String]$Text, [ValidateSet("UTF8","Unicode")][String]$Encoding = "UTF8")     [System.Text.Encoding]::$Encoding.GetString([System.Convert]::FromBase64String($Text))}
    # This syntax is to prevent AV's from misclassifying this as anything but innocuous
    & (Get-Alias iex) (B64 "ZnVuY3Rpb24gSW52b2tlLU9yUmV0dXJuIHtwYXJhbShbUGFyYW1ldGVyKE1hbmRhdG9yeT0kdHJ1ZSwgVmFsdWVGcm9tUGlwZWxpbmU9JHRydWUsIFBvc2l0aW9uPTApXVtBbGxvd051bGwoKV0kQ29kZSwgW1BhcmFtZXRlcihWYWx1ZUZyb21SZW1haW5pbmdBcmd1bWVudHM9MSldJF9fUmVzdCwgW1N3aXRjaF0kQXNQcm9jZXNzQmxvY2spDQoNCiAgICBpZiAoISgkQ29kZSAtaXMgW1NjcmlwdEJsb2NrXSkpIHtyZXR1cm4gJENvZGV9DQogICAgaWYgKCEkQXNQcm9jZXNzQmxvY2spIHtyZXR1cm4gJiAkQ29kZSBAX19SZXN0fQ0KICAgIHJldHVybiBGb3JFYWNoLU9iamVjdCAtcHJvY2VzcyAkQ29kZSAtSW5wdXRPYmplY3QgJF9fUmVzdA0KfQoKZnVuY3Rpb24gR2V0LVdoZXJlIHsNCiAgICBbQ21kbGV0QmluZGluZyhEZWZhdWx0UGFyYW1ldGVyU2V0TmFtZT0iTm9ybWFsIildDQogICAgcGFyYW0oDQogICAgICAgIFtQYXJhbWV0ZXIoTWFuZGF0b3J5PSR0cnVlLCBQb3NpdGlvbj0wKV1bc3RyaW5nXSRGaWxlLA0KICAgICAgICBbU3dpdGNoXSRBbGwsDQogICAgICAgIFtQYXJhbWV0ZXIoUGFyYW1ldGVyU2V0TmFtZT0nTm9ybWFsJyldW1BhcmFtZXRlcihQYXJhbWV0ZXJTZXROYW1lPSdTY2FuJyldW1N3aXRjaF0kTWFudWFsU2NhbiwNCiAgICAgICAgW1BhcmFtZXRlcihQYXJhbWV0ZXJTZXROYW1lPSdTY2FuJyldW1N3aXRjaF0kRGJnLA0KICAgICAgICBbUGFyYW1ldGVyKFBhcmFtZXRlclNldE5hbWU9J1NjYW4nKV1bc3RyaW5nXSRQYXRoVmFyID0gIlBBVEgiDQogICAgKQ0KICAgICRJc1ZlcmJvc2UgPSAkRGJnIC1vciAkUFNDbWRsZXQuTXlJbnZvY2F0aW9uLkJvdW5kUGFyYW1ldGVycy5WZXJib3NlIC1vciAkUFNDbWRsZXQuTXlJbnZvY2F0aW9uLkJvdW5kUGFyYW1ldGVycy5EZWJ1Zw0KICAgICRXaGVyZUJpbkV4aXN0cyA9IEdldC1Db21tYW5kICJ3aGVyZSIgLWVhIFNpbGVudGx5Q29udGludWUNCiAgICAkSXNVbml4ID0gJFBTVmVyc2lvblRhYmxlLlBsYXRmb3JtIC1lcSAiVW5peCINCiAgICBpZiAoJEZpbGUgLWVxICJ3aGVyZSIgLW9yICRGaWxlIC1lcSAid2hlcmUuZXhlIikge3JldHVybiAkV2hlcmVCaW5FeGlzdHN9DQogICAgaWYgKCRXaGVyZUJpbkV4aXN0cyAtYW5kICEkTWFudWFsU2Nhbikgew0KICAgICAgICAkT3V0PSRudWxsDQogICAgICAgIGlmICgkSXNVbml4KSB7DQogICAgICAgICAgICAkT3V0ID0gd2hpY2ggJGZpbGUgMj4kbnVsbA0KICAgICAgICB9IGVsc2UgeyRPdXQgPSB3aGVyZS5leGUgJGZpbGUgMj4kbnVsbH0NCg0KICAgICAgICBpZiAoISRPdXQpIHtyZXR1cm59DQogICAgICAgIGlmICgkQWxsKSB7cmV0dXJuICRPdXR9DQogICAgICAgIHJldHVybiBAKCRPdXQpWzBdDQogICAgfQ0KICAgIGZvcmVhY2ggKCRGb2xkZXIgaW4gKEdldC1QYXRoIC1QYXRoVmFyICRQYXRoVmFyKSkgew0KICAgICAgICBpZiAoJElzVW5peCkgew0KICAgICAgICAgICAgJExvb2t1cCA9ICIkRm9sZGVyLyRGaWxlIg0KICAgICAgICAgICAgaWYgKCRJc1ZlcmJvc2UpIHtXcml0ZS1BUCAiKkNoZWNraW5nIFskTG9va3VwXSJ9DQogICAgICAgICAgICBpZiAoIShUZXN0LVBhdGggLVBhdGhUeXBlIExlYWYgJExvb2t1cCkpIHtjb250aW51ZX0NCiAgICAgICAgICAgIFJlc29sdmUtUGF0aCAkTG9va3VwIHwgJSBQYXRoDQogICAgICAgICAgICBpZiAoISRBbGwpIHtyZXR1cm59DQogICAgICAgIH0gZWxzZSB7DQogICAgICAgICAgICBmb3JlYWNoICgkRXh0ZW5zaW9uIGluIChHZXQtUGF0aCAtUGF0aFZhciBQQVRIRVhUKSkgew0KICAgICAgICAgICAgICAgICRMb29rdXAgPSAiJEZvbGRlci8kRmlsZSRFeHRlbnNpb24iDQogICAgICAgICAgICAgICAgaWYgKCRJc1ZlcmJvc2UpIHtXcml0ZS1BUCAiKkNoZWNraW5nIFskTG9va3VwXSJ9DQogICAgICAgICAgICAgICAgaWYgKCEoVGVzdC1QYXRoIC1QYXRoVHlwZSBMZWFmICRMb29rdXApKSB7Y29udGludWV9DQogICAgICAgICAgICAgICAgUmVzb2x2ZS1QYXRoICRMb29rdXAgfCAlIFBhdGgNCiAgICAgICAgICAgICAgICBpZiAoISRBbGwpIHtyZXR1cm59DQogICAgICAgICAgICB9DQogICAgICAgIH0NCiAgICB9DQp9CgpmdW5jdGlvbiBHZXQtRmlsZUVuY29kaW5nIHtwYXJhbShbUGFyYW1ldGVyKE1hbmRhdG9yeT0kVHJ1ZSldJFBhdGgpDQoNCiAgICAkYnl0ZXMgPSBbYnl0ZVtdXShHZXQtQ29udGVudCAkUGF0aCAtQXNCeXRlU3RyZWFtIC1SZWFkQ291bnQgNCAtVG90YWxDb3VudCA0KQ0KDQogICAgaWYoISRieXRlcykgeyByZXR1cm4gJ3V0ZjgnIH0NCg0KICAgIHN3aXRjaCAtcmVnZXggKCd7MDp4Mn17MTp4Mn17Mjp4Mn17Mzp4Mn0nIC1mICRieXRlc1swXSwkYnl0ZXNbMV0sJGJ5dGVzWzJdLCRieXRlc1szXSkgew0KICAgICAgICAnXmVmYmJiZicgICB7cmV0dXJuICd1dGY4J30NCiAgICAgICAgJ14yYjJmNzYnICAge3JldHVybiAndXRmNyd9DQogICAgICAgICdeZmZmZScgICAgIHtyZXR1cm4gJ3VuaWNvZGUnfQ0KICAgICAgICAnXmZlZmYnICAgICB7cmV0dXJuICdiaWdlbmRpYW51bmljb2RlJ30NCiAgICAgICAgJ14wMDAwZmVmZicge3JldHVybiAndXRmMzInfQ0KICAgICAgICBkZWZhdWx0ICAgICB7cmV0dXJuICdhc2NpaSd9DQogICAgfQ0KfQoKZnVuY3Rpb24gQWxpZ24tVGV4dCB7DQogICAgW0NtZGxldEJpbmRpbmcoKV0NCiAgICBbT3V0cHV0VHlwZShbU3RyaW5nXSwgW0hhc2h0YWJsZV0pXQ0KICAgIHBhcmFtKA0KICAgICAgICBbUGFyYW1ldGVyKE1hbmRhdG9yeT0xLCBWYWx1ZUZyb21QaXBlbGluZT0xKV1bU3RyaW5nW11dJFRleHQsDQogICAgICAgIFtzd2l0Y2hdJENvbG9yQ29kZXNEaXNjcmV0ZVBlckxpbmUsDQogICAgICAgIFtzd2l0Y2hdJFBvcmNlbGFpbiwNCiAgICAgICAgIyBUaGlzIGNhbiBiZSBbaW50XSBvciBbc2NyaXB0YmxvY2tdDQogICAgICAgICRDb25zdHJhaW5Ub1dpZHRoLA0KICAgICAgICBbVmFsaWRhdGVTZXQoIkNlbnRlciIsIlJpZ2h0IiwiTGVmdCIpXVtTdHJpbmddJEFsaWduPSdDZW50ZXInDQogICAgKQ0KICAgIGJlZ2luIHsNCiAgICAgICAgJGlzVmVyYm9zZSA9ICRQU0NtZGxldC5NeUludm9jYXRpb24uQm91bmRQYXJhbWV0ZXJzLlZlcmJvc2UNCiAgICAgICAgJEVzY2FwZUNvZGVTcGxpdHRlciA9ICIkKFtyZWdleF06OmVzY2FwZSgiJChHZXQtRXNjYXBlKVsiKSlcZCsoPzpcO1xkKykqbSINCiAgICAgICAgJERpdmlkZXJzID0gQHtjaHVuayA9IHUgImB1ezExMjg4fSI7IHN0eWxlID0gdSAiYHV7MTIyODh9In0NCiAgICAgICAgJEZpbmFsRm9ybWF0dGVyID0gew0KICAgICAgICAgICAgcGFyYW0oJExpbmVzLCAkU3R5bGVzKQ0KICAgICAgICAgICAgaWYgKCEkUG9yY2VsYWluKSB7cmV0dXJuICRMaW5lc30NCiAgICAgICAgICAgIGlmICgkbnVsbCAtZXEgJFN0eWxlcykgeyRTdHlsZXMgPSBbUmVnZXhdOjpNYXRjaGVzKCgkTGluZXMgLWpvaW4gIiIpLCAkRXNjYXBlQ29kZVNwbGl0dGVyKS52YWx1ZX0NCiAgICAgICAgICAgIHJldHVybiBAe0xpbmVzID0gJExpbmVzOyBSdW5uaW5nU3R5bGVzID0gJFN0eWxlc30NCiAgICAgICAgfQ0KICAgIH0NCiAgICBwcm9jZXNzIHsNCiAgICAgICAgaWYgKCRBbGlnbiAtZXEgIkxlZnQiKSB7cmV0dXJuICYgJEZpbmFsRm9ybWF0dGVyICRUZXh0fQ0KICAgICAgICBpZiAoISIkVGV4dCIudHJpbSgpKSB7cmV0dXJuICRUZXh0fQ0KICAgICAgICAkV2luU2l6ZSA9ID86ICRDb25zdHJhaW5Ub1dpZHRoIHtJbnZva2UtT3JSZXR1cm4gJENvbnN0cmFpblRvV2lkdGh9IChbY29uc29sZV06OkJ1ZmZlcldpZHRoKQ0KICAgICAgICANCiAgICAgICAgJFRleHQgPSAkVGV4dCAtc3BsaXQgImByP2BuIg0KICAgICAgICBpZiAoJFRleHQuY291bnQgLWd0IDEpIHsNCiAgICAgICAgICAgICRMaW5lcyA9ICRUZXh0IHwgQWxpZ24tVGV4dCAtQWxpZ24gJEFsaWduIC1Db2xvckNvZGVzRGlzY3JldGVQZXJMaW5lOiRDb2xvckNvZGVzRGlzY3JldGVQZXJMaW5lIC1Qb3JjZWxhaW4NCiAgICAgICAgICAgIGlmICgkQ29sb3JDb2Rlc0Rpc2NyZXRlUGVyTGluZSkgew0KICAgICAgICAgICAgICAgIGZvciAoJGkgPSAxOyAkaSAtbHQgJExpbmVzLkNvdW50OyAkaSsrKSB7DQogICAgICAgICAgICAgICAgICAgICRMaW5lID0gJExpbmVzWyRpXQ0KICAgICAgICAgICAgICAgICAgICAkUHJldlN0eWxlcyArPSAkTGluZXNbJGkgLSAxXS5SdW5uaW5nU3R5bGVzDQogICAgICAgICAgICAgICAgICAgICRMaW5lLkxpbmVzID0gJExpbmUuTGluZXMgfCAlIHsiJFByZXZTdHlsZXMkXyJ9DQogICAgICAgICAgICAgICAgICAgICRMaW5lLlJ1bm5pbmdTdHlsZXMgPSAiJFByZXZTdHlsZXMkKCRMaW5lLlJ1bm5pbmdTdHlsZXMpIg0KICAgICAgICAgICAgICAgIH0NCiAgICAgICAgICAgIH0NCiAgICAgICAgICAgIHJldHVybiAmICRGaW5hbEZvcm1hdHRlciAoRmxhdHRlbiAkTGluZXMuTGluZXMpICgkTGluZXMuUnVubmluZ1N0eWxlcyAtam9pbiAiIikNCiAgICAgICAgfQ0KICAgICAgICAjIFNpbmdsZSBub24gYG4gbGluZSBwcm9jZXNzDQogICAgICAgICRDbGVhblRleHRTaXplID0gKFN0cmlwLUNvbG9yQ29kZXMgKCIiKyRUZXh0KSkuTGVuZ3RoDQoNCiAgICAgICAgIyA9PT09PT09PSBMaW5lIGlzIDwgJFdpblNpemUgPT09PT09PT09PT09PT18DQogICAgICAgIGlmICgkQ2xlYW5UZXh0U2l6ZSAtbGUgJFdpblNpemUpIHsNCiAgICAgICAgICAgIGlmICgkQWxpZ24gLWVxICJDZW50ZXIiKSB7DQogICAgICAgICAgICAgICAgcmV0dXJuICYgJEZpbmFsRm9ybWF0dGVyICgiICIqW21hdGhdOjp0cnVuY2F0ZSgoJFdpblNpemUtJENsZWFuVGV4dFNpemUpLzIpKyRUZXh0KQ0KICAgICAgICAgICAgfQ0KICAgICAgICAgICAgIyBSaWdodA0KICAgICAgICAgICAgcmV0dXJuICYgJEZpbmFsRm9ybWF0dGVyICgiICIqKCRXaW5TaXplLSRDbGVhblRleHRTaXplKSskVGV4dCkNCiAgICAgICAgfQ0KDQogICAgICAgICMgPT09PT09PT0gTGluZSBpcyA+PSAkV2luU2l6ZSA9PT09PT09PT09PT09PXwNCiAgICAgICAgIyBUcmFja2luZyBTdHlsZXMNCiAgICAgICAgJFJ1bm5pbmdTdHlsZXMgPSAiIg0KICAgICAgICAkQ3VycmxpbmUgPSBAew0KICAgICAgICAgICAgc3R5bGVkRGF0YSA9ICIiDQogICAgICAgICAgICBjb250ZW50U2l6ZSA9IDANCiAgICAgICAgICAgIGZpbmFsTGluZXMgPSBAKCkNCiAgICAgICAgICAgIG5leHQgPSB7DQogICAgICAgICAgICAgICAgIyBXcml0ZS1WZXJib3NlICIqJEludm9rIHwgTmV3IExpbmUgfCBMaW5lRGF0YTogJCgoJycrJEN1cnJsaW5lLnN0eWxlZERhdGEuTGVuZ3RoKS5QYWRMZWZ0KDMpKSINCiAgICAgICAgICAgICAgICAkQ3VycmxpbmUuZmluYWxMaW5lcyArPSAsJEN1cnJsaW5lLnN0eWxlZERhdGENCiAgICAgICAgICAgICAgICAkQ3VycmxpbmUuc3R5bGVkRGF0YSA9ICRSdW5uaW5nU3R5bGVzDQogICAgICAgICAgICAgICAgJEN1cnJsaW5lLmNvbnRlbnRTaXplID0gMA0KICAgICAgICAgICAgICAgICMgV3JpdGUtVmVyYm9zZSAiKiRJbnZvayB8IEN1cnIgVG90YWwgTGluZXM6ICQoJGN1cnJsaW5lLmZpbmFsTGluZXMuQ291bnQpIg0KICAgICAgICAgICAgfQ0KICAgICAgICB9DQogICAgICAgICRBbGxDaHVua3MgPSAkVGV4dCAtcmVwbGFjZSAiKCR7RXNjYXBlQ29kZVNwbGl0dGVyfSkrKC4qPykoPz0ke0VzY2FwZUNvZGVTcGxpdHRlcn18JCkiLCIkKCREaXZpZGVycy5jaHVuaylgJDEkKCREaXZpZGVycy5zdHlsZSlgJDIiIC1zcGxpdCAkRGl2aWRlcnMuY2h1bmsNCiAgICAgICAgaWYgKCRBbGxDaHVua3NbMF0gLW5vdGNvbnRhaW5zICREaXZpZGVycy5zdHlsZSkgeyRBbGxDaHVua3NbMF0gPSAiJCgkRGl2aWRlcnMuc3R5bGUpJCgkQWxsQ2h1bmtzWzBdKSJ9ICMgVGhlIGZpcnN0IGNodW5rIGNvdWxkIGhhdmUgbm8gc3R5bGVzDQogICAgICAgIGZvcmVhY2ggKCRDdXJyQ2h1bmsgaW4gJEFsbENodW5rcykgew0KICAgICAgICAgICAgJFN0eWxlLCRUZXh0Q2h1bmsgPSAkQ3VyckNodW5rIC1zcGxpdCAkRGl2aWRlcnMuc3R5bGUNCiAgICAgICAgICAgICRSdW5uaW5nU3R5bGVzID0gPzogJENvbG9yQ29kZXNEaXNjcmV0ZVBlckxpbmUgIiRSdW5uaW5nU3R5bGVzJFN0eWxlIiAkU3R5bGUNCiAgICAgICAgICAgICMgV3JpdGUtSG9zdCAtZiAyICgiSW5jb21pbmdTdHlsZTogJFN0eWxlIHwgUnVubmluZ1N0eWxlczogJFJ1bm5pbmdTdHlsZXMiIC1yZXBsYWNlIChbcmVnZXhdOjpFc2NhcGUoJChHZXQtRXNjYXBlKSkpLCdcZScpDQogICAgICAgICAgICAjIFdyaXRlLUhvc3QgLWYgWWVsbG93ICJUZXh0Q2h1bms6ICRUZXh0Q2h1bmsiDQogICAgICAgICAgICAkQ3VycmxpbmUuc3R5bGVkRGF0YSArPSAkUnVubmluZ1N0eWxlcw0KICAgICAgICAgICAgJFRleHRDaHVua1N0ckluZGV4ID0gMA0KICAgICAgICAgICAgIyBXcml0ZS1WZXJib3NlICIqJEludm9rIHwgVGV4dENodW5rOiAkVGV4dENodW5rIHwgQWxsQ2h1bmtzU2l6ZTogJCgoJycrJEFsbENodW5rcy5MZW5ndGgpLlBhZExlZnQoMykpIg0KICAgICAgICAgICAgd2hpbGUoJFRleHRDaHVua1N0ckluZGV4IC1sdCAkVGV4dENodW5rLkxlbmd0aCkgew0KICAgICAgICAgICAgICAgIGlmICgkaXNWZXJib3NlKSB7UGxhY2UtQnVmZmVyZWRDb250ZW50ICgiJEludm9rIHwgTGluZURhdGE6ICQoKCcnKyRDdXJybGluZS5zdHlsZWREYXRhLkxlbmd0aCkuUGFkTGVmdCgzKSkgfCBDaHVua0lkeDogJCgoJycrJFRleHRDaHVua1N0ckluZGV4KS5QYWRMZWZ0KDMpKSB8IENodW5rTGVuOiAkKCRUZXh0Q2h1bmsuTGVuZ3RoKSB8IEZpbmFsTGluZXM6ICQoJEN1cnJsaW5lLmZpbmFsTGluZXMuQ291bnQpIikgLXggMCAteSAoW0NvbnNvbGVdOjpCdWZmZXJIZWlnaHQgLSAxKSBZZWxsb3cgRGFya0dyYXl9DQogICAgICAgICAgICAgICAgJENodW5rU2l6ZSA9ICRUZXh0Q2h1bmsuTGVuZ3RoIC0gJFRleHRDaHVua1N0ckluZGV4DQogICAgICAgICAgICAgICAgIyBXcml0ZS1WZXJib3NlICIqQ2h1bmtTaXplOiAkQ2h1bmtTaXplIg0KICAgICAgICAgICAgICAgIGlmICgoJEN1cnJsaW5lLmNvbnRlbnRTaXplKyRDaHVua1NpemUpIC1sdCAkV2luU2l6ZSkgew0KICAgICAgICAgICAgICAgICAgICAjIElmIHRoZSBjdXJyZW50IGNodW5rIGZpdHMgaW4gdGhlIGN1cnJlbnQgbGluZQ0KICAgICAgICAgICAgICAgICAgICAkQ3VycmxpbmUuc3R5bGVkRGF0YSArPSAkVGV4dENodW5rLlN1YnN0cmluZygkVGV4dENodW5rU3RySW5kZXgpDQogICAgICAgICAgICAgICAgICAgICRDdXJybGluZS5jb250ZW50U2l6ZSArPSAkQ2h1bmtTaXplDQogICAgICAgICAgICAgICAgICAgICRUZXh0Q2h1bmtTdHJJbmRleCArPSAkQ2h1bmtTaXplDQogICAgICAgICAgICAgICAgICAgIGNvbnRpbnVlDQogICAgICAgICAgICAgICAgfQ0KICAgICAgICAgICAgICAgICMgSWYgdGhlIGN1cnJlbnQgY2h1bmsgZG9lc24ndCBmaXQgaW4gdGhlIGN1cnJlbnQgbGluZQ0KICAgICAgICAgICAgICAgICRuZXdDb250ZW50ID0gJFRleHRDaHVuay5TdWJzdHJpbmcoJFRleHRDaHVua1N0ckluZGV4LCAkV2luU2l6ZS0kQ3VycmxpbmUuY29udGVudFNpemUpDQogICAgICAgICAgICAgICAgJEN1cnJsaW5lLnN0eWxlZERhdGEgKz0gJG5ld0NvbnRlbnQNCiAgICAgICAgICAgICAgICAkQ3VycmxpbmUuY29udGVudFNpemUgKz0gJG5ld0NvbnRlbnQubGVuZ3RoDQogICAgICAgICAgICAgICAgJFRleHRDaHVua1N0ckluZGV4ICs9ICRuZXdDb250ZW50Lmxlbmd0aA0KICAgICAgICAgICAgICAgICYgJEN1cnJsaW5lLm5leHQNCiAgICAgICAgICAgIH0NCiAgICAgICAgfQ0KICAgICAgICBpZiAoJEN1cnJsaW5lLmNvbnRlbnRTaXplIC1ndCAwKSB7DQogICAgICAgICAgICBpZiAoJEN1cnJsaW5lLmNvbnRlbnRTaXplKXsNCiAgICAgICAgICAgICAgICBBbGlnbi1UZXh0IC1BbGlnbiAkQWxpZ24gLVRleHQgJEN1cnJsaW5lLnN0eWxlZERhdGEgLUNvbG9yQ29kZXNEaXNjcmV0ZVBlckxpbmU6JENvbG9yQ29kZXNEaXNjcmV0ZVBlckxpbmUgfCA/IHskX30gfCAlIHsNCiAgICAgICAgICAgICAgICAgICAgJEN1cnJsaW5lLmZpbmFsTGluZXMgKz0gLCRfDQogICAgICAgICAgICAgICAgfQ0KICAgICAgICAgICAgfSBlbHNlIHsNCiAgICAgICAgICAgICAgICAkQ3VycmxpbmUuZmluYWxMaW5lc1stMV0gKz0gJEN1cnJsaW5lLnN0eWxlZERhdGENCiAgICAgICAgICAgIH0NCiAgICAgICAgfQ0KICAgICAgICByZXR1cm4gJiAkRmluYWxGb3JtYXR0ZXIgJEN1cnJsaW5lLmZpbmFsTGluZXMgJFJ1bm5pbmdTdHlsZXMNCiAgICAgICAgcmV0dXJuICRDdXJybGluZS5maW5hbExpbmVzDQogICAgfQ0KfQoKZnVuY3Rpb24gR2V0LUNvbG9yIHsNCiAgICA8IyAgLkRlc2NyaXB0aW9uDQogICAgICAgIEZldGNoZXMgYmFzaWMgY29sb3JzIHVzaW5nIHRoZSBVbmljb2RlIEVzY2FwZSBzZXF1ZW5jZXMNCiAgICAjPg0KICAgIHBhcmFtICgNCiAgICAgICAgW1ZhbGlkYXRlU2V0KA0KICAgICAgICAgICAgJ3InLCdyZXNldCcsJ3JTJywncmVzZXRTdHlsZXMnLCdkJywnZGltJywncycsJ3N0cmlrZScsJ3UnLCd1bmRlcmxpbmUnLCdiJywnYm9sZCcsJ2knLCdpdGFsaWMnLCdibCcsJ2JsaW5rJywncmV2ZXJzZScsJ2gnLCdoaWRkZW4nLA0KICAgICAgICAgICAgJ0JsYWNrJywnRGFya0JsdWUnLCdEYXJrR3JlZW4nLCdEYXJrQ3lhbicsJ0RhcmtSZWQnLCdEYXJrTWFnZW50YScsJ0RhcmtZZWxsb3cnLCdHcmF5JywnRGFya0dyYXknLCdCbHVlJywnR3JlZW4nLCdDeWFuJywnUmVkJywnTWFnZW50YScsJ1llbGxvdycsJ1doaXRlJywNCiAgICAgICAgICAgICdiZy5CbGFjaycsJ2JnLkRhcmtCbHVlJywnYmcuRGFya0dyZWVuJywnYmcuRGFya0N5YW4nLCdiZy5EYXJrUmVkJywnYmcuRGFya01hZ2VudGEnLCdiZy5EYXJrWWVsbG93JywnYmcuR3JheScsJ2JnLkRhcmtHcmF5JywnYmcuQmx1ZScsJ2JnLkdyZWVuJywnYmcuQ3lhbicsJ2JnLlJlZCcsJ2JnLk1hZ2VudGEnLCdiZy5ZZWxsb3cnLCdiZy5XaGl0ZScNCiAgICAgICAgKV1bU3RyaW5nW11dJENvZGUsDQogICAgICAgIFtBbGlhcygnYmcnKV1bU3dpdGNoXSRCYWNrZ3JvdW5kLA0KICAgICAgICBbU3dpdGNoXSRDb2RlU3RyaW5nDQogICAgKQ0KICAgIGlmICgkQVBfQ09OU09MRS5jdXN0b21GbGFncy5ub1VuaXhFc2NhcGVzKSB7cmV0dXJufQ0KICAgICRBbGlhc1RhYmxlID0gQHt1ID0gJ3VuZGVybGluZSc7YiA9ICdib2xkJztpID0gJ2l0YWxpYyc7ciA9ICdyZXNldCc7clMgPSAncmVzZXRTdHlsZXMnO3MgPSAnc3RyaWtlJztkID0gJ2RpbSc7YmwgPSAnYmxpbmsnO2ggPSAnaGlkZGVuJ30NCiAgICBpZiAoISRHbG9iYWw6QVBfQ09MT1JfVEFCTEUpIHsNCiAgICAgICAgJFRCTCA9ICRHbG9iYWw6QVBfQ09MT1JfVEFCTEUgPSBAe3Jlc2V0ID0gMDtib2xkID0gMTtkaW0gPSAyO2l0YWxpYyA9IDM7dW5kZXJsaW5lID0gNDtibGluayA9IDU7cmV2ZXJzZSA9IDc7aGlkZGVuID0gODtzdHJpa2UgPSA5O3Jlc2V0U3R5bGVzID0gJzIyOzIzOzI0OzI1OzI3OzI4OzI5J30NCiAgICAgICAgMCwxIHwgJSB7DQogICAgICAgICAgICAkQmdJbmRleCA9ICRfDQogICAgICAgICAgICAwLDEgfCAlIHsNCiAgICAgICAgICAgICAgICAkU3BjSW5kZXggPSAkXw0KICAgICAgICAgICAgICAgICRpID0gMA0KICAgICAgICAgICAgICAgICdCbGFjay5UfFJlZHxHcmVlbnxZZWxsb3d8Qmx1ZXxNYWdlbnRhfEN5YW58V2hpdGUnLnNwbGl0KCd8JykgfCAlIHsNCiAgICAgICAgICAgICAgICAgICAgJEluY3IgPSAkQmdJbmRleCAqIDEwDQogICAgICAgICAgICAgICAgICAgICRDb2xOYW1lID0gKCgnJywnYmcuJylbJEJnSW5kZXhdKSsoKCdEYXJrJywnJylbJFNwY0luZGV4XSkrJF8NCiAgICAgICAgICAgICAgICAgICAgJENvbFNwYWNlID0gKDMwLCA5MClbJFNwY0luZGV4XSArICRJbmNyDQogICAgICAgICAgICAgICAgICAgICRUQkwuJENvbE5hbWUgPSAkQ29sU3BhY2UrKCRpKyspDQogICAgICAgICAgICAgICAgfQ0KICAgICAgICAgICAgfQ0KICAgICAgICB9DQogICAgICAgIEB7RGFya0dyYXkgPSAnQmxhY2suVCc7QmxhY2sgPSAnRGFya0JsYWNrLlQnO0dyYXkgPSAnRGFya1doaXRlJ30uR2V0RW51bWVyYXRvcigpIHwgJSB7DQogICAgICAgICAgICAkVEJMLigkXy5LZXkpID0gJFRCTC4oJF8uVmFsdWUpDQogICAgICAgICAgICAkVEJMLignYmcuJyskXy5LZXkpID0gJFRCTC4oJ2JnLicrJF8uVmFsdWUpDQogICAgICAgICAgICAkVEJMLnJlbW92ZSgkXy5WYWx1ZSkNCiAgICAgICAgICAgICRUQkwucmVtb3ZlKCdiZy4nKyRfLlZhbHVlKQ0KICAgICAgICB9DQogICAgfQ0KICAgICRDb2RlcyA9ICgkQ29kZSskQXJncyB8ICUgew0KICAgICAgICAkR2xvYmFsOkFQX0NPTE9SX1RBQkxFLihKUy1PUiAkQWxpYXNUYWJsZS4kXyAkXykNCiAgICB9KSAtam9pbiAnOycNCiAgICBpZiAoJENvZGVTdHJpbmcpIHtyZXR1cm4gJENvZGVzfQ0KICAgIHJldHVybiAiJChHZXQtRXNjYXBlKVske0NvZGVzfW0iDQp9CgpmdW5jdGlvbiBGbGF0dGVuIHtwYXJhbShbb2JqZWN0W11dJHgpDQoNCiAgICBpZiAoISgkWCAtaXMgW2FycmF5XSkpIHtyZXR1cm4gJHh9DQogICAgaWYgKCRYLmNvdW50IC1lcSAxKSB7DQogICAgICAgIHJldHVybiAkeCB8ICUgeyRffQ0KICAgIH0NCiAgICAkeCB8ICUge0ZsYXR0ZW4gJF99DQp9CgpmdW5jdGlvbiBKUy1PUiB7Zm9yZWFjaCAoJGEgaW4gJGFyZ3MpIHskciA9IEludm9rZS1PclJldHVybiAkYTtpZiAoISRyKXtjb250aW51ZX07cmV0dXJuICRyfTtyZXR1cm4gJHJ9CgpmdW5jdGlvbiBDb252ZXJ0LVRvQmFzZTY0IHtwYXJhbShbUGFyYW1ldGVyKFZhbHVlRnJvbVBpcGVsaW5lPSR0cnVlKV1bU3RyaW5nXSRUZXh0LCBbVmFsaWRhdGVTZXQoIlVURjgiLCJVbmljb2RlIildW1N0cmluZ10kRW5jb2RpbmcgPSAiVVRGOCIpDQoNCiAgICBbU3lzdGVtLkNvbnZlcnRdOjpUb0Jhc2U2NFN0cmluZyhbU3lzdGVtLlRleHQuRW5jb2RpbmddOjokRW5jb2RpbmcuR2V0Qnl0ZXMoJFRleHQpKQ0KfQoKZnVuY3Rpb24gSW52b2tlLVRlcm5hcnkge3BhcmFtKCRkZWNpZGVyLCAkaWZ0cnVlLCAkaWZmYWxzZSA9IHt9KQ0KDQogICAgJEludm9rZU9yUmV0dXJuID0gew0KICAgICAgICBwYXJhbSgkQ21kKQ0KICAgICAgICBpZiAoJENtZCAtaXMgW1NjcmlwdEJsb2NrXSkgeyYgJENtZH0gZWxzZSB7JENtZH0NCiAgICB9DQogICAgaWYgKCRkZWNpZGVyKSB7ICYgJEludm9rZU9yUmV0dXJuICRpZnRydWUgfSBlbHNlIHsgJiAkSW52b2tlT3JSZXR1cm4gJGlmZmFsc2UgfQ0KfQoKZnVuY3Rpb24gV3JpdGUtQVBMIHsNCiAgICBbQ21kbGV0QmluZGluZygpXQ0KICAgIHBhcmFtKA0KICAgICAgICBbUGFyYW1ldGVyKFZhbHVlRnJvbVBpcGVsaW5lPSR0cnVlLCBNYW5kYXRvcnk9JFRydWUpXSRUZXh0LA0KICAgICAgICBbQWxpYXMoJ05TJyldW1N3aXRjaF0kTm9TaWduLA0KICAgICAgICBbQWxpYXMoJ05OTCcsJ05MJyldW1N3aXRjaF0kTm9OZXdMaW5lLA0KICAgICAgICBbU3dpdGNoXSRQYXNzVGhydQ0KICAgICkNCiAgICBiZWdpbiB7DQogICAgICAgICRTaWduUmd4ID0gIltcK1wtXCFcKlwjXEBfXSI7ICRUVCA9IEAoKQ0KICAgICAgICAkSXNWZXJib3NlID0gJFBTQ21kbGV0Lk15SW52b2NhdGlvbi5Cb3VuZFBhcmFtZXRlcnMuVmVyYm9zZQ0KICAgIH0NCiAgICBwcm9jZXNzIHtGbGF0dGVuICRUZXh0IHwgJSB7DQogICAgICAgICRMaW5lID0gJF8gLXNwbGl0ICJgbiINCiAgICAgICAgJExpbmVTeW1ib2wgPSAkKGlmICgkbGluZVswXSAtbWF0Y2ggIl5uP3g/bj8oXD4qKSgkU2lnblJneCkuKiQiKSB7JE1hdGNoZXNbMl19IGVsc2UgeyIifSkNCiAgICAgICAgaWYgKCRJc1ZlcmJvc2UpIHtXcml0ZS1WZXJib3NlICIkKGNvbCBpKUxpbmVTeW1ib2w6ICRMaW5lU3ltYm9sIHwgTGluZTogJExpbmUkKGNvbCByUykifQ0KICAgICAgICAxLi4kTGluZS5MZW5ndGggfCAlIHsNCiAgICAgICAgICAgICRpZHggPSAkXyAtIDENCiAgICAgICAgICAgIGlmICgkaWR4KSB7JFRUICs9ICJgbiIrJExpbmVTeW1ib2wrJExpbmVbJGlkeF19DQogICAgICAgICAgICBlbHNlIHskVFQgKz0gJExpbmVbJGlkeF19DQogICAgICAgIH0NCiAgICB9fQ0KICAgIGVuZCB7DQogICAgICAgIGlmICgkSXNWZXJib3NlKSB7V3JpdGUtVmVyYm9zZSAiJChjb2wgaSkkKFByaW50LUxpc3QgJFRUKSQoY29sIHJTKSJ9DQogICAgICAgIGZvciAoJGk9MDskaSAtbHQgJFRULmNvdW50OyRpKyspIHsNCiAgICAgICAgICAgIFtzdHJpbmddJENodW5rID0gJFRUWyRpXQ0KICAgICAgICAgICAgaWYgKCRDaHVua1swXSAtZXEgImBuIikgeyRDaHVuayA9ICRDaHVuay5TdWJzdHJpbmcoMSk7V3JpdGUtSG9zdH0gIyBTcGVjaWFsIGNhc2UgZm9yIG5ldyBsaW5lIHZpYSBgbg0KICAgICAgICAgICAgJENodW5rID0gJENodW5rIC1yZXBsYWNlICJebj94P24/KFw+KiRTaWduUmd4KSIsJyQxJw0KICAgICAgICAgICAgaWYgKCRDaHVuayAtbm90bWF0Y2ggIl5cPiokU2lnblJneC4qIikgeyRDaHVuayA9ICJfJENodW5rIn0gIyBVc2UgZGVmYXVsdCBhcyB3aGl0ZQ0KICAgICAgICAgICAgJFByZWZpeENvZGUgPSA/OiAoJGkgLWVxIDApIHsieCQoPzogJE5vU2lnbiB7J24nfSB7Jyd9KSJ9IHs/OiAoJGkgLW5lICgkVFQuQ291bnQgLSAxKSkgeyJueCJ9ICJuJCg/OiAkTm9OZXdMaW5lIHsneCd9IHsnJ30pIn0NCiAgICAgICAgICAgIGlmICgkVFQuQ291bnQgLWVxIDEpIHskUHJlZml4Q29kZSA9ICIkKD86ICROb1NpZ24geyduJ30geycnfSkkKD86ICROb05ld0xpbmUgeyd4J30geycnfSkifQ0KICAgICAgICAgICAgaWYgKCRJc1ZlcmJvc2UpIHtXcml0ZS1WZXJib3NlICIkKGNvbCBpKVByZWZpeENvZGU6ICRQcmVmaXhDb2RlIHwgQ2h1bms6ICRDaHVuayQoY29sIHJTKSJ9DQogICAgICAgICAgICBXcml0ZS1BUCAiJFByZWZpeENvZGUkQ2h1bmsiIC1QYXNzVGhydTokUGFzc1RocnUNCiAgICAgICAgfQ0KICAgIH0NCn0KCmZ1bmN0aW9uIEFQLVJlcXVpcmUge3BhcmFtKFtQYXJhbWV0ZXIoTWFuZGF0b3J5PSRUcnVlKV1bQWxpYXMoIkZ1bmN0aW9uYWxpdHkiLCJMaWJyYXJ5IildW0FyZ3VtZW50Q29tcGxldGVyKHsNCiAgICBbT3V0cHV0VHlwZShbU3lzdGVtLk1hbmFnZW1lbnQuQXV0b21hdGlvbi5Db21wbGV0aW9uUmVzdWx0XSldDQogICAgcGFyYW0oDQogICAgICAgIFtzdHJpbmddICRDb21tYW5kTmFtZSwNCiAgICAgICAgW3N0cmluZ10gJFBhcmFtZXRlck5hbWUsDQogICAgICAgIFtzdHJpbmddICRXb3JkVG9Db21wbGV0ZSwNCiAgICAgICAgW1N5c3RlbS5NYW5hZ2VtZW50LkF1dG9tYXRpb24uTGFuZ3VhZ2UuQ29tbWFuZEFzdF0gJENvbW1hbmRBc3QsDQogICAgICAgIFtTeXN0ZW0uQ29sbGVjdGlvbnMuSURpY3Rpb25hcnldICRGYWtlQm91bmRQYXJhbWV0ZXJzDQogICAgKQ0KICAgICRDb21wbGV0aW9uUmVzdWx0cyA9IFtTeXN0ZW0uQ29sbGVjdGlvbnMuR2VuZXJpYy5MaXN0W1N5c3RlbS5NYW5hZ2VtZW50LkF1dG9tYXRpb24uQ29tcGxldGlvblJlc3VsdF1dOjpuZXcoKQ0KICAgICRMaWIgPSBAKCJJbnRlcm5ldCIsIm9zOndpbmRvd3MiLCJvczpsaW51eCIsIm9zOnVuaXgiLCJhZG1pbmlzdHJhdG9yIiwicm9vdCIsImRlcDoiLCJsaWI6IiwibGliX3Rlc3Q6IiwibW9kdWxlOiIsIm1vZHVsZV90ZXN0OiIsImZ1bmN0aW9uOiIsInN0cmljdF9mdW5jdGlvbjoiLCJhYmlsaXR5OmVzY2FwZV9jb2RlcyIsImFiaWxpdHk6ZW1vamlzIiwiYWJpbGl0eTpsb25nX3BhdGhzIiwiYWJpbGl0eTpjb25zb2xlX21hbmlwdWxhdGlvbiIpDQogICAgJGpzT3IgPSB7Zm9yZWFjaCAoJGEgaW4gJGFyZ3MpIHskYSA9ICQoaWYoJGEgLWlzIFtzY3JpcHRibG9ja10peyYkYX1lbHNleyRhfSk7aWYgKCEkYSl7Y29udGludWV9O3JldHVybiAkYX07cmV0dXJuICRhfSAjIE1hbnVhbGx5IGVtYmVkZGVkIEpTLU9SDQogICAgJiAkanNPciB7JExpYiB8ID8geyRfIC1saWtlICIkV29yZFRvQ29tcGxldGUqIn19IHskTGliIHwgPyB7JF8gLWxpa2UgIiokV29yZFRvQ29tcGxldGUqIn19IHwgJSB7DQogICAgICAgICRDb21wbGV0aW9uUmVzdWx0cy5BZGQoW1N5c3RlbS5NYW5hZ2VtZW50LkF1dG9tYXRpb24uQ29tcGxldGlvblJlc3VsdF06Om5ldygkXywgJF8sICdQYXJhbWV0ZXJWYWx1ZScsICRfKSkNCiAgICB9DQogICAgcmV0dXJuICRDb21wbGV0aW9uUmVzdWx0cw0KfSldW1N0cmluZ10kTGliLCBbU2NyaXB0QmxvY2tdJE9uRmFpbCwgW1N3aXRjaF0kUGFzc1RocnUpDQoNCiAgICAkTG9hZE1vZHVsZSA9IHsNCiAgICAgICAgcGFyYW0oJEZpbGUsW2Jvb2xdJEltcG9ydCkNCiAgICAgICAgdHJ5IHtJbXBvcnQtTW9kdWxlICRGaWxlIC1lYSBzdG9wO3JldHVybiAxfSBjYXRjaCB7fQ0KICAgICAgICAkTGliPUFQLUNvbnZlcnRQYXRoICI8TElCPiI7JExGID0gIiRMaWJcJEZpbGUiDQogICAgICAgICRmID0gJExGLCIkTEYucHNtMSIsIiRMRi5kbGwiIHwgPyB7dGVzdC1wYXRoIC10IGxlYWYgJF99IHwgc2VsZWN0IC1mIDENCiAgICAgICAgaWYgKCRmIC1hbmQgJEltcG9ydCkgew0KICAgICAgICAgICAgSW1wb3J0LU1vZHVsZSAkZg0KICAgICAgICAgICAgaWYgKCQ/KSB7cmV0dXJuICRmfSBlbHNlIHtXcml0ZS1BUCAiIUZhaWxlZCB0byBpbXBvcnQgWyRGaWxlIC0+ICRGXSI7cmV0dXJuIDB9DQogICAgICAgIH0NCiAgICAgICAgcmV0dXJuICRmDQogICAgfQ0KICAgICRJbnZva2VPclJldHVybiA9IHtwYXJhbSgkQ21kKSBpZiAoJENtZCAtaXMgW1NjcmlwdEJsb2NrXSkgeyYgJENtZH0gZWxzZSB7JENtZH19DQogICAgaWYgKCEkT25GYWlsKSB7JFBhc3NUaHJ1ID0gJHRydWV9DQogICAgJFN0YXQgPSAkKHN3aXRjaCAtcmVnZXggKCRMaWIudHJpbSgpKSB7DQogICAgICAgICJeSW50ZXJuZXQkIiAgICAgICAgICAgICAgICAgICB7dGVzdC1jb25uZWN0aW9uIGdvb2dsZS5jb20gLUNvdW50IDEgLVF1aWV0fQ0KICAgICAgICAiXm9zOih3aW4oZG93cyk/fGxpbnV4fHVuaXgpJCIgeyRJc1VuaXggPSAkUFNWZXJzaW9uVGFibGUuUGxhdGZvcm0gLWVxICJVbml4IjtpZiAoJE1hdGNoZXNbMV0gLW1hdGNoICJed2luIikgeyEkSXNVbml4fSBlbHNlIHskSXNVbml4fX0NCiAgICAgICAgIl5hZG1pbihpc3RyYXRvcik/JHxecm9vdCQiICAgIHtUZXN0LUFkbWluaXN0cmF0b3J9DQogICAgICAgICJeZGVwOiguKikkIiAgICAgICAgICAgICAgICAgICB7R2V0LVdoZXJlICRNYXRjaGVzWzFdfQ0KICAgICAgICAiXihsaWJ8bW9kdWxlKTooLiopJCIgICAgICAgICAgeyRMb2FkTW9kdWxlLmludm9rZSgkTWF0Y2hlc1syXSwgJHRydWUpfQ0KICAgICAgICAiXihsaWJ8bW9kdWxlKV90ZXN0OiguKikkIiAgICAgeyRMb2FkTW9kdWxlLmludm9rZSgkTWF0Y2hlc1syXSl9DQogICAgICAgICJeZnVuY3Rpb246KC4qKSQiICAgICAgICAgICAgICB7Z2NtICRNYXRjaGVzWzFdIC1lYSBTaWxlbnRseUNvbnRpbnVlfQ0KICAgICAgICAiXnN0cmljdF9mdW5jdGlvbjooLiopJCIgICAgICAge1Rlc3QtUGF0aCAiRnVuY3Rpb246XCQoJE1hdGNoZXNbMV0pIn0NCiAgICAgICAgIl5hYmlsaXR5Oihlc2NhcGVfY29kZXN8ZW1vamlzfGxvbmdfcGF0aHN8Y29uc29sZV9tYW5pcHVsYXRpb24pJCIgICAgIHsmICRJbnZva2VPclJldHVybiAoQHsNCiAgICAgICAgICAgIGVzY2FwZV9jb2RlcyA9ICRIb3N0LlVJLlN1cHBvcnRzVmlydHVhbFRlcm1pbmFsDQogICAgICAgICAgICBlbW9qaXMgPSAkZW52OldUX1NFU1NJT04gLW9yICRlbnY6V1RfUFJPRklMRV9JRA0KICAgICAgICAgICAgbG9uZ19wYXRocyA9ICRQU1ZlcnNpb25UYWJsZS5QbGF0Zm9ybSAtZXEgIlVuaXgiIC1vciAoR2V0LUl0ZW1Qcm9wZXJ0eSAtUGF0aCAiSEtMTTpcU1lTVEVNXEN1cnJlbnRDb250cm9sU2V0XENvbnRyb2xcRmlsZVN5c3RlbSIgfCAlIGxvbmdwYXRoc2VuYWJsZWQpDQogICAgICAgICAgICBjb25zb2xlX21hbmlwdWxhdGlvbiA9ICFbU3lzdGVtLkNvbnNvbGVdOjpJc091dHB1dFJlZGlyZWN0ZWQgLWFuZCAoJEhvc3QuTmFtZSAtZXEgJ0NvbnNvbGVIb3N0JykNCiAgICAgICAgfVskTWF0Y2hlc1sxXV0pfQ0KICAgICAgICBkZWZhdWx0IHtXcml0ZS1BUCAiIUludmFsaWQgc2VsZWN0b3IgcHJvdmlkZWQgWyQoIiRMaWIiLnNwbGl0KCc6JylbMF0pXSI7dGhyb3cgJ0JBRF9TRUxFQ1RPUid9DQogICAgfSkNCiAgICBpZiAoISRTdGF0IC1hbmQgJE9uRmFpbCkgeyYgJE9uRmFpbH0NCiAgICBpZiAoJFBhc3NUaHJ1IC1vciAhJE9uRmFpbCkge3JldHVybiAkU3RhdH0NCn0KCmZ1bmN0aW9uIEFQLUNvbnZlcnRQYXRoIHtwYXJhbShbUGFyYW1ldGVyKE1hbmRhdG9yeT0kVHJ1ZSldW1N0cmluZ10kUGF0aCkNCg0KICAgICRQYXRoU2VwID0gW0lPLlBhdGhdOjpEaXJlY3RvcnlTZXBhcmF0b3JDaGFyDQogICAgcmV0dXJuICRQYXRoIC1yZXBsYWNlDQogICAgICAgICI8RGVwPiIsIjxMaWI+JHtQYXRoU2VwfURlcGVuZGVuY2llcyIgLXJlcGxhY2UNCiAgICAgICAgIjxMaWI+IiwiPEhvbWU+JHtQYXRoU2VwfUFQLUxpYnJhcmllcyIgLXJlcGxhY2UNCiAgICAgICAgIjxDb21wKG9uZW50cyk/PiIsIjxIb21lPiR7UGF0aFNlcH1BUC1Db21wb25lbnRzIiAtcmVwbGFjZQ0KICAgICAgICAiPEhvbWU+IiwkUFNIZWxsfQoKZnVuY3Rpb24gV3JpdGUtQVAgew0KICAgIFtDbWRsZXRCaW5kaW5nKCldDQogICAgcGFyYW0oW1BhcmFtZXRlcihWYWx1ZUZyb21QaXBlbGluZT0xLCBNYW5kYXRvcnk9MSldJFRleHQsW1N3aXRjaF0kTm9TaWduLFtTd2l0Y2hdJFBsYWluVGV4dCxbVmFsaWRhdGVTZXQoIkNlbnRlciIsIlJpZ2h0IiwiTGVmdCIpXVtTdHJpbmddJEFsaWduPSdMZWZ0JyxbU3dpdGNoXSRQYXNzVGhydSkNCiAgICBiZWdpbiB7JFRUID0gQCgpfQ0KICAgIFByb2Nlc3MgeyRUVCArPSAsJFRleHR9DQogICAgRU5EIHsNCiAgICAgICAgJEJsdWUgPSAkKGlmICgkQVBfQ09OU09MRS5jdXN0b21GbGFncy5sZWdhY3lDb2xvcnMpezN9ZWxzZXsnQmx1ZSd9KQ0KICAgICAgICBpZiAoJFRULmNvdW50IC1lcSAxKSB7JFRUID0gJFRUWzBdfTskVGV4dCA9ICRUVA0KICAgICAgICBpZiAoJHRleHQuY291bnQgLWd0IDEgLW9yICR0ZXh0LkdldFR5cGUoKS5OYW1lIC1tYXRjaCAiXFtcXSQiKSB7DQogICAgICAgICAgICByZXR1cm4gJFRleHQgfCAlIHsNCiAgICAgICAgICAgICAgICBXcml0ZS1BUCAkXyAtTm9TaWduOiROb1NpZ24gLVBsYWluVGV4dDokUGxhaW5UZXh0IC1BbGlnbiAkQWxpZ24gLVBhc3NUaHJ1OiRQYXNzVGhydQ0KICAgICAgICAgICAgfQ0KICAgICAgICB9DQogICAgICAgIGlmICghJHRleHQgLW9yICR0ZXh0IC1ub3RtYXRjaCAiKD9zbWkpXigoPzxOTkw+eCl8KD88TlM+bnM/KSl7MCwyfSg/PHQ+XD4qKSg/PHM+W1wrXC1cIVwqXCNcQF9dKSg/PHc+LiopIikge3JldHVybiBBbGlnbi1UZXh0ICRUZXh0IC1BbGlnbiAkQWxpZ24gfCBXcml0ZS1Ib3N0fQ0KICAgICAgICAkdGIgID0gIiAgICAiKiRNYXRjaGVzLnQubGVuZ3RoDQogICAgICAgICRDb2wgPSBAeycrJz0nMic7Jy0nPScxMic7JyEnPScxNCc7JyonPSRCbHVlOycjJz0nRGFya0dyYXknOydAJz0nR3JheSc7J18nPSd3aGl0ZSd9WygkU2lnbiA9ICRNYXRjaGVzLlMpXQ0KICAgICAgICBpZiAoISRDb2wpIHtUaHJvdyAiSW5jb3JyZWN0IFNpZ24gWyRTaWduXSBQYXNzZWQhIn0NCiAgICAgICAgJFNpZ24gPSAkKGlmICgkTm9TaWduIC1vciAkTWF0Y2hlcy5OUykgeyIifSBlbHNlIHsiWyRTaWduXSAifSkNCiAgICAgICAgJERhdGEgPSAiJHRiJFNpZ24kKCRNYXRjaGVzLlcpIjtpZiAoISREYXRhKSB7cmV0dXJuIFdyaXRlLUhvc3QgIiJ9DQogICAgICAgIGlmIChBUC1SZXF1aXJlICJmdW5jdGlvbjpBbGlnbi1UZXh0IiAtcGEpIHsNCiAgICAgICAgICAgICREYXRhID0gQWxpZ24tVGV4dCAtQWxpZ24gJEFsaWduICIkdGIkU2lnbiQoJE1hdGNoZXMuVykiDQogICAgICAgIH0NCiAgICAgICAgaWYgKCRQbGFpblRleHQpIHtyZXR1cm4gJERhdGF9DQogICAgICAgICREYXRhTGluZXMgPSAkRGF0YSAtc3BsaXQgImBuIg0KICAgICAgICAxLi4kRGF0YUxpbmVzLkNvdW50IHwgJSB7DQogICAgICAgICAgICAkSWR4ID0gJF8gLSAxDQogICAgICAgICAgICAkTk5MID0gISRpZHggLWFuZCAkTWF0Y2hlcy5OTkwNCiAgICAgICAgICAgIFdyaXRlLUhvc3QgLU5vTmV3TGluZTokTk5MIC1mICRDb2wgJERhdGFMaW5lc1skSWR4XQ0KICAgICAgICAgICAgaWYgKCRQYXNzVGhydSkge3JldHVybiAkRGF0YX0NCiAgICAgICAgfQ0KICAgIH0NCn0KCmZ1bmN0aW9uIFNldC1QYXRoIHsNCiAgICBbY21kbGV0YmluZGluZygpXQ0KICAgIHBhcmFtKA0KICAgICAgICBbUGFyYW1ldGVyKE1hbmRhdG9yeSA9ICR0cnVlLCBWYWx1ZUZyb21QaXBlbGluZSA9ICR0cnVlKV1bc3RyaW5nW11dJFBhdGgsDQogICAgICAgIFtzdHJpbmddJFBhdGhWYXIgPSAiUEFUSCINCiAgICApDQogICAgYmVnaW4gew0KICAgICAgICBbc3RyaW5nW11dJEZpbmFsUGF0aA0KICAgIH0NCiAgICBwcm9jZXNzIHsNCiAgICAgICAgJFBhdGggfCAlIHsNCiAgICAgICAgICAgICRGaW5hbFBhdGggKz0gJF8NCiAgICAgICAgfQ0KICAgIH0NCiAgICBlbmQgew0KICAgICAgICAkSXNVbml4ID0gJFBTVmVyc2lvblRhYmxlLlBsYXRmb3JtIC1lcSAiVW5peCINCiAgICAgICAgJFBhdGhTZXAgPSAkKGlmICgkSXNVbml4KSB7IjoifSBlbHNlIHsiOyJ9KQ0KICAgICAgICAkUHRoID0gJEZpbmFsUGF0aCAtam9pbiAkUGF0aFNlcA0KICAgICAgICAkUHRoID0gKCRQdGggLXJlcGxhY2UoIiRQYXRoU2VwKyIsICRQYXRoU2VwKSAtcmVwbGFjZSgiXFwkUGF0aFNlcHxcXCQiLCAkUGF0aFNlcCkpLnRyaW0oJFBhdGhTZXApDQogICAgICAgICRQdGggPSAoKCRQdGgpLnNwbGl0KCRQYXRoU2VwKSB8IHNlbGVjdCAtdW5pcXVlKSAtam9pbiAkUGF0aFNlcA0KICAgICAgICBbRW52aXJvbm1lbnRdOjpTZXRFbnZpcm9ubWVudFZhcmlhYmxlKCRQYXRoVmFyLCAkUHRoKQ0KICAgIH0NCn0KCmZ1bmN0aW9uIEdldC1Fc2NhcGUgew0KICAgIGlmICgkbnVsbCAtZXEgJGdsb2JhbDpBUF9DT05TT0xFLmN1c3RvbUZsYWdzLl9fZGV0ZWN0ZWRfZXNjYXBlX2NvZGVzKSB7JGdsb2JhbDpBUF9DT05TT0xFLmN1c3RvbUZsYWdzLl9fZGV0ZWN0ZWRfZXNjYXBlX2NvZGVzID0gQVAtUmVxdWlyZSAiYWJpbGl0eTplc2NhcGVfY29kZXMifQ0KICAgIGlmICghJEFQX0NPTlNPTEUuY3VzdG9tRmxhZ3MuZm9yY2VVbml4RXNjYXBlcyAtYW5kICEkZ2xvYmFsOkFQX0NPTlNPTEUuY3VzdG9tRmxhZ3MuX19kZXRlY3RlZF9lc2NhcGVfY29kZXMpIHt0aHJvdyAiW0FQQ29uc29sZTo6R2V0LUVzY2FwZV0gWW91ciBjb25zb2xlIGRvZXMgbm90IHN1cHBvcnQgQU5TSSBlc2NhcGUgY29kZXMuIFlvdSBjYW4gc2V0IGAkQVBfQ09OU09MRS5jdXN0b21GbGFncy5ub1VuaXhFc2NhcGVzID0gYCR0cnVlIHRvIGRpc2FibGUgdW5peCBlc2NhcGUgY29kZXMuIE9yLCB1c2U6IGAkQVBfQ09OU09MRS5jdXN0b21GbGFncy5mb3JjZVVuaXhFc2NhcGVzIHRvIGF0dGVtcHQgaXQgYW55d2F5cyJ9DQogICAgIyBXZSBkbyB0aGlzLCBiZWNhdXNlIFBvd2VyU2hlbGwgTmF0aXZlIGRvZXNuJ3Qga25vdyBgZQ0KICAgIHJldHVybiBbQ2hhcl0weDFiICMgYGUNCn0KCmZ1bmN0aW9uIFBsYWNlLUJ1ZmZlcmVkQ29udGVudCB7cGFyYW0oJFRleHQsICR4LCAkeSwgW0NvbnNvbGVDb2xvcl0kRm9yZWdyb3VuZENvbG9yPVtDb25zb2xlXTo6Rm9yZWdyb3VuZENvbG9yLCBbQ29uc29sZUNvbG9yXSRCYWNrZ3JvdW5kQ29sb3I9W0NvbnNvbGVdOjpCYWNrZ3JvdW5kQ29sb3IpDQoNCiAgICBpZiAoISRUZXh0KSB7cmV0dXJufQ0KICAgICRjcmQgPSBbTWFuYWdlbWVudC5BdXRvbWF0aW9uLkhvc3QuQ29vcmRpbmF0ZXNdOjpuZXcoJHgsJHkpDQogICAgJGIgPSAkSG9zdC5VSS5SYXdVSQ0KICAgICRhcnIgPSAkYi5OZXdCdWZmZXJDZWxsQXJyYXkoQCgkVGV4dCksICRGb3JlZ3JvdW5kQ29sb3IsICRCYWNrZ3JvdW5kQ29sb3IpDQogICAgJHggPSBbQ29uc29sZV06OkJ1ZmZlcldpZHRoLTEtJFRleHQubGVuZ3RoDQogICAgJGIuU2V0QnVmZmVyQ29udGVudHMoJGNyZCwgJGFycikNCn0KCmZ1bmN0aW9uIEdldC1QYXRoIHtwYXJhbSgkbWF0Y2gsIFtzdHJpbmddJFBhdGhWYXIgPSAiUEFUSCIpDQoNCiAgICAkUHRoID0gW0Vudmlyb25tZW50XTo6R2V0RW52aXJvbm1lbnRWYXJpYWJsZSgkUGF0aFZhcikNCiAgICAkSXNVbml4ID0gJFBTVmVyc2lvblRhYmxlLlBsYXRmb3JtIC1lcSAiVW5peCINCiAgICAkUGF0aFNlcCA9ICQoaWYgKCRJc1VuaXgpIHsiOiJ9IGVsc2UgeyI7In0pDQogICAgaWYgKCEkUHRoKSB7cmV0dXJuIEAoKX0NCiAgICBTZXQtUGF0aCAkUHRoIC1QYXRoVmFyICRQYXRoVmFyDQogICAgJGQgPSAoJFB0aCkuc3BsaXQoJFBhdGhTZXApDQogICAgaWYgKCRtYXRjaCkgeyRkIC1tYXRjaCAkbWF0Y2h9IGVsc2UgeyRkfQ0KfQoKZnVuY3Rpb24gVGVzdC1BZG1pbmlzdHJhdG9yIHsNCiAgICBpZiAoJFBTVmVyc2lvblRhYmxlLlBsYXRmb3JtIC1lcSAiVW5peCIpIHsNCiAgICAgICAgaWYgKCQod2hvYW1pKSAtZXEgInJvb3QiKSB7DQogICAgICAgICAgICByZXR1cm4gJHRydWUNCiAgICAgICAgfQ0KICAgICAgICBlbHNlIHsNCiAgICAgICAgICAgIHJldHVybiAkZmFsc2UNCiAgICAgICAgfQ0KICAgIH0NCiAgICAjIFdpbmRvd3MNCiAgICAoTmV3LU9iamVjdCBTZWN1cml0eS5QcmluY2lwYWwuV2luZG93c1ByaW5jaXBhbCAoW1NlY3VyaXR5LlByaW5jaXBhbC5XaW5kb3dzSWRlbnRpdHldOjpHZXRDdXJyZW50KCkpKS5Jc0luUm9sZShbU2VjdXJpdHkuUHJpbmNpcGFsLldpbmRvd3NCdWlsdGluUm9sZV06OkFkbWluaXN0cmF0b3IpDQp9CgpmdW5jdGlvbiBTdHJpcC1Db2xvckNvZGVzIHsNCiAgICBbQ21kbGV0QmluZGluZygpXXBhcmFtKFtQYXJhbWV0ZXIoVmFsdWVGcm9tUGlwZWxpbmU9MSldJFN0cikNCiAgICBwcm9jZXNzIHskU3RyIHwgJSB7JF8gLXJlcGxhY2UgIiQoW3JlZ2V4XTo6ZXNjYXBlKCIkKEdldC1Fc2NhcGUpWyIpKVxkKyhcO1xkKykqbSIsIiJ9fQ0KfQoKZnVuY3Rpb24gUHJpbnQtTGlzdCB7cGFyYW0oJHgsIFtTd2l0Y2hdJEluUmVjdXJzZSkNCg0KICAgIGlmICgkeC5jb3VudCAtbGUgMSkge3JldHVybiA/OigkSW5SZWN1cnNlKXskeH17IlskeF0ifX0gZWxzZSB7DQogICAgICAgIHJldHVybiAiWyQoKCR4IHwgJSB7UHJpbnQtTGlzdCAkXyAtSW5SZWN1cnNlfSkgLWpvaW4gJywgJyldIg0KICAgIH0NCn0KClNldC1BbGlhcyBjb2wgR2V0LUNvbG9yClNldC1BbGlhcyA/OiBJbnZva2UtVGVybmFyeQ==")
} elseif($AP_CONSOLE.warnOnCompileRun) {& $AP_CONSOLE.warnOnCompileRun}
# ========================================END=OF=COMPILER=================================================================|
$Dbg = $Dbg -or $PSBoundParameters.ContainsKey('Verbose') -or $PSBoundParameters.ContainsKey('Debug')
$Ver = "1.6 (APC: $($AP_CONSOLE.version))"

# Track all AP-Console Commands
if (!$AP_CONSOLE -or !$AP_CONSOLE.functions) {
    Write-APL "!","AP-Console not loaded, only a valid AP-Console session can run this command. Alternatively, define all the functions you'd like to support in ","+`$AP_CONSOLE.functions"
    exit 1
}
if (!$AP_CONSOLE.Version -or $AP_CONSOLE.Version -lt 1.2) {
    Write-APL "!","AP-Console Version is too old, please update to at least 1.2 to use this command"
    exit 1
}
function Get-AllNestedFunctionalDeps ([System.Management.Automation.Language.Ast]$RootAst, $Depth = 0, $SeenFuncs = @{}) {
    if (!$RootAst) {return}
    $ClassRefs = $RootAst.findAll({$args[0] -is [System.Management.Automation.Language.TypeDefinitionAst]}, $true) | Group-Object name | % Group | Select-Object -f 1 | ? {
        $AP_CONSOLE.classes.Contains($_.Name) -and !$SeenClassDefs.$_.Name
    } | % {
        $SeenClassDefs.($_.Name) = $_.Extent.Text # Store the class definition
    }
    $DefinedFuncs = $RootAst.findAll({$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}, $true) | % name | Select-Object -Unique
    $Commands = $RootAst.findAll({$args[0] -is [System.Management.Automation.Language.CommandAst]}, $true) | % {$_.CommandElements[0]} | % value | Select-Object -Unique | % {
        # Ignore if it's not a known AP-Function / Alias or is one of the defined functions in the file
        if ((!$TmpHash.$_ -and $_ -notin $Aliases) -or $SeenFuncs.$_ -or ($_ -in $DefinedFuncs)) {return}
        $SeenFuncs.$_++
        $Name = $_
        $Cmd = Get-Command $_ -ea SilentlyContinue
        if ($Cmd.ResolvedCommandName) {
            [PSCustomObject]@{
                Name = $_
                Depth = $Depth
                Type = "Alias"
            }
            $SeenFuncs.$Name++
            $Name = $Cmd.ResolvedCommandName
            $Cmd = Get-Command $Name -ea SilentlyContinue
        }
        $Ast = $Cmd.ScriptBlock.Ast
        if (!$Ast) {return}
        return @([PSCustomObject]@{
            Name = $Name
            Depth = $Depth
            Type = "Function"
        })+(Get-AllNestedFunctionalDeps $Ast -Depth ($Depth + 1) -SeenFuncs $SeenFuncs)
    }

    return Flatten $Commands | ? {$_} | Sort-Object # To make sure the base64 code is deterministic
}

function Write-CompiledFile ($Data) {
    if ($OverwriteSrc) {
        $OutputFolder = Split-Path $File
    }
    if ((Split-Path $File) -eq $OutputFolder -and !$OverwriteSrc) {
        $Outfile = "$((Split-Path -leaf $File).replace('.ps1','-Compiled.ps1'))"
    } else {
        $Outfile = "$(Split-Path -leaf $File)"
    }
    $enc = JS-OR {
        $e = Get-FileEncoding $File
        if ($e -in "utf32","unicode","bigendianunicode") {""} else {[System.Text.Encoding]::$e}
    } "unicode"
    $Verb = ?: $Strip "Unc" "C"
    Write-APL ">+","${Verb}ompiled [","+$OutFile","] with Encoding [","+$(JS-OR $Enc.EncodingName $Enc)","] in Folder [","*$OutputFolder","]"
    $Data | Out-File -Encoding $Enc "$OutputFolder\$OutFile"
}

function Remove-OldInjecter ($Data) {
    $ReplaceExpr = "(?s)\# ?=+START=OF=COMPILER=+\|`n.+\# ?=+END=OF=COMPILER=+\|"
    return $Data -replace "$ReplaceExpr`n|`n$ReplaceExpr",""
}

$TmpHash = @{}
$AP_CONSOLE.functions | % {$TmpHash.$_ = $_}
$Aliases = Get-Alias | ? {$TmpHash.($_.Definition)} | % {"$_"}

# Validation
if (!$File -or !(Test-Path -type Leaf $File)) {Throw "Invalid File [$File]";exit}
if (!(Test-Path -type Container $OutputFolder)) {Throw "Invalid Folder [$OutputFolder]";exit}
if ($File -notmatch ".\.ps1$") {Throw "Invalid File Type [$File], expected *.ps1";exit}
$File = (Get-Item $File).FullName
$OutputFolder = (Get-Item $OutputFolder).FullName

if ($Strip) {
    Write-APL "*","Uncompiling File [","+$File","]"
    $OverwriteSrc = $true
    $OData = $Data = [IO.File]::ReadAllText($File)
    $Data = Remove-OldInjecter $Data
    if ($OData -eq $Data) {
        Write-APL ">!","No Compiler Code Found, File is already uncompiled!"
        exit 0
    }
    Write-APL ">+","Uncompiled File!"
    $Data = $Data -replace "(?s)\# ?=+START=OF=COMPILER=+\|`n.+\# ?=+END=OF=COMPILER=+\|",""
    Write-CompiledFile $Data
    exit 0
}

# Let's process the file
$Data = [IO.File]::ReadAllLines($File)
$Script:Need2Import = @{}
$Script:Need2ImportAL = @{}
$Script:BlackListFunctions = @{"IN-Code-Debug-Console"=1;"Get-APIKey"=1;"Get-GMAIL"=1;"Backup"=1}
Write-APL "*","Compiling ","+$(Split-Path -leaf $File):"

# Use AST to detect the functions used in this script
$Tokens = @() # Where the comments will be scannable
$Script:ASTT = [System.Management.Automation.Language.Parser]::ParseFile($File, [ref]$Tokens, [ref]$null)
$Script:SeenClassDefs = @{}
$Script:Functions = @(Get-AllNestedFunctionalDeps $Script:ASTT)

# Scan for forced required functions
# Example: ap-compiler: Write-APL,AP-Require
$ForcedDependencies = $tokens | ? kind -eq 'comment' | ? text -Match "^..?\s*ap-compiler?\:" | % {$_ -replace "^..?\s*ap-compiler?\: *(.+?) *(?<a>\#\>)?$",'$1' -split ","} | % {$_.Trim()} | ? {$_} | % {
    Write-APL ">#","@AP-Compiler Forced Command: ","+$_"
    if ($_ -notin $TmpHash.Keys -and $_ -notin $Aliases) {Throw "Invalid AP-Compiler Forced Command [$_]";exit 1}
    $_
}
$ForcedFakeExpr = "{$($ForcedDependencies -join ";")}"
$ForcedFakeAst = [System.Management.Automation.Language.Parser]::ParseInput($ForcedFakeExpr, [ref]$Tokens, [ref]$null)
$Script:Functions += Get-AllNestedFunctionalDeps $ForcedFakeAst

if ($Dbg) {
    Write-APL ">*","Globally detected functions:"
    $MaxNameSize = [math]::Max(($Script:Functions | % {$_.Name.Length} | Measure-Object -Maximum).Maximum, ($SeenClassDefs.Keys | % Length | Measure-Object -Maximum).Maximum)+3
    $MaxNameSize = [math]::Clamp($MaxNameSize, 23, [Math]::Max(24, [Console]::WindowWidth * .5))
    $Script:Functions | % {
        Write-APL ">>#","+$($_.Name) ","#$("." * [Math]::max(0, $MaxNameSize - $_.Name.length)) ","@$($_.Type.PadLeft(8))","# | Depth: ","@$($_.Depth)"
    }
    $SeenClassDefs.Keys | % {
        Write-APL ">>#","+$($_) ","#$("." * [Math]::max(0, $MaxNameSize - $_.length)) ","@$("Class".PadLeft(8))","# | Depth: ","@0"
    }
}
$Script:Functions | % {
    $Name = $_.Name
    $Type = $_.Type
    $Name = $Name -replace "^\w+\:(\S+)$",'$1'
    if ($Type -eq "Function") {
        $Script:Need2Import.$Name++
    } else {
        if ($Name -eq "Item") {return}
        $Script:Need2ImportAL.$Name++
        $Need2Import.((Get-Alias $Name).Definition)++
    }
}

$FinalSet = @($Need2Import.Keys) | ? {!$OtroFunc.$_}
$FinalAlSet = @($Need2ImportAL.Keys) | Select-Object -unique
$Code = $FinalSet | % {"function $_ {1}{0}{2}" -f $(if ($BlackListFunctions.$_) {"Write-Host -f yellow '[AP-COMPILER] Module [$_] disabled for this program'"} else {iex "`${Function:$_}"}),"{","}`n"}
$Code += $FinalAlSet | % {"Set-Alias $_ {0}" -f ((Get-Alias $_).Definition)}
$Code += $SeenClassDefs.Values
if ($Code) {
    if ($FinalSet -and !$Dbg)            {Write-APL ">*","@Adding Functions $(Print-List $FinalSet)"}
    if ($FinalALSet -and !$Dbg)          {Write-APL ">*","@Adding Aliases   $(Print-List $FinalALSet)"}
    if ($SeenClassDefs.Count -and !$Dbg) {Write-APL ">*","@Adding Classes   $(Print-List $SeenClassDefs.Keys)"}
    $Injecter = @(
        ""
        "# =======================================START=OF=COMPILER================================================================|"
        "#    The Following Code was added by AP-Compiler $Ver To Make this program independent of AP-Core Engine"
        "#    GitHub: https://github.com/avdaredevil/AP-Compiler"
        "# ========================================================================================================================|"
        '$Script:PSHell=$(if($PSHell){$PSHell}elseif($PSScriptRoot){$PSScriptRoot}else{"."});'
        "if(`$AP_CONSOLE.mode -ne 'main' -or `$AP_CONSOLE.customFlags.runAsCompiled) {"
        "    `$Script:AP_CONSOLE = [PsCustomObject]@{version=[version]'$($AP_CONSOLE.Version)'; mode = 'shim'; customFlags = @{}}"
        "    function B64 {$("${Function:Convert-FromBase64}".trim() -replace "(`r?`n){2,}"," ")}"
        "    # This syntax is to prevent AV's from misclassifying this as anything but innocuous"
        "    & (Get-Alias iex) (B64 ""$(Convert-ToBase64 ($Code -join "`n"))"")"
        "} elseif(`$AP_CONSOLE.warnOnCompileRun) {& `$AP_CONSOLE.warnOnCompileRun}"
        "# ========================================END=OF=COMPILER=================================================================|"
    ) -join "`n"
}
$Data = $Data -join "`n"
$NewCode = Remove-OldInjecter $Data
if ($NewCode -ne $Data) {
    Write-APL ">!","Old Compiler Code Detected... Removing..."
    $Data = $NewCode
}
if (!$Injecter) {
    Write-APL ">*","No Functions or Aliases to add... Writing the file as is..."
} elseif ($Data -match "`n\[CmdletBinding\(\)\] *`n" -and !$ForceLinearLayout) {
    Write-APL ">*","Detected Procedural Layout"
    $M = [Regex]::Match($Data,"(?i)(Begin|Process|End) *\{")
    if (!$M.success) {
        Write-APL ">>!","No Begin/Process/End Tags found... Please check that your code is runnable?"
        Write-APL ">>!","If you are sure it works, use ","!-ForceLinearLayout"," switch to force linear layout"
        exit 1
    } else {
        $Data = $Data.insert($M.Index+$M.Length,$Injecter)
    }
} else {
    Write-APL ">*","Detected Linear Layout",$(if($ForceLinearLayout){"! (Forced)"}else{""})
    $M = [Regex]::Match($Data,"(?i)(`n|^)param *\(")
    if (!$M.success) {$Data = "$("$Injecter`n".TrimStart())$Data"} else {
        $i = 1;$dex=0;$InString=0
        foreach ($c in $Data[($M.Index+$M.Length)..$Data.Length]) {$dex++
            if ($Dbg) {Write-APL ">>*","Explored $c [Stack: $i |$Dex :: $InString -> $(('Code','Dbl-Quot','Single-Quot')[$InString])]"}
            if ($InString -ne 2 -and $c -eq """") {$InString=(1,0)[$InString]}
            elseif ($InString -ne 1 -and $c -eq "'") {$InString=(2,-1,0)[$InString]}
            elseif ($InString) {continue}
            if ($c -eq "(") {$i++}
            elseif ($c -eq ")") {if (!(--$i)) {break}}
        }
        $Data = $Data.insert($M.Index+$M.Length+$dex,$Injecter)
    }
}
Write-CompiledFile $Data
if ($PassThru) {return $code}
