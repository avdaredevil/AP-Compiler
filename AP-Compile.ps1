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
& (Get-Alias iex) (B64 "ZnVuY3Rpb24gQ29udmVydC1Ub0Jhc2U2NCB7cGFyYW0oW1BhcmFtZXRlcihWYWx1ZUZyb21QaXBlbGluZT0kdHJ1ZSldW1N0cmluZ10kVGV4dCwgW1ZhbGlkYXRlU2V0KCJVVEY4IiwiVW5pY29kZSIpXVtTdHJpbmddJEVuY29kaW5nID0gIlVURjgiKQ0KDQogICAgW1N5c3RlbS5Db252ZXJ0XTo6VG9CYXNlNjRTdHJpbmcoW1N5c3RlbS5UZXh0LkVuY29kaW5nXTo6JEVuY29kaW5nLkdldEJ5dGVzKCRUZXh0KSkNCn0KCmZ1bmN0aW9uIEZsYXR0ZW4ge3BhcmFtKFtvYmplY3RbXV0keCkNCg0KICAgIGlmICghKCRYIC1pcyBbYXJyYXldKSkge3JldHVybiAkeH0NCiAgICBpZiAoJFguY291bnQgLWVxIDEpIHsNCiAgICAgICAgcmV0dXJuICR4IHwgJSB7JF99DQogICAgfQ0KICAgICR4IHwgJSB7RmxhdHRlbiAkX30NCn0KCmZ1bmN0aW9uIEFsaWduLVRleHQge3BhcmFtKFtQYXJhbWV0ZXIoTWFuZGF0b3J5PSRUcnVlKV1bU3RyaW5nW11dJFRleHQsIFtWYWxpZGF0ZVNldCgiQ2VudGVyIiwiUmlnaHQiLCJMZWZ0IildW1N0cmluZ10kQWxpZ249J0NlbnRlcicpDQoNCiAgICBpZiAoJFRleHQuY291bnQgLWd0IDEpIHsNCiAgICAgICAgJGFucyA9IEAoKQ0KICAgICAgICBmb3JlYWNoICgkbG4gaW4gJFRleHQpIHskQW5zICs9IEFsaWduLVRleHQgJGxuICRBbGlnbn0NCiAgICAgICAgcmV0dXJuICgkYW5zKQ0KICAgIH0gZWxzZSB7DQogICAgICAgICRXaW5TaXplID0gW2NvbnNvbGVdOjpCdWZmZXJXaWR0aA0KICAgICAgICAkQ2xlYW5UZXh0U2l6ZSA9IChTdHJpcC1Db2xvckNvZGVzICgiIiskVGV4dCkpLkxlbmd0aA0KICAgICAgICBpZiAoJENsZWFuVGV4dFNpemUgLWdlICRXaW5TaXplKSB7DQogICAgICAgICAgICAkQXBwZW5kZXIgPSBAKCIiKTsNCiAgICAgICAgICAgICRqID0gMA0KICAgICAgICAgICAgZm9yZWFjaCAoJHAgaW4gMC4uKCRDbGVhblRleHRTaXplLTEpKXsNCiAgICAgICAgICAgICAgICBpZiAoKCRwKzEpJSR3aW5zaXplIC1lcSAwKSB7JGorKzskQXBwZW5kZXIgKz0gIiJ9DQogICAgICAgICAgICAgICAgIyAiIiskaisiIC0gIiskcA0KICAgICAgICAgICAgICAgICRBcHBlbmRlclskal0gKz0gJFRleHQuY2hhcnMoJHApDQogICAgICAgICAgICB9DQogICAgICAgICAgICByZXR1cm4gKEFsaWduLVRleHQgJEFwcGVuZGVyICRBbGlnbikNCiAgICAgICAgfSBlbHNlIHsNCiAgICAgICAgICAgIGlmICgkQWxpZ24gLWVxICJDZW50ZXIiKSB7DQogICAgICAgICAgICAgICAgcmV0dXJuICgiICIqW21hdGhdOjp0cnVuY2F0ZSgoJFdpblNpemUtJENsZWFuVGV4dFNpemUpLzIpKyRUZXh0KQ0KICAgICAgICAgICAgfSBlbHNlaWYgKCRBbGlnbiAtZXEgIlJpZ2h0Iikgew0KICAgICAgICAgICAgICAgIHJldHVybiAoIiAiKigkV2luU2l6ZS0kQ2xlYW5UZXh0U2l6ZS0xKSskVGV4dCkNCiAgICAgICAgICAgIH0gZWxzZSB7DQogICAgICAgICAgICAgICAgcmV0dXJuICgkVGV4dCkNCiAgICAgICAgICAgIH0NCiAgICAgICAgfQ0KICAgIH0NCn0KCmZ1bmN0aW9uIEdldC1QYXRoIHtwYXJhbSgkbWF0Y2gsIFtzdHJpbmddJFBhdGhWYXIgPSAiUEFUSCIpDQoNCiAgICAkUHRoID0gW0Vudmlyb25tZW50XTo6R2V0RW52aXJvbm1lbnRWYXJpYWJsZSgkUGF0aFZhcikNCiAgICAkSXNVbml4ID0gJFBTVmVyc2lvblRhYmxlLlBsYXRmb3JtIC1lcSAiVW5peCINCiAgICAkUGF0aFNlcCA9ICQoaWYgKCRJc1VuaXgpIHsiOiJ9IGVsc2UgeyI7In0pDQogICAgaWYgKCEkUHRoKSB7cmV0dXJuIEAoKX0NCiAgICBTZXQtUGF0aCAkUHRoIC1QYXRoVmFyICRQYXRoVmFyDQogICAgJGQgPSAoJFB0aCkuc3BsaXQoJFBhdGhTZXApDQogICAgaWYgKCRtYXRjaCkgeyRkIC1tYXRjaCAkbWF0Y2h9IGVsc2UgeyRkfQ0KfQoKZnVuY3Rpb24gR2V0LUVzY2FwZSB7DQogICAgaWYgKCEoQVAtUmVxdWlyZSAiYWJpbGl0eTplc2NhcGVfY29kZXMiKSkge3Rocm93ICJbR2V0LVJCR10gWW91ciBjb25zb2xlIGRvZXMgbm90IHN1cHBvcnQgQU5TSSBlc2NhcGUgY29kZXMifQ0KICAgIHJldHVybiBbQ2hhcl0weDFiICMgYGUNCn0KCmZ1bmN0aW9uIEdldC1GaWxlRW5jb2Rpbmcge3BhcmFtKFtQYXJhbWV0ZXIoTWFuZGF0b3J5PSRUcnVlKV0kUGF0aCkNCg0KICAgICRieXRlcyA9IFtieXRlW11dKEdldC1Db250ZW50ICRQYXRoIC1Bc0J5dGVTdHJlYW0gLVJlYWRDb3VudCA0IC1Ub3RhbENvdW50IDQpDQoNCiAgICBpZighJGJ5dGVzKSB7IHJldHVybiAndXRmOCcgfQ0KDQogICAgc3dpdGNoIC1yZWdleCAoJ3swOngyfXsxOngyfXsyOngyfXszOngyfScgLWYgJGJ5dGVzWzBdLCRieXRlc1sxXSwkYnl0ZXNbMl0sJGJ5dGVzWzNdKSB7DQogICAgICAgICdeZWZiYmJmJyAgIHtyZXR1cm4gJ3V0ZjgnfQ0KICAgICAgICAnXjJiMmY3NicgICB7cmV0dXJuICd1dGY3J30NCiAgICAgICAgJ15mZmZlJyAgICAge3JldHVybiAndW5pY29kZSd9DQogICAgICAgICdeZmVmZicgICAgIHtyZXR1cm4gJ2JpZ2VuZGlhbnVuaWNvZGUnfQ0KICAgICAgICAnXjAwMDBmZWZmJyB7cmV0dXJuICd1dGYzMid9DQogICAgICAgIGRlZmF1bHQgICAgIHtyZXR1cm4gJ2FzY2lpJ30NCiAgICB9DQp9CgpmdW5jdGlvbiBTdHJpcC1Db2xvckNvZGVzIHtwYXJhbSgkU3RyKQ0KDQogICAgJFN0ciB8ICUgeyRfIC1yZXBsYWNlICIkKFtyZWdleF06OmVzY2FwZSgiJChHZXQtRXNjYXBlKVsiKSlcZCsoXDtcZCspKm0iLCIifQ0KfQoKZnVuY3Rpb24gSW52b2tlLVRlcm5hcnkge3BhcmFtKCRkZWNpZGVyLCAkaWZ0cnVlLCAkaWZmYWxzZSA9IHt9KQ0KDQogICAgJEludm9rZU9yUmV0dXJuID0gew0KICAgICAgICBwYXJhbSgkQ21kKQ0KICAgICAgICBpZiAoJENtZCAtaXMgW1NjcmlwdEJsb2NrXSkgeyYgJENtZH0gZWxzZSB7JENtZH0NCiAgICB9DQogICAgaWYgKCRkZWNpZGVyKSB7ICYgJEludm9rZU9yUmV0dXJuICRpZnRydWUgfSBlbHNlIHsgJiAkSW52b2tlT3JSZXR1cm4gJGlmZmFsc2UgfQ0KfQoKZnVuY3Rpb24gSlMtT1Ige2ZvcmVhY2ggKCRhIGluICRhcmdzKSB7aWYgKCEkYSkge2NvbnRpbnVlfTtpZiAoJGEuR2V0VHlwZSgpLk5hbWUgLWVxICJTY3JpcHRCbG9jayIpIHskYSA9ICRhLmludm9rZSgpO2lmICghJGEpe2NvbnRpbnVlfX07cmV0dXJuICRhfX0KCmZ1bmN0aW9uIFdyaXRlLUFQIHsNCiAgICBbQ21kbGV0QmluZGluZygpXQ0KICAgIHBhcmFtKFtQYXJhbWV0ZXIoVmFsdWVGcm9tUGlwZWxpbmU9JHRydWUsIE1hbmRhdG9yeT0kVHJ1ZSldJFRleHQsW1N3aXRjaF0kTm9TaWduLFtTd2l0Y2hdJFBsYWluVGV4dCxbVmFsaWRhdGVTZXQoIkNlbnRlciIsIlJpZ2h0IiwiTGVmdCIpXVtTdHJpbmddJEFsaWduPSdMZWZ0JyxbU3dpdGNoXSRQYXNzVGhydSkNCiAgICBiZWdpbiB7JFRUID0gQCgpfQ0KICAgIFByb2Nlc3MgeyRUVCArPSAsJFRleHR9DQogICAgRU5EIHsNCiAgICAgICAgJEJsdWUgPSAkKGlmICgkV1JJVEVfQVBfTEVHQUNZX0NPTE9SUyl7M31lbHNleydCbHVlJ30pDQogICAgICAgIGlmICgkVFQuY291bnQgLWVxIDEpIHskVFQgPSAkVFRbMF19OyRUZXh0ID0gJFRUDQogICAgICAgIGlmICgkdGV4dC5jb3VudCAtZ3QgMSAtb3IgJHRleHQuR2V0VHlwZSgpLk5hbWUgLW1hdGNoICJcW1xdJCIpIHsNCiAgICAgICAgICAgIHJldHVybiAkVGV4dCB8ID8geyIkXyJ9IHwgJSB7DQogICAgICAgICAgICAgICAgV3JpdGUtQVAgJF8gLU5vU2lnbjokTm9TaWduIC1QbGFpblRleHQ6JFBsYWluVGV4dCAtQWxpZ24gJEFsaWduIC1QYXNzVGhydTokUGFzc1RocnUNCiAgICAgICAgICAgIH0NCiAgICAgICAgfQ0KICAgICAgICBpZiAoISR0ZXh0IC1vciAkdGV4dCAtbm90bWF0Y2ggIl4oKD88Tk5MPngpfCg/PE5TPm5zPykpezAsMn0oPzx0Plw+KikoPzxzPltcK1wtXCFcKlwjXEBfXSkoPzx3Pi4qKSIpIHtyZXR1cm4gJFRleHR9DQogICAgICAgICR0YiAgPSAiICAgICIqJE1hdGNoZXMudC5sZW5ndGgNCiAgICAgICAgJENvbCA9IEB7JysnPScyJzsnLSc9JzEyJzsnISc9JzE0JzsnKic9JEJsdWU7JyMnPSdEYXJrR3JheSc7J0AnPSdHcmF5JzsnXyc9J3doaXRlJ31bKCRTaWduID0gJE1hdGNoZXMuUyldDQogICAgICAgIGlmICghJENvbCkge1Rocm93ICJJbmNvcnJlY3QgU2lnbiBbJFNpZ25dIFBhc3NlZCEifQ0KICAgICAgICAkU2lnbiA9ICQoaWYgKCROb1NpZ24gLW9yICRNYXRjaGVzLk5TKSB7IiJ9IGVsc2UgeyJbJFNpZ25dICJ9KQ0KICAgICAgICAkRGF0YSA9ICIkdGIkU2lnbiQoJE1hdGNoZXMuVykiO2lmICghJERhdGEpIHtyZXR1cm59DQogICAgICAgIGlmIChBUC1SZXF1aXJlICJmdW5jdGlvbjpBbGlnbi1UZXh0IiAtcGEpIHsNCiAgICAgICAgICAgICREYXRhID0gQWxpZ24tVGV4dCAtQWxpZ24gJEFsaWduICIkdGIkU2lnbiQoJE1hdGNoZXMuVykiDQogICAgICAgIH0NCiAgICAgICAgaWYgKCRQbGFpblRleHQpIHtyZXR1cm4gJERhdGF9DQogICAgICAgIFdyaXRlLUhvc3QgLU5vTmV3TGluZTokKFtib29sXSRNYXRjaGVzLk5OTCkgLWYgJENvbCAkRGF0YQ0KICAgICAgICBpZiAoJFBhc3NUaHJ1KSB7cmV0dXJuICREYXRhfQ0KICAgIH0NCn0KCmZ1bmN0aW9uIFNldC1QYXRoIHsNCiAgICBbY21kbGV0YmluZGluZygpXQ0KICAgIHBhcmFtKA0KICAgICAgICBbUGFyYW1ldGVyKE1hbmRhdG9yeSA9ICR0cnVlLCBWYWx1ZUZyb21QaXBlbGluZSA9ICR0cnVlKV1bc3RyaW5nW11dJFBhdGgsDQogICAgICAgIFtzdHJpbmddJFBhdGhWYXIgPSAiUEFUSCINCiAgICApDQogICAgYmVnaW4gew0KICAgICAgICBbc3RyaW5nW11dJEZpbmFsUGF0aA0KICAgIH0NCiAgICBwcm9jZXNzIHsNCiAgICAgICAgJFBhdGggfCAlIHsNCiAgICAgICAgICAgICRGaW5hbFBhdGggKz0gJF8NCiAgICAgICAgfQ0KICAgIH0NCiAgICBlbmQgew0KICAgICAgICAkSXNVbml4ID0gJFBTVmVyc2lvblRhYmxlLlBsYXRmb3JtIC1lcSAiVW5peCINCiAgICAgICAgJFBhdGhTZXAgPSAkKGlmICgkSXNVbml4KSB7IjoifSBlbHNlIHsiOyJ9KQ0KICAgICAgICAkUHRoID0gJEZpbmFsUGF0aCAtam9pbiAkUGF0aFNlcA0KICAgICAgICAkUHRoID0gKCRQdGggLXJlcGxhY2UoIiRQYXRoU2VwKyIsICRQYXRoU2VwKSAtcmVwbGFjZSgiXFwkUGF0aFNlcHxcXCQiLCAkUGF0aFNlcCkpLnRyaW0oJFBhdGhTZXApDQogICAgICAgICRQdGggPSAoKCRQdGgpLnNwbGl0KCRQYXRoU2VwKSB8IHNlbGVjdCAtdW5pcXVlKSAtam9pbiAkUGF0aFNlcA0KICAgICAgICBbRW52aXJvbm1lbnRdOjpTZXRFbnZpcm9ubWVudFZhcmlhYmxlKCRQYXRoVmFyLCAkUHRoKQ0KICAgIH0NCn0KCmZ1bmN0aW9uIEdldC1XaGVyZSB7DQogICAgW0NtZGxldEJpbmRpbmcoRGVmYXVsdFBhcmFtZXRlclNldE5hbWU9Ik5vcm1hbCIpXQ0KICAgIHBhcmFtKA0KICAgICAgICBbUGFyYW1ldGVyKE1hbmRhdG9yeT0kdHJ1ZSwgUG9zaXRpb249MCldW3N0cmluZ10kRmlsZSwNCiAgICAgICAgW1N3aXRjaF0kQWxsLA0KICAgICAgICBbUGFyYW1ldGVyKFBhcmFtZXRlclNldE5hbWU9J05vcm1hbCcpXVtQYXJhbWV0ZXIoUGFyYW1ldGVyU2V0TmFtZT0nU2NhbicpXVtTd2l0Y2hdJE1hbnVhbFNjYW4sDQogICAgICAgIFtQYXJhbWV0ZXIoUGFyYW1ldGVyU2V0TmFtZT0nU2NhbicpXVtTd2l0Y2hdJERiZywNCiAgICAgICAgW1BhcmFtZXRlcihQYXJhbWV0ZXJTZXROYW1lPSdTY2FuJyldW3N0cmluZ10kUGF0aFZhciA9ICJQQVRIIg0KICAgICkNCiAgICAkSXNWZXJib3NlID0gJERiZyAtb3IgJFBTQm91bmRQYXJhbWV0ZXJzLkNvbnRhaW5zS2V5KCdWZXJib3NlJykgLW9yICRQU0JvdW5kUGFyYW1ldGVycy5Db250YWluc0tleSgnRGVidWcnKQ0KICAgICRXaGVyZUJpbkV4aXN0cyA9IEdldC1Db21tYW5kICJ3aGVyZSIgLWVhIFNpbGVudGx5Q29udGludWUNCiAgICAkSXNVbml4ID0gJFBTVmVyc2lvblRhYmxlLlBsYXRmb3JtIC1lcSAiVW5peCINCiAgICBpZiAoJEZpbGUgLWVxICJ3aGVyZSIgLW9yICRGaWxlIC1lcSAid2hlcmUuZXhlIikge3JldHVybiAkV2hlcmVCaW5FeGlzdHN9DQogICAgaWYgKCRXaGVyZUJpbkV4aXN0cyAtYW5kICEkTWFudWFsU2Nhbikgew0KICAgICAgICAkT3V0PSRudWxsDQogICAgICAgIGlmICgkSXNVbml4KSB7DQogICAgICAgICAgICAkT3V0ID0gd2hpY2ggJGZpbGUgMj4kbnVsbA0KICAgICAgICB9IGVsc2UgeyRPdXQgPSB3aGVyZS5leGUgJGZpbGUgMj4kbnVsbH0NCiAgICAgICAgDQogICAgICAgIGlmICghJE91dCkge3JldHVybn0NCiAgICAgICAgaWYgKCRBbGwpIHtyZXR1cm4gJE91dH0NCiAgICAgICAgcmV0dXJuIEAoJE91dClbMF0NCiAgICB9DQogICAgZm9yZWFjaCAoJEZvbGRlciBpbiAoR2V0LVBhdGggLVBhdGhWYXIgJFBhdGhWYXIpKSB7DQogICAgICAgIGlmICgkSXNVbml4KSB7DQogICAgICAgICAgICAkTG9va3VwID0gIiRGb2xkZXIvJEZpbGUiDQogICAgICAgICAgICBpZiAoJElzVmVyYm9zZSkge1dyaXRlLUFQICIqQ2hlY2tpbmcgWyRMb29rdXBdIn0NCiAgICAgICAgICAgIGlmICghKFRlc3QtUGF0aCAtUGF0aFR5cGUgTGVhZiAkTG9va3VwKSkge2NvbnRpbnVlfQ0KICAgICAgICAgICAgUmVzb2x2ZS1QYXRoICRMb29rdXAgfCAlIFBhdGgNCiAgICAgICAgICAgIGlmICghJEFsbCkge3JldHVybn0NCiAgICAgICAgfSBlbHNlIHsNCiAgICAgICAgICAgIGZvcmVhY2ggKCRFeHRlbnNpb24gaW4gKEdldC1QYXRoIC1QYXRoVmFyIFBBVEhFWFQpKSB7DQogICAgICAgICAgICAgICAgJExvb2t1cCA9ICIkRm9sZGVyLyRGaWxlJEV4dGVuc2lvbiINCiAgICAgICAgICAgICAgICBpZiAoJElzVmVyYm9zZSkge1dyaXRlLUFQICIqQ2hlY2tpbmcgWyRMb29rdXBdIn0NCiAgICAgICAgICAgICAgICBpZiAoIShUZXN0LVBhdGggLVBhdGhUeXBlIExlYWYgJExvb2t1cCkpIHtjb250aW51ZX0NCiAgICAgICAgICAgICAgICBSZXNvbHZlLVBhdGggJExvb2t1cCB8ICUgUGF0aA0KICAgICAgICAgICAgICAgIGlmICghJEFsbCkge3JldHVybn0NCiAgICAgICAgICAgIH0NCiAgICAgICAgfQ0KICAgIH0NCn0KCmZ1bmN0aW9uIFdyaXRlLUFQTCB7DQogICAgW0NtZGxldEJpbmRpbmcoKV0NCiAgICBwYXJhbSgNCiAgICAgICAgW1BhcmFtZXRlcihWYWx1ZUZyb21QaXBlbGluZT0kdHJ1ZSwgTWFuZGF0b3J5PSRUcnVlKV0kVGV4dCwNCiAgICAgICAgW0FsaWFzKCdOUycpXVtTd2l0Y2hdJE5vU2lnbiwNCiAgICAgICAgW0FsaWFzKCdOTkwnLCdOTCcpXVtTd2l0Y2hdJE5vTmV3TGluZSwNCiAgICAgICAgW1N3aXRjaF0kUGFzc1RocnUNCiAgICApDQogICAgYmVnaW4geyRUVCA9IEAoKX0NCiAgICBwcm9jZXNzIHskVGV4dCB8ICUgeyRUVCArPSAsJF99fQ0KICAgIGVuZCB7DQogICAgICAgIGZvciAoJGk9MDskaSAtbHQgJFRULmNvdW50OyRpKyspIHsNCiAgICAgICAgICAgIFtzdHJpbmddJENodW5rID0gJFRUWyRpXQ0KICAgICAgICAgICAgJFNpZ25SZ3ggPSAiW1wrXC1cIVwqXCNcQF9cPl0iDQogICAgICAgICAgICAkQ2h1bmsgPSAkQ2h1bmsgLXJlcGxhY2UgIl5uP3g/bj8oJFNpZ25SZ3gpIiwnJDEnDQogICAgICAgICAgICBpZiAoJENodW5rIC1ub3RtYXRjaCAiXiRTaWduUmd4LioiKSB7JENodW5rID0gIl8kQ2h1bmsifSAjIFVzZSBkZWZhdWx0IGFzIHdoaXRlDQogICAgICAgICAgICAkUHJlZml4Q29kZSA9ID86ICgkaSAtZXEgMCkgeyJ4JCg/OiAkTm9TaWduIHsnbid9IHsnJ30pIn0gez86ICgkaSAtbmUgKCRUVC5Db3VudCAtIDEpKSB7Im54In0gIm4kKD86ICROb05ld0xpbmUgeyd4J30geycnfSkifQ0KICAgICAgICAgICAgaWYgKCRUVC5Db3VudCAtZXEgMSkgeyRQcmVmaXhDb2RlID0gIiQoPzogJE5vU2lnbiB7J24nfSB7Jyd9KSQoPzogJE5vTmV3TGluZSB7J3gnfSB7Jyd9KSJ9DQogICAgICAgICAgICBXcml0ZS1BUCAiJFByZWZpeENvZGUkQ2h1bmsiIC1QYXNzVGhydTokUGFzc1RocnUNCiAgICAgICAgfQ0KICAgIH0NCn0KCmZ1bmN0aW9uIEFQLUNvbnZlcnRQYXRoIHtwYXJhbShbUGFyYW1ldGVyKE1hbmRhdG9yeT0kVHJ1ZSldW1N0cmluZ10kUGF0aCkNCg0KICAgICRQYXRoU2VwID0gW0lPLlBhdGhdOjpEaXJlY3RvcnlTZXBhcmF0b3JDaGFyDQogICAgcmV0dXJuICRQYXRoIC1yZXBsYWNlIA0KICAgICAgICAiPERlcD4iLCI8TGliPiR7UGF0aFNlcH1EZXBlbmRlbmNpZXMiIC1yZXBsYWNlIA0KICAgICAgICAiPExpYj4iLCI8SG9tZT4ke1BhdGhTZXB9QVAtTGlicmFyaWVzIiAtcmVwbGFjZSANCiAgICAgICAgIjxDb21wKG9uZW50cyk/PiIsIjxIb21lPiR7UGF0aFNlcH1BUC1Db21wb25lbnRzIiAtcmVwbGFjZSANCiAgICAgICAgIjxIb21lPiIsJFBTSGVsbH0KCmZ1bmN0aW9uIEFQLVJlcXVpcmUge3BhcmFtKFtQYXJhbWV0ZXIoTWFuZGF0b3J5PSRUcnVlKV1bQWxpYXMoIkZ1bmN0aW9uYWxpdHkiLCJMaWJyYXJ5IildW0FyZ3VtZW50Q29tcGxldGVyKHsNCiAgICBbT3V0cHV0VHlwZShbU3lzdGVtLk1hbmFnZW1lbnQuQXV0b21hdGlvbi5Db21wbGV0aW9uUmVzdWx0XSldDQogICAgcGFyYW0oDQogICAgICAgIFtzdHJpbmddICRDb21tYW5kTmFtZSwNCiAgICAgICAgW3N0cmluZ10gJFBhcmFtZXRlck5hbWUsDQogICAgICAgIFtzdHJpbmddICRXb3JkVG9Db21wbGV0ZSwNCiAgICAgICAgW1N5c3RlbS5NYW5hZ2VtZW50LkF1dG9tYXRpb24uTGFuZ3VhZ2UuQ29tbWFuZEFzdF0gJENvbW1hbmRBc3QsDQogICAgICAgIFtTeXN0ZW0uQ29sbGVjdGlvbnMuSURpY3Rpb25hcnldICRGYWtlQm91bmRQYXJhbWV0ZXJzDQogICAgKQ0KICAgICRDb21wbGV0aW9uUmVzdWx0cyA9IFtTeXN0ZW0uQ29sbGVjdGlvbnMuR2VuZXJpYy5MaXN0W1N5c3RlbS5NYW5hZ2VtZW50LkF1dG9tYXRpb24uQ29tcGxldGlvblJlc3VsdF1dOjpuZXcoKQ0KICAgICRMaWIgPSBAKCJJbnRlcm5ldCIsIm9zOndpbmRvd3MiLCJvczpsaW51eCIsIm9zOnVuaXgiLCJhZG1pbmlzdHJhdG9yIiwicm9vdCIsImxpYjoiLCJsaWJfdGVzdDoiLCJmdW5jdGlvbjoiLCJzdHJpY3RfZnVuY3Rpb246IiwiYWJpbGl0eTplc2NhcGVfY29kZXMiLCJhYmlsaXR5OmVtb2ppcyIpDQogICAgSlMtT1IgeyRMaWIgfCA/IHskXyAtbGlrZSAiJFdvcmRUb0NvbXBsZXRlKiJ9fSB7JExpYiB8ID8geyRfIC1saWtlICIqJFdvcmRUb0NvbXBsZXRlKiJ9fSB8ICUgew0KICAgICAgICAkQ29tcGxldGlvblJlc3VsdHMuQWRkKFtTeXN0ZW0uTWFuYWdlbWVudC5BdXRvbWF0aW9uLkNvbXBsZXRpb25SZXN1bHRdOjpuZXcoJF8sICRfLCAnUGFyYW1ldGVyVmFsdWUnLCAkXykpDQogICAgfQ0KICAgIHJldHVybiAkQ29tcGxldGlvblJlc3VsdHMNCn0pXVtTdHJpbmddJExpYiwgW1NjcmlwdEJsb2NrXSRPbkZhaWwsIFtTd2l0Y2hdJFBhc3NUaHJ1KQ0KDQogICAgJExvYWRNb2R1bGUgPSB7DQogICAgICAgIHBhcmFtKCRGaWxlLFtib29sXSRJbXBvcnQpDQogICAgICAgIHRyeSB7SW1wb3J0LU1vZHVsZSAkRmlsZSAtZWEgc3RvcDtyZXR1cm4gMX0gY2F0Y2gge30NCiAgICAgICAgJExpYj1BUC1Db252ZXJ0UGF0aCAiPExJQj4iOyRMRiA9ICIkTGliXCRGaWxlIg0KICAgICAgICBbc3RyaW5nXSRmID0gaWYodGVzdC1wYXRoIC10IGxlYWYgJExGKXskTEZ9ZWxzZWlmKHRlc3QtcGF0aCAtdCBsZWFmICIkTEYuZGxsIil7IiRMRi5kbGwifQ0KICAgICAgICBpZiAoJGYgLWFuZCAkSW1wb3J0KSB7SW1wb3J0LU1vZHVsZSAkZn0NCiAgICAgICAgcmV0dXJuICRmDQogICAgfQ0KICAgICRJbnZva2VPclJldHVybiA9IHsNCiAgICAgICAgcGFyYW0oJENtZCkNCiAgICAgICAgaWYgKCRDbWQgLWlzIFtTY3JpcHRCbG9ja10pIHsmICRDbWR9IGVsc2UgeyRDbWR9DQogICAgfQ0KICAgIGlmICghJE9uRmFpbCkgeyRQYXNzVGhydSA9ICR0cnVlfQ0KICAgICRTdGF0ID0gJChzd2l0Y2ggLXJlZ2V4ICgkTGliLnRyaW0oKSkgew0KICAgICAgICAiXkludGVybmV0JCIgICAgICAgICAgICAgICAgICAge3Rlc3QtY29ubmVjdGlvbiBnb29nbGUuY29tIC1Db3VudCAxIC1RdWlldH0NCiAgICAgICAgIl5vczood2luKGRvd3MpP3xsaW51eHx1bml4KSQiIHskSXNVbml4ID0gJFBTVmVyc2lvblRhYmxlLlBsYXRmb3JtIC1lcSAiVW5peCI7aWYgKCRNYXRjaGVzWzFdIC1tYXRjaCAiXndpbiIpIHshJElzVW5peH0gZWxzZSB7JElzVW5peH19DQogICAgICAgICJeYWRtaW4oaXN0cmF0b3IpPyR8XnJvb3QkIiAgICB7VGVzdC1BZG1pbmlzdHJhdG9yfQ0KICAgICAgICAiXmRlcDooLiopJCIgICAgICAgICAgICAgICAgICAge0dldC1XaGVyZSAkTWF0Y2hlc1sxXX0NCiAgICAgICAgIl4obGlifG1vZHVsZSk6KC4qKSQiICAgICAgICAgIHskTG9hZE1vZHVsZS5pbnZva2UoJE1hdGNoZXNbMl0sICR0cnVlKX0NCiAgICAgICAgIl4obGlifG1vZHVsZSlfdGVzdDooLiopJCIgICAgIHskTG9hZE1vZHVsZS5pbnZva2UoJE1hdGNoZXNbMl0pfQ0KICAgICAgICAiXmZ1bmN0aW9uOiguKikkIiAgICAgICAgICAgICAge2djbSAkTWF0Y2hlc1sxXSAtZWEgU2lsZW50bHlDb250aW51ZX0NCiAgICAgICAgIl5zdHJpY3RfZnVuY3Rpb246KC4qKSQiICAgICAgIHtUZXN0LVBhdGggIkZ1bmN0aW9uOlwkKCRNYXRjaGVzWzFdKSJ9DQogICAgICAgICJeYWJpbGl0eTooZXNjYXBlX2NvZGVzfGVtb2ppcykkIiAgICAgeyYgJEludm9rZU9yUmV0dXJuIChAew0KICAgICAgICAgICAgZXNjYXBlX2NvZGVzID0gJEhvc3QuVUkuU3VwcG9ydHNWaXJ0dWFsVGVybWluYWwNCiAgICAgICAgICAgIGVtb2ppcyA9ICRlbnY6V1RfU0VTU0lPTiAtb3IgJGVudjpXVF9QUk9GSUxFX0lEDQogICAgICAgIH1bJE1hdGNoZXNbMV1dKX0NCiAgICAgICAgZGVmYXVsdCB7V3JpdGUtQVAgIiFJbnZhbGlkIHNlbGVjdG9yIHByb3ZpZGVkIFskKCIkTGliIi5zcGxpdCgnOicpWzBdKV0iO3Rocm93ICdCQURfU0VMRUNUT1InfQ0KICAgIH0pDQogICAgaWYgKCEkU3RhdCAtYW5kICRPbkZhaWwpIHsmICRPbkZhaWx9DQogICAgaWYgKCRQYXNzVGhydSAtb3IgISRPbkZhaWwpIHtyZXR1cm4gJFN0YXR9DQp9CgpmdW5jdGlvbiBUZXN0LUFkbWluaXN0cmF0b3Igew0KICAgIGlmICgkUFNWZXJzaW9uVGFibGUuUGxhdGZvcm0gLWVxICJVbml4Iikgew0KICAgICAgICBpZiAoJCh3aG9hbWkpIC1lcSAicm9vdCIpIHsNCiAgICAgICAgICAgIHJldHVybiAkdHJ1ZQ0KICAgICAgICB9DQogICAgICAgIGVsc2Ugew0KICAgICAgICAgICAgcmV0dXJuICRmYWxzZQ0KICAgICAgICB9DQogICAgfQ0KICAgICMgV2luZG93cw0KICAgIChOZXctT2JqZWN0IFNlY3VyaXR5LlByaW5jaXBhbC5XaW5kb3dzUHJpbmNpcGFsIChbU2VjdXJpdHkuUHJpbmNpcGFsLldpbmRvd3NJZGVudGl0eV06OkdldEN1cnJlbnQoKSkpLklzSW5Sb2xlKFtTZWN1cml0eS5QcmluY2lwYWwuV2luZG93c0J1aWx0aW5Sb2xlXTo6QWRtaW5pc3RyYXRvcikNCn0KCmZ1bmN0aW9uIFByaW50LUxpc3Qge3BhcmFtKCR4LCBbU3dpdGNoXSRJblJlY3Vyc2UpDQoNCiAgICBpZiAoJHguY291bnQgLWxlIDEpIHtyZXR1cm4gPzooJEluUmVjdXJzZSl7JHh9eyJbJHhdIn19IGVsc2Ugew0KICAgICAgICByZXR1cm4gIlskKCgkeCB8ICUge1ByaW50LUxpc3QgJF8gLUluUmVjdXJzZX0pIC1qb2luICcsICcpXSINCiAgICB9DQp9CgpTZXQtQWxpYXMgPzogSW52b2tlLVRlcm5hcnk=")
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
$ForcedDependencies = $tokens | ? kind -eq 'comment' | ? text -Match "^..?\s*ap-compiler?\s?\:" | % {$_ -replace "^.*?ap-compiler?\s?\: *(.+?) *(?<a>\#\>)?$",'$1' -split ","} | % {$_.Trim()} | ? {$_} | % {
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
    Write-APL ">*","Detected Linear Layout",$(if($ForceLinearLayout){"! (Forced)"}else{"."})
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
