# DevTools-Win

~~为 Windows 用户程序员设计的 Powershell 辅助开发模块。~~

个人在 Windows 下的自用的 Powershell 脚本集合，可以有效改善 Windows 下的开发体验。

![Icon2](https://cdn.jsdelivr.net/gh/ChanthMiao/DevTools-Win@main/assets/icon_64px.png)

## 主要功能

|       命令        | 别名  | 功能简述                                          |
| :---------------: | :---: | :------------------------------------------------ |
|   Set-WebProxy    |  swp  | 为当前Powershell会话设置网络代理                  |
|  Clear-WebProxy   | clwp  | 清除当前Powershell会话的网络代理                  |
|     Add-Path      |  apa  | 快速向环境变量（PATH一类）添加路径                |
|    Remove-Path    |  rpa  | 快速从环境变量（PATH一类）删除路径                |
|    Enter-VsEnv    | etvs  | 轻松设定 VS 开发者 cli 环境                       |
|   Enable-Clang    | ecla  | 设置运行clang必要的环境变量（LIB, INCLUDE, PATH） |
|   Enable-Vcpkg    | evpg  | 为 cli 环境集成 vcpkg                             |
|  Format-ItemSize  |  fis  | 字节单位换算，提高文件大小可读性                  |
|   Get-ItemSize    |  gis  | 计算指定文件/文件夹大小                           |
|    Get-TempDir    |  gtd  | 获取系统/用户临时文件夹                           |
|  Get-CmdletAlias  | gcas  | 查询命令别名                                      |
| Send-Notification | sdnf  | 发送桌面通知（可用作定时任务脚本的完成通知）      |
|     Write-Log     | wrlg  | 简易日志接口，提高脚本可维护性                    |
|     Start-Log     | salg  | 记录当前 Powershell 会话或脚本输出                |
|     Stop-Log      | splg  | 停止记录当前 Powershell 会话或脚本输出            |

## 命令详细文档

~~暂无计划，此模块目前主要是自用~~（欢迎PR）

## 安装

主要安装方式有三：

- 手动下载仓库[源码包](https://github.com/xmake-io/xmake/archive/refs/heads/master.zip)，并解压至 PSModulePath 所包含的路径下；
- 进入 PSModulePath 所包含的路径，执行仓库克隆
- ~~使用 scoop 进行安装~~（暂未实现）

## 可选依赖库

本模块唯一的可选依赖库为[适用于 .Net5 的 Windows SDK 库](https://www.nuget.org/packages/Microsoft.Windows.SDK.NET.Ref)。该库用于为切换至 .Net5 后的 Powershell Core 提供 WinRT API 支持，以实现 `Send-Notification` 命令。具体原因可参考一下两条链接内容：

- <https://github.com/dotnet/runtime/issues/37672>
- <https://github.com/PowerShell/PowerShell/blob/master/CHANGELOG/7.1.md>

不需要在 Powershell Core 使用 `Send-Notification` 命令的用户，可在模块配置目录的创建名为disable-cswinrt的空文件（对应指令为`New-Item $Env:LOCALAPPDATA\DevTools-Win\disable-cswinrt -Force`）。

需要使用此依赖的用户则遵照以下步的依赖安装：

```ps1
# 进入 DevTools.psd1 所在目录
cd "DevTools-Win"
# 设置http(s)代理（推荐网络受限地区用户采用）
. .\src\public\Set-WebProxy.ps1
swp http://<你的代理地址>:<你的代理端口>
# 首次加载模块，触发自动依赖下载和安装
Import-Module "DevTools-Win"
# 查看lib目录，依赖文件已就绪
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

后续如果需要更新依赖库文件，仅需手动删除上述 lib 路径，重新执行以上依赖安装步骤。

## 自定义配置

自定义配置存放于目录`$Env:LOCALAPPDATA\DevTools-Win`下的 config.json 文件（不支持注释）内，用于覆盖默认配置

```json5
{
    "Proxy": "http://192.168.36.1:8080", // 避免每次使用swp时重复输入，可被$Env:HTTP(S)_PROXY覆盖，默认为空
    "VsWhere": "C:\\Program Files (x86)\\Microsoft Visual Studio\\Installer\\vswhere.exe", // 指定vswhere程序路径，可被$Env:VSWHERE_PATH覆盖
    "VcpkgRoot": "C:\\Users\\abc\\source\\repos\\vcpkg", // 指定 vcpkg 根目录，可被$Env:VCPKG_ROOT覆盖，默认为空
    "Clang": "C:\\Users\\abc\\scoop\\shims\\clang.ps1", // 指定clang路径，可被$Env:CLANG_PATH覆盖，默认为空
}
```

## 兼容性

本模块属于自用脚本打包分享。我个人的主要使用环境为 Windows 10 + Powershell Core + Windows Terminal。在正式发布前，已针对 Windows Powershell 5.1 进行了一定程度的兼容性适配，但不保证 100% 兼容。

微软当前对Powershell的开发重心已全方面倾斜至 Powershell Core，原 Windows Powershell 5.1 仅做兼容性保留（实际使用上，我已遇到不少Bug，但长期未修复）。考虑到目前二者间差异和维护状态，个人建议用户迁移至 Powershell Core。

## Dirty Hack

由于 .Net 技术栈本身的限制，`Remove-Module` 无法卸载 Assembly 文件。这会导致烦人的文件占用问题。为了克服这一问题，`Send-Notification` 命令在实现上采用了一点小技巧。通过 `Start-Job` 创建后台任务的副作用（脱离当前会话），使 Assembly 文件的加载限定在新的 AppDomain 内。这样，Assembly 文件会在任务完成后自动完成卸载（随新 AppDomain 一起被卸载）。
