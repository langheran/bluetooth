IniRead, DeviceName, %A_ScriptDir%\bluetooth.ini, Settings, DeviceName, WorkTunes Connect
IniWrite, %DeviceName%, %A_ScriptDir%\bluetooth.ini, Settings, DeviceName
Run, powershell -command .\bluetooth.ps1 -BluetoothStatus On, %A_ScriptDir%, Hide
Run, powershell -command .\devcon_admin.ps1 -DeviceName '%DeviceName%', %A_ScriptDir%, Hide
