# DevTools-Win

~~Powershell development helper module designed for Windows users.~~

A collection of Powershell scripts for personal use under Windows, which can effectively improve the development experience under Windows.

![Icon2](https://cdn.jsdelivr.net/gh/ChanthMiao/DevTools-Win@main/assets/icon_64px.png)

## Functions

|      Command      | Alias | Description                                                                                  |
| :---------------: | :---: | :------------------------------------------------------------------------------------------- |
|   Set-WebProxy    |  swp  | Set up a network proxy for the current Powershell session                                    |
|  Clear-WebProxy   | clwp  | Clear the network proxy of the current Powershell session                                    |
|     Add-Path      |  apa  | Add paths to environment variables (PATH, etc.)                                              |
|    Remove-Path    |  rpa  | Delete the path from the environment variable (PATH, etc.)                                   |
|    Enter-VsEnv    | etvs  | Set up the VS developer cli environment                                                      |
|   Enable-Clang    | ecla  | Set the environment variables necessary to run clang (LIB, INCLUDE, PATH)                    |
|   Enable-Vcpkg    | evpg  | Integrate vcpkg for cli environment                                                          |
|  Format-ItemSize  |  fis  | Byte unit conversion to improve the readability of file size                                 |
|   Get-ItemSize    |  gis  | Calculate the size of the specified file/folder                                              |
|    Get-TempDir    |  gtd  | Get system/user temporary folder                                                             |
|  Get-CmdletAlias  | gcas  | Query command alias                                                                          |
| Send-Notification | sdnf  | Send desktop notification (can be used as completion notification for scheduled task script) |
|     Write-Log     | wrlg  | Simple log interface to improve script maintainability                                       |
|     Start-Log     | salg  | Start recording the current Powershell session or script output                              |
|     Stop-Log      | splg  | Stop recording the current Powershell session or script output                               |
|  New-RandString   |  nrs  | Generate random string                                                                       |

## Document

~~This module is mainly for personal daily working, there is no plan to write documents currently.~~（PR is welcomed）

## Installation

There are three main installation methods:

- Manually download[Source code package](https://github.com/xmake-io/xmake/archive/refs/heads/master.zip)，then extract it into a path that contained by PSModulePath;
- Clone this repo into a path that contained by PSModulePath;
- ~~Use scoop to install it~~（Not yet implemented）

## Optional Dependent Libraries

The only optional dependent library for this module is [Windows SDK library for .Net5](https://www.nuget.org/packages/Microsoft.Windows.SDK.NET.Ref)。This library is used to provide WinRT API support for Powershell Core after switching to .Net5, to implement `Send-Notification` command. For details, please refer to the following two links:

- <https://github.com/dotnet/runtime/issues/37672>
- <https://github.com/PowerShell/PowerShell/blob/master/CHANGELOG/7.1.md>

Users who do not need to use the `Send-Notification` command in Powershell Core can create an empty file named disable-cswinrt in the module configuration directory(The corresponding command is `New-Item $Env:LOCALAPPDATA\DevTools-Win\disable-cswinrt -Force`).

Users who need to use this dependency follow the following steps to install the dependency:

```ps1
# Enter the directory where DevTools.psd1 is located
cd "DevTools-Win"
# Set up http(s) proxy (recommended for users in restricted network areas)
. .\src\public\Set-WebProxy.ps1
swp http://<your proxy ip>:<your proxy port>
# Load the module for the first time, triggering automatic dependency download and installation
Import-Module "DevTools-Win"
# Check the lib directory. It can be seen that the dependent files are ready
ls .\lib
# 
#     Directory: C:\Users\shiel\source\modules\DevTools-Win\lib
# 
# Mode                 LastWriteTime         Length Name
# ----                 -------------         ------ ----
# -a---           2021/4/13    20:26       26685320 Microsoft.Windows.SDK.NET.dll
# -a---           2021/4/13    20:26         300424 WinRT.Runtime.dll
# 
```

If you need to update the dependent library files later, you only need to manually delete the above lib path to trigger the dependent installation at the next load.

## Configuration

The custom configuration is stored in the config.json file (comments not supported) under the directory `$Env:LOCALAPPDATA\DevTools-Win`, which is used to override the default configuration.

```json5
{
    "Proxy": "http://192.168.36.1:8080", // Avoid repeated input every time you use swp, which can be overridden by $Env:HTTP(S)_PROXY. The default value is empty.
    "VsWhere": "C:\\Program Files (x86)\\Microsoft Visual Studio\\Installer\\vswhere.exe", // Specify the vswhere program path, which can be overridden by $Env:VSWHERE_PATH.
    "VcpkgRoot": "C:\\Users\\abc\\source\\repos\\vcpkg", // Specify the root directory of vcpkg, which can be overridden by $Env:VCPKG_ROOT. The default value is empty.
    "Clang": "C:\\Users\\abc\\scoop\\shims\\clang.ps1", // Specify the clang path, which can be overridden by $Env:CLANG_PATH. The default value is empty
}
```

## Compatibility

This module is a collection of self-use scripts. My personal main use environment is Windows 10 + Powershell Core + Windows Terminal. Before the official release, a certain degree of compatibility adaptation has been carried out for Windows Powershell 5.1, but 100% compatibility is not guaranteed.

Microsoft's current focus on Powershell development has been tilted to Powershell Core in all aspects. The original Windows Powershell 5.1 is only keeped for compatibility (I have encountered some bugs, which have not been fixed for a long time in actual use.). Taking into account the current differences and maintenance status between the two, I personally recommend that users should migrate to Powershell Core.

## Dirty Hack

Due to the limitation of the .Net technology stack, `Remove-Module` cannot uninstall the Assembly file. This can cause annoying file occupation problems. In order to overcome this problem, the `Send-Notification` command adopts a little trick in its implementation. The side effect of creating a background task through `Start-Job` (out of the current session) makes the loading of the Assembly file limited to the new AppDomain. In this way, the Assembly file will be automatically uninstalled after the task is completed (it will be uninstalled along with the new AppDomain).
