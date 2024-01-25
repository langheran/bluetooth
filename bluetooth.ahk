; Read command line parameters
; https://www.autohotkey.com/docs/commands/CommandLine.htm

if A_Args.Length() > 0
{
    DeviceNumber := A_Args[1]
}
else
{
    DeviceNumber := 1
}
if (DeviceNumber=0){
    Run, powershell -command .\bluetooth.ps1 -BluetoothStatus Off, %A_ScriptDir%, Hide
} else {
    IniRead, DeviceName, %A_ScriptDir%\bluetooth.ini, Settings, DeviceName.%DeviceNumber%, WorkTunes Connect
    IniWrite, %DeviceName%, %A_ScriptDir%\bluetooth.ini, Settings, DeviceName.%DeviceNumber%
    Run, powershell -command .\bluetooth.ps1 -BluetoothStatus On, %A_ScriptDir%, Hide
    Run, powershell -command .\devcon_admin.ps1 -DeviceName '%DeviceName%', %A_ScriptDir%, Hide
}
