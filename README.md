# Bluetooth Switcher

## 1. How to Compile and Install

In order to compile and install the Bluetooth Manager, follow these steps:

### Prerequisites

1. Make sure you have AutoHotkey installed on your system. You can download it from [https://www.autohotkey.com/](https://www.autohotkey.com/).
2. The `devcon.exe` utility should be present in the application directory. This tool is part of the Windows Driver Kit (WDK), which you can download from the [Microsoft Hardware Dev Center](https://developer.microsoft.com/en-us/windows/hardware/download-windows-hardware-labs-kit).

### Compilation

1. Make sure you have all the necessary files downloaded and placed within the same directory as the `compile_bluetooth.bat` script.
2. Locate the `compile_bluetooth.bat` in the root folder of the project.
3. Run the `compile_bluetooth.bat` batch file by double-clicking it. This will perform the following actions:
   - Terminate any currently running instance of `bluetooth.exe` using the `taskkill` command.
   - Utilize the `Ahk2Exe.exe` compiler from the AutoHotkey installation directory to compile the `bluetooth.ahk` script into an executable `bluetooth.exe`.
   - The compilation will be done with UTF-8 encoding (code page 65001) and the specified icon `bluetooth.ico`.
   - Once the compilation is complete, it will start the newly created `bluetooth.exe`.
5. The compiled executable `bluetooth.exe` is now ready and will be located in the same folder as the source script and batch files.

### Installation

After compilation, the `bluetooth.exe` file can be run directly without any installation needed. If you want to create a shortcut to the application or place it in a different directory, ensure that all the associated files and the `bluetooth` folder remain in the same directory as the `bluetooth.exe` file.

## 2. The Folder Structure

The folder structure of the Bluetooth Manager is as follows:

- `LICENSE` - The license file that specifies the terms under which the software is distributed.
- `README.md` - This file, which gives instructions on how to compile, install, and use the application.
- `bluetooth` - A directory containing registry files for each Bluetooth device.
  - `1c6e4c14e9ca.reg` - Registry file for a specific Bluetooth device. This files and folders are created automatically.
- `bluetooth.ahk` - The source script for the Bluetooth Manager written in AutoHotkey.
- `bluetooth.bat` - A batch file that may be used to start the application.
- `bluetooth.exe` - The compiled executable of the Bluetooth Manager.
- `bluetooth.ico` - An icon file used to visually represent the Bluetooth Manager.
- `bluetooth.ini` - A configuration file for the Bluetooth Manager containing settings such as device numbers and names.
- `bluetooth.ps1` - A PowerShell script that interfaces with the Bluetooth settings.
- `compile_bluetooth.bat` - A batch file used to compile the AutoHotkey script into an executable.
- `devcon.exe` - The executable file for the Device Console Command-Line Utility (`devcon`).
- `devcon_admin.ps1` - A PowerShell script that uses `devcon` to manage devices.
- `status.md` - A file potentially used for summarizing the status of the Bluetooth Manager.
- `tree.md` - A file containing a markdown representation of the folder and file structure.
- `tree_folder_wsl.bat` - A batch file that might be used to generate the `tree.md` in a Windows Subsystem for Linux (WSL) environment.
## 3. How to Use

The Bluetooth Manager allows you to manage your Bluetooth devices and connections via scripts. Here’s how to use it:

### Enabling/Disabling Bluetooth Devices

1. Edit the `bluetooth.ini` file to include the name and index number of your Bluetooth devices.
2. Run the `bluetooth.exe` file to execute the command specified in `bluetooth.ahk` or `bluetooth.bat`.
3. The script will automatically read from the `bluetooth.ini` based on the device index passed as a command argument or the default one set in the file.
4. Devices can be enabled or disabled according to the settings defined in the script logic.

### Using PowerShell Scripts

- The `bluetooth.ps1` script can switch the Bluetooth status on or off. Run it with the respective parameters for the desired action.
- The `devcon_admin.ps1` script requires administrative privileges and can enable or disable devices using the `devcon` utility.

### Automating Tasks

You can schedule tasks in Windows Task Scheduler to run the Bluetooth Manager scripts at predefined times or events.

## 4. Customizing and Hotkeys

### Customizing Scripts

You can modify the provided AutoHotkey script (`bluetooth.ahk`) and PowerShell scripts (`bluetooth.ps1` and `devcon_admin.ps1`) to fit your particular use case. Customizations may include changing device-related settings, altering the logic for enabling/disabling devices, or adding new functionality.

### Setting Hotkeys

Within `bluetooth.ahk`, it is possible to assign hotkeys to automate tasks such as toggling the Bluetooth status or switching between devices. For instance:
