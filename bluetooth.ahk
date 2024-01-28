#SingleInstance force

; create bluetooth folder if not exists
if not FileExist(A_ScriptDir "\bluetooth")
    FileCreateDir, %A_ScriptDir%\bluetooth

; Read command line parameters
; https://www.autohotkey.com/docs/v1/Scripts.htm#cmd
if A_Args.Length() > 0
{
    DeviceNumber := A_Args[1]
}
else
{
    IniRead, DeviceNumber, %A_ScriptDir%\bluetooth.ini, Settings, DeviceNumber, 1
}
ObjIndexOf(obj, item, case_sensitive:=false)
{
	for i, val in obj {
		if (case_sensitive ? (val == item) : (val = item))
			return i
	}
    return 0
}

RestartService(){
    ; RunWait, net stop "Bluetooth Support Service" /y, , Max
    RunWait, net stop "Bluetooth Support Service" /y, , Hide
    ; RunWait, net start "Bluetooth Support Service" /y, , Max
    RunWait, net start "Bluetooth Support Service" /y, , Hide
}

; export registry .reg files for all bluetooth devices
RegGetKeys(RegPath) {
    Keys:=[]
    Loop, Reg, % RegPath, KVR
    {
        if A_LoopRegType = key
            value =
        else
        {
            RegRead, value
            if ErrorLevel
                value = *error*
        }
        if (A_LoopRegType=="KEY"){
            RegExport(RegPath "\" A_LoopRegName, A_ScriptDir "\bluetooth\" A_LoopRegName ".reg")
            Keys.Push(A_LoopRegName)
        }
    }
    Loop, Files, %A_ScriptDir%\bluetooth\*.reg
    {
        key:=StrReplace(A_LoopFileName, "." A_LoopFileExt)
        if !ObjIndexOf(Keys,key){
            Keys.Push(key)
        }
    }
    return Keys
}
BinaryToString(BinaryData){
    StringFromBinary := ""
    Loop, % StrLen(BinaryData)//2
    {
        Hex := SubStr(BinaryData, A_Index * 2 - 1, 2)
        StringFromBinary .= Chr("0x" . Hex)
    }
    return StringFromBinary
}
RegExport(RegPath, OutputFile) {
    RunWait, regedit /e "%OutputFile%" "%RegPath%"
}

ShowTooltip:
    CoordMode, Tooltip, Screen
    ToolTip, %TooltipMessage%, 0, 0
    Sleep, 3000
    ToolTip
return

BluetoothControl(DeviceName, Action){
    BluetoothDevices:=RegGetKeys("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\BTHPORT\Parameters\Devices")
    Loop, % BluetoothDevices.MaxIndex()
    {
        BluetoothDevice:=BluetoothDevices[A_Index]
        IniRead, BluetoothDeviceName, %A_ScriptDir%\bluetooth\%BluetoothDevice%.reg, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\BTHPORT\Parameters\Devices\%BluetoothDevice%, "Name", 0
        if (BluetoothDeviceName){
            BluetoothDeviceName:=StrReplace(BluetoothDeviceName, "hex:", "")
            BluetoothDeviceName:=StrReplace(BluetoothDeviceName, ",", "")
            if (BluetoothDeviceName!="" && InStr(BluetoothDeviceName, "")){
                BluetoothDeviceName:=BinaryToString(BluetoothDeviceName)
                if (InStr(BluetoothDeviceName, DeviceName)){
                    if (Action="Disable"){
                        ; Run, sc config deviceassociationservice start=demand, %A_ScriptDir%, Hide
                        ; Run, sc stop deviceassociationservice, %A_ScriptDir%, Hide
                        RegDelete, HKEY_LOCAL_MACHINE, SYSTEM\CurrentControlSet\Services\BTHPORT\Parameters\Devices\%BluetoothDevice%
                    } else {
                        Run, regedit /s "%A_ScriptDir%\bluetooth\%BluetoothDevice%.reg", %A_ScriptDir%, Hide
                    }
                }
            }
        }
    }
}
if (DeviceNumber=0){
    Run, powershell -command .\bluetooth.ps1 -BluetoothStatus Off, %A_ScriptDir%, Hide
    TooltipMessage=Bluetooth Disconnected
    SetTimer, ShowTooltip, -1
} else {
    IniRead, DeviceName, %A_ScriptDir%\bluetooth.ini, Settings, DeviceName.%DeviceNumber%,0
    if (DeviceName){
        IniRead, PrevDeviceNumber, %A_ScriptDir%\bluetooth.ini, Settings, DeviceNumber, 0
        if (PrevDeviceNumber!=DeviceNumber && PrevDeviceNumber){
            IniRead, PrevDeviceName, %A_ScriptDir%\bluetooth.ini, Settings, DeviceName.%PrevDeviceNumber%, 0
            if (PrevDeviceName){
                ; msgbox, %PrevDeviceName%
                RunWait, powershell -command .\devcon_admin.ps1 -DeviceName '%PrevDeviceName%' -Disable 1, %A_ScriptDir%, Hide
                BluetoothControl(PrevDeviceName, "Disable")
                RestartService()
                ; RunWait, powershell -command .\devcon_admin.ps1 -DeviceName '%PrevDeviceName%' -Disable 1 -Pause 1, %A_ScriptDir%, Max
                RunWait, powershell -command .\bluetooth.ps1 -BluetoothStatus Off, %A_ScriptDir%, Hide
            }
            Sleep, 100
        }
        IniWrite, %DeviceNumber%, %A_ScriptDir%\bluetooth.ini, Settings, DeviceNumber
        IniWrite, %DeviceName%, %A_ScriptDir%\bluetooth.ini, Settings, DeviceName.%DeviceNumber%
        BluetoothControl(DeviceName, "Enable")
        RestartService()
        RunWait, powershell -command .\bluetooth.ps1 -BluetoothStatus On, %A_ScriptDir%, Hide
        RunWait, powershell -command .\devcon_admin.ps1 -DeviceName '%DeviceName%', %A_ScriptDir%, Hide
        ; RunWait, powershell -command .\devcon_admin.ps1 -DeviceName '%DeviceName%' -Pause 1, %A_ScriptDir%, Max
        TooltipMessage=Bluetooth %DeviceName% Connected
        SetTimer, ShowTooltip, -1
    }
}
Sleep, 10000
