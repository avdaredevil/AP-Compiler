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
param([Parameter(Mandatory=$True)][String]$File,[String]$OutputFolder = '.',[switch]$OverwriteSrc,[Switch]$Dbg,[Switch]$PassThru)
# =======================================START=OF=COMPILER==========================================================|
#    The Following Code was added by AP-Compiler Version [1.3] To Make this program independent of AP-Core Engine
#    GitHub: https://github.com/avdaredevil/AP-Compiler
# ==================================================================================================================|
$Script:PSHell=$(if($PSHell){$PSHell}elseif($PSScriptRoot){$PSScriptRoot}else{"."});
iex ([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("ZnVuY3Rpb24gQVAtQ29udmVydFBhdGgge3BhcmFtKFtQYXJhbWV0ZXIoTWFuZGF0b3J5PSRUcnVlKV1bU3RyaW5nXSRQYXRoKQ0KDQogICAgcmV0dXJuICRQYXRoIC1yZXBsYWNlIA0KICAgICAgICAiPERlcD4iLCI8TGliPlxEZXBlbmRlbmNpZXMiIC1yZXBsYWNlIA0KICAgICAgICAiPExpYj4iLCI8SG9tZT5cQVAtTGlicmFyaWVzIiAtcmVwbGFjZSANCiAgICAgICAgIjxDb21wKG9uZW50cyk/PiIsIjxIb21lPlxBUC1Db21wb25lbnRzIiAtcmVwbGFjZSANCiAgICAgICAgIjxIb21lPiIsJFBTSGVsbH0KCmZ1bmN0aW9uIEludm9rZS1UZXJuYXJ5IHtwYXJhbShbYm9vbF0kZGVjaWRlciwgW3NjcmlwdGJsb2NrXSRpZnRydWUsIFtzY3JpcHRibG9ja10kaWZmYWxzZSkNCg0KICAgIGlmICgkZGVjaWRlcikgeyAmJGlmdHJ1ZX0gZWxzZSB7ICYkaWZmYWxzZSB9DQp9CgpmdW5jdGlvbiBXcml0ZS1BUCB7DQogICAgW0NtZGxldEJpbmRpbmcoKV0NCiAgICBwYXJhbShbUGFyYW1ldGVyKFZhbHVlRnJvbVBpcGVsaW5lPSR0cnVlLCBNYW5kYXRvcnk9JFRydWUpXSRUZXh0LFtTd2l0Y2hdJE5vU2lnbixbU3dpdGNoXSRQbGFpblRleHQsW1ZhbGlkYXRlU2V0KCJDZW50ZXIiLCJSaWdodCIsIkxlZnQiKV1bU3RyaW5nXSRBbGlnbj0nTGVmdCcsW1N3aXRjaF0kUGFzc1RocnUpDQogICAgYmVnaW4geyRUVCA9IEAoKX0NCiAgICBQcm9jZXNzIHskVFQgKz0gLCRUZXh0fQ0KICAgIEVORCB7DQogICAgICAgICRCbHVlID0gJChpZiAoJFdSSVRFX0FQX0xFR0FDWV9DT0xPUlMpezN9ZWxzZXsnQmx1ZSd9KQ0KICAgICAgICBpZiAoJFRULmNvdW50IC1lcSAxKSB7JFRUID0gJFRUWzBdfTskVGV4dCA9ICRUVA0KICAgICAgICBpZiAoJHRleHQuY291bnQgLWd0IDEgLW9yICR0ZXh0LkdldFR5cGUoKS5OYW1lIC1tYXRjaCAiXFtcXSQiKSB7DQogICAgICAgICAgICByZXR1cm4gJFRleHQgfCA/IHsiJF8ifSB8ICUgew0KICAgICAgICAgICAgICAgIFdyaXRlLUFQICRfIC1Ob1NpZ246JE5vU2lnbiAtUGxhaW5UZXh0OiRQbGFpblRleHQgLUFsaWduICRBbGlnbiAtUGFzc1RocnU6JFBhc3NUaHJ1DQogICAgICAgICAgICB9DQogICAgICAgIH0NCiAgICAgICAgaWYgKCEkdGV4dCAtb3IgJHRleHQgLW5vdG1hdGNoICJeKCg/PE5OTD54KXwoPzxOUz5ucz8pKXswLDJ9KD88dD5cPiopKD88cz5bK1wtIVwqXCNcQF9dKSg/PHc+LiopIikge3JldHVybiAkVGV4dH0NCiAgICAgICAgJHRiICA9ICIgICAgIiokTWF0Y2hlcy50Lmxlbmd0aA0KICAgICAgICAkQ29sID0gQHsnKyc9JzInOyctJz0nMTInOychJz0nMTQnOycqJz0kQmx1ZTsnIyc9J0RhcmtHcmF5JzsnQCc9J0dyYXknOydfJz0nd2hpdGUnfVsoJFNpZ24gPSAkTWF0Y2hlcy5TKV0NCiAgICAgICAgaWYgKCEkQ29sKSB7VGhyb3cgIkluY29ycmVjdCBTaWduIFskU2lnbl0gUGFzc2VkISJ9DQogICAgICAgICRTaWduID0gJChpZiAoJE5vU2lnbiAtb3IgJE1hdGNoZXMuTlMpIHsiIn0gZWxzZSB7IlskU2lnbl0gIn0pDQogICAgICAgIEFQLVJlcXVpcmUgImZ1bmN0aW9uOkFsaWduLVRleHQiIHtmdW5jdGlvbiBHbG9iYWw6QWxpZ24tVGV4dCgkYWxpZ24sJHRleHQpIHskdGV4dH19DQogICAgICAgICREYXRhID0gIiR0YiRTaWduJCgkTWF0Y2hlcy5XKSI7aWYgKCEkRGF0YSkge3JldHVybn0NCiAgICAgICAgJERhdGEgPSBBbGlnbi1UZXh0IC1BbGlnbiAkQWxpZ24gIiR0YiRTaWduJCgkTWF0Y2hlcy5XKSINCiAgICAgICAgaWYgKCRQbGFpblRleHQpIHtyZXR1cm4gJERhdGF9DQogICAgICAgIFdyaXRlLUhvc3QgLU5vTmV3TGluZTokKFtib29sXSRNYXRjaGVzLk5OTCkgLWYgJENvbCAkRGF0YQ0KICAgICAgICBpZiAoJFBhc3NUaHJ1KSB7cmV0dXJuICREYXRhfQ0KICAgIH0NCn0KCmZ1bmN0aW9uIEpTLU9SIHtmb3JlYWNoICgkYSBpbiAkYXJncykge2lmICghJGEpIHtjb250aW51ZX07aWYgKCRhLkdldFR5cGUoKS5OYW1lIC1lcSAiU2NyaXB0QmxvY2siKSB7JGEgPSAkYS5pbnZva2UoKTtpZiAoISRhKXtjb250aW51ZX19O3JldHVybiAkYX19CgpmdW5jdGlvbiBBUC1SZXF1aXJlIHtwYXJhbShbUGFyYW1ldGVyKE1hbmRhdG9yeT0kVHJ1ZSldW0FsaWFzKCJGdW5jdGlvbmFsaXR5IiwiTGlicmFyeSIpXVtTdHJpbmddJExpYiwgW1NjcmlwdEJsb2NrXSRPbkZhaWw9e30sIFtTd2l0Y2hdJFBhc3NUaHJ1KQ0KDQogICAgJExvYWRNb2R1bGUgPSB7DQogICAgICAgIHBhcmFtKCRGaWxlLFtib29sXSRJbXBvcnQpDQogICAgICAgIHRyeSB7SW1wb3J0LU1vZHVsZSAkRmlsZSAtZWEgc3RvcDtyZXR1cm4gMX0gY2F0Y2gge30NCiAgICAgICAgJExpYj1BUC1Db252ZXJ0UGF0aCAiPExJQj4iOyRMRiA9ICIkTGliXCRGaWxlIg0KICAgICAgICBbc3RyaW5nXSRmID0gaWYodGVzdC1wYXRoIC10IGxlYWYgJExGKXskTEZ9ZWxzZWlmKHRlc3QtcGF0aCAtdCBsZWFmICIkTEYuZGxsIil7IiRMRi5kbGwifQ0KICAgICAgICBpZiAoJGYgLWFuZCAkSW1wb3J0KSB7SW1wb3J0LU1vZHVsZSAkZn0NCiAgICAgICAgcmV0dXJuICRmDQogICAgfQ0KICAgICRTdGF0ID0gJChzd2l0Y2ggLXJlZ2V4ICgkTGliLnRyaW0oKSkgew0KICAgICAgICAiXkludGVybmV0IiAgICAgICAgICAgICAgIHt0ZXN0LWNvbm5lY3Rpb24gZ29vZ2xlLmNvbSAtQ291bnQgMSAtUXVpZXR9DQogICAgICAgICJeZGVwOiguKikiICAgICAgICAgICAgICAge0dldC1XaGVyZSAkTWF0Y2hlc1sxXX0NCiAgICAgICAgIl4obGlifG1vZHVsZSk6KC4qKSIgICAgICB7JExvYWRNb2R1bGUuaW52b2tlKCRNYXRjaGVzWzJdLCAkdHJ1ZSl9DQogICAgICAgICJeKGxpYnxtb2R1bGUpX3Rlc3Q6KC4qKSIgeyRMb2FkTW9kdWxlLmludm9rZSgkTWF0Y2hlc1syXSl9DQogICAgICAgICJeZnVuY3Rpb246KC4qKSIgICAgICAgICAge2djbSAkTWF0Y2hlc1sxXSAtZWEgU2lsZW50bHlDb250aW51ZX0NCiAgICAgICAgIl5zdHJpY3RfZnVuY3Rpb246KC4qKSIgICB7VGVzdC1QYXRoICJGdW5jdGlvbjpcJCgkTWF0Y2hlc1sxXSkifQ0KICAgICAgICBkZWZhdWx0IHtXcml0ZS1BUCAiIUludmFsaWQgc2VsZWN0b3IgcHJvdmlkZWQgWyQoIiRMaWIiLnNwbGl0KCc6JylbMF0pXSI7dGhyb3cgJ0JBRF9TRUxFQ1RPUid9DQogICAgfSkNCiAgICBpZiAoISRTdGF0KSB7JE9uRmFpbC5JbnZva2UoKX0NCiAgICBpZiAoJFBhc3NUaHJ1KSB7cmV0dXJuICRTdGF0fQ0KfQoKZnVuY3Rpb24gRmxhdHRlbiB7cGFyYW0oW29iamVjdFtdXSR4KQ0KDQogICAgaWYgKCEoJFggLWlzIFthcnJheV0pKSB7cmV0dXJuICR4fQ0KICAgIGlmICgkWC5jb3VudCAtZXEgMSkgew0KICAgICAgICByZXR1cm4gJHggfCAlIHskX30NCiAgICB9DQogICAgJHggfCAlIHtGbGF0dGVuICRffQ0KfQoKZnVuY3Rpb24gR2V0LUZpbGVFbmNvZGluZyB7cGFyYW0oW1BhcmFtZXRlcihNYW5kYXRvcnk9JFRydWUpXSRQYXRoKQ0KDQogICAgJGJ5dGVzID0gW2J5dGVbXV0oR2V0LUNvbnRlbnQgJFBhdGggLUFzQnl0ZVN0cmVhbSAtUmVhZENvdW50IDQgLVRvdGFsQ291bnQgNCkNCg0KICAgIGlmKCEkYnl0ZXMpIHsgcmV0dXJuICd1dGY4JyB9DQoNCiAgICBzd2l0Y2ggLXJlZ2V4ICgnezA6eDJ9ezE6eDJ9ezI6eDJ9ezM6eDJ9JyAtZiAkYnl0ZXNbMF0sJGJ5dGVzWzFdLCRieXRlc1syXSwkYnl0ZXNbM10pIHsNCiAgICAgICAgJ15lZmJiYmYnICAge3JldHVybiAndXRmOCd9DQogICAgICAgICdeMmIyZjc2JyAgIHtyZXR1cm4gJ3V0ZjcnfQ0KICAgICAgICAnXmZmZmUnICAgICB7cmV0dXJuICd1bmljb2RlJ30NCiAgICAgICAgJ15mZWZmJyAgICAge3JldHVybiAnYmlnZW5kaWFudW5pY29kZSd9DQogICAgICAgICdeMDAwMGZlZmYnIHtyZXR1cm4gJ3V0ZjMyJ30NCiAgICAgICAgZGVmYXVsdCAgICAge3JldHVybiAnYXNjaWknfQ0KICAgIH0NCn0KCmZ1bmN0aW9uIENvbnZlcnQtVG9CYXNlNjQge3BhcmFtKFtQYXJhbWV0ZXIoVmFsdWVGcm9tUGlwZWxpbmU9JHRydWUpXVtTdHJpbmddJFRleHQsIFtWYWxpZGF0ZVNldCgiVVRGOCIsIlVuaWNvZGUiKV1bU3RyaW5nXSRFbmNvZGluZyA9ICJVVEY4IikNCg0KICAgIFtTeXN0ZW0uQ29udmVydF06OlRvQmFzZTY0U3RyaW5nKFtTeXN0ZW0uVGV4dC5FbmNvZGluZ106OiRFbmNvZGluZy5HZXRCeXRlcygkVGV4dCkpDQp9CgpmdW5jdGlvbiBBbGlnbi1UZXh0IHtwYXJhbShbUGFyYW1ldGVyKE1hbmRhdG9yeT0kVHJ1ZSldW1N0cmluZ1tdXSRUZXh0LCBbVmFsaWRhdGVTZXQoIkNlbnRlciIsIlJpZ2h0IiwiTGVmdCIpXVtTdHJpbmddJEFsaWduPSdDZW50ZXInKQ0KDQogICAgaWYgKCRUZXh0LmNvdW50IC1ndCAxKSB7DQogICAgICAgICRhbnMgPSBAKCkNCiAgICAgICAgZm9yZWFjaCAoJGxuIGluICRUZXh0KSB7JEFucyArPSBBbGlnbi1UZXh0ICRsbiAkQWxpZ259DQogICAgICAgIHJldHVybiAoJGFucykNCiAgICB9IGVsc2Ugew0KICAgICAgICAkV2luU2l6ZSA9IFtjb25zb2xlXTo6QnVmZmVyV2lkdGgNCiAgICAgICAgaWYgKCgiIiskVGV4dCkuTGVuZ3RoIC1nZSAkV2luU2l6ZSkgew0KICAgICAgICAgICAgJEFwcGVuZGVyID0gQCgiIik7DQogICAgICAgICAgICAkaiA9IDANCiAgICAgICAgICAgIGZvcmVhY2ggKCRwIGluIDAuLigoIiIrJFRleHQpLkxlbmd0aC0xKSl7DQogICAgICAgICAgICAgICAgaWYgKCgkcCsxKSUkd2luc2l6ZSAtZXEgMCkgeyRqKys7JEFwcGVuZGVyICs9ICIifQ0KICAgICAgICAgICAgICAgICMgIiIrJGorIiAtICIrJHANCiAgICAgICAgICAgICAgICAkQXBwZW5kZXJbJGpdICs9ICRUZXh0LmNoYXJzKCRwKQ0KICAgICAgICAgICAgfQ0KICAgICAgICAgICAgcmV0dXJuIChBbGlnbi1UZXh0ICRBcHBlbmRlciAkQWxpZ24pDQogICAgICAgIH0gZWxzZSB7DQogICAgICAgICAgICBpZiAoJEFsaWduIC1lcSAiQ2VudGVyIikgew0KICAgICAgICAgICAgICAgIHJldHVybiAoIiAiKlttYXRoXTo6dHJ1bmNhdGUoKCRXaW5TaXplLSgiIiskVGV4dCkuTGVuZ3RoKS8yKSskVGV4dCkNCiAgICAgICAgICAgIH0gZWxzZWlmICgkQWxpZ24gLWVxICJSaWdodCIpIHsNCiAgICAgICAgICAgICAgICByZXR1cm4gKCIgIiooJFdpblNpemUtKCIiKyRUZXh0KS5MZW5ndGgtMSkrJFRleHQpDQogICAgICAgICAgICB9IGVsc2Ugew0KICAgICAgICAgICAgICAgIHJldHVybiAoJFRleHQpDQogICAgICAgICAgICB9DQogICAgICAgIH0NCiAgICB9DQp9CgpmdW5jdGlvbiBHZXQtV2hlcmUgew0KICAgIFtDbWRsZXRCaW5kaW5nKERlZmF1bHRQYXJhbWV0ZXJTZXROYW1lPSJOb3JtYWwiKV0NCiAgICBwYXJhbSgNCiAgICAgICAgW1BhcmFtZXRlcihNYW5kYXRvcnk9JHRydWUsIFBvc2l0aW9uPTApXVtzdHJpbmddJEZpbGUsDQogICAgICAgIFtTd2l0Y2hdJEFsbCwNCiAgICAgICAgW1BhcmFtZXRlcihQYXJhbWV0ZXJTZXROYW1lPSdOb3JtYWwnKV1bUGFyYW1ldGVyKFBhcmFtZXRlclNldE5hbWU9J1NjYW4nKV1bU3dpdGNoXSRNYW51YWxTY2FuLA0KICAgICAgICBbUGFyYW1ldGVyKFBhcmFtZXRlclNldE5hbWU9J1NjYW4nKV1bU3dpdGNoXSREYmcsDQogICAgICAgIFtQYXJhbWV0ZXIoUGFyYW1ldGVyU2V0TmFtZT0nU2NhbicpXVtzdHJpbmddJFBhdGhWYXIgPSAiUEFUSCINCiAgICApDQogICAgJElzVmVyYm9zZSA9ICREYmcgLW9yICRQU0JvdW5kUGFyYW1ldGVycy5Db250YWluc0tleSgnVmVyYm9zZScpIC1vciAkUFNCb3VuZFBhcmFtZXRlcnMuQ29udGFpbnNLZXkoJ0RlYnVnJykNCiAgICAkV2hlcmVCaW5FeGlzdHMgPSBHZXQtQ29tbWFuZCAid2hlcmUiIC1lYSBTaWxlbnRseUNvbnRpbnVlDQogICAgJElzVW5peCA9ICRQU1ZlcnNpb25UYWJsZS5QbGF0Zm9ybSAtZXEgIlVuaXgiDQogICAgaWYgKCRGaWxlIC1lcSAid2hlcmUiIC1vciAkRmlsZSAtZXEgIndoZXJlLmV4ZSIpIHtyZXR1cm4gJFdoZXJlQmluRXhpc3RzfQ0KICAgIGlmICgkV2hlcmVCaW5FeGlzdHMgLWFuZCAhJE1hbnVhbFNjYW4pIHsNCiAgICAgICAgJE91dD0kbnVsbA0KICAgICAgICBpZiAoJElzVW5peCkgew0KICAgICAgICAgICAgJE91dCA9IHdoaWNoICRmaWxlIDI+JG51bGwNCiAgICAgICAgfSBlbHNlIHskT3V0ID0gd2hlcmUuZXhlICRmaWxlIDI+JG51bGx9DQogICAgICAgIA0KICAgICAgICBpZiAoISRPdXQpIHtyZXR1cm59DQogICAgICAgIGlmICgkQWxsKSB7cmV0dXJuICRPdXR9DQogICAgICAgIHJldHVybiBAKCRPdXQpWzBdDQogICAgfQ0KICAgIGZvcmVhY2ggKCRGb2xkZXIgaW4gKEdldC1QYXRoIC1QYXRoVmFyICRQYXRoVmFyKSkgew0KICAgICAgICBpZiAoJElzVW5peCkgew0KICAgICAgICAgICAgJExvb2t1cCA9ICIkRm9sZGVyLyRGaWxlIg0KICAgICAgICAgICAgaWYgKCRJc1ZlcmJvc2UpIHtXcml0ZS1BUCAiKkNoZWNraW5nIFskTG9va3VwXSJ9DQogICAgICAgICAgICBpZiAoIShUZXN0LVBhdGggLVBhdGhUeXBlIExlYWYgJExvb2t1cCkpIHtjb250aW51ZX0NCiAgICAgICAgICAgIFJlc29sdmUtUGF0aCAkTG9va3VwIHwgJSBQYXRoDQogICAgICAgICAgICBpZiAoISRBbGwpIHtyZXR1cm59DQogICAgICAgIH0gZWxzZSB7DQogICAgICAgICAgICBmb3JlYWNoICgkRXh0ZW5zaW9uIGluIChHZXQtUGF0aCAtUGF0aFZhciBQQVRIRVhUKSkgew0KICAgICAgICAgICAgICAgICRMb29rdXAgPSAiJEZvbGRlci8kRmlsZSRFeHRlbnNpb24iDQogICAgICAgICAgICAgICAgaWYgKCRJc1ZlcmJvc2UpIHtXcml0ZS1BUCAiKkNoZWNraW5nIFskTG9va3VwXSJ9DQogICAgICAgICAgICAgICAgaWYgKCEoVGVzdC1QYXRoIC1QYXRoVHlwZSBMZWFmICRMb29rdXApKSB7Y29udGludWV9DQogICAgICAgICAgICAgICAgUmVzb2x2ZS1QYXRoICRMb29rdXAgfCAlIFBhdGgNCiAgICAgICAgICAgICAgICBpZiAoISRBbGwpIHtyZXR1cm59DQogICAgICAgICAgICB9DQogICAgICAgIH0NCiAgICB9DQp9CgpmdW5jdGlvbiBHZXQtUGF0aCB7cGFyYW0oJG1hdGNoLCBbc3RyaW5nXSRQYXRoVmFyID0gIlBBVEgiKQ0KDQogICAgJFB0aCA9IFtFbnZpcm9ubWVudF06OkdldEVudmlyb25tZW50VmFyaWFibGUoJFBhdGhWYXIpDQogICAgJElzVW5peCA9ICRQU1ZlcnNpb25UYWJsZS5QbGF0Zm9ybSAtZXEgIlVuaXgiDQogICAgJFBhdGhTZXAgPSAkKGlmICgkSXNVbml4KSB7IjoifSBlbHNlIHsiOyJ9KQ0KICAgIGlmICghJFB0aCkge3JldHVybiBAKCl9DQogICAgU2V0LVBhdGggJFB0aCAtUGF0aFZhciAkUGF0aFZhcg0KICAgICRkID0gKCRQdGgpLnNwbGl0KCRQYXRoU2VwKQ0KICAgIGlmICgkbWF0Y2gpIHskZCAtbWF0Y2ggJG1hdGNofSBlbHNlIHskZH0NCn0KCmZ1bmN0aW9uIFByaW50LUxpc3Qge3BhcmFtKCR4LCBbU3dpdGNoXSRJblJlY3Vyc2UpDQoNCiAgICBpZiAoJHguY291bnQgLWxlIDEpIHtyZXR1cm4gPzooJEluUmVjdXJzZSl7JHh9eyJbJHhdIn19IGVsc2Ugew0KICAgICAgICByZXR1cm4gIlskKCgkeCB8ICUge1ByaW50LUxpc3QgJF8gLUluUmVjdXJzZX0pIC1qb2luICcsICcpXSINCiAgICB9DQp9CgpTZXQtQWxpYXMgPzogSW52b2tlLVRlcm5hcnk=")))
# ========================================END=OF=COMPILER===========================================================|

$Ver = '1.3'

# Track all AP-Console Commands
$TmpHash = @{}
$Tokens = @() # Where the comments will be scannable
$Dep.Keys | % {$TmpHash.$_ = $_}
$Aliases = Get-Alias | ? {$TmpHash.($_.Definition)} | % {"$_"}

function Get-AllNestedFunctionalDeps ([System.Management.Automation.Language.Ast]$RootAst, $Depth = 0, $SeenFuncs = @{}) {
    if (!$RootAst) {return}
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

    return Flatten $Commands | ? {$_}
}

# Validation
if (!$File -or !(Test-Path -type Leaf $File)) {Throw "Invalid File";exit}
if (!(Test-Path -type Container $OutputFolder)) {Throw "Invalid Folder";exit}
$File = (Get-Item $File).FullName
$OutputFolder = (Get-Item $OutputFolder).FullName

# Let's process the file
$Data = [IO.File]::ReadAllLines($File)
$Script:Need2Import = @{}
$Script:Need2ImportAL = @{}
$Script:BlackListFunctions = @{"IN-Code-Debug-Console"=1;"Get-APIKey"=1;"Get-GMAIL"=1;"Backup"=1}


# Use AST to detect the functions used in this script
$Script:ASTT = [System.Management.Automation.Language.Parser]::ParseFile($File, [ref]$Tokens, [ref]$null)
$Script:Functions = Get-AllNestedFunctionalDeps $Script:ASTT

Write-AP "x*","nx_Compiling ","n+$(Split-Path -leaf $File):"
if ($Dbg) {
    Write-AP "x>*","n_Globally detected functions:"
    $Script:Functions | % {
        Write-AP "x>>#","nx+$($_.Name) ","nx#$("." * (23 - $_.Name.length)) ","nx@$($_.Type.PadLeft(8))","nx# | Depth: ","n@$($_.Depth)"
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
$tokens | ? kind -eq 'comment' | ? text -Match "ap-compiler?\:" | % {$_ -replace "^.+?\: *(.+) *(?<a>\#\>)$",'$1' -split ","} | % {$_.Trim()} | ? {$_} | % {
    Write-AP "x>>#","nx@AP-Compiler Forced Command: ","nx+$_"
    if ($_ -in $Aliases) {
        Write-Host ""
        return $Script:Need2ImportAL.$_++
    }
    if ($TmpHash.$_) {
        Write-Host ""
        return $Script:Need2Import.$_++
    }
    Write-AP "n- - Error: Command is not a valid AP-Function or Alias"
}

# if ($Need2Import.KeyPressed) {"KeyTranslate","KeyPressedCode" | % {$Need2Import.$_++};Write-AP "+Added AP-KeyPress Support"}
# if ($Need2Import.Keys | ? {$_ -match "\-path$"}) {"Fix-Path","Set-Path","Get-Path","Remove-FromPath","Add-ToPath" | % {$Need2Import.$_++};Write-AP "+Added AP-Path Support"}
$FinalSet = @($Need2Import.Keys) | ? {!$OtroFunc.$_}
$FinalAlSet = @($Need2ImportAL.Keys) | Select-Object -unique
$Code = $FinalSet | % {"function $_ {1}{0}{2}" -f $(if ($BlackListFunctions.$_) {"Write-Host -f yellow '[AP-COMPILER] Module [$_] disabled for this program'"} else {iex "`${Function:$_}"}),"{","}`n"}
$Code += $FinalAlSet | % {"Set-Alias $_ {0}" -f ((Get-Alias $_).Definition)}
if ($Code) {
    if ($FinalSet -and !$Dbg)   {Write-AP "x>*","n@Adding Functions $(Print-List $FinalSet)"}
    if ($FinalALSet -and !$Dbg) {Write-AP "x>*","n@Adding Aliases   $(Print-List $FinalALSet)"}
    $Injecter = "",
    "# =======================================START=OF=COMPILER==========================================================|",
    "#    The Following Code was added by AP-Compiler Version [$Ver] To Make this program independent of AP-Core Engine",
    "#    GitHub: https://github.com/avdaredevil/AP-Compiler",
    "# ==================================================================================================================|",
    '$Script:PSHell=$(if($PSHell){$PSHell}elseif($PSScriptRoot){$PSScriptRoot}else{"."});',"iex ([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String(""$(Convert-ToBase64 ($Code -join "`n"))"")))",
    "# ========================================END=OF=COMPILER===========================================================|",
    "" -join "`n"
}
$Data = $Data -join "`n"
if ($Data -match "`n\[CmdletBinding\(\)\] *`n") {
    Write-AP "x>*","n_Detected Procedural Layout"
    $M = [Regex]::Match($Data,"(Begin|Process|End) *\{")
    if (!$M.success) {
        Write-AP "x>>!","n_No Begin/Process/End Tags found... Please check that your code is runnable?"
    } else {
        $Data = $Data.insert($M.Index+$M.Length,$Injecter)
    }
} else {
    Write-AP "x>*","n_Detected Linear Layout"
    $M = [Regex]::Match($Data,"(?i)(`n|^)param *\(")
    if (!$M.success) {$Data = "$Injecter$Data"} else {
        $i = 1;$dex=0;$InString=0
        foreach ($c in $Data[($M.Index+$M.Length)..$Data.Length]) {$dex++
            if ($Dbg) {Write-AP "x>>*","n_Explored $c [Stack: $i |$Dex :: $InString -> $(('Code','Dbl-Quot','Single-Quot')[$InString])]"}
            if ($InString -ne 2 -and $c -eq """") {$InString=(1,0)[$InString]}
            elseif ($InString -ne 1 -and $c -eq "'") {$InString=(2,-1,0)[$InString]}
            elseif ($InString) {continue}
            if ($c -eq "(") {$i++}
            elseif ($c -eq ")") {if (!(--$i)) {break}}
        }
        $Data = $Data.insert($M.Index+$M.Length+$dex,$Injecter)
    }
}
if ((Split-Path $File) -eq $OutputFolder -and !$OverwriteSrc) {
    $Outfile = "$((Split-Path -leaf $File).replace('.ps1','-Compiled.ps1'))"
} else {
    $Outfile = "$(Split-Path -leaf $File)"
}
Write-AP "x+","nx_Compiled [","nx+$OutFile","n_]"
$Data | Out-File -Encoding (JS-OR {
    $e = Get-FileEncoding $File
    if ($e -in "utf32","unicode","bigendianunicod") {""} else {[System.Text.Encoding]::$e}
} "utf8") "$OutputFolder\$OutFile"
if ($PassThru) {return $code}
