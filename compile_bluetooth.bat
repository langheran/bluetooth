taskkill /f /im "bluetooth.exe"
"C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /cp 65001 /icon bluetooth.ico /in bluetooth.ahk /out bluetooth.exe
start "" "bluetooth.exe"
@REM start "" "bluetooth.exe" 0
