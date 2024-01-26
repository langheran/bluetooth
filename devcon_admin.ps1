[CmdletBinding()] Param (
    [Parameter(Mandatory=$false)][string]$DeviceName="WorkTunes Connect",
    [Parameter(Mandatory=$false)][bool]$Disable=$false,
    [Parameter(Mandatory=$false)][bool]$Pause=$false
)
Write-Host "Restarting Bluetooth Device" $DeviceName
$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
Push-Location $dir

$Source = @"
	[DllImport("BluetoothAPIs.dll", SetLastError = true, CallingConvention = CallingConvention.StdCall)]
	[return: MarshalAs(UnmanagedType.U4)]
	static extern UInt32 BluetoothRemoveDevice(IntPtr pAddress);
	public static UInt32 Unpair(UInt64 BTAddress) {
		GCHandle pinnedAddr = GCHandle.Alloc(BTAddress, GCHandleType.Pinned);
		IntPtr pAddress     = pinnedAddr.AddrOfPinnedObject();
		UInt32 result       = BluetoothRemoveDevice(pAddress);
		pinnedAddr.Free();
		return result;
	}
"@

$BTR = Add-Type -MemberDefinition $Source -Name "BTRemover"  -Namespace "BStuff" -PassThru

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
    $BTDevice =  Get-PnpDevice | Where-Object {($_.FriendlyName -match ".*$DeviceName.*" -or $_.FriendlyName -eq $DeviceName) -and $_.class -eq "Bluetooth"}
    # Write-Host "Type" $BTDevice.GetType().Name
    if ($BTDevice -is [CimInstance] -or $BTDevice -is [array]){
        $BTDevice = @($BTDevice)
        Write-Host "Matches count:" $BTDevice.Count
        for ($j = 0; $j -lt $BTDevice.Count; $j++) {
            $BTDev = $BTDevice[$j]
            Write-Host "Bluetooth Device Name" $BTDev.FriendlyName
            if ($BTDev.DeviceID){
                $newID = "$($BTDev.DeviceID)"
                Write-Host "Bluetooth Device ID" $newID
                $device_ids=@($device_ids, $newID)
            }
        }
    } else {
        if ($BTDevice.DeviceID){
            Write-Host "Bluetooth Device Name" $BTDevice.FriendlyName
            $newID = "$($BTDevice.DeviceID)"
            Write-Host "Bluetooth Device ID" $newID
            $device_ids=@($device_ids, $newID)
        }
    }
}
$device_ids=$device_ids | Get-Unique
for ($i = 0; $i -lt $device_ids.Count; $i++) {
    $device_id = $device_ids[$i]
    if (-not $device_id)
    {
        continue
    }
    Write-Host "Restarting Bluetooth Device" $device_id
    $BTDevice =  Get-PnpDevice | Where-Object {$_.DeviceID -eq $device_id}
    Write-Host "Device:" $BTDevice.InstanceId
    Disable-PnpDevice -InstanceId $device_id -Confirm:$false -ErrorAction SilentlyContinue
    Start-Process devcon.exe -ArgumentList "disable ""@$($device_id)""" -Verb RunAs -WindowStyle hidden
    if(-not $Disable){
        Start-Process devcon.exe -ArgumentList "enable ""@$($device_id)""" -Verb RunAs -WindowStyle hidden
        Enable-PnpDevice -InstanceId $device_id -Confirm:$false -ErrorAction SilentlyContinue
    } else {
        Write-Host "Bluetooth Device" $device_id "Disabled"
        # $Address = [uInt64]('0x{0}' -f $BTDevice.HardwareID[0].Substring(12))
        # $BTR::Disconnect($Address)
    }
}
Pop-Location
if($Pause){
    pause
}
