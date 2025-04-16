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
param(
    [Parameter(Mandatory=$True)][String]$File,
    [String]$OutputFolder = '.',
    [switch]$OverwriteSrc,
    [switch]$ForceLinearLayout,
    [Switch]$Dbg,
    [Switch]$PassThru
)
# =======================================START=OF=COMPILER==========================================================|
#    The Following Code was added by AP-Compiler 1.6 (APC: 1.2) To Make this program independent of AP-Core Engine
#    GitHub: https://github.com/avdaredevil/AP-Compiler
# ==================================================================================================================|
$Script:PSHell=$(if($PSHell){$PSHell}elseif($PSScriptRoot){$PSScriptRoot}else{"."});
$Script:AP_Console = @{version=[version]'1.2'; isShim = $true}
function B64 {param([Parameter(ValueFromPipeline=$true)][String]$Text, [ValidateSet("UTF8","Unicode")][String]$Encoding = "UTF8")     [System.Text.Encoding]::$Encoding.GetString([System.Convert]::FromBase64String($Text))}
# This syntax is to prevent AV's from misclassifying this as anything but innocuous
& (Get-Alias iex) (B64 "ZnVuY3Rpb24gR2V0LUNvbG9yIHsNCiAgICA8IyAgLkRlc2NyaXB0aW9uDQogICAgICAgIEZldGNoZXMgYmFzaWMgY29sb3JzIHVzaW5nIHRoZSBVbmljb2RlIEVzY2FwZSBzZXF1ZW5jZXMNCiAgICAjPg0KICAgIHBhcmFtICgNCiAgICAgICAgW1ZhbGlkYXRlU2V0KA0KICAgICAgICAgICAgJ3InLCdyZXNldCcsJ3JTJywncmVzZXRTdHlsZXMnLCdkJywnZGltJywncycsJ3N0cmlrZScsJ3UnLCd1bmRlcmxpbmUnLCdiJywnYm9sZCcsJ2knLCdpdGFsaWMnLCdibCcsJ2JsaW5rJywncmV2ZXJzZScsJ2gnLCdoaWRkZW4nLA0KICAgICAgICAgICAgJ0JsYWNrJywnRGFya0JsdWUnLCdEYXJrR3JlZW4nLCdEYXJrQ3lhbicsJ0RhcmtSZWQnLCdEYXJrTWFnZW50YScsJ0RhcmtZZWxsb3cnLCdHcmF5JywnRGFya0dyYXknLCdCbHVlJywnR3JlZW4nLCdDeWFuJywnUmVkJywnTWFnZW50YScsJ1llbGxvdycsJ1doaXRlJywNCiAgICAgICAgICAgICdiZy5CbGFjaycsJ2JnLkRhcmtCbHVlJywnYmcuRGFya0dyZWVuJywnYmcuRGFya0N5YW4nLCdiZy5EYXJrUmVkJywnYmcuRGFya01hZ2VudGEnLCdiZy5EYXJrWWVsbG93JywnYmcuR3JheScsJ2JnLkRhcmtHcmF5JywnYmcuQmx1ZScsJ2JnLkdyZWVuJywnYmcuQ3lhbicsJ2JnLlJlZCcsJ2JnLk1hZ2VudGEnLCdiZy5ZZWxsb3cnLCdiZy5XaGl0ZScNCiAgICAgICAgKV1bU3RyaW5nW11dJENvZGUsDQogICAgICAgIFtBbGlhcygnYmcnKV1bU3dpdGNoXSRCYWNrZ3JvdW5kLA0KICAgICAgICBbU3dpdGNoXSRDb2RlU3RyaW5nDQogICAgKQ0KICAgICRBbGlhc1RhYmxlID0gQHt1ID0gJ3VuZGVybGluZSc7YiA9ICdib2xkJztpID0gJ2l0YWxpYyc7ciA9ICdyZXNldCc7clMgPSAncmVzZXRTdHlsZXMnO3MgPSAnc3RyaWtlJztkID0gJ2RpbSc7YmwgPSAnYmxpbmsnO2ggPSAnaGlkZGVuJ30NCiAgICBpZiAoISRHbG9iYWw6QVBfQ09MT1JfVEFCTEUpIHsNCiAgICAgICAgJFRCTCA9ICRHbG9iYWw6QVBfQ09MT1JfVEFCTEUgPSBAe3Jlc2V0ID0gMDtib2xkID0gMTtkaW0gPSAyO2l0YWxpYyA9IDM7dW5kZXJsaW5lID0gNDtibGluayA9IDU7cmV2ZXJzZSA9IDc7aGlkZGVuID0gODtzdHJpa2UgPSA5O3Jlc2V0U3R5bGVzID0gJzIyOzIzOzI0OzI1OzI3OzI4OzI5J30NCiAgICAgICAgMCwxIHwgJSB7DQogICAgICAgICAgICAkQmdJbmRleCA9ICRfDQogICAgICAgICAgICAwLDEgfCAlIHsNCiAgICAgICAgICAgICAgICAkU3BjSW5kZXggPSAkXw0KICAgICAgICAgICAgICAgICRpID0gMA0KICAgICAgICAgICAgICAgICdCbGFjay5UfFJlZHxHcmVlbnxZZWxsb3d8Qmx1ZXxNYWdlbnRhfEN5YW58V2hpdGUnLnNwbGl0KCd8JykgfCAlIHsNCiAgICAgICAgICAgICAgICAgICAgJEluY3IgPSAkQmdJbmRleCAqIDEwDQogICAgICAgICAgICAgICAgICAgICRDb2xOYW1lID0gKCgnJywnYmcuJylbJEJnSW5kZXhdKSsoKCdEYXJrJywnJylbJFNwY0luZGV4XSkrJF8NCiAgICAgICAgICAgICAgICAgICAgJENvbFNwYWNlID0gKDMwLCA5MClbJFNwY0luZGV4XSArICRJbmNyDQogICAgICAgICAgICAgICAgICAgICRUQkwuJENvbE5hbWUgPSAkQ29sU3BhY2UrKCRpKyspDQogICAgICAgICAgICAgICAgfQ0KICAgICAgICAgICAgfQ0KICAgICAgICB9DQogICAgICAgIEB7RGFya0dyYXkgPSAnQmxhY2suVCc7QmxhY2sgPSAnRGFya0JsYWNrLlQnO0dyYXkgPSAnRGFya1doaXRlJ30uR2V0RW51bWVyYXRvcigpIHwgJSB7DQogICAgICAgICAgICAkVEJMLigkXy5LZXkpID0gJFRCTC4oJF8uVmFsdWUpDQogICAgICAgICAgICAkVEJMLignYmcuJyskXy5LZXkpID0gJFRCTC4oJ2JnLicrJF8uVmFsdWUpDQogICAgICAgICAgICAkVEJMLnJlbW92ZSgkXy5WYWx1ZSkNCiAgICAgICAgICAgICRUQkwucmVtb3ZlKCdiZy4nKyRfLlZhbHVlKQ0KICAgICAgICB9DQogICAgfQ0KICAgICRDb2RlcyA9ICgkQ29kZSskQXJncyB8ICUgew0KICAgICAgICAkR2xvYmFsOkFQX0NPTE9SX1RBQkxFLihKUy1PUiAkQWxpYXNUYWJsZS4kXyAkXykNCiAgICB9KSAtam9pbiAnOycNCiAgICBpZiAoJENvZGVTdHJpbmcpIHtyZXR1cm4gJENvZGVzfQ0KICAgIHJldHVybiAiJChHZXQtRXNjYXBlKVske0NvZGVzfW0iDQp9CgpmdW5jdGlvbiBHZXQtV2hlcmUgew0KICAgIFtDbWRsZXRCaW5kaW5nKERlZmF1bHRQYXJhbWV0ZXJTZXROYW1lPSJOb3JtYWwiKV0NCiAgICBwYXJhbSgNCiAgICAgICAgW1BhcmFtZXRlcihNYW5kYXRvcnk9JHRydWUsIFBvc2l0aW9uPTApXVtzdHJpbmddJEZpbGUsDQogICAgICAgIFtTd2l0Y2hdJEFsbCwNCiAgICAgICAgW1BhcmFtZXRlcihQYXJhbWV0ZXJTZXROYW1lPSdOb3JtYWwnKV1bUGFyYW1ldGVyKFBhcmFtZXRlclNldE5hbWU9J1NjYW4nKV1bU3dpdGNoXSRNYW51YWxTY2FuLA0KICAgICAgICBbUGFyYW1ldGVyKFBhcmFtZXRlclNldE5hbWU9J1NjYW4nKV1bU3dpdGNoXSREYmcsDQogICAgICAgIFtQYXJhbWV0ZXIoUGFyYW1ldGVyU2V0TmFtZT0nU2NhbicpXVtzdHJpbmddJFBhdGhWYXIgPSAiUEFUSCINCiAgICApDQogICAgJElzVmVyYm9zZSA9ICREYmcgLW9yICRQU0NtZGxldC5NeUludm9jYXRpb24uQm91bmRQYXJhbWV0ZXJzLlZlcmJvc2UgLW9yICRQU0NtZGxldC5NeUludm9jYXRpb24uQm91bmRQYXJhbWV0ZXJzLkRlYnVnDQogICAgJFdoZXJlQmluRXhpc3RzID0gR2V0LUNvbW1hbmQgIndoZXJlIiAtZWEgU2lsZW50bHlDb250aW51ZQ0KICAgICRJc1VuaXggPSAkUFNWZXJzaW9uVGFibGUuUGxhdGZvcm0gLWVxICJVbml4Ig0KICAgIGlmICgkRmlsZSAtZXEgIndoZXJlIiAtb3IgJEZpbGUgLWVxICJ3aGVyZS5leGUiKSB7cmV0dXJuICRXaGVyZUJpbkV4aXN0c30NCiAgICBpZiAoJFdoZXJlQmluRXhpc3RzIC1hbmQgISRNYW51YWxTY2FuKSB7DQogICAgICAgICRPdXQ9JG51bGwNCiAgICAgICAgaWYgKCRJc1VuaXgpIHsNCiAgICAgICAgICAgICRPdXQgPSB3aGljaCAkZmlsZSAyPiRudWxsDQogICAgICAgIH0gZWxzZSB7JE91dCA9IHdoZXJlLmV4ZSAkZmlsZSAyPiRudWxsfQ0KICAgICAgICANCiAgICAgICAgaWYgKCEkT3V0KSB7cmV0dXJufQ0KICAgICAgICBpZiAoJEFsbCkge3JldHVybiAkT3V0fQ0KICAgICAgICByZXR1cm4gQCgkT3V0KVswXQ0KICAgIH0NCiAgICBmb3JlYWNoICgkRm9sZGVyIGluIChHZXQtUGF0aCAtUGF0aFZhciAkUGF0aFZhcikpIHsNCiAgICAgICAgaWYgKCRJc1VuaXgpIHsNCiAgICAgICAgICAgICRMb29rdXAgPSAiJEZvbGRlci8kRmlsZSINCiAgICAgICAgICAgIGlmICgkSXNWZXJib3NlKSB7V3JpdGUtQVAgIipDaGVja2luZyBbJExvb2t1cF0ifQ0KICAgICAgICAgICAgaWYgKCEoVGVzdC1QYXRoIC1QYXRoVHlwZSBMZWFmICRMb29rdXApKSB7Y29udGludWV9DQogICAgICAgICAgICBSZXNvbHZlLVBhdGggJExvb2t1cCB8ICUgUGF0aA0KICAgICAgICAgICAgaWYgKCEkQWxsKSB7cmV0dXJufQ0KICAgICAgICB9IGVsc2Ugew0KICAgICAgICAgICAgZm9yZWFjaCAoJEV4dGVuc2lvbiBpbiAoR2V0LVBhdGggLVBhdGhWYXIgUEFUSEVYVCkpIHsNCiAgICAgICAgICAgICAgICAkTG9va3VwID0gIiRGb2xkZXIvJEZpbGUkRXh0ZW5zaW9uIg0KICAgICAgICAgICAgICAgIGlmICgkSXNWZXJib3NlKSB7V3JpdGUtQVAgIipDaGVja2luZyBbJExvb2t1cF0ifQ0KICAgICAgICAgICAgICAgIGlmICghKFRlc3QtUGF0aCAtUGF0aFR5cGUgTGVhZiAkTG9va3VwKSkge2NvbnRpbnVlfQ0KICAgICAgICAgICAgICAgIFJlc29sdmUtUGF0aCAkTG9va3VwIHwgJSBQYXRoDQogICAgICAgICAgICAgICAgaWYgKCEkQWxsKSB7cmV0dXJufQ0KICAgICAgICAgICAgfQ0KICAgICAgICB9DQogICAgfQ0KfQoKZnVuY3Rpb24gU3RyaXAtQ29sb3JDb2RlcyB7cGFyYW0oJFN0cikNCg0KICAgICRTdHIgfCAlIHskXyAtcmVwbGFjZSAiJChbcmVnZXhdOjplc2NhcGUoIiQoR2V0LUVzY2FwZSlbIikpXGQrKFw7XGQrKSptIiwiIn0NCn0KCmZ1bmN0aW9uIEludm9rZS1PclJldHVybiB7cGFyYW0oW1BhcmFtZXRlcihNYW5kYXRvcnk9JHRydWUsIFZhbHVlRnJvbVBpcGVsaW5lPSR0cnVlLCBQb3NpdGlvbj0wKV1bQWxsb3dOdWxsKCldJENvZGUsIFtQYXJhbWV0ZXIoVmFsdWVGcm9tUmVtYWluaW5nQXJndW1lbnRzPTEpXSRfX1Jlc3QsIFtTd2l0Y2hdJEFzUHJvY2Vzc0Jsb2NrKQ0KDQogICAgaWYgKCEoJENvZGUgLWlzIFtTY3JpcHRCbG9ja10pKSB7cmV0dXJuICRDb2RlfQ0KICAgIGlmICghJEFzUHJvY2Vzc0Jsb2NrKSB7cmV0dXJuICYgJENvZGUgQF9fUmVzdH0NCiAgICByZXR1cm4gRm9yRWFjaC1PYmplY3QgLXByb2Nlc3MgJENvZGUgLUlucHV0T2JqZWN0ICRfX1Jlc3QNCn0KCmZ1bmN0aW9uIEdldC1QYXRoIHtwYXJhbSgkbWF0Y2gsIFtzdHJpbmddJFBhdGhWYXIgPSAiUEFUSCIpDQoNCiAgICAkUHRoID0gW0Vudmlyb25tZW50XTo6R2V0RW52aXJvbm1lbnRWYXJpYWJsZSgkUGF0aFZhcikNCiAgICAkSXNVbml4ID0gJFBTVmVyc2lvblRhYmxlLlBsYXRmb3JtIC1lcSAiVW5peCINCiAgICAkUGF0aFNlcCA9ICQoaWYgKCRJc1VuaXgpIHsiOiJ9IGVsc2UgeyI7In0pDQogICAgaWYgKCEkUHRoKSB7cmV0dXJuIEAoKX0NCiAgICBTZXQtUGF0aCAkUHRoIC1QYXRoVmFyICRQYXRoVmFyDQogICAgJGQgPSAoJFB0aCkuc3BsaXQoJFBhdGhTZXApDQogICAgaWYgKCRtYXRjaCkgeyRkIC1tYXRjaCAkbWF0Y2h9IGVsc2UgeyRkfQ0KfQoKZnVuY3Rpb24gV3JpdGUtQVAgew0KICAgIFtDbWRsZXRCaW5kaW5nKCldDQogICAgcGFyYW0oW1BhcmFtZXRlcihWYWx1ZUZyb21QaXBlbGluZT0kdHJ1ZSwgTWFuZGF0b3J5PSRUcnVlKV0kVGV4dCxbU3dpdGNoXSROb1NpZ24sW1N3aXRjaF0kUGxhaW5UZXh0LFtWYWxpZGF0ZVNldCgiQ2VudGVyIiwiUmlnaHQiLCJMZWZ0IildW1N0cmluZ10kQWxpZ249J0xlZnQnLFtTd2l0Y2hdJFBhc3NUaHJ1KQ0KICAgIGJlZ2luIHskVFQgPSBAKCl9DQogICAgUHJvY2VzcyB7JFRUICs9ICwkVGV4dH0NCiAgICBFTkQgew0KICAgICAgICAkQmx1ZSA9ICQoaWYgKCRXUklURV9BUF9MRUdBQ1lfQ09MT1JTKXszfWVsc2V7J0JsdWUnfSkNCiAgICAgICAgaWYgKCRUVC5jb3VudCAtZXEgMSkgeyRUVCA9ICRUVFswXX07JFRleHQgPSAkVFQNCiAgICAgICAgaWYgKCR0ZXh0LmNvdW50IC1ndCAxIC1vciAkdGV4dC5HZXRUeXBlKCkuTmFtZSAtbWF0Y2ggIlxbXF0kIikgew0KICAgICAgICAgICAgcmV0dXJuICRUZXh0IHwgJSB7DQogICAgICAgICAgICAgICAgV3JpdGUtQVAgJF8gLU5vU2lnbjokTm9TaWduIC1QbGFpblRleHQ6JFBsYWluVGV4dCAtQWxpZ24gJEFsaWduIC1QYXNzVGhydTokUGFzc1RocnUNCiAgICAgICAgICAgIH0NCiAgICAgICAgfQ0KICAgICAgICBpZiAoISR0ZXh0IC1vciAkdGV4dCAtbm90bWF0Y2ggIig/c21pKV4oKD88Tk5MPngpfCg/PE5TPm5zPykpezAsMn0oPzx0Plw+KikoPzxzPltcK1wtXCFcKlwjXEBfXSkoPzx3Pi4qKSIpIHtyZXR1cm4gV3JpdGUtSG9zdCAkVGV4dH0NCiAgICAgICAgJHRiICA9ICIgICAgIiokTWF0Y2hlcy50Lmxlbmd0aA0KICAgICAgICAkQ29sID0gQHsnKyc9JzInOyctJz0nMTInOychJz0nMTQnOycqJz0kQmx1ZTsnIyc9J0RhcmtHcmF5JzsnQCc9J0dyYXknOydfJz0nd2hpdGUnfVsoJFNpZ24gPSAkTWF0Y2hlcy5TKV0NCiAgICAgICAgaWYgKCEkQ29sKSB7VGhyb3cgIkluY29ycmVjdCBTaWduIFskU2lnbl0gUGFzc2VkISJ9DQogICAgICAgICRTaWduID0gJChpZiAoJE5vU2lnbiAtb3IgJE1hdGNoZXMuTlMpIHsiIn0gZWxzZSB7IlskU2lnbl0gIn0pDQogICAgICAgICREYXRhID0gIiR0YiRTaWduJCgkTWF0Y2hlcy5XKSI7aWYgKCEkRGF0YSkge3JldHVybiBXcml0ZS1Ib3N0ICIifQ0KICAgICAgICBpZiAoQVAtUmVxdWlyZSAiZnVuY3Rpb246QWxpZ24tVGV4dCIgLXBhKSB7DQogICAgICAgICAgICAkRGF0YSA9IEFsaWduLVRleHQgLUFsaWduICRBbGlnbiAiJHRiJFNpZ24kKCRNYXRjaGVzLlcpIg0KICAgICAgICB9DQogICAgICAgIGlmICgkUGxhaW5UZXh0KSB7cmV0dXJuICREYXRhfQ0KICAgICAgICAkRGF0YUxpbmVzID0gJERhdGEgLXNwbGl0ICJgbiINCiAgICAgICAgMS4uJERhdGFMaW5lcy5Db3VudCB8ICUgew0KICAgICAgICAgICAgJElkeCA9ICRfIC0gMQ0KICAgICAgICAgICAgJE5OTCA9ICEkaWR4IC1hbmQgJE1hdGNoZXMuTk5MDQogICAgICAgICAgICBXcml0ZS1Ib3N0IC1Ob05ld0xpbmU6JE5OTCAtZiAkQ29sICREYXRhTGluZXNbJElkeF0NCiAgICAgICAgICAgIGlmICgkUGFzc1RocnUpIHtyZXR1cm4gJERhdGF9DQogICAgICAgIH0NCiAgICB9DQp9CgpmdW5jdGlvbiBQcmludC1MaXN0IHtwYXJhbSgkeCwgW1N3aXRjaF0kSW5SZWN1cnNlKQ0KDQogICAgaWYgKCR4LmNvdW50IC1sZSAxKSB7cmV0dXJuID86KCRJblJlY3Vyc2UpeyR4fXsiWyR4XSJ9fSBlbHNlIHsNCiAgICAgICAgcmV0dXJuICJbJCgoJHggfCAlIHtQcmludC1MaXN0ICRfIC1JblJlY3Vyc2V9KSAtam9pbiAnLCAnKV0iDQogICAgfQ0KfQoKZnVuY3Rpb24gU2V0LVBhdGggew0KICAgIFtjbWRsZXRiaW5kaW5nKCldDQogICAgcGFyYW0oDQogICAgICAgIFtQYXJhbWV0ZXIoTWFuZGF0b3J5ID0gJHRydWUsIFZhbHVlRnJvbVBpcGVsaW5lID0gJHRydWUpXVtzdHJpbmdbXV0kUGF0aCwNCiAgICAgICAgW3N0cmluZ10kUGF0aFZhciA9ICJQQVRIIg0KICAgICkNCiAgICBiZWdpbiB7DQogICAgICAgIFtzdHJpbmdbXV0kRmluYWxQYXRoDQogICAgfQ0KICAgIHByb2Nlc3Mgew0KICAgICAgICAkUGF0aCB8ICUgew0KICAgICAgICAgICAgJEZpbmFsUGF0aCArPSAkXw0KICAgICAgICB9DQogICAgfQ0KICAgIGVuZCB7DQogICAgICAgICRJc1VuaXggPSAkUFNWZXJzaW9uVGFibGUuUGxhdGZvcm0gLWVxICJVbml4Ig0KICAgICAgICAkUGF0aFNlcCA9ICQoaWYgKCRJc1VuaXgpIHsiOiJ9IGVsc2UgeyI7In0pDQogICAgICAgICRQdGggPSAkRmluYWxQYXRoIC1qb2luICRQYXRoU2VwDQogICAgICAgICRQdGggPSAoJFB0aCAtcmVwbGFjZSgiJFBhdGhTZXArIiwgJFBhdGhTZXApIC1yZXBsYWNlKCJcXCRQYXRoU2VwfFxcJCIsICRQYXRoU2VwKSkudHJpbSgkUGF0aFNlcCkNCiAgICAgICAgJFB0aCA9ICgoJFB0aCkuc3BsaXQoJFBhdGhTZXApIHwgc2VsZWN0IC11bmlxdWUpIC1qb2luICRQYXRoU2VwDQogICAgICAgIFtFbnZpcm9ubWVudF06OlNldEVudmlyb25tZW50VmFyaWFibGUoJFBhdGhWYXIsICRQdGgpDQogICAgfQ0KfQoKZnVuY3Rpb24gQWxpZ24tVGV4dCB7cGFyYW0oW1BhcmFtZXRlcihNYW5kYXRvcnk9JFRydWUpXVtTdHJpbmdbXV0kVGV4dCwgW1ZhbGlkYXRlU2V0KCJDZW50ZXIiLCJSaWdodCIsIkxlZnQiKV1bU3RyaW5nXSRBbGlnbj0nQ2VudGVyJykNCg0KICAgIGlmICgkQWxpZ24gLWVxICJMZWZ0Iikge3JldHVybiAkVGV4dH0NCiAgICANCiAgICBpZiAoJFRleHQuY291bnQgLWd0IDEpIHsNCiAgICAgICAgcmV0dXJuICRUZXh0IHwgJSB7QWxpZ24tVGV4dCAkXyAkQWxpZ259ICAgDQogICAgfQ0KICAgICRXaW5TaXplID0gW2NvbnNvbGVdOjpCdWZmZXJXaWR0aA0KICAgICRDbGVhblRleHRTaXplID0gKFN0cmlwLUNvbG9yQ29kZXMgKCIiKyRUZXh0KSkuTGVuZ3RoDQogICAgaWYgKCRDbGVhblRleHRTaXplIC1nZSAkV2luU2l6ZSkgew0KICAgICAgICAkQXBwZW5kZXIgPSBAKCIiKTsNCiAgICAgICAgJGogPSAwDQogICAgICAgIGZvcmVhY2ggKCRwIGluIDAuLigkQ2xlYW5UZXh0U2l6ZS0xKSl7DQogICAgICAgICAgICBpZiAoKCRwKzEpJSR3aW5zaXplIC1lcSAwKSB7JGorKzskQXBwZW5kZXIgKz0gIiJ9DQogICAgICAgICAgICAjICIiKyRqKyIgLSAiKyRwDQogICAgICAgICAgICAkQXBwZW5kZXJbJGpdICs9ICRUZXh0LmNoYXJzKCRwKQ0KICAgICAgICB9DQogICAgICAgIHJldHVybiAoQWxpZ24tVGV4dCAkQXBwZW5kZXIgJEFsaWduKQ0KICAgIH0NCiAgICBpZiAoJEFsaWduIC1lcSAiQ2VudGVyIikgew0KICAgICAgICByZXR1cm4gKCIgIipbbWF0aF06OnRydW5jYXRlKCgkV2luU2l6ZS0kQ2xlYW5UZXh0U2l6ZSkvMikrJFRleHQpDQogICAgfQ0KICAgICMgUmlnaHQNCiAgICByZXR1cm4gKCIgIiooJFdpblNpemUtJENsZWFuVGV4dFNpemUtMSkrJFRleHQpDQp9CgpmdW5jdGlvbiBBUC1SZXF1aXJlIHtwYXJhbShbUGFyYW1ldGVyKE1hbmRhdG9yeT0kVHJ1ZSldW0FsaWFzKCJGdW5jdGlvbmFsaXR5IiwiTGlicmFyeSIpXVtBcmd1bWVudENvbXBsZXRlcih7DQogICAgW091dHB1dFR5cGUoW1N5c3RlbS5NYW5hZ2VtZW50LkF1dG9tYXRpb24uQ29tcGxldGlvblJlc3VsdF0pXQ0KICAgIHBhcmFtKA0KICAgICAgICBbc3RyaW5nXSAkQ29tbWFuZE5hbWUsDQogICAgICAgIFtzdHJpbmddICRQYXJhbWV0ZXJOYW1lLA0KICAgICAgICBbc3RyaW5nXSAkV29yZFRvQ29tcGxldGUsDQogICAgICAgIFtTeXN0ZW0uTWFuYWdlbWVudC5BdXRvbWF0aW9uLkxhbmd1YWdlLkNvbW1hbmRBc3RdICRDb21tYW5kQXN0LA0KICAgICAgICBbU3lzdGVtLkNvbGxlY3Rpb25zLklEaWN0aW9uYXJ5XSAkRmFrZUJvdW5kUGFyYW1ldGVycw0KICAgICkNCiAgICAkQ29tcGxldGlvblJlc3VsdHMgPSBbU3lzdGVtLkNvbGxlY3Rpb25zLkdlbmVyaWMuTGlzdFtTeXN0ZW0uTWFuYWdlbWVudC5BdXRvbWF0aW9uLkNvbXBsZXRpb25SZXN1bHRdXTo6bmV3KCkNCiAgICAkTGliID0gQCgiSW50ZXJuZXQiLCJvczp3aW5kb3dzIiwib3M6bGludXgiLCJvczp1bml4IiwiYWRtaW5pc3RyYXRvciIsInJvb3QiLCJsaWI6IiwibGliX3Rlc3Q6IiwiZnVuY3Rpb246Iiwic3RyaWN0X2Z1bmN0aW9uOiIsImFiaWxpdHk6ZXNjYXBlX2NvZGVzIiwiYWJpbGl0eTplbW9qaXMiKQ0KICAgICRqc09yID0ge2ZvcmVhY2ggKCRhIGluICRhcmdzKSB7JGEgPSBJbnZva2UtT3JSZXR1cm4gJGE7aWYgKCEkYSl7Y29udGludWV9O3JldHVybiAkYX07cmV0dXJuICRhfSAjIE1hbnVhbGx5IGVtYmVkZGVkIEpTLU9SDQogICAgJiAkanNPciB7JExpYiB8ID8geyRfIC1saWtlICIkV29yZFRvQ29tcGxldGUqIn19IHskTGliIHwgPyB7JF8gLWxpa2UgIiokV29yZFRvQ29tcGxldGUqIn19IHwgJSB7DQogICAgICAgICRDb21wbGV0aW9uUmVzdWx0cy5BZGQoW1N5c3RlbS5NYW5hZ2VtZW50LkF1dG9tYXRpb24uQ29tcGxldGlvblJlc3VsdF06Om5ldygkXywgJF8sICdQYXJhbWV0ZXJWYWx1ZScsICRfKSkNCiAgICB9DQogICAgcmV0dXJuICRDb21wbGV0aW9uUmVzdWx0cw0KfSldW1N0cmluZ10kTGliLCBbU2NyaXB0QmxvY2tdJE9uRmFpbCwgW1N3aXRjaF0kUGFzc1RocnUpDQoNCiAgICAkTG9hZE1vZHVsZSA9IHsNCiAgICAgICAgcGFyYW0oJEZpbGUsW2Jvb2xdJEltcG9ydCkNCiAgICAgICAgdHJ5IHtJbXBvcnQtTW9kdWxlICRGaWxlIC1lYSBzdG9wO3JldHVybiAxfSBjYXRjaCB7fQ0KICAgICAgICAkTGliPUFQLUNvbnZlcnRQYXRoICI8TElCPiI7JExGID0gIiRMaWJcJEZpbGUiDQogICAgICAgIFtzdHJpbmddJGYgPSBpZih0ZXN0LXBhdGggLXQgbGVhZiAkTEYpeyRMRn1lbHNlaWYodGVzdC1wYXRoIC10IGxlYWYgIiRMRi5kbGwiKXsiJExGLmRsbCJ9DQogICAgICAgIGlmICgkZiAtYW5kICRJbXBvcnQpIHtJbXBvcnQtTW9kdWxlICRmfQ0KICAgICAgICByZXR1cm4gJGYNCiAgICB9DQogICAgJEludm9rZU9yUmV0dXJuID0gew0KICAgICAgICBwYXJhbSgkQ21kKQ0KICAgICAgICBpZiAoJENtZCAtaXMgW1NjcmlwdEJsb2NrXSkgeyYgJENtZH0gZWxzZSB7JENtZH0NCiAgICB9DQogICAgaWYgKCEkT25GYWlsKSB7JFBhc3NUaHJ1ID0gJHRydWV9DQogICAgJFN0YXQgPSAkKHN3aXRjaCAtcmVnZXggKCRMaWIudHJpbSgpKSB7DQogICAgICAgICJeSW50ZXJuZXQkIiAgICAgICAgICAgICAgICAgICB7dGVzdC1jb25uZWN0aW9uIGdvb2dsZS5jb20gLUNvdW50IDEgLVF1aWV0fQ0KICAgICAgICAiXm9zOih3aW4oZG93cyk/fGxpbnV4fHVuaXgpJCIgeyRJc1VuaXggPSAkUFNWZXJzaW9uVGFibGUuUGxhdGZvcm0gLWVxICJVbml4IjtpZiAoJE1hdGNoZXNbMV0gLW1hdGNoICJed2luIikgeyEkSXNVbml4fSBlbHNlIHskSXNVbml4fX0NCiAgICAgICAgIl5hZG1pbihpc3RyYXRvcik/JHxecm9vdCQiICAgIHtUZXN0LUFkbWluaXN0cmF0b3J9DQogICAgICAgICJeZGVwOiguKikkIiAgICAgICAgICAgICAgICAgICB7R2V0LVdoZXJlICRNYXRjaGVzWzFdfQ0KICAgICAgICAiXihsaWJ8bW9kdWxlKTooLiopJCIgICAgICAgICAgeyRMb2FkTW9kdWxlLmludm9rZSgkTWF0Y2hlc1syXSwgJHRydWUpfQ0KICAgICAgICAiXihsaWJ8bW9kdWxlKV90ZXN0OiguKikkIiAgICAgeyRMb2FkTW9kdWxlLmludm9rZSgkTWF0Y2hlc1syXSl9DQogICAgICAgICJeZnVuY3Rpb246KC4qKSQiICAgICAgICAgICAgICB7Z2NtICRNYXRjaGVzWzFdIC1lYSBTaWxlbnRseUNvbnRpbnVlfQ0KICAgICAgICAiXnN0cmljdF9mdW5jdGlvbjooLiopJCIgICAgICAge1Rlc3QtUGF0aCAiRnVuY3Rpb246XCQoJE1hdGNoZXNbMV0pIn0NCiAgICAgICAgIl5hYmlsaXR5Oihlc2NhcGVfY29kZXN8ZW1vamlzKSQiICAgICB7JiAkSW52b2tlT3JSZXR1cm4gKEB7DQogICAgICAgICAgICBlc2NhcGVfY29kZXMgPSAkSG9zdC5VSS5TdXBwb3J0c1ZpcnR1YWxUZXJtaW5hbA0KICAgICAgICAgICAgZW1vamlzID0gJGVudjpXVF9TRVNTSU9OIC1vciAkZW52OldUX1BST0ZJTEVfSUQNCiAgICAgICAgfVskTWF0Y2hlc1sxXV0pfQ0KICAgICAgICBkZWZhdWx0IHtXcml0ZS1BUCAiIUludmFsaWQgc2VsZWN0b3IgcHJvdmlkZWQgWyQoIiRMaWIiLnNwbGl0KCc6JylbMF0pXSI7dGhyb3cgJ0JBRF9TRUxFQ1RPUid9DQogICAgfSkNCiAgICBpZiAoISRTdGF0IC1hbmQgJE9uRmFpbCkgeyYgJE9uRmFpbH0NCiAgICBpZiAoJFBhc3NUaHJ1IC1vciAhJE9uRmFpbCkge3JldHVybiAkU3RhdH0NCn0KCmZ1bmN0aW9uIEpTLU9SIHtmb3JlYWNoICgkYSBpbiAkYXJncykgeyRyID0gSW52b2tlLU9yUmV0dXJuICRhO2lmICghJHIpe2NvbnRpbnVlfTtyZXR1cm4gJHJ9O3JldHVybiAkcn0KCmZ1bmN0aW9uIEdldC1GaWxlRW5jb2Rpbmcge3BhcmFtKFtQYXJhbWV0ZXIoTWFuZGF0b3J5PSRUcnVlKV0kUGF0aCkNCg0KICAgICRieXRlcyA9IFtieXRlW11dKEdldC1Db250ZW50ICRQYXRoIC1Bc0J5dGVTdHJlYW0gLVJlYWRDb3VudCA0IC1Ub3RhbENvdW50IDQpDQoNCiAgICBpZighJGJ5dGVzKSB7IHJldHVybiAndXRmOCcgfQ0KDQogICAgc3dpdGNoIC1yZWdleCAoJ3swOngyfXsxOngyfXsyOngyfXszOngyfScgLWYgJGJ5dGVzWzBdLCRieXRlc1sxXSwkYnl0ZXNbMl0sJGJ5dGVzWzNdKSB7DQogICAgICAgICdeZWZiYmJmJyAgIHtyZXR1cm4gJ3V0ZjgnfQ0KICAgICAgICAnXjJiMmY3NicgICB7cmV0dXJuICd1dGY3J30NCiAgICAgICAgJ15mZmZlJyAgICAge3JldHVybiAndW5pY29kZSd9DQogICAgICAgICdeZmVmZicgICAgIHtyZXR1cm4gJ2JpZ2VuZGlhbnVuaWNvZGUnfQ0KICAgICAgICAnXjAwMDBmZWZmJyB7cmV0dXJuICd1dGYzMid9DQogICAgICAgIGRlZmF1bHQgICAgIHtyZXR1cm4gJ2FzY2lpJ30NCiAgICB9DQp9CgpmdW5jdGlvbiBHZXQtRXNjYXBlIHsNCiAgICBpZiAoIShBUC1SZXF1aXJlICJhYmlsaXR5OmVzY2FwZV9jb2RlcyIpKSB7dGhyb3cgIltHZXQtUkJHXSBZb3VyIGNvbnNvbGUgZG9lcyBub3Qgc3VwcG9ydCBBTlNJIGVzY2FwZSBjb2RlcyJ9DQogICAgIyBXZSBkbyB0aGlzLCBiZWNhdXNlIFBvd2VyU2hlbGwgTmF0aXZlIGRvZXNuJ3Qga25vdyBgZQ0KICAgIHJldHVybiBbQ2hhcl0weDFiICMgYGUNCn0KCmZ1bmN0aW9uIENvbnZlcnQtVG9CYXNlNjQge3BhcmFtKFtQYXJhbWV0ZXIoVmFsdWVGcm9tUGlwZWxpbmU9JHRydWUpXVtTdHJpbmddJFRleHQsIFtWYWxpZGF0ZVNldCgiVVRGOCIsIlVuaWNvZGUiKV1bU3RyaW5nXSRFbmNvZGluZyA9ICJVVEY4IikNCg0KICAgIFtTeXN0ZW0uQ29udmVydF06OlRvQmFzZTY0U3RyaW5nKFtTeXN0ZW0uVGV4dC5FbmNvZGluZ106OiRFbmNvZGluZy5HZXRCeXRlcygkVGV4dCkpDQp9CgpmdW5jdGlvbiBJbnZva2UtVGVybmFyeSB7cGFyYW0oJGRlY2lkZXIsICRpZnRydWUsICRpZmZhbHNlID0ge30pDQoNCiAgICAkSW52b2tlT3JSZXR1cm4gPSB7DQogICAgICAgIHBhcmFtKCRDbWQpDQogICAgICAgIGlmICgkQ21kIC1pcyBbU2NyaXB0QmxvY2tdKSB7JiAkQ21kfSBlbHNlIHskQ21kfQ0KICAgIH0NCiAgICBpZiAoJGRlY2lkZXIpIHsgJiAkSW52b2tlT3JSZXR1cm4gJGlmdHJ1ZSB9IGVsc2UgeyAmICRJbnZva2VPclJldHVybiAkaWZmYWxzZSB9DQp9CgpmdW5jdGlvbiBXcml0ZS1BUEwgew0KICAgIFtDbWRsZXRCaW5kaW5nKCldDQogICAgcGFyYW0oDQogICAgICAgIFtQYXJhbWV0ZXIoVmFsdWVGcm9tUGlwZWxpbmU9JHRydWUsIE1hbmRhdG9yeT0kVHJ1ZSldJFRleHQsDQogICAgICAgIFtBbGlhcygnTlMnKV1bU3dpdGNoXSROb1NpZ24sDQogICAgICAgIFtBbGlhcygnTk5MJywnTkwnKV1bU3dpdGNoXSROb05ld0xpbmUsDQogICAgICAgIFtTd2l0Y2hdJFBhc3NUaHJ1DQogICAgKQ0KICAgIGJlZ2luIHsNCiAgICAgICAgJFNpZ25SZ3ggPSAiW1wrXC1cIVwqXCNcQF9dIjsgJFRUID0gQCgpDQogICAgICAgICRJc1ZlcmJvc2UgPSAkUFNDbWRsZXQuTXlJbnZvY2F0aW9uLkJvdW5kUGFyYW1ldGVycy5WZXJib3NlDQogICAgfQ0KICAgIHByb2Nlc3Mge0ZsYXR0ZW4gJFRleHQgfCAlIHsNCiAgICAgICAgJExpbmUgPSAkXyAtc3BsaXQgImBuIg0KICAgICAgICAkTGluZVN5bWJvbCA9ICQoaWYgKCRsaW5lWzBdIC1tYXRjaCAiXm4/eD9uPyhcPiopKCRTaWduUmd4KS4qJCIpIHskTWF0Y2hlc1syXX0gZWxzZSB7IiJ9KQ0KICAgICAgICBpZiAoJElzVmVyYm9zZSkge1dyaXRlLVZlcmJvc2UgIiQoY29sIGkpTGluZVN5bWJvbDogJExpbmVTeW1ib2wgfCBMaW5lOiAkTGluZSQoY29sIHJTKSJ9DQogICAgICAgIDEuLiRMaW5lLkxlbmd0aCB8ICUgew0KICAgICAgICAgICAgJGlkeCA9ICRfIC0gMQ0KICAgICAgICAgICAgaWYgKCRpZHgpIHskVFQgKz0gImBuIiskTGluZVN5bWJvbCskTGluZVskaWR4XX0NCiAgICAgICAgICAgIGVsc2UgeyRUVCArPSAkTGluZVskaWR4XX0NCiAgICAgICAgfQ0KICAgIH19DQogICAgZW5kIHsNCiAgICAgICAgaWYgKCRJc1ZlcmJvc2UpIHtXcml0ZS1WZXJib3NlICIkKGNvbCBpKSQoUHJpbnQtTGlzdCAkVFQpJChjb2wgclMpIn0NCiAgICAgICAgZm9yICgkaT0wOyRpIC1sdCAkVFQuY291bnQ7JGkrKykgew0KICAgICAgICAgICAgW3N0cmluZ10kQ2h1bmsgPSAkVFRbJGldDQogICAgICAgICAgICBpZiAoJENodW5rWzBdIC1lcSAiYG4iKSB7JENodW5rID0gJENodW5rLlN1YnN0cmluZygxKTtXcml0ZS1Ib3N0fSAjIFNwZWNpYWwgY2FzZSBmb3IgbmV3IGxpbmUgdmlhIGBuDQogICAgICAgICAgICAkQ2h1bmsgPSAkQ2h1bmsgLXJlcGxhY2UgIl5uP3g/bj8oXD4qJFNpZ25SZ3gpIiwnJDEnDQogICAgICAgICAgICBpZiAoJENodW5rIC1ub3RtYXRjaCAiXlw+KiRTaWduUmd4LioiKSB7JENodW5rID0gIl8kQ2h1bmsifSAjIFVzZSBkZWZhdWx0IGFzIHdoaXRlDQogICAgICAgICAgICAkUHJlZml4Q29kZSA9ID86ICgkaSAtZXEgMCkgeyJ4JCg/OiAkTm9TaWduIHsnbid9IHsnJ30pIn0gez86ICgkaSAtbmUgKCRUVC5Db3VudCAtIDEpKSB7Im54In0gIm4kKD86ICROb05ld0xpbmUgeyd4J30geycnfSkifQ0KICAgICAgICAgICAgaWYgKCRUVC5Db3VudCAtZXEgMSkgeyRQcmVmaXhDb2RlID0gIiQoPzogJE5vU2lnbiB7J24nfSB7Jyd9KSQoPzogJE5vTmV3TGluZSB7J3gnfSB7Jyd9KSJ9DQogICAgICAgICAgICBpZiAoJElzVmVyYm9zZSkge1dyaXRlLVZlcmJvc2UgIiQoY29sIGkpUHJlZml4Q29kZTogJFByZWZpeENvZGUgfCBDaHVuazogJENodW5rJChjb2wgclMpIn0NCiAgICAgICAgICAgIFdyaXRlLUFQICIkUHJlZml4Q29kZSRDaHVuayIgLVBhc3NUaHJ1OiRQYXNzVGhydQ0KICAgICAgICB9DQogICAgfQ0KfQoKZnVuY3Rpb24gQVAtQ29udmVydFBhdGgge3BhcmFtKFtQYXJhbWV0ZXIoTWFuZGF0b3J5PSRUcnVlKV1bU3RyaW5nXSRQYXRoKQ0KDQogICAgJFBhdGhTZXAgPSBbSU8uUGF0aF06OkRpcmVjdG9yeVNlcGFyYXRvckNoYXINCiAgICByZXR1cm4gJFBhdGggLXJlcGxhY2UgDQogICAgICAgICI8RGVwPiIsIjxMaWI+JHtQYXRoU2VwfURlcGVuZGVuY2llcyIgLXJlcGxhY2UgDQogICAgICAgICI8TGliPiIsIjxIb21lPiR7UGF0aFNlcH1BUC1MaWJyYXJpZXMiIC1yZXBsYWNlIA0KICAgICAgICAiPENvbXAob25lbnRzKT8+IiwiPEhvbWU+JHtQYXRoU2VwfUFQLUNvbXBvbmVudHMiIC1yZXBsYWNlIA0KICAgICAgICAiPEhvbWU+IiwkUFNIZWxsfQoKZnVuY3Rpb24gVGVzdC1BZG1pbmlzdHJhdG9yIHsNCiAgICBpZiAoJFBTVmVyc2lvblRhYmxlLlBsYXRmb3JtIC1lcSAiVW5peCIpIHsNCiAgICAgICAgaWYgKCQod2hvYW1pKSAtZXEgInJvb3QiKSB7DQogICAgICAgICAgICByZXR1cm4gJHRydWUNCiAgICAgICAgfQ0KICAgICAgICBlbHNlIHsNCiAgICAgICAgICAgIHJldHVybiAkZmFsc2UNCiAgICAgICAgfQ0KICAgIH0NCiAgICAjIFdpbmRvd3MNCiAgICAoTmV3LU9iamVjdCBTZWN1cml0eS5QcmluY2lwYWwuV2luZG93c1ByaW5jaXBhbCAoW1NlY3VyaXR5LlByaW5jaXBhbC5XaW5kb3dzSWRlbnRpdHldOjpHZXRDdXJyZW50KCkpKS5Jc0luUm9sZShbU2VjdXJpdHkuUHJpbmNpcGFsLldpbmRvd3NCdWlsdGluUm9sZV06OkFkbWluaXN0cmF0b3IpDQp9CgpmdW5jdGlvbiBGbGF0dGVuIHtwYXJhbShbb2JqZWN0W11dJHgpDQoNCiAgICBpZiAoISgkWCAtaXMgW2FycmF5XSkpIHtyZXR1cm4gJHh9DQogICAgaWYgKCRYLmNvdW50IC1lcSAxKSB7DQogICAgICAgIHJldHVybiAkeCB8ICUgeyRffQ0KICAgIH0NCiAgICAkeCB8ICUge0ZsYXR0ZW4gJF99DQp9CgpTZXQtQWxpYXMgPzogSW52b2tlLVRlcm5hcnkKU2V0LUFsaWFzIGNvbCBHZXQtQ29sb3I=")
# ========================================END=OF=COMPILER===========================================================|
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
$TmpHash = @{}
$AP_CONSOLE.functions | % {$TmpHash.$_ = $_}
$Aliases = Get-Alias | ? {$TmpHash.($_.Definition)} | % {"$_"}

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
    Write-APL ">+","Compiled [","+$OutFile","] with Encoding [","+$(JS-OR $Enc.EncodingName $Enc)","] in Folder [","*$OutputFolder","]"
    $Data | Out-File -Encoding $Enc "$OutputFolder\$OutFile"
}

function Remove-OldInjecter ($Data) {
    $ReplaceExpr = "(?s)\# ?=+START=OF=COMPILER=+\|`n.+\# ?=+END=OF=COMPILER=+\|"
    return $Data -replace "$ReplaceExpr`n|`n$ReplaceExpr",""
}

# Validation
if (!$File -or !(Test-Path -type Leaf $File)) {Throw "Invalid File [$File]";exit}
if (!(Test-Path -type Container $OutputFolder)) {Throw "Invalid Folder [$OutputFolder]";exit}
if ($File -notmatch ".\.ps1$") {Throw "Invalid File Type [$File], expected *.ps1";exit}
$File = (Get-Item $File).FullName
$OutputFolder = (Get-Item $OutputFolder).FullName

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
        "# =======================================START=OF=COMPILER==========================================================|"
        "#    The Following Code was added by AP-Compiler $Ver To Make this program independent of AP-Core Engine"
        "#    GitHub: https://github.com/avdaredevil/AP-Compiler"
        "# ==================================================================================================================|"
        '$Script:PSHell=$(if($PSHell){$PSHell}elseif($PSScriptRoot){$PSScriptRoot}else{"."});'
        "`$Script:AP_Console = @{version=[version]'$($AP_CONSOLE.Version)'; isShim = `$true}"
        "function B64 {$("${Function:Convert-FromBase64}".trim() -replace "(`r?`n){2,}"," ")}"
        "# This syntax is to prevent AV's from misclassifying this as anything but innocuous"
        "& (Get-Alias iex) (B64 ""$(Convert-ToBase64 ($Code -join "`n"))"")"
        "# ========================================END=OF=COMPILER===========================================================|"
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
