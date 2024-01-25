[CmdletBinding()] Param (
    [Parameter(Mandatory=$true)][string]$DeviceName="WorkTunes Connect"
)
Write-Host "Restarting Bluetooth Device" $DeviceName
$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
Push-Location $dir
# read the device ids from the output of devcon.exe
$device_ids = @()
$DeviceNames = @(
    $DeviceName,
    "$DeviceName Avrcp Transport",
    "$DeviceName Hands-Free AG Audio",
    "$DeviceName Stereo",
    "$DeviceName Hands-Free AG"
)
for ($i = 0; $i -lt $DeviceNames.Count; $i++) {
    $DeviceName = $DeviceNames[$i]
    Write-Host "Bluetooth Device" $DeviceName
    $BTDevice =  Get-PnpDevice | Where-Object {$_.FriendlyName -eq $DeviceName -and $_.class -eq "Bluetooth"} 
    if ($BTDevice.DeviceID){
        Write-Host "Bluetooth Device " $BTDevice.DeviceID
        $device_ids+="@"+$BTDevice.DeviceID
    }
}
for ($i = 0; $i -lt $device_ids.Count; $i++) {
    $device_id = $device_ids[$i]
    Write-Host "Restarting Bluetooth Device" $device_id
    Start-Process devcon.exe -ArgumentList "disable ""$($device_id)""" -Verb RunAs -WindowStyle hidden
    Start-Process devcon.exe -ArgumentList "enable ""$($device_id)""" -Verb RunAs -WindowStyle hidden
}
Pop-Location
