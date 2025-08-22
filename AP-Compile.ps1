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
    & (Get-Alias iex) (B64 "ZnVuY3Rpb24gUHJvY2Vzcy1Vbmljb2RlIHsNCiAgICAkRmluYWxBcmdzID0gRmxhdHRlbiAkYXJncw0KICAgICMgUG93ZXJTaGVsbCBDb3JlIHN5bnRheCB3aGVuIHByb2Nlc3NlZCBieSBQb3dlclNoZWxsIE5hdGl2ZQ0KICAgIGlmICgiJEZpbmFsQXJncyIgLW1hdGNoICJ1eyhcdyspfSIpIHsNCiAgICAgICAgcmV0dXJuIFtSZWdleF06OlVuZXNjYXBlKCgiJEZpbmFsQXJncyIgLXJlcGxhY2UgInV7KFx3Kyl9IiwnXHUkMScpKQ0KICAgIH0NCiAgICBpZiAoISgkRmluYWxBcmdzIHwgPyB7JF8gLWlzbm90IFtpbnRdfSkpIHsNCiAgICAgICAgcmV0dXJuIFtjaGFyW11dJEZpbmFsQXJncyAtam9pbiAnJw0KICAgIH0NCiAgICByZXR1cm4gJGFyZ3MNCn0KCmZ1bmN0aW9uIEdldC1GaWxlRW5jb2Rpbmcge3BhcmFtKFtQYXJhbWV0ZXIoTWFuZGF0b3J5PSRUcnVlKV0kUGF0aCkNCg0KICAgICRieXRlcyA9IFtieXRlW11dKEdldC1Db250ZW50ICRQYXRoIC1Bc0J5dGVTdHJlYW0gLVJlYWRDb3VudCA0IC1Ub3RhbENvdW50IDQpDQoNCiAgICBpZighJGJ5dGVzKSB7IHJldHVybiAndXRmOCcgfQ0KDQogICAgc3dpdGNoIC1yZWdleCAoJ3swOngyfXsxOngyfXsyOngyfXszOngyfScgLWYgJGJ5dGVzWzBdLCRieXRlc1sxXSwkYnl0ZXNbMl0sJGJ5dGVzWzNdKSB7DQogICAgICAgICdeZWZiYmJmJyAgIHtyZXR1cm4gJ3V0ZjgnfQ0KICAgICAgICAnXjJiMmY3NicgICB7cmV0dXJuICd1dGY3J30NCiAgICAgICAgJ15mZmZlJyAgICAge3JldHVybiAndW5pY29kZSd9DQogICAgICAgICdeZmVmZicgICAgIHtyZXR1cm4gJ2JpZ2VuZGlhbnVuaWNvZGUnfQ0KICAgICAgICAnXjAwMDBmZWZmJyB7cmV0dXJuICd1dGYzMid9DQogICAgICAgIGRlZmF1bHQgICAgIHtyZXR1cm4gJ2FzY2lpJ30NCiAgICB9DQp9CgpmdW5jdGlvbiBHZXQtV2hlcmUgew0KICAgIFtDbWRsZXRCaW5kaW5nKERlZmF1bHRQYXJhbWV0ZXJTZXROYW1lPSJOb3JtYWwiKV0NCiAgICBwYXJhbSgNCiAgICAgICAgW1BhcmFtZXRlcihNYW5kYXRvcnk9JHRydWUsIFBvc2l0aW9uPTApXVtzdHJpbmddJEZpbGUsDQogICAgICAgIFtTd2l0Y2hdJEFsbCwNCiAgICAgICAgW1BhcmFtZXRlcihQYXJhbWV0ZXJTZXROYW1lPSdOb3JtYWwnKV1bUGFyYW1ldGVyKFBhcmFtZXRlclNldE5hbWU9J1NjYW4nKV1bU3dpdGNoXSRNYW51YWxTY2FuLA0KICAgICAgICBbUGFyYW1ldGVyKFBhcmFtZXRlclNldE5hbWU9J1NjYW4nKV1bU3dpdGNoXSREYmcsDQogICAgICAgIFtQYXJhbWV0ZXIoUGFyYW1ldGVyU2V0TmFtZT0nU2NhbicpXVtzdHJpbmddJFBhdGhWYXIgPSAiUEFUSCINCiAgICApDQogICAgJElzVmVyYm9zZSA9ICREYmcgLW9yICRQU0NtZGxldC5NeUludm9jYXRpb24uQm91bmRQYXJhbWV0ZXJzLlZlcmJvc2UgLW9yICRQU0NtZGxldC5NeUludm9jYXRpb24uQm91bmRQYXJhbWV0ZXJzLkRlYnVnDQogICAgJFdoZXJlQmluRXhpc3RzID0gR2V0LUNvbW1hbmQgIndoZXJlIiAtZWEgU2lsZW50bHlDb250aW51ZQ0KICAgICRJc1VuaXggPSAkUFNWZXJzaW9uVGFibGUuUGxhdGZvcm0gLWVxICJVbml4Ig0KICAgIGlmICgkRmlsZSAtZXEgIndoZXJlIiAtb3IgJEZpbGUgLWVxICJ3aGVyZS5leGUiKSB7cmV0dXJuICRXaGVyZUJpbkV4aXN0c30NCiAgICBpZiAoJFdoZXJlQmluRXhpc3RzIC1hbmQgISRNYW51YWxTY2FuKSB7DQogICAgICAgICRPdXQ9JG51bGwNCiAgICAgICAgaWYgKCRJc1VuaXgpIHsNCiAgICAgICAgICAgICRPdXQgPSB3aGljaCAkZmlsZSAyPiRudWxsDQogICAgICAgIH0gZWxzZSB7JE91dCA9IHdoZXJlLmV4ZSAkZmlsZSAyPiRudWxsfQ0KDQogICAgICAgIGlmICghJE91dCkge3JldHVybn0NCiAgICAgICAgaWYgKCRBbGwpIHtyZXR1cm4gJE91dH0NCiAgICAgICAgcmV0dXJuIEAoJE91dClbMF0NCiAgICB9DQogICAgZm9yZWFjaCAoJEZvbGRlciBpbiAoR2V0LVBhdGggLVBhdGhWYXIgJFBhdGhWYXIpKSB7DQogICAgICAgIGlmICgkSXNVbml4KSB7DQogICAgICAgICAgICAkTG9va3VwID0gIiRGb2xkZXIvJEZpbGUiDQogICAgICAgICAgICBpZiAoJElzVmVyYm9zZSkge1dyaXRlLUFQICIqQ2hlY2tpbmcgWyRMb29rdXBdIn0NCiAgICAgICAgICAgIGlmICghKFRlc3QtUGF0aCAtUGF0aFR5cGUgTGVhZiAkTG9va3VwKSkge2NvbnRpbnVlfQ0KICAgICAgICAgICAgUmVzb2x2ZS1QYXRoICRMb29rdXAgfCAlIFBhdGgNCiAgICAgICAgICAgIGlmICghJEFsbCkge3JldHVybn0NCiAgICAgICAgfSBlbHNlIHsNCiAgICAgICAgICAgIGZvcmVhY2ggKCRFeHRlbnNpb24gaW4gKEdldC1QYXRoIC1QYXRoVmFyIFBBVEhFWFQpKSB7DQogICAgICAgICAgICAgICAgJExvb2t1cCA9ICIkRm9sZGVyLyRGaWxlJEV4dGVuc2lvbiINCiAgICAgICAgICAgICAgICBpZiAoJElzVmVyYm9zZSkge1dyaXRlLUFQICIqQ2hlY2tpbmcgWyRMb29rdXBdIn0NCiAgICAgICAgICAgICAgICBpZiAoIShUZXN0LVBhdGggLVBhdGhUeXBlIExlYWYgJExvb2t1cCkpIHtjb250aW51ZX0NCiAgICAgICAgICAgICAgICBSZXNvbHZlLVBhdGggJExvb2t1cCB8ICUgUGF0aA0KICAgICAgICAgICAgICAgIGlmICghJEFsbCkge3JldHVybn0NCiAgICAgICAgICAgIH0NCiAgICAgICAgfQ0KICAgIH0NCn0KCmZ1bmN0aW9uIEdldC1Db2xvciB7DQogICAgPCMgIC5EZXNjcmlwdGlvbg0KICAgICAgICBGZXRjaGVzIGJhc2ljIGNvbG9ycyB1c2luZyB0aGUgVW5pY29kZSBFc2NhcGUgc2VxdWVuY2VzDQogICAgIz4NCiAgICBwYXJhbSAoDQogICAgICAgIFtWYWxpZGF0ZVNldCgNCiAgICAgICAgICAgICdyJywncmVzZXQnLCdyUycsJ3Jlc2V0U3R5bGVzJywnZCcsJ2RpbScsJ3MnLCdzdHJpa2UnLCd1JywndW5kZXJsaW5lJywnYicsJ2JvbGQnLCdpJywnaXRhbGljJywnYmwnLCdibGluaycsJ3JldmVyc2UnLCdoJywnaGlkZGVuJywNCiAgICAgICAgICAgICdCbGFjaycsJ0RhcmtCbHVlJywnRGFya0dyZWVuJywnRGFya0N5YW4nLCdEYXJrUmVkJywnRGFya01hZ2VudGEnLCdEYXJrWWVsbG93JywnR3JheScsJ0RhcmtHcmF5JywnQmx1ZScsJ0dyZWVuJywnQ3lhbicsJ1JlZCcsJ01hZ2VudGEnLCdZZWxsb3cnLCdXaGl0ZScsDQogICAgICAgICAgICAnYmcuQmxhY2snLCdiZy5EYXJrQmx1ZScsJ2JnLkRhcmtHcmVlbicsJ2JnLkRhcmtDeWFuJywnYmcuRGFya1JlZCcsJ2JnLkRhcmtNYWdlbnRhJywnYmcuRGFya1llbGxvdycsJ2JnLkdyYXknLCdiZy5EYXJrR3JheScsJ2JnLkJsdWUnLCdiZy5HcmVlbicsJ2JnLkN5YW4nLCdiZy5SZWQnLCdiZy5NYWdlbnRhJywnYmcuWWVsbG93JywnYmcuV2hpdGUnDQogICAgICAgICldW1N0cmluZ1tdXSRDb2RlLA0KICAgICAgICBbQWxpYXMoJ2JnJyldW1N3aXRjaF0kQmFja2dyb3VuZCwNCiAgICAgICAgW1N3aXRjaF0kQ29kZVN0cmluZw0KICAgICkNCiAgICBpZiAoJEFQX0NPTlNPTEUuY3VzdG9tRmxhZ3Mubm9Vbml4RXNjYXBlcykge3JldHVybn0NCiAgICAkQWxpYXNUYWJsZSA9IEB7dSA9ICd1bmRlcmxpbmUnO2IgPSAnYm9sZCc7aSA9ICdpdGFsaWMnO3IgPSAncmVzZXQnO3JTID0gJ3Jlc2V0U3R5bGVzJztzID0gJ3N0cmlrZSc7ZCA9ICdkaW0nO2JsID0gJ2JsaW5rJztoID0gJ2hpZGRlbid9DQogICAgaWYgKCEkR2xvYmFsOkFQX0NPTE9SX1RBQkxFKSB7DQogICAgICAgICRUQkwgPSAkR2xvYmFsOkFQX0NPTE9SX1RBQkxFID0gQHtyZXNldCA9IDA7Ym9sZCA9IDE7ZGltID0gMjtpdGFsaWMgPSAzO3VuZGVybGluZSA9IDQ7YmxpbmsgPSA1O3JldmVyc2UgPSA3O2hpZGRlbiA9IDg7c3RyaWtlID0gOTtyZXNldFN0eWxlcyA9ICcyMjsyMzsyNDsyNTsyNzsyODsyOSd9DQogICAgICAgIDAsMSB8ICUgew0KICAgICAgICAgICAgJEJnSW5kZXggPSAkXw0KICAgICAgICAgICAgMCwxIHwgJSB7DQogICAgICAgICAgICAgICAgJFNwY0luZGV4ID0gJF8NCiAgICAgICAgICAgICAgICAkaSA9IDANCiAgICAgICAgICAgICAgICAnQmxhY2suVHxSZWR8R3JlZW58WWVsbG93fEJsdWV8TWFnZW50YXxDeWFufFdoaXRlJy5zcGxpdCgnfCcpIHwgJSB7DQogICAgICAgICAgICAgICAgICAgICRJbmNyID0gJEJnSW5kZXggKiAxMA0KICAgICAgICAgICAgICAgICAgICAkQ29sTmFtZSA9ICgoJycsJ2JnLicpWyRCZ0luZGV4XSkrKCgnRGFyaycsJycpWyRTcGNJbmRleF0pKyRfDQogICAgICAgICAgICAgICAgICAgICRDb2xTcGFjZSA9ICgzMCwgOTApWyRTcGNJbmRleF0gKyAkSW5jcg0KICAgICAgICAgICAgICAgICAgICAkVEJMLiRDb2xOYW1lID0gJENvbFNwYWNlKygkaSsrKQ0KICAgICAgICAgICAgICAgIH0NCiAgICAgICAgICAgIH0NCiAgICAgICAgfQ0KICAgICAgICBAe0RhcmtHcmF5ID0gJ0JsYWNrLlQnO0JsYWNrID0gJ0RhcmtCbGFjay5UJztHcmF5ID0gJ0RhcmtXaGl0ZSd9LkdldEVudW1lcmF0b3IoKSB8ICUgew0KICAgICAgICAgICAgJFRCTC4oJF8uS2V5KSA9ICRUQkwuKCRfLlZhbHVlKQ0KICAgICAgICAgICAgJFRCTC4oJ2JnLicrJF8uS2V5KSA9ICRUQkwuKCdiZy4nKyRfLlZhbHVlKQ0KICAgICAgICAgICAgJFRCTC5yZW1vdmUoJF8uVmFsdWUpDQogICAgICAgICAgICAkVEJMLnJlbW92ZSgnYmcuJyskXy5WYWx1ZSkNCiAgICAgICAgfQ0KICAgIH0NCiAgICAkQ29kZXMgPSAoJENvZGUrJEFyZ3MgfCAlIHsNCiAgICAgICAgJEdsb2JhbDpBUF9DT0xPUl9UQUJMRS4oSlMtT1IgJEFsaWFzVGFibGUuJF8gJF8pDQogICAgfSkgLWpvaW4gJzsnDQogICAgaWYgKCRDb2RlU3RyaW5nKSB7cmV0dXJuICRDb2Rlc30NCiAgICByZXR1cm4gIiQoR2V0LUVzY2FwZSlbJHtDb2Rlc31tIg0KfQoKZnVuY3Rpb24gRmxhdHRlbiB7cGFyYW0oW29iamVjdFtdXSR4KQ0KDQogICAgaWYgKCEoJFggLWlzIFthcnJheV0pKSB7cmV0dXJuICR4fQ0KICAgIGlmICgkWC5jb3VudCAtZXEgMSkgew0KICAgICAgICByZXR1cm4gJHggfCAlIHskX30NCiAgICB9DQogICAgJHggfCAlIHtGbGF0dGVuICRffQ0KfQoKZnVuY3Rpb24gSW52b2tlLU9yUmV0dXJuIHtwYXJhbShbUGFyYW1ldGVyKE1hbmRhdG9yeT0kdHJ1ZSwgVmFsdWVGcm9tUGlwZWxpbmU9JHRydWUsIFBvc2l0aW9uPTApXVtBbGxvd051bGwoKV0kQ29kZSwgW1BhcmFtZXRlcihWYWx1ZUZyb21SZW1haW5pbmdBcmd1bWVudHM9MSldJF9fUmVzdCwgW1N3aXRjaF0kQXNQcm9jZXNzQmxvY2spDQoNCiAgICBpZiAoISgkQ29kZSAtaXMgW1NjcmlwdEJsb2NrXSkpIHtyZXR1cm4gJENvZGV9DQogICAgaWYgKCEkQXNQcm9jZXNzQmxvY2spIHtyZXR1cm4gJiAkQ29kZSBAX19SZXN0fQ0KICAgIHJldHVybiBGb3JFYWNoLU9iamVjdCAtcHJvY2VzcyAkQ29kZSAtSW5wdXRPYmplY3QgJF9fUmVzdA0KfQoKZnVuY3Rpb24gSlMtT1Ige2ZvcmVhY2ggKCRhIGluICRhcmdzKSB7JHIgPSBJbnZva2UtT3JSZXR1cm4gJGE7aWYgKCEkcil7Y29udGludWV9O3JldHVybiAkcn07cmV0dXJuICRyfQoKZnVuY3Rpb24gQ29udmVydC1Ub0Jhc2U2NCB7cGFyYW0oW1BhcmFtZXRlcihWYWx1ZUZyb21QaXBlbGluZT0kdHJ1ZSldW1N0cmluZ10kVGV4dCwgW1ZhbGlkYXRlU2V0KCJVVEY4IiwiVW5pY29kZSIpXVtTdHJpbmddJEVuY29kaW5nID0gIlVURjgiKQ0KDQogICAgW1N5c3RlbS5Db252ZXJ0XTo6VG9CYXNlNjRTdHJpbmcoW1N5c3RlbS5UZXh0LkVuY29kaW5nXTo6JEVuY29kaW5nLkdldEJ5dGVzKCRUZXh0KSkNCn0KCmZ1bmN0aW9uIEludm9rZS1UZXJuYXJ5IHtwYXJhbSgkZGVjaWRlciwgJGlmdHJ1ZSwgJGlmZmFsc2UgPSB7fSkNCg0KICAgICRJbnZva2VPclJldHVybiA9IHsNCiAgICAgICAgcGFyYW0oJENtZCkNCiAgICAgICAgaWYgKCRDbWQgLWlzIFtTY3JpcHRCbG9ja10pIHsmICRDbWR9IGVsc2UgeyRDbWR9DQogICAgfQ0KICAgIGlmICgkZGVjaWRlcikgeyAmICRJbnZva2VPclJldHVybiAkaWZ0cnVlIH0gZWxzZSB7ICYgJEludm9rZU9yUmV0dXJuICRpZmZhbHNlIH0NCn0KCmZ1bmN0aW9uIFdyaXRlLUFQTCB7DQogICAgW0NtZGxldEJpbmRpbmcoKV0NCiAgICBwYXJhbSgNCiAgICAgICAgW1BhcmFtZXRlcihWYWx1ZUZyb21QaXBlbGluZT0kdHJ1ZSwgTWFuZGF0b3J5PSRUcnVlKV0kVGV4dCwNCiAgICAgICAgW0FsaWFzKCdOUycpXVtTd2l0Y2hdJE5vU2lnbiwNCiAgICAgICAgW0FsaWFzKCdOTkwnLCdOTCcpXVtTd2l0Y2hdJE5vTmV3TGluZSwNCiAgICAgICAgW1N3aXRjaF0kUGFzc1RocnUNCiAgICApDQogICAgYmVnaW4gew0KICAgICAgICAkU2lnblJneCA9ICJbXCtcLVwhXCpcI1xAX10iOyAkVFQgPSBAKCkNCiAgICAgICAgJElzVmVyYm9zZSA9ICRQU0NtZGxldC5NeUludm9jYXRpb24uQm91bmRQYXJhbWV0ZXJzLlZlcmJvc2UNCiAgICB9DQogICAgcHJvY2VzcyB7RmxhdHRlbiAkVGV4dCB8ICUgew0KICAgICAgICAkTGluZSA9ICRfIC1zcGxpdCAiYG4iDQogICAgICAgICRMaW5lU3ltYm9sID0gJChpZiAoJGxpbmVbMF0gLW1hdGNoICJebj94P24/KFw+KikoJFNpZ25SZ3gpLiokIikgeyRNYXRjaGVzWzJdfSBlbHNlIHsiIn0pDQogICAgICAgIGlmICgkSXNWZXJib3NlKSB7V3JpdGUtVmVyYm9zZSAiJChjb2wgaSlMaW5lU3ltYm9sOiAkTGluZVN5bWJvbCB8IExpbmU6ICRMaW5lJChjb2wgclMpIn0NCiAgICAgICAgMS4uJExpbmUuTGVuZ3RoIHwgJSB7DQogICAgICAgICAgICAkaWR4ID0gJF8gLSAxDQogICAgICAgICAgICBpZiAoJGlkeCkgeyRUVCArPSAiYG4iKyRMaW5lU3ltYm9sKyRMaW5lWyRpZHhdfQ0KICAgICAgICAgICAgZWxzZSB7JFRUICs9ICRMaW5lWyRpZHhdfQ0KICAgICAgICB9DQogICAgfX0NCiAgICBlbmQgew0KICAgICAgICBpZiAoJElzVmVyYm9zZSkge1dyaXRlLVZlcmJvc2UgIiQoY29sIGkpJChQcmludC1MaXN0ICRUVCkkKGNvbCByUykifQ0KICAgICAgICBmb3IgKCRpPTA7JGkgLWx0ICRUVC5jb3VudDskaSsrKSB7DQogICAgICAgICAgICBbc3RyaW5nXSRDaHVuayA9ICRUVFskaV0NCiAgICAgICAgICAgIGlmICgkQ2h1bmtbMF0gLWVxICJgbiIpIHskQ2h1bmsgPSAkQ2h1bmsuU3Vic3RyaW5nKDEpO1dyaXRlLUhvc3R9ICMgU3BlY2lhbCBjYXNlIGZvciBuZXcgbGluZSB2aWEgYG4NCiAgICAgICAgICAgICRDaHVuayA9ICRDaHVuayAtcmVwbGFjZSAiXm4/eD9uPyhcPiokU2lnblJneCkiLCckMScNCiAgICAgICAgICAgIGlmICgkQ2h1bmsgLW5vdG1hdGNoICJeXD4qJFNpZ25SZ3guKiIpIHskQ2h1bmsgPSAiXyRDaHVuayJ9ICMgVXNlIGRlZmF1bHQgYXMgd2hpdGUNCiAgICAgICAgICAgICRQcmVmaXhDb2RlID0gPzogKCRpIC1lcSAwKSB7IngkKD86ICROb1NpZ24geyduJ30geycnfSkifSB7PzogKCRpIC1uZSAoJFRULkNvdW50IC0gMSkpIHsibngifSAibiQoPzogJE5vTmV3TGluZSB7J3gnfSB7Jyd9KSJ9DQogICAgICAgICAgICBpZiAoJFRULkNvdW50IC1lcSAxKSB7JFByZWZpeENvZGUgPSAiJCg/OiAkTm9TaWduIHsnbid9IHsnJ30pJCg/OiAkTm9OZXdMaW5lIHsneCd9IHsnJ30pIn0NCiAgICAgICAgICAgIGlmICgkSXNWZXJib3NlKSB7V3JpdGUtVmVyYm9zZSAiJChjb2wgaSlQcmVmaXhDb2RlOiAkUHJlZml4Q29kZSB8IENodW5rOiAkQ2h1bmskKGNvbCByUykifQ0KICAgICAgICAgICAgV3JpdGUtQVAgIiRQcmVmaXhDb2RlJENodW5rIiAtUGFzc1RocnU6JFBhc3NUaHJ1DQogICAgICAgIH0NCiAgICB9DQp9CgpmdW5jdGlvbiBBUC1SZXF1aXJlIHtwYXJhbShbUGFyYW1ldGVyKE1hbmRhdG9yeT0kVHJ1ZSldW0FsaWFzKCJGdW5jdGlvbmFsaXR5IiwiTGlicmFyeSIpXVtBcmd1bWVudENvbXBsZXRlcih7DQogICAgW091dHB1dFR5cGUoW1N5c3RlbS5NYW5hZ2VtZW50LkF1dG9tYXRpb24uQ29tcGxldGlvblJlc3VsdF0pXQ0KICAgIHBhcmFtKA0KICAgICAgICBbc3RyaW5nXSAkQ29tbWFuZE5hbWUsDQogICAgICAgIFtzdHJpbmddICRQYXJhbWV0ZXJOYW1lLA0KICAgICAgICBbc3RyaW5nXSAkV29yZFRvQ29tcGxldGUsDQogICAgICAgIFtTeXN0ZW0uTWFuYWdlbWVudC5BdXRvbWF0aW9uLkxhbmd1YWdlLkNvbW1hbmRBc3RdICRDb21tYW5kQXN0LA0KICAgICAgICBbU3lzdGVtLkNvbGxlY3Rpb25zLklEaWN0aW9uYXJ5XSAkRmFrZUJvdW5kUGFyYW1ldGVycw0KICAgICkNCiAgICAkQ29tcGxldGlvblJlc3VsdHMgPSBbU3lzdGVtLkNvbGxlY3Rpb25zLkdlbmVyaWMuTGlzdFtTeXN0ZW0uTWFuYWdlbWVudC5BdXRvbWF0aW9uLkNvbXBsZXRpb25SZXN1bHRdXTo6bmV3KCkNCiAgICAkTGliID0gQCgiSW50ZXJuZXQiLCJvczp3aW5kb3dzIiwib3M6bGludXgiLCJvczp1bml4IiwiYWRtaW5pc3RyYXRvciIsInJvb3QiLCJkZXA6IiwibGliOiIsImxpYl90ZXN0OiIsIm1vZHVsZToiLCJtb2R1bGVfdGVzdDoiLCJmdW5jdGlvbjoiLCJzdHJpY3RfZnVuY3Rpb246IiwiYWJpbGl0eTplc2NhcGVfY29kZXMiLCJhYmlsaXR5OmVtb2ppcyIsImFiaWxpdHk6bG9uZ19wYXRocyIsImFiaWxpdHk6Y29uc29sZV9tYW5pcHVsYXRpb24iKQ0KICAgICRqc09yID0ge2ZvcmVhY2ggKCRhIGluICRhcmdzKSB7JGEgPSAkKGlmKCRhIC1pcyBbc2NyaXB0YmxvY2tdKXsmJGF9ZWxzZXskYX0pO2lmICghJGEpe2NvbnRpbnVlfTtyZXR1cm4gJGF9O3JldHVybiAkYX0gIyBNYW51YWxseSBlbWJlZGRlZCBKUy1PUg0KICAgICYgJGpzT3IgeyRMaWIgfCA/IHskXyAtbGlrZSAiJFdvcmRUb0NvbXBsZXRlKiJ9fSB7JExpYiB8ID8geyRfIC1saWtlICIqJFdvcmRUb0NvbXBsZXRlKiJ9fSB8ICUgew0KICAgICAgICAkQ29tcGxldGlvblJlc3VsdHMuQWRkKFtTeXN0ZW0uTWFuYWdlbWVudC5BdXRvbWF0aW9uLkNvbXBsZXRpb25SZXN1bHRdOjpuZXcoJF8sICRfLCAnUGFyYW1ldGVyVmFsdWUnLCAkXykpDQogICAgfQ0KICAgIHJldHVybiAkQ29tcGxldGlvblJlc3VsdHMNCn0pXVtTdHJpbmddJExpYiwgW1NjcmlwdEJsb2NrXSRPbkZhaWwsIFtTd2l0Y2hdJFBhc3NUaHJ1KQ0KDQogICAgJExvYWRNb2R1bGUgPSB7DQogICAgICAgIHBhcmFtKCRGaWxlLFtib29sXSRJbXBvcnQpDQogICAgICAgIHRyeSB7SW1wb3J0LU1vZHVsZSAkRmlsZSAtZWEgc3RvcDtyZXR1cm4gMX0gY2F0Y2gge30NCiAgICAgICAgJExpYj1BUC1Db252ZXJ0UGF0aCAiPExJQj4iOyRMRiA9ICIkTGliXCRGaWxlIg0KICAgICAgICAkZiA9ICRMRiwiJExGLnBzbTEiLCIkTEYuZGxsIiB8ID8ge3Rlc3QtcGF0aCAtdCBsZWFmICRffSB8IHNlbGVjdCAtZiAxDQogICAgICAgIGlmICgkZiAtYW5kICRJbXBvcnQpIHsNCiAgICAgICAgICAgIEltcG9ydC1Nb2R1bGUgJGYNCiAgICAgICAgICAgIGlmICgkPykge3JldHVybiAkZn0gZWxzZSB7V3JpdGUtQVAgIiFGYWlsZWQgdG8gaW1wb3J0IFskRmlsZSAtPiAkRl0iO3JldHVybiAwfQ0KICAgICAgICB9DQogICAgICAgIHJldHVybiAkZg0KICAgIH0NCiAgICAkSW52b2tlT3JSZXR1cm4gPSB7cGFyYW0oJENtZCkgaWYgKCRDbWQgLWlzIFtTY3JpcHRCbG9ja10pIHsmICRDbWR9IGVsc2UgeyRDbWR9fQ0KICAgIGlmICghJE9uRmFpbCkgeyRQYXNzVGhydSA9ICR0cnVlfQ0KICAgICRTdGF0ID0gJChzd2l0Y2ggLXJlZ2V4ICgkTGliLnRyaW0oKSkgew0KICAgICAgICAiXkludGVybmV0JCIgICAgICAgICAgICAgICAgICAge3Rlc3QtY29ubmVjdGlvbiBnb29nbGUuY29tIC1Db3VudCAxIC1RdWlldH0NCiAgICAgICAgIl5vczood2luKGRvd3MpP3xsaW51eHx1bml4KSQiIHskSXNVbml4ID0gJFBTVmVyc2lvblRhYmxlLlBsYXRmb3JtIC1lcSAiVW5peCI7aWYgKCRNYXRjaGVzWzFdIC1tYXRjaCAiXndpbiIpIHshJElzVW5peH0gZWxzZSB7JElzVW5peH19DQogICAgICAgICJeYWRtaW4oaXN0cmF0b3IpPyR8XnJvb3QkIiAgICB7VGVzdC1BZG1pbmlzdHJhdG9yfQ0KICAgICAgICAiXmRlcDooLiopJCIgICAgICAgICAgICAgICAgICAge0dldC1XaGVyZSAkTWF0Y2hlc1sxXX0NCiAgICAgICAgIl4obGlifG1vZHVsZSk6KC4qKSQiICAgICAgICAgIHskTG9hZE1vZHVsZS5pbnZva2UoJE1hdGNoZXNbMl0sICR0cnVlKX0NCiAgICAgICAgIl4obGlifG1vZHVsZSlfdGVzdDooLiopJCIgICAgIHskTG9hZE1vZHVsZS5pbnZva2UoJE1hdGNoZXNbMl0pfQ0KICAgICAgICAiXmZ1bmN0aW9uOiguKikkIiAgICAgICAgICAgICAge2djbSAkTWF0Y2hlc1sxXSAtZWEgU2lsZW50bHlDb250aW51ZX0NCiAgICAgICAgIl5zdHJpY3RfZnVuY3Rpb246KC4qKSQiICAgICAgIHtUZXN0LVBhdGggIkZ1bmN0aW9uOlwkKCRNYXRjaGVzWzFdKSJ9DQogICAgICAgICJeYWJpbGl0eTooZXNjYXBlX2NvZGVzfGVtb2ppc3xsb25nX3BhdGhzfGNvbnNvbGVfbWFuaXB1bGF0aW9uKSQiICAgICB7JiAkSW52b2tlT3JSZXR1cm4gKEB7DQogICAgICAgICAgICBlc2NhcGVfY29kZXMgPSAkSG9zdC5VSS5TdXBwb3J0c1ZpcnR1YWxUZXJtaW5hbA0KICAgICAgICAgICAgZW1vamlzID0gJGVudjpXVF9TRVNTSU9OIC1vciAkZW52OldUX1BST0ZJTEVfSUQNCiAgICAgICAgICAgIGxvbmdfcGF0aHMgPSAkUFNWZXJzaW9uVGFibGUuUGxhdGZvcm0gLWVxICJVbml4IiAtb3IgKEdldC1JdGVtUHJvcGVydHkgLVBhdGggIkhLTE06XFNZU1RFTVxDdXJyZW50Q29udHJvbFNldFxDb250cm9sXEZpbGVTeXN0ZW0iIHwgJSBsb25ncGF0aHNlbmFibGVkKQ0KICAgICAgICAgICAgY29uc29sZV9tYW5pcHVsYXRpb24gPSAhW1N5c3RlbS5Db25zb2xlXTo6SXNPdXRwdXRSZWRpcmVjdGVkIC1hbmQgKCRIb3N0Lk5hbWUgLWVxICdDb25zb2xlSG9zdCcpDQogICAgICAgIH1bJE1hdGNoZXNbMV1dKX0NCiAgICAgICAgZGVmYXVsdCB7V3JpdGUtQVAgIiFJbnZhbGlkIHNlbGVjdG9yIHByb3ZpZGVkIFskKCIkTGliIi5zcGxpdCgnOicpWzBdKV0iO3Rocm93ICdCQURfU0VMRUNUT1InfQ0KICAgIH0pDQogICAgaWYgKCEkU3RhdCAtYW5kICRPbkZhaWwpIHsmICRPbkZhaWx9DQogICAgaWYgKCRQYXNzVGhydSAtb3IgISRPbkZhaWwpIHtyZXR1cm4gJFN0YXR9DQp9CgpmdW5jdGlvbiBBUC1Db252ZXJ0UGF0aCB7cGFyYW0oW1BhcmFtZXRlcihNYW5kYXRvcnk9JFRydWUpXVtTdHJpbmddJFBhdGgpDQoNCiAgICAkUGF0aFNlcCA9IFtJTy5QYXRoXTo6RGlyZWN0b3J5U2VwYXJhdG9yQ2hhcg0KICAgIHJldHVybiAkUGF0aCAtcmVwbGFjZQ0KICAgICAgICAiPERlcD4iLCI8TGliPiR7UGF0aFNlcH1EZXBlbmRlbmNpZXMiIC1yZXBsYWNlDQogICAgICAgICI8TGliPiIsIjxIb21lPiR7UGF0aFNlcH1BUC1MaWJyYXJpZXMiIC1yZXBsYWNlDQogICAgICAgICI8Q29tcChvbmVudHMpPz4iLCI8SG9tZT4ke1BhdGhTZXB9QVAtQ29tcG9uZW50cyIgLXJlcGxhY2UNCiAgICAgICAgIjxIb21lPiIsJFBTSGVsbH0KCmZ1bmN0aW9uIFdyaXRlLUFQIHsNCiAgICBbQ21kbGV0QmluZGluZygpXQ0KICAgIHBhcmFtKFtQYXJhbWV0ZXIoVmFsdWVGcm9tUGlwZWxpbmU9MSwgTWFuZGF0b3J5PTEpXSRUZXh0LFtTd2l0Y2hdJE5vU2lnbixbU3dpdGNoXSRQbGFpblRleHQsW1ZhbGlkYXRlU2V0KCJDZW50ZXIiLCJSaWdodCIsIkxlZnQiKV1bU3RyaW5nXSRBbGlnbj0nTGVmdCcsW1N3aXRjaF0kUGFzc1RocnUpDQogICAgYmVnaW4geyRUVCA9IEAoKX0NCiAgICBQcm9jZXNzIHskVFQgKz0gLCRUZXh0fQ0KICAgIEVORCB7DQogICAgICAgICRCbHVlID0gJChpZiAoJEFQX0NPTlNPTEUuY3VzdG9tRmxhZ3MubGVnYWN5Q29sb3JzKXszfWVsc2V7J0JsdWUnfSkNCiAgICAgICAgaWYgKCRUVC5jb3VudCAtZXEgMSkgeyRUVCA9ICRUVFswXX07JFRleHQgPSAkVFQNCiAgICAgICAgaWYgKCR0ZXh0LmNvdW50IC1ndCAxIC1vciAkdGV4dC5HZXRUeXBlKCkuTmFtZSAtbWF0Y2ggIlxbXF0kIikgew0KICAgICAgICAgICAgcmV0dXJuICRUZXh0IHwgJSB7DQogICAgICAgICAgICAgICAgV3JpdGUtQVAgJF8gLU5vU2lnbjokTm9TaWduIC1QbGFpblRleHQ6JFBsYWluVGV4dCAtQWxpZ24gJEFsaWduIC1QYXNzVGhydTokUGFzc1RocnUNCiAgICAgICAgICAgIH0NCiAgICAgICAgfQ0KICAgICAgICBpZiAoISR0ZXh0IC1vciAkdGV4dCAtbm90bWF0Y2ggIig/c21pKV4oKD88Tk5MPngpfCg/PE5TPm5zPykpezAsMn0oPzx0Plw+KikoPzxzPltcK1wtXCFcKlwjXEBfXSkoPzx3Pi4qKSIpIHtyZXR1cm4gQWxpZ24tVGV4dCAkVGV4dCAtQWxpZ24gJEFsaWduIHwgV3JpdGUtSG9zdH0NCiAgICAgICAgJHRiICA9ICIgICAgIiokTWF0Y2hlcy50Lmxlbmd0aA0KICAgICAgICAkQ29sID0gQHsnKyc9JzInOyctJz0nMTInOychJz0nMTQnOycqJz0kQmx1ZTsnIyc9J0RhcmtHcmF5JzsnQCc9J0dyYXknOydfJz0nd2hpdGUnfVsoJFNpZ24gPSAkTWF0Y2hlcy5TKV0NCiAgICAgICAgaWYgKCEkQ29sKSB7VGhyb3cgIkluY29ycmVjdCBTaWduIFskU2lnbl0gUGFzc2VkISJ9DQogICAgICAgICRTaWduID0gJChpZiAoJE5vU2lnbiAtb3IgJE1hdGNoZXMuTlMpIHsiIn0gZWxzZSB7IlskU2lnbl0gIn0pDQogICAgICAgICREYXRhID0gIiR0YiRTaWduJCgkTWF0Y2hlcy5XKSI7aWYgKCEkRGF0YSkge3JldHVybiBXcml0ZS1Ib3N0ICIifQ0KICAgICAgICBpZiAoQVAtUmVxdWlyZSAiZnVuY3Rpb246QWxpZ24tVGV4dCIgLXBhKSB7DQogICAgICAgICAgICAkRGF0YSA9IEFsaWduLVRleHQgLUFsaWduICRBbGlnbiAiJHRiJFNpZ24kKCRNYXRjaGVzLlcpIg0KICAgICAgICB9DQogICAgICAgIGlmICgkUGxhaW5UZXh0KSB7cmV0dXJuICREYXRhfQ0KICAgICAgICAkRGF0YUxpbmVzID0gJERhdGEgLXNwbGl0ICJgbiINCiAgICAgICAgMS4uJERhdGFMaW5lcy5Db3VudCB8ICUgew0KICAgICAgICAgICAgJElkeCA9ICRfIC0gMQ0KICAgICAgICAgICAgJE5OTCA9ICEkaWR4IC1hbmQgJE1hdGNoZXMuTk5MDQogICAgICAgICAgICBXcml0ZS1Ib3N0IC1Ob05ld0xpbmU6JE5OTCAtZiAkQ29sICREYXRhTGluZXNbJElkeF0NCiAgICAgICAgICAgIGlmICgkUGFzc1RocnUpIHtyZXR1cm4gJERhdGF9DQogICAgICAgIH0NCiAgICB9DQp9CgpmdW5jdGlvbiBTZXQtUGF0aCB7DQogICAgW2NtZGxldGJpbmRpbmcoKV0NCiAgICBwYXJhbSgNCiAgICAgICAgW1BhcmFtZXRlcihNYW5kYXRvcnkgPSAkdHJ1ZSwgVmFsdWVGcm9tUGlwZWxpbmUgPSAkdHJ1ZSldW3N0cmluZ1tdXSRQYXRoLA0KICAgICAgICBbc3RyaW5nXSRQYXRoVmFyID0gIlBBVEgiDQogICAgKQ0KICAgIGJlZ2luIHsNCiAgICAgICAgW3N0cmluZ1tdXSRGaW5hbFBhdGgNCiAgICB9DQogICAgcHJvY2VzcyB7DQogICAgICAgICRQYXRoIHwgJSB7DQogICAgICAgICAgICAkRmluYWxQYXRoICs9ICRfDQogICAgICAgIH0NCiAgICB9DQogICAgZW5kIHsNCiAgICAgICAgJElzVW5peCA9ICRQU1ZlcnNpb25UYWJsZS5QbGF0Zm9ybSAtZXEgIlVuaXgiDQogICAgICAgICRQYXRoU2VwID0gJChpZiAoJElzVW5peCkgeyI6In0gZWxzZSB7IjsifSkNCiAgICAgICAgJFB0aCA9ICRGaW5hbFBhdGggLWpvaW4gJFBhdGhTZXANCiAgICAgICAgJFB0aCA9ICgkUHRoIC1yZXBsYWNlKCIkUGF0aFNlcCsiLCAkUGF0aFNlcCkgLXJlcGxhY2UoIlxcJFBhdGhTZXB8XFwkIiwgJFBhdGhTZXApKS50cmltKCRQYXRoU2VwKQ0KICAgICAgICAkUHRoID0gKCgkUHRoKS5zcGxpdCgkUGF0aFNlcCkgfCBzZWxlY3QgLXVuaXF1ZSkgLWpvaW4gJFBhdGhTZXANCiAgICAgICAgW0Vudmlyb25tZW50XTo6U2V0RW52aXJvbm1lbnRWYXJpYWJsZSgkUGF0aFZhciwgJFB0aCkNCiAgICB9DQp9CgpmdW5jdGlvbiBBbGlnbi1UZXh0IHsNCiAgICBbQ21kbGV0QmluZGluZygpXQ0KICAgIFtPdXRwdXRUeXBlKFtTdHJpbmddLCBbSGFzaHRhYmxlXSldDQogICAgcGFyYW0oDQogICAgICAgIFtQYXJhbWV0ZXIoTWFuZGF0b3J5PTEsIFZhbHVlRnJvbVBpcGVsaW5lPTEpXVtTdHJpbmdbXV0kVGV4dCwNCiAgICAgICAgW3N3aXRjaF0kQ29sb3JDb2Rlc0Rpc2NyZXRlUGVyTGluZSwNCiAgICAgICAgW3N3aXRjaF0kUG9yY2VsYWluLA0KICAgICAgICAjIFRoaXMgY2FuIGJlIFtpbnRdIG9yIFtzY3JpcHRibG9ja10NCiAgICAgICAgJENvbnN0cmFpblRvV2lkdGgsDQogICAgICAgIFtWYWxpZGF0ZVNldCgiQ2VudGVyIiwiUmlnaHQiLCJMZWZ0IildW1N0cmluZ10kQWxpZ249J0NlbnRlcicNCiAgICApDQogICAgYmVnaW4gew0KICAgICAgICAkaXNWZXJib3NlID0gJFBTQ21kbGV0Lk15SW52b2NhdGlvbi5Cb3VuZFBhcmFtZXRlcnMuVmVyYm9zZQ0KICAgICAgICAkRXNjYXBlQ29kZVNwbGl0dGVyID0gIiQoW3JlZ2V4XTo6ZXNjYXBlKCIkKEdldC1Fc2NhcGUpWyIpKVxkKyg/Olw7XGQrKSptIg0KICAgICAgICAkRGl2aWRlcnMgPSBAe2NodW5rID0gdSAiYHV7MTEyODh9Ijsgc3R5bGUgPSB1ICJgdXsxMjI4OH0ifQ0KICAgICAgICAkRmluYWxGb3JtYXR0ZXIgPSB7DQogICAgICAgICAgICBwYXJhbSgkTGluZXMsICRTdHlsZXMpDQogICAgICAgICAgICBpZiAoISRQb3JjZWxhaW4pIHtyZXR1cm4gJExpbmVzfQ0KICAgICAgICAgICAgaWYgKCRudWxsIC1lcSAkU3R5bGVzKSB7JFN0eWxlcyA9IFtSZWdleF06Ok1hdGNoZXMoKCRMaW5lcyAtam9pbiAiIiksICRFc2NhcGVDb2RlU3BsaXR0ZXIpLnZhbHVlfQ0KICAgICAgICAgICAgcmV0dXJuIEB7TGluZXMgPSAkTGluZXM7IFJ1bm5pbmdTdHlsZXMgPSAkU3R5bGVzfQ0KICAgICAgICB9DQogICAgfQ0KICAgIHByb2Nlc3Mgew0KICAgICAgICBpZiAoJEFsaWduIC1lcSAiTGVmdCIpIHtyZXR1cm4gJiAkRmluYWxGb3JtYXR0ZXIgJFRleHR9DQogICAgICAgIGlmICghIiRUZXh0Ii50cmltKCkpIHtyZXR1cm4gJFRleHR9DQogICAgICAgICRXaW5TaXplID0gPzogJENvbnN0cmFpblRvV2lkdGgge0ludm9rZS1PclJldHVybiAkQ29uc3RyYWluVG9XaWR0aH0gKFtjb25zb2xlXTo6QnVmZmVyV2lkdGgpDQogICAgICAgIA0KICAgICAgICAkVGV4dCA9ICRUZXh0IC1zcGxpdCAiYHI/YG4iDQogICAgICAgIGlmICgkVGV4dC5jb3VudCAtZ3QgMSkgew0KICAgICAgICAgICAgJExpbmVzID0gJFRleHQgfCBBbGlnbi1UZXh0IC1BbGlnbiAkQWxpZ24gLUNvbG9yQ29kZXNEaXNjcmV0ZVBlckxpbmU6JENvbG9yQ29kZXNEaXNjcmV0ZVBlckxpbmUgLVBvcmNlbGFpbg0KICAgICAgICAgICAgaWYgKCRDb2xvckNvZGVzRGlzY3JldGVQZXJMaW5lKSB7DQogICAgICAgICAgICAgICAgZm9yICgkaSA9IDE7ICRpIC1sdCAkTGluZXMuQ291bnQ7ICRpKyspIHsNCiAgICAgICAgICAgICAgICAgICAgJExpbmUgPSAkTGluZXNbJGldDQogICAgICAgICAgICAgICAgICAgICRQcmV2U3R5bGVzICs9ICRMaW5lc1skaSAtIDFdLlJ1bm5pbmdTdHlsZXMNCiAgICAgICAgICAgICAgICAgICAgJExpbmUuTGluZXMgPSAkTGluZS5MaW5lcyB8ICUgeyIkUHJldlN0eWxlcyRfIn0NCiAgICAgICAgICAgICAgICAgICAgJExpbmUuUnVubmluZ1N0eWxlcyA9ICIkUHJldlN0eWxlcyQoJExpbmUuUnVubmluZ1N0eWxlcykiDQogICAgICAgICAgICAgICAgfQ0KICAgICAgICAgICAgfQ0KICAgICAgICAgICAgcmV0dXJuICYgJEZpbmFsRm9ybWF0dGVyIChGbGF0dGVuICRMaW5lcy5MaW5lcykgKCRMaW5lcy5SdW5uaW5nU3R5bGVzIC1qb2luICIiKQ0KICAgICAgICB9DQogICAgICAgICMgU2luZ2xlIG5vbiBgbiBsaW5lIHByb2Nlc3MNCiAgICAgICAgJENsZWFuVGV4dFNpemUgPSAoU3RyaXAtQ29sb3JDb2RlcyAoIiIrJFRleHQpKS5MZW5ndGgNCg0KICAgICAgICAjID09PT09PT09IExpbmUgaXMgPCAkV2luU2l6ZSA9PT09PT09PT09PT09PXwNCiAgICAgICAgaWYgKCRDbGVhblRleHRTaXplIC1sZSAkV2luU2l6ZSkgew0KICAgICAgICAgICAgaWYgKCRBbGlnbiAtZXEgIkNlbnRlciIpIHsNCiAgICAgICAgICAgICAgICByZXR1cm4gJiAkRmluYWxGb3JtYXR0ZXIgKCIgIipbbWF0aF06OnRydW5jYXRlKCgkV2luU2l6ZS0kQ2xlYW5UZXh0U2l6ZSkvMikrJFRleHQpDQogICAgICAgICAgICB9DQogICAgICAgICAgICAjIFJpZ2h0DQogICAgICAgICAgICByZXR1cm4gJiAkRmluYWxGb3JtYXR0ZXIgKCIgIiooJFdpblNpemUtJENsZWFuVGV4dFNpemUpKyRUZXh0KQ0KICAgICAgICB9DQoNCiAgICAgICAgIyA9PT09PT09PSBMaW5lIGlzID49ICRXaW5TaXplID09PT09PT09PT09PT09fA0KICAgICAgICAjIFRyYWNraW5nIFN0eWxlcw0KICAgICAgICAkUnVubmluZ1N0eWxlcyA9ICIiDQogICAgICAgICRDdXJybGluZSA9IEB7DQogICAgICAgICAgICBzdHlsZWREYXRhID0gIiINCiAgICAgICAgICAgIGNvbnRlbnRTaXplID0gMA0KICAgICAgICAgICAgZmluYWxMaW5lcyA9IEAoKQ0KICAgICAgICAgICAgbmV4dCA9IHsNCiAgICAgICAgICAgICAgICAjIFdyaXRlLVZlcmJvc2UgIiokSW52b2sgfCBOZXcgTGluZSB8IExpbmVEYXRhOiAkKCgnJyskQ3VycmxpbmUuc3R5bGVkRGF0YS5MZW5ndGgpLlBhZExlZnQoMykpIg0KICAgICAgICAgICAgICAgICRDdXJybGluZS5maW5hbExpbmVzICs9ICwkQ3VycmxpbmUuc3R5bGVkRGF0YQ0KICAgICAgICAgICAgICAgICRDdXJybGluZS5zdHlsZWREYXRhID0gJFJ1bm5pbmdTdHlsZXMNCiAgICAgICAgICAgICAgICAkQ3VycmxpbmUuY29udGVudFNpemUgPSAwDQogICAgICAgICAgICAgICAgIyBXcml0ZS1WZXJib3NlICIqJEludm9rIHwgQ3VyciBUb3RhbCBMaW5lczogJCgkY3VycmxpbmUuZmluYWxMaW5lcy5Db3VudCkiDQogICAgICAgICAgICB9DQogICAgICAgIH0NCiAgICAgICAgJEFsbENodW5rcyA9ICRUZXh0IC1yZXBsYWNlICIoJHtFc2NhcGVDb2RlU3BsaXR0ZXJ9KSsoLio/KSg/PSR7RXNjYXBlQ29kZVNwbGl0dGVyfXwkKSIsIiQoJERpdmlkZXJzLmNodW5rKWAkMSQoJERpdmlkZXJzLnN0eWxlKWAkMiIgLXNwbGl0ICREaXZpZGVycy5jaHVuaw0KICAgICAgICBpZiAoJEFsbENodW5rc1swXSAtbm90Y29udGFpbnMgJERpdmlkZXJzLnN0eWxlKSB7JEFsbENodW5rc1swXSA9ICIkKCREaXZpZGVycy5zdHlsZSkkKCRBbGxDaHVua3NbMF0pIn0gIyBUaGUgZmlyc3QgY2h1bmsgY291bGQgaGF2ZSBubyBzdHlsZXMNCiAgICAgICAgZm9yZWFjaCAoJEN1cnJDaHVuayBpbiAkQWxsQ2h1bmtzKSB7DQogICAgICAgICAgICAkU3R5bGUsJFRleHRDaHVuayA9ICRDdXJyQ2h1bmsgLXNwbGl0ICREaXZpZGVycy5zdHlsZQ0KICAgICAgICAgICAgJFJ1bm5pbmdTdHlsZXMgPSA/OiAkQ29sb3JDb2Rlc0Rpc2NyZXRlUGVyTGluZSAiJFJ1bm5pbmdTdHlsZXMkU3R5bGUiICRTdHlsZQ0KICAgICAgICAgICAgIyBXcml0ZS1Ib3N0IC1mIDIgKCJJbmNvbWluZ1N0eWxlOiAkU3R5bGUgfCBSdW5uaW5nU3R5bGVzOiAkUnVubmluZ1N0eWxlcyIgLXJlcGxhY2UgKFtyZWdleF06OkVzY2FwZSgkKEdldC1Fc2NhcGUpKSksJ1xlJykNCiAgICAgICAgICAgICMgV3JpdGUtSG9zdCAtZiBZZWxsb3cgIlRleHRDaHVuazogJFRleHRDaHVuayINCiAgICAgICAgICAgICRDdXJybGluZS5zdHlsZWREYXRhICs9ICRSdW5uaW5nU3R5bGVzDQogICAgICAgICAgICAkVGV4dENodW5rU3RySW5kZXggPSAwDQogICAgICAgICAgICAjIFdyaXRlLVZlcmJvc2UgIiokSW52b2sgfCBUZXh0Q2h1bms6ICRUZXh0Q2h1bmsgfCBBbGxDaHVua3NTaXplOiAkKCgnJyskQWxsQ2h1bmtzLkxlbmd0aCkuUGFkTGVmdCgzKSkiDQogICAgICAgICAgICB3aGlsZSgkVGV4dENodW5rU3RySW5kZXggLWx0ICRUZXh0Q2h1bmsuTGVuZ3RoKSB7DQogICAgICAgICAgICAgICAgaWYgKCRpc1ZlcmJvc2UpIHtQbGFjZS1CdWZmZXJlZENvbnRlbnQgKCIkSW52b2sgfCBMaW5lRGF0YTogJCgoJycrJEN1cnJsaW5lLnN0eWxlZERhdGEuTGVuZ3RoKS5QYWRMZWZ0KDMpKSB8IENodW5rSWR4OiAkKCgnJyskVGV4dENodW5rU3RySW5kZXgpLlBhZExlZnQoMykpIHwgQ2h1bmtMZW46ICQoJFRleHRDaHVuay5MZW5ndGgpIHwgRmluYWxMaW5lczogJCgkQ3VycmxpbmUuZmluYWxMaW5lcy5Db3VudCkiKSAteCAwIC15IChbQ29uc29sZV06OkJ1ZmZlckhlaWdodCAtIDEpIFllbGxvdyBEYXJrR3JheX0NCiAgICAgICAgICAgICAgICAkQ2h1bmtTaXplID0gJFRleHRDaHVuay5MZW5ndGggLSAkVGV4dENodW5rU3RySW5kZXgNCiAgICAgICAgICAgICAgICAjIFdyaXRlLVZlcmJvc2UgIipDaHVua1NpemU6ICRDaHVua1NpemUiDQogICAgICAgICAgICAgICAgaWYgKCgkQ3VycmxpbmUuY29udGVudFNpemUrJENodW5rU2l6ZSkgLWx0ICRXaW5TaXplKSB7DQogICAgICAgICAgICAgICAgICAgICMgSWYgdGhlIGN1cnJlbnQgY2h1bmsgZml0cyBpbiB0aGUgY3VycmVudCBsaW5lDQogICAgICAgICAgICAgICAgICAgICRDdXJybGluZS5zdHlsZWREYXRhICs9ICRUZXh0Q2h1bmsuU3Vic3RyaW5nKCRUZXh0Q2h1bmtTdHJJbmRleCkNCiAgICAgICAgICAgICAgICAgICAgJEN1cnJsaW5lLmNvbnRlbnRTaXplICs9ICRDaHVua1NpemUNCiAgICAgICAgICAgICAgICAgICAgJFRleHRDaHVua1N0ckluZGV4ICs9ICRDaHVua1NpemUNCiAgICAgICAgICAgICAgICAgICAgY29udGludWUNCiAgICAgICAgICAgICAgICB9DQogICAgICAgICAgICAgICAgIyBJZiB0aGUgY3VycmVudCBjaHVuayBkb2Vzbid0IGZpdCBpbiB0aGUgY3VycmVudCBsaW5lDQogICAgICAgICAgICAgICAgJG5ld0NvbnRlbnQgPSAkVGV4dENodW5rLlN1YnN0cmluZygkVGV4dENodW5rU3RySW5kZXgsICRXaW5TaXplLSRDdXJybGluZS5jb250ZW50U2l6ZSkNCiAgICAgICAgICAgICAgICAkQ3VycmxpbmUuc3R5bGVkRGF0YSArPSAkbmV3Q29udGVudA0KICAgICAgICAgICAgICAgICRDdXJybGluZS5jb250ZW50U2l6ZSArPSAkbmV3Q29udGVudC5sZW5ndGgNCiAgICAgICAgICAgICAgICAkVGV4dENodW5rU3RySW5kZXggKz0gJG5ld0NvbnRlbnQubGVuZ3RoDQogICAgICAgICAgICAgICAgJiAkQ3VycmxpbmUubmV4dA0KICAgICAgICAgICAgfQ0KICAgICAgICB9DQogICAgICAgIGlmICgkQ3VycmxpbmUuY29udGVudFNpemUgLWd0IDApIHsNCiAgICAgICAgICAgIGlmICgkQ3VycmxpbmUuY29udGVudFNpemUpew0KICAgICAgICAgICAgICAgIEFsaWduLVRleHQgLUFsaWduICRBbGlnbiAtVGV4dCAkQ3VycmxpbmUuc3R5bGVkRGF0YSAtQ29sb3JDb2Rlc0Rpc2NyZXRlUGVyTGluZTokQ29sb3JDb2Rlc0Rpc2NyZXRlUGVyTGluZSB8ID8geyRffSB8ICUgew0KICAgICAgICAgICAgICAgICAgICAkQ3VycmxpbmUuZmluYWxMaW5lcyArPSAsJF8NCiAgICAgICAgICAgICAgICB9DQogICAgICAgICAgICB9IGVsc2Ugew0KICAgICAgICAgICAgICAgICRDdXJybGluZS5maW5hbExpbmVzWy0xXSArPSAkQ3VycmxpbmUuc3R5bGVkRGF0YQ0KICAgICAgICAgICAgfQ0KICAgICAgICB9DQogICAgICAgIHJldHVybiAmICRGaW5hbEZvcm1hdHRlciAkQ3VycmxpbmUuZmluYWxMaW5lcyAkUnVubmluZ1N0eWxlcw0KICAgICAgICByZXR1cm4gJEN1cnJsaW5lLmZpbmFsTGluZXMNCiAgICB9DQp9CgpmdW5jdGlvbiBQbGFjZS1CdWZmZXJlZENvbnRlbnQge3BhcmFtKCRUZXh0LCAkeCwgJHksIFtDb25zb2xlQ29sb3JdJEZvcmVncm91bmRDb2xvcj1bQ29uc29sZV06OkZvcmVncm91bmRDb2xvciwgW0NvbnNvbGVDb2xvcl0kQmFja2dyb3VuZENvbG9yPVtDb25zb2xlXTo6QmFja2dyb3VuZENvbG9yKQ0KDQogICAgaWYgKCEkVGV4dCkge3JldHVybn0NCiAgICAkY3JkID0gW01hbmFnZW1lbnQuQXV0b21hdGlvbi5Ib3N0LkNvb3JkaW5hdGVzXTo6bmV3KCR4LCR5KQ0KICAgICRiID0gJEhvc3QuVUkuUmF3VUkNCiAgICAkYXJyID0gJGIuTmV3QnVmZmVyQ2VsbEFycmF5KEAoJFRleHQpLCAkRm9yZWdyb3VuZENvbG9yLCAkQmFja2dyb3VuZENvbG9yKQ0KICAgICR4ID0gW0NvbnNvbGVdOjpCdWZmZXJXaWR0aC0xLSRUZXh0Lmxlbmd0aA0KICAgICRiLlNldEJ1ZmZlckNvbnRlbnRzKCRjcmQsICRhcnIpDQp9CgpmdW5jdGlvbiBHZXQtUGF0aCB7cGFyYW0oJG1hdGNoLCBbc3RyaW5nXSRQYXRoVmFyID0gIlBBVEgiKQ0KDQogICAgJFB0aCA9IFtFbnZpcm9ubWVudF06OkdldEVudmlyb25tZW50VmFyaWFibGUoJFBhdGhWYXIpDQogICAgJElzVW5peCA9ICRQU1ZlcnNpb25UYWJsZS5QbGF0Zm9ybSAtZXEgIlVuaXgiDQogICAgJFBhdGhTZXAgPSAkKGlmICgkSXNVbml4KSB7IjoifSBlbHNlIHsiOyJ9KQ0KICAgIGlmICghJFB0aCkge3JldHVybiBAKCl9DQogICAgU2V0LVBhdGggJFB0aCAtUGF0aFZhciAkUGF0aFZhcg0KICAgICRkID0gKCRQdGgpLnNwbGl0KCRQYXRoU2VwKQ0KICAgIGlmICgkbWF0Y2gpIHskZCAtbWF0Y2ggJG1hdGNofSBlbHNlIHskZH0NCn0KCmZ1bmN0aW9uIEdldC1Fc2NhcGUgew0KICAgIGlmICgkbnVsbCAtZXEgJEFQX0NPTlNPTEUuY3VzdG9tRmxhZ3MuX19kZXRlY3RlZF9lc2NhcGVfY29kZXMpIHskQVBfQ09OU09MRS5jdXN0b21GbGFncy5fX2RldGVjdGVkX2VzY2FwZV9jb2RlcyA9IEFQLVJlcXVpcmUgImFiaWxpdHk6ZXNjYXBlX2NvZGVzIn0NCiAgICBpZiAoISRBUF9DT05TT0xFLmN1c3RvbUZsYWdzLmZvcmNlVW5peEVzY2FwZXMgLWFuZCAhJEFQX0NPTlNPTEUuY3VzdG9tRmxhZ3MuX19kZXRlY3RlZF9lc2NhcGVfY29kZXMpIHt0aHJvdyAiW0FQQ29uc29sZTo6R2V0LUVzY2FwZV0gWW91ciBjb25zb2xlIGRvZXMgbm90IHN1cHBvcnQgQU5TSSBlc2NhcGUgY29kZXMuIFlvdSBjYW4gc2V0IGAkQVBfQ09OU09MRS5jdXN0b21GbGFncy5ub1VuaXhFc2NhcGVzID0gYCR0cnVlIHRvIGRpc2FibGUgdW5peCBlc2NhcGUgY29kZXMuIE9yLCB1c2U6IGAkQVBfQ09OU09MRS5jdXN0b21GbGFncy5mb3JjZVVuaXhFc2NhcGVzIHRvIGF0dGVtcHQgaXQgYW55d2F5cyJ9DQogICAgIyBXZSBkbyB0aGlzLCBiZWNhdXNlIFBvd2VyU2hlbGwgTmF0aXZlIGRvZXNuJ3Qga25vdyBgZQ0KICAgIHJldHVybiBbQ2hhcl0weDFiICMgYGUNCn0KCmZ1bmN0aW9uIFRlc3QtQWRtaW5pc3RyYXRvciB7DQogICAgaWYgKCRQU1ZlcnNpb25UYWJsZS5QbGF0Zm9ybSAtZXEgIlVuaXgiKSB7DQogICAgICAgIGlmICgkKHdob2FtaSkgLWVxICJyb290Iikgew0KICAgICAgICAgICAgcmV0dXJuICR0cnVlDQogICAgICAgIH0NCiAgICAgICAgZWxzZSB7DQogICAgICAgICAgICByZXR1cm4gJGZhbHNlDQogICAgICAgIH0NCiAgICB9DQogICAgIyBXaW5kb3dzDQogICAgKE5ldy1PYmplY3QgU2VjdXJpdHkuUHJpbmNpcGFsLldpbmRvd3NQcmluY2lwYWwgKFtTZWN1cml0eS5QcmluY2lwYWwuV2luZG93c0lkZW50aXR5XTo6R2V0Q3VycmVudCgpKSkuSXNJblJvbGUoW1NlY3VyaXR5LlByaW5jaXBhbC5XaW5kb3dzQnVpbHRpblJvbGVdOjpBZG1pbmlzdHJhdG9yKQ0KfQoKZnVuY3Rpb24gU3RyaXAtQ29sb3JDb2RlcyB7DQogICAgW0NtZGxldEJpbmRpbmcoKV1wYXJhbShbUGFyYW1ldGVyKFZhbHVlRnJvbVBpcGVsaW5lPTEpXSRTdHIpDQogICAgcHJvY2VzcyB7JFN0ciB8ICUgeyRfIC1yZXBsYWNlICIkKFtyZWdleF06OmVzY2FwZSgiJChHZXQtRXNjYXBlKVsiKSlcZCsoXDtcZCspKm0iLCIifX0NCn0KCmZ1bmN0aW9uIFByaW50LUxpc3Qge3BhcmFtKCR4LCBbU3dpdGNoXSRJblJlY3Vyc2UpDQoNCiAgICBpZiAoJHguY291bnQgLWxlIDEpIHtyZXR1cm4gPzooJEluUmVjdXJzZSl7JHh9eyJbJHhdIn19IGVsc2Ugew0KICAgICAgICByZXR1cm4gIlskKCgkeCB8ICUge1ByaW50LUxpc3QgJF8gLUluUmVjdXJzZX0pIC1qb2luICcsICcpXSINCiAgICB9DQp9CgpTZXQtQWxpYXMgdSBQcm9jZXNzLVVuaWNvZGUKU2V0LUFsaWFzIGNvbCBHZXQtQ29sb3IKU2V0LUFsaWFzID86IEludm9rZS1UZXJuYXJ5")
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
