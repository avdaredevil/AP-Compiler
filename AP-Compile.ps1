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
param([Parameter(Mandatory=$True)][String]$File,[String]$OutputFolder = '.',[switch]$OverwriteSrc,[Switch]$Dbg,[Switch]$PassThru)
# =======================================START=OF=COMPILER==========================================================|
#    The Following Code was added by AP-Compiler 1.6 (APC: 1.2) To Make this program independent of AP-Core Engine
#    GitHub: https://github.com/avdaredevil/AP-Compiler
# ==================================================================================================================|
$Script:PSHell=$(if($PSHell){$PSHell}elseif($PSScriptRoot){$PSScriptRoot}else{"."});
$Script:AP_Console = @{version=[version]'1.2'; isShim = $true}
function B64 {param([Parameter(ValueFromPipeline=$true)][String]$Text, [ValidateSet("UTF8","Unicode")][String]$Encoding = "UTF8")     [System.Text.Encoding]::$Encoding.GetString([System.Convert]::FromBase64String($Text))}
# This syntax is to prevent AV's from misclassifying this as anything but innocuous
& (Get-Alias iex) (B64 "ZnVuY3Rpb24gSlMtT1Ige2ZvcmVhY2ggKCRhIGluICRhcmdzKSB7aWYgKCEkYSkge2NvbnRpbnVlfTtpZiAoJGEuR2V0VHlwZSgpLk5hbWUgLWVxICJTY3JpcHRCbG9jayIpIHskYSA9ICRhLmludm9rZSgpO2lmICghJGEpe2NvbnRpbnVlfX07cmV0dXJuICRhfX0KCmZ1bmN0aW9uIFdyaXRlLUFQIHsNCiAgICBbQ21kbGV0QmluZGluZygpXQ0KICAgIHBhcmFtKFtQYXJhbWV0ZXIoVmFsdWVGcm9tUGlwZWxpbmU9JHRydWUsIE1hbmRhdG9yeT0kVHJ1ZSldJFRleHQsW1N3aXRjaF0kTm9TaWduLFtTd2l0Y2hdJFBsYWluVGV4dCxbVmFsaWRhdGVTZXQoIkNlbnRlciIsIlJpZ2h0IiwiTGVmdCIpXVtTdHJpbmddJEFsaWduPSdMZWZ0JyxbU3dpdGNoXSRQYXNzVGhydSkNCiAgICBiZWdpbiB7JFRUID0gQCgpfQ0KICAgIFByb2Nlc3MgeyRUVCArPSAsJFRleHR9DQogICAgRU5EIHsNCiAgICAgICAgJEJsdWUgPSAkKGlmICgkV1JJVEVfQVBfTEVHQUNZX0NPTE9SUyl7M31lbHNleydCbHVlJ30pDQogICAgICAgIGlmICgkVFQuY291bnQgLWVxIDEpIHskVFQgPSAkVFRbMF19OyRUZXh0ID0gJFRUDQogICAgICAgIGlmICgkdGV4dC5jb3VudCAtZ3QgMSAtb3IgJHRleHQuR2V0VHlwZSgpLk5hbWUgLW1hdGNoICJcW1xdJCIpIHsNCiAgICAgICAgICAgIHJldHVybiAkVGV4dCB8ID8geyIkXyJ9IHwgJSB7DQogICAgICAgICAgICAgICAgV3JpdGUtQVAgJF8gLU5vU2lnbjokTm9TaWduIC1QbGFpblRleHQ6JFBsYWluVGV4dCAtQWxpZ24gJEFsaWduIC1QYXNzVGhydTokUGFzc1RocnUNCiAgICAgICAgICAgIH0NCiAgICAgICAgfQ0KICAgICAgICBpZiAoISR0ZXh0IC1vciAkdGV4dCAtbm90bWF0Y2ggIl4oKD88Tk5MPngpfCg/PE5TPm5zPykpezAsMn0oPzx0Plw+KikoPzxzPlsrXC0hXCpcI1xAX10pKD88dz4uKikiKSB7cmV0dXJuICRUZXh0fQ0KICAgICAgICAkdGIgID0gIiAgICAiKiRNYXRjaGVzLnQubGVuZ3RoDQogICAgICAgICRDb2wgPSBAeycrJz0nMic7Jy0nPScxMic7JyEnPScxNCc7JyonPSRCbHVlOycjJz0nRGFya0dyYXknOydAJz0nR3JheSc7J18nPSd3aGl0ZSd9WygkU2lnbiA9ICRNYXRjaGVzLlMpXQ0KICAgICAgICBpZiAoISRDb2wpIHtUaHJvdyAiSW5jb3JyZWN0IFNpZ24gWyRTaWduXSBQYXNzZWQhIn0NCiAgICAgICAgJFNpZ24gPSAkKGlmICgkTm9TaWduIC1vciAkTWF0Y2hlcy5OUykgeyIifSBlbHNlIHsiWyRTaWduXSAifSkNCiAgICAgICAgJERhdGEgPSAiJHRiJFNpZ24kKCRNYXRjaGVzLlcpIjtpZiAoISREYXRhKSB7cmV0dXJufQ0KICAgICAgICBpZiAoQVAtUmVxdWlyZSAiZnVuY3Rpb246QWxpZ24tVGV4dCIgLXBhKSB7DQogICAgICAgICAgICAkRGF0YSA9IEFsaWduLVRleHQgLUFsaWduICRBbGlnbiAiJHRiJFNpZ24kKCRNYXRjaGVzLlcpIg0KICAgICAgICB9DQogICAgICAgIGlmICgkUGxhaW5UZXh0KSB7cmV0dXJuICREYXRhfQ0KICAgICAgICBXcml0ZS1Ib3N0IC1Ob05ld0xpbmU6JChbYm9vbF0kTWF0Y2hlcy5OTkwpIC1mICRDb2wgJERhdGENCiAgICAgICAgaWYgKCRQYXNzVGhydSkge3JldHVybiAkRGF0YX0NCiAgICB9DQp9CgpmdW5jdGlvbiBBUC1SZXF1aXJlIHtwYXJhbShbUGFyYW1ldGVyKE1hbmRhdG9yeT0kVHJ1ZSldW0FsaWFzKCJGdW5jdGlvbmFsaXR5IiwiTGlicmFyeSIpXVtTdHJpbmddJExpYiwgW1NjcmlwdEJsb2NrXSRPbkZhaWwsIFtTd2l0Y2hdJFBhc3NUaHJ1KQoNCiAgICAkTG9hZE1vZHVsZSA9IHsNCiAgICAgICAgcGFyYW0oJEZpbGUsW2Jvb2xdJEltcG9ydCkNCiAgICAgICAgdHJ5IHtJbXBvcnQtTW9kdWxlICRGaWxlIC1lYSBzdG9wO3JldHVybiAxfSBjYXRjaCB7fQ0KICAgICAgICAkTGliPUFQLUNvbnZlcnRQYXRoICI8TElCPiI7JExGID0gIiRMaWJcJEZpbGUiDQogICAgICAgIFtzdHJpbmddJGYgPSBpZih0ZXN0LXBhdGggLXQgbGVhZiAkTEYpeyRMRn1lbHNlaWYodGVzdC1wYXRoIC10IGxlYWYgIiRMRi5kbGwiKXsiJExGLmRsbCJ9DQogICAgICAgIGlmICgkZiAtYW5kICRJbXBvcnQpIHtJbXBvcnQtTW9kdWxlICRmfQ0KICAgICAgICByZXR1cm4gJGYNCiAgICB9DQogICAgJFN0YXQgPSAkKHN3aXRjaCAtcmVnZXggKCRMaWIudHJpbSgpKSB7DQogICAgICAgICJeSW50ZXJuZXQkIiAgICAgICAgICAgICAgIHt0ZXN0LWNvbm5lY3Rpb24gZ29vZ2xlLmNvbSAtQ291bnQgMSAtUXVpZXR9DQogICAgICAgICJeb3M6KHdpbnxsaW51eHx1bml4KSQiICAgIHskSXNVbml4ID0gJFBTVmVyc2lvblRhYmxlLlBsYXRmb3JtIC1lcSAiVW5peCI7aWYgKCRNYXRjaGVzWzFdIC1lcSAid2luIikgeyEkSXNVbml4fSBlbHNlIHskSXNVbml4fX0NCiAgICAgICAgIl5hZG1pbiQiICAgICAgICAgICAgICAgICAge1Rlc3QtQWRtaW5pc3RyYXRvcn0NCiAgICAgICAgIl5kZXA6KC4qKSQiICAgICAgICAgICAgICAge0dldC1XaGVyZSAkTWF0Y2hlc1sxXX0NCiAgICAgICAgIl4obGlifG1vZHVsZSk6KC4qKSQiICAgICAgeyRMb2FkTW9kdWxlLmludm9rZSgkTWF0Y2hlc1syXSwgJHRydWUpfQ0KICAgICAgICAiXihsaWJ8bW9kdWxlKV90ZXN0OiguKikkIiB7JExvYWRNb2R1bGUuaW52b2tlKCRNYXRjaGVzWzJdKX0NCiAgICAgICAgIl5mdW5jdGlvbjooLiopJCIgICAgICAgICAge2djbSAkTWF0Y2hlc1sxXSAtZWEgU2lsZW50bHlDb250aW51ZX0NCiAgICAgICAgIl5zdHJpY3RfZnVuY3Rpb246KC4qKSQiICAge1Rlc3QtUGF0aCAiRnVuY3Rpb246XCQoJE1hdGNoZXNbMV0pIn0NCiAgICAgICAgZGVmYXVsdCB7V3JpdGUtQVAgIiFJbnZhbGlkIHNlbGVjdG9yIHByb3ZpZGVkIFskKCIkTGliIi5zcGxpdCgnOicpWzBdKV0iO3Rocm93ICdCQURfU0VMRUNUT1InfQ0KICAgIH0pDQogICAgaWYgKCEkU3RhdCAtYW5kICRPbkZhaWwpIHskT25GYWlsLkludm9rZSgpfQ0KICAgIGlmICgkUGFzc1RocnUgLW9yICEkT25GYWlsKSB7cmV0dXJuICRTdGF0fQ0KfQoKZnVuY3Rpb24gQ29udmVydC1Ub0Jhc2U2NCB7cGFyYW0oW1BhcmFtZXRlcihWYWx1ZUZyb21QaXBlbGluZT0kdHJ1ZSldW1N0cmluZ10kVGV4dCwgW1ZhbGlkYXRlU2V0KCJVVEY4IiwiVW5pY29kZSIpXVtTdHJpbmddJEVuY29kaW5nID0gIlVURjgiKQoNCiAgICBbU3lzdGVtLkNvbnZlcnRdOjpUb0Jhc2U2NFN0cmluZyhbU3lzdGVtLlRleHQuRW5jb2RpbmddOjokRW5jb2RpbmcuR2V0Qnl0ZXMoJFRleHQpKQ0KfQoKZnVuY3Rpb24gVGVzdC1BZG1pbmlzdHJhdG9yIHsNCiAgICBpZiAoJFBTVmVyc2lvblRhYmxlLlBsYXRmb3JtIC1lcSAiVW5peCIpIHsNCiAgICAgICAgaWYgKCQod2hvYW1pKSAtZXEgInJvb3QiKSB7DQogICAgICAgICAgICByZXR1cm4gJHRydWUNCiAgICAgICAgfQ0KICAgICAgICBlbHNlIHsNCiAgICAgICAgICAgIHJldHVybiAkZmFsc2UNCiAgICAgICAgfQ0KICAgIH0NCiAgICAjIFdpbmRvd3MNCiAgICAoTmV3LU9iamVjdCBTZWN1cml0eS5QcmluY2lwYWwuV2luZG93c1ByaW5jaXBhbCAoW1NlY3VyaXR5LlByaW5jaXBhbC5XaW5kb3dzSWRlbnRpdHldOjpHZXRDdXJyZW50KCkpKS5Jc0luUm9sZShbU2VjdXJpdHkuUHJpbmNpcGFsLldpbmRvd3NCdWlsdGluUm9sZV06OkFkbWluaXN0cmF0b3IpDQp9CgpmdW5jdGlvbiBJbnZva2UtVGVybmFyeSB7cGFyYW0oW2Jvb2xdJGRlY2lkZXIsIFtzY3JpcHRibG9ja10kaWZ0cnVlLCBbc2NyaXB0YmxvY2tdJGlmZmFsc2UpCg0KICAgIGlmICgkZGVjaWRlcikgeyAmJGlmdHJ1ZX0gZWxzZSB7ICYkaWZmYWxzZSB9DQp9CgpmdW5jdGlvbiBQcmludC1MaXN0IHtwYXJhbSgkeCwgW1N3aXRjaF0kSW5SZWN1cnNlKQoNCiAgICBpZiAoJHguY291bnQgLWxlIDEpIHtyZXR1cm4gPzooJEluUmVjdXJzZSl7JHh9eyJbJHhdIn19IGVsc2Ugew0KICAgICAgICByZXR1cm4gIlskKCgkeCB8ICUge1ByaW50LUxpc3QgJF8gLUluUmVjdXJzZX0pIC1qb2luICcsICcpXSINCiAgICB9DQp9CgpmdW5jdGlvbiBTdHJpcC1Db2xvckNvZGVzIHtwYXJhbSgkU3RyKQoNCiAgICAkU3RyIHwgJSB7JF8gLXJlcGxhY2UgIiQoW3JlZ2V4XTo6ZXNjYXBlKCIkKEdldC1Fc2NhcGUpWyIpKVxkKyhcO1xkKykqbSIsIiJ9DQp9CgpmdW5jdGlvbiBHZXQtRXNjYXBlIHtbQ2hhcl0weDFifQoKZnVuY3Rpb24gQWxpZ24tVGV4dCB7cGFyYW0oW1BhcmFtZXRlcihNYW5kYXRvcnk9JFRydWUpXVtTdHJpbmdbXV0kVGV4dCwgW1ZhbGlkYXRlU2V0KCJDZW50ZXIiLCJSaWdodCIsIkxlZnQiKV1bU3RyaW5nXSRBbGlnbj0nQ2VudGVyJykKDQogICAgaWYgKCRUZXh0LmNvdW50IC1ndCAxKSB7DQogICAgICAgICRhbnMgPSBAKCkNCiAgICAgICAgZm9yZWFjaCAoJGxuIGluICRUZXh0KSB7JEFucyArPSBBbGlnbi1UZXh0ICRsbiAkQWxpZ259DQogICAgICAgIHJldHVybiAoJGFucykNCiAgICB9IGVsc2Ugew0KICAgICAgICAkV2luU2l6ZSA9IFtjb25zb2xlXTo6QnVmZmVyV2lkdGgNCiAgICAgICAgJENsZWFuVGV4dFNpemUgPSAoU3RyaXAtQ29sb3JDb2RlcyAoIiIrJFRleHQpKS5MZW5ndGgNCiAgICAgICAgaWYgKCRDbGVhblRleHRTaXplIC1nZSAkV2luU2l6ZSkgew0KICAgICAgICAgICAgJEFwcGVuZGVyID0gQCgiIik7DQogICAgICAgICAgICAkaiA9IDANCiAgICAgICAgICAgIGZvcmVhY2ggKCRwIGluIDAuLigkQ2xlYW5UZXh0U2l6ZS0xKSl7DQogICAgICAgICAgICAgICAgaWYgKCgkcCsxKSUkd2luc2l6ZSAtZXEgMCkgeyRqKys7JEFwcGVuZGVyICs9ICIifQ0KICAgICAgICAgICAgICAgICMgIiIrJGorIiAtICIrJHANCiAgICAgICAgICAgICAgICAkQXBwZW5kZXJbJGpdICs9ICRUZXh0LmNoYXJzKCRwKQ0KICAgICAgICAgICAgfQ0KICAgICAgICAgICAgcmV0dXJuIChBbGlnbi1UZXh0ICRBcHBlbmRlciAkQWxpZ24pDQogICAgICAgIH0gZWxzZSB7DQogICAgICAgICAgICBpZiAoJEFsaWduIC1lcSAiQ2VudGVyIikgew0KICAgICAgICAgICAgICAgIHJldHVybiAoIiAiKlttYXRoXTo6dHJ1bmNhdGUoKCRXaW5TaXplLSRDbGVhblRleHRTaXplKS8yKSskVGV4dCkNCiAgICAgICAgICAgIH0gZWxzZWlmICgkQWxpZ24gLWVxICJSaWdodCIpIHsNCiAgICAgICAgICAgICAgICByZXR1cm4gKCIgIiooJFdpblNpemUtJENsZWFuVGV4dFNpemUtMSkrJFRleHQpDQogICAgICAgICAgICB9IGVsc2Ugew0KICAgICAgICAgICAgICAgIHJldHVybiAoJFRleHQpDQogICAgICAgICAgICB9DQogICAgICAgIH0NCiAgICB9DQp9CgpmdW5jdGlvbiBHZXQtV2hlcmUgew0KICAgIFtDbWRsZXRCaW5kaW5nKERlZmF1bHRQYXJhbWV0ZXJTZXROYW1lPSJOb3JtYWwiKV0NCiAgICBwYXJhbSgNCiAgICAgICAgW1BhcmFtZXRlcihNYW5kYXRvcnk9JHRydWUsIFBvc2l0aW9uPTApXVtzdHJpbmddJEZpbGUsDQogICAgICAgIFtTd2l0Y2hdJEFsbCwNCiAgICAgICAgW1BhcmFtZXRlcihQYXJhbWV0ZXJTZXROYW1lPSdOb3JtYWwnKV1bUGFyYW1ldGVyKFBhcmFtZXRlclNldE5hbWU9J1NjYW4nKV1bU3dpdGNoXSRNYW51YWxTY2FuLA0KICAgICAgICBbUGFyYW1ldGVyKFBhcmFtZXRlclNldE5hbWU9J1NjYW4nKV1bU3dpdGNoXSREYmcsDQogICAgICAgIFtQYXJhbWV0ZXIoUGFyYW1ldGVyU2V0TmFtZT0nU2NhbicpXVtzdHJpbmddJFBhdGhWYXIgPSAiUEFUSCINCiAgICApDQogICAgJElzVmVyYm9zZSA9ICREYmcgLW9yICRQU0JvdW5kUGFyYW1ldGVycy5Db250YWluc0tleSgnVmVyYm9zZScpIC1vciAkUFNCb3VuZFBhcmFtZXRlcnMuQ29udGFpbnNLZXkoJ0RlYnVnJykNCiAgICAkV2hlcmVCaW5FeGlzdHMgPSBHZXQtQ29tbWFuZCAid2hlcmUiIC1lYSBTaWxlbnRseUNvbnRpbnVlDQogICAgJElzVW5peCA9ICRQU1ZlcnNpb25UYWJsZS5QbGF0Zm9ybSAtZXEgIlVuaXgiDQogICAgaWYgKCRGaWxlIC1lcSAid2hlcmUiIC1vciAkRmlsZSAtZXEgIndoZXJlLmV4ZSIpIHtyZXR1cm4gJFdoZXJlQmluRXhpc3RzfQ0KICAgIGlmICgkV2hlcmVCaW5FeGlzdHMgLWFuZCAhJE1hbnVhbFNjYW4pIHsNCiAgICAgICAgJE91dD0kbnVsbA0KICAgICAgICBpZiAoJElzVW5peCkgew0KICAgICAgICAgICAgJE91dCA9IHdoaWNoICRmaWxlIDI+JG51bGwNCiAgICAgICAgfSBlbHNlIHskT3V0ID0gd2hlcmUuZXhlICRmaWxlIDI+JG51bGx9DQogICAgICAgIA0KICAgICAgICBpZiAoISRPdXQpIHtyZXR1cm59DQogICAgICAgIGlmICgkQWxsKSB7cmV0dXJuICRPdXR9DQogICAgICAgIHJldHVybiBAKCRPdXQpWzBdDQogICAgfQ0KICAgIGZvcmVhY2ggKCRGb2xkZXIgaW4gKEdldC1QYXRoIC1QYXRoVmFyICRQYXRoVmFyKSkgew0KICAgICAgICBpZiAoJElzVW5peCkgew0KICAgICAgICAgICAgJExvb2t1cCA9ICIkRm9sZGVyLyRGaWxlIg0KICAgICAgICAgICAgaWYgKCRJc1ZlcmJvc2UpIHtXcml0ZS1BUCAiKkNoZWNraW5nIFskTG9va3VwXSJ9DQogICAgICAgICAgICBpZiAoIShUZXN0LVBhdGggLVBhdGhUeXBlIExlYWYgJExvb2t1cCkpIHtjb250aW51ZX0NCiAgICAgICAgICAgIFJlc29sdmUtUGF0aCAkTG9va3VwIHwgJSBQYXRoDQogICAgICAgICAgICBpZiAoISRBbGwpIHtyZXR1cm59DQogICAgICAgIH0gZWxzZSB7DQogICAgICAgICAgICBmb3JlYWNoICgkRXh0ZW5zaW9uIGluIChHZXQtUGF0aCAtUGF0aFZhciBQQVRIRVhUKSkgew0KICAgICAgICAgICAgICAgICRMb29rdXAgPSAiJEZvbGRlci8kRmlsZSRFeHRlbnNpb24iDQogICAgICAgICAgICAgICAgaWYgKCRJc1ZlcmJvc2UpIHtXcml0ZS1BUCAiKkNoZWNraW5nIFskTG9va3VwXSJ9DQogICAgICAgICAgICAgICAgaWYgKCEoVGVzdC1QYXRoIC1QYXRoVHlwZSBMZWFmICRMb29rdXApKSB7Y29udGludWV9DQogICAgICAgICAgICAgICAgUmVzb2x2ZS1QYXRoICRMb29rdXAgfCAlIFBhdGgNCiAgICAgICAgICAgICAgICBpZiAoISRBbGwpIHtyZXR1cm59DQogICAgICAgICAgICB9DQogICAgICAgIH0NCiAgICB9DQp9CgpmdW5jdGlvbiBTZXQtUGF0aCB7DQogICAgW2NtZGxldGJpbmRpbmcoKV0NCiAgICBwYXJhbSgNCiAgICAgICAgW1BhcmFtZXRlcihNYW5kYXRvcnkgPSAkdHJ1ZSwgVmFsdWVGcm9tUGlwZWxpbmUgPSAkdHJ1ZSldW3N0cmluZ1tdXSRQYXRoLA0KICAgICAgICBbc3RyaW5nXSRQYXRoVmFyID0gIlBBVEgiDQogICAgKQ0KICAgIGJlZ2luIHsNCiAgICAgICAgW3N0cmluZ1tdXSRGaW5hbFBhdGgNCiAgICB9DQogICAgcHJvY2VzcyB7DQogICAgICAgICRQYXRoIHwgJSB7DQogICAgICAgICAgICAkRmluYWxQYXRoICs9ICRfDQogICAgICAgIH0NCiAgICB9DQogICAgZW5kIHsNCiAgICAgICAgJElzVW5peCA9ICRQU1ZlcnNpb25UYWJsZS5QbGF0Zm9ybSAtZXEgIlVuaXgiDQogICAgICAgICRQYXRoU2VwID0gJChpZiAoJElzVW5peCkgeyI6In0gZWxzZSB7IjsifSkNCiAgICAgICAgJFB0aCA9ICRGaW5hbFBhdGggLWpvaW4gJFBhdGhTZXANCiAgICAgICAgJFB0aCA9ICgkUHRoIC1yZXBsYWNlKCIkUGF0aFNlcCsiLCAkUGF0aFNlcCkgLXJlcGxhY2UoIlxcJFBhdGhTZXB8XFwkIiwgJFBhdGhTZXApKS50cmltKCRQYXRoU2VwKQ0KICAgICAgICAkUHRoID0gKCgkUHRoKS5zcGxpdCgkUGF0aFNlcCkgfCBzZWxlY3QgLXVuaXF1ZSkgLWpvaW4gJFBhdGhTZXANCiAgICAgICAgW0Vudmlyb25tZW50XTo6U2V0RW52aXJvbm1lbnRWYXJpYWJsZSgkUGF0aFZhciwgJFB0aCkNCiAgICB9DQp9CgpmdW5jdGlvbiBGbGF0dGVuIHtwYXJhbShbb2JqZWN0W11dJHgpCg0KICAgIGlmICghKCRYIC1pcyBbYXJyYXldKSkge3JldHVybiAkeH0NCiAgICBpZiAoJFguY291bnQgLWVxIDEpIHsNCiAgICAgICAgcmV0dXJuICR4IHwgJSB7JF99DQogICAgfQ0KICAgICR4IHwgJSB7RmxhdHRlbiAkX30NCn0KCmZ1bmN0aW9uIEdldC1GaWxlRW5jb2Rpbmcge3BhcmFtKFtQYXJhbWV0ZXIoTWFuZGF0b3J5PSRUcnVlKV0kUGF0aCkKDQogICAgJGJ5dGVzID0gW2J5dGVbXV0oR2V0LUNvbnRlbnQgJFBhdGggLUFzQnl0ZVN0cmVhbSAtUmVhZENvdW50IDQgLVRvdGFsQ291bnQgNCkNCg0KICAgIGlmKCEkYnl0ZXMpIHsgcmV0dXJuICd1dGY4JyB9DQoNCiAgICBzd2l0Y2ggLXJlZ2V4ICgnezA6eDJ9ezE6eDJ9ezI6eDJ9ezM6eDJ9JyAtZiAkYnl0ZXNbMF0sJGJ5dGVzWzFdLCRieXRlc1syXSwkYnl0ZXNbM10pIHsNCiAgICAgICAgJ15lZmJiYmYnICAge3JldHVybiAndXRmOCd9DQogICAgICAgICdeMmIyZjc2JyAgIHtyZXR1cm4gJ3V0ZjcnfQ0KICAgICAgICAnXmZmZmUnICAgICB7cmV0dXJuICd1bmljb2RlJ30NCiAgICAgICAgJ15mZWZmJyAgICAge3JldHVybiAnYmlnZW5kaWFudW5pY29kZSd9DQogICAgICAgICdeMDAwMGZlZmYnIHtyZXR1cm4gJ3V0ZjMyJ30NCiAgICAgICAgZGVmYXVsdCAgICAge3JldHVybiAnYXNjaWknfQ0KICAgIH0NCn0KCmZ1bmN0aW9uIFdyaXRlLUFQTCB7DQogICAgW0NtZGxldEJpbmRpbmcoKV0NCiAgICBwYXJhbSgNCiAgICAgICAgW1BhcmFtZXRlcihWYWx1ZUZyb21QaXBlbGluZT0kdHJ1ZSwgTWFuZGF0b3J5PSRUcnVlKV0kVGV4dCwNCiAgICAgICAgW0FsaWFzKCdOUycpXVtTd2l0Y2hdJE5vU2lnbiwNCiAgICAgICAgW0FsaWFzKCdOTkwnLCdOTCcpXVtTd2l0Y2hdJE5vTmV3TGluZSwNCiAgICAgICAgW1N3aXRjaF0kUGFzc1RocnUNCiAgICApDQogICAgYmVnaW4geyRUVCA9IEAoKX0NCiAgICBwcm9jZXNzIHskVGV4dCB8ICUgeyRUVCArPSAsJF99fQ0KICAgIGVuZCB7DQogICAgICAgIGZvciAoJGk9MDskaSAtbHQgJFRULmNvdW50OyRpKyspIHsNCiAgICAgICAgICAgIFtzdHJpbmddJENodW5rID0gJFRUWyRpXQ0KICAgICAgICAgICAgJENodW5rID0gJENodW5rIC1yZXBsYWNlICJebj94P24/IiwnJw0KICAgICAgICAgICAgaWYgKCRDaHVuayAtbm90bWF0Y2ggIl5bK1wtIVwqXCNcQF9cPl0uKiIpIHskQ2h1bmsgPSAiXyRDaHVuayJ9ICMgVXNlIGRlZmF1bHQgYXMgd2hpdGUNCiAgICAgICAgICAgICRQcmVmaXhDb2RlID0gJGkgLWVxIDAgPyAieCQoJE5vU2lnbiA/ICduJyA6ICcnKSIgOiAkaSAtbmUgKCRUVC5Db3VudCAtIDEpID8gIm54IiA6ICJuJCgkTm9OZXdMaW5lID8gJ3gnIDogJycpIg0KICAgICAgICAgICAgaWYgKCRUVC5Db3VudCAtZXEgMSkgeyRQcmVmaXhDb2RlID0gIiQoJE5vU2lnbiA/ICduJyA6ICcnKSQoJE5vTmV3TGluZSA/ICd4JyA6ICcnKSJ9DQogICAgICAgICAgICBXcml0ZS1BUCAiJFByZWZpeENvZGUkQ2h1bmsiIC1QYXNzVGhydTokUGFzc1RocnUNCiAgICAgICAgfQ0KICAgIH0NCn0KCmZ1bmN0aW9uIEdldC1QYXRoIHtwYXJhbSgkbWF0Y2gsIFtzdHJpbmddJFBhdGhWYXIgPSAiUEFUSCIpCg0KICAgICRQdGggPSBbRW52aXJvbm1lbnRdOjpHZXRFbnZpcm9ubWVudFZhcmlhYmxlKCRQYXRoVmFyKQ0KICAgICRJc1VuaXggPSAkUFNWZXJzaW9uVGFibGUuUGxhdGZvcm0gLWVxICJVbml4Ig0KICAgICRQYXRoU2VwID0gJChpZiAoJElzVW5peCkgeyI6In0gZWxzZSB7IjsifSkNCiAgICBpZiAoISRQdGgpIHtyZXR1cm4gQCgpfQ0KICAgIFNldC1QYXRoICRQdGggLVBhdGhWYXIgJFBhdGhWYXINCiAgICAkZCA9ICgkUHRoKS5zcGxpdCgkUGF0aFNlcCkNCiAgICBpZiAoJG1hdGNoKSB7JGQgLW1hdGNoICRtYXRjaH0gZWxzZSB7JGR9DQp9CgpmdW5jdGlvbiBBUC1Db252ZXJ0UGF0aCB7cGFyYW0oW1BhcmFtZXRlcihNYW5kYXRvcnk9JFRydWUpXVtTdHJpbmddJFBhdGgpCg0KICAgICRQYXRoU2VwID0gW0lPLlBhdGhdOjpEaXJlY3RvcnlTZXBhcmF0b3JDaGFyDQogICAgcmV0dXJuICRQYXRoIC1yZXBsYWNlIA0KICAgICAgICAiPERlcD4iLCI8TGliPiR7UGF0aFNlcH1EZXBlbmRlbmNpZXMiIC1yZXBsYWNlIA0KICAgICAgICAiPExpYj4iLCI8SG9tZT4ke1BhdGhTZXB9QVAtTGlicmFyaWVzIiAtcmVwbGFjZSANCiAgICAgICAgIjxDb21wKG9uZW50cyk/PiIsIjxIb21lPiR7UGF0aFNlcH1BUC1Db21wb25lbnRzIiAtcmVwbGFjZSANCiAgICAgICAgIjxIb21lPiIsJFBTSGVsbH0KClNldC1BbGlhcyA/OiBJbnZva2UtVGVybmFyeQ==")
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
$ForcedDependencies = $tokens | ? kind -eq 'comment' | ? text -Match "^..?\s*ap-compiler?\:" | % {$_ -replace "^.*?ap-compiler\: *(.+?) *(?<a>\#\>)?$",'$1' -split ","} | % {$_.Trim()} | ? {$_} | % {
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
} elseif ($Data -match "`n\[CmdletBinding\(\)\] *`n") {
    Write-APL ">*","Detected Procedural Layout"
    $M = [Regex]::Match($Data,"(Begin|Process|End) *\{")
    if (!$M.success) {
        Write-APL ">>!","No Begin/Process/End Tags found... Please check that your code is runnable?"
    } else {
        $Data = $Data.insert($M.Index+$M.Length,$Injecter)
    }
} else {
    Write-APL ">*","Detected Linear Layout"
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
