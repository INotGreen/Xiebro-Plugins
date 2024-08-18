# Table of Contents

- [1. 扩展外部表单](#1 扩展外部表单)

- [2. 扩展会话命令](#2 扩展会话命令)

- [3. 扩展功能菜单栏](#3 扩展功能菜单栏)

- [4. 菜单栏布局](#4 菜单栏布局)

- [5. 使用内置 API 扩展表单](#5 使用内置 API 扩展表单)

When writing plug-ins, please refer to the function prototype carefully: [XiebroC2-PluginsFunctions](https://github.com/INotGreen/Xiebro-Plugins/blob/main/Function.md)

## 1. Extend external form

xiebroC2提供了简单的插件接口，可以降低插件编写门槛，实现类似CobaltStrike的插件系统

例如在控制端顶部菜单栏添加shellcode分离加载器：

<video src="https://private-user-images.githubusercontent.com/89376703/311126700-913d66d5-fe82-459a-8b3d-ea73682a9bb7.mp4?" width="640" height="480" controls></video>

- 将Winform .Net程序转换为XiebroC2的lua插件

```powershell
Import-Module .\Convert-NetToLua.ps1
Convert-NetToLua -infile .\Plugins.exe -Output a.lua -Name loader
```

在写winform的时候需要把入口点改成下面这样，如果是通过Application.EnableVisualStyles启动的话，当转换成lua插件的时候，主控端加载的时候会报错

```C#
internal static class Program
{
/// <summary>
/// The main entry point of the application.
/// </summary>
[STAThread]
static void Main()
{
Form1 form1 = new Form1();
form1.ShowDialog();
}
}
```

## 2. Extend Session command

<img src="Image\\image-20240308134300864.png" />

Add external command in command list

```lua
AddCommand(
"SharpKatz", --Name
"Plugins\\SharpKatz.exe", -- FilePath
"execute-assembly", --load type
"Steal domain login credentials", --Descripttion
"SharpKatz -h" --Usage
)
```

- AddCommand 第三个参数有三种加载方式，如果是.net程序集，选择“execute-assembly”和“Inline-assembly”，如果是C/C++/Golang/rust/nim编写的PE文件，选择RunPE
- SharpKatz命令添加成功

<img src="Image\\image-20240308144452120.png" />

## 3. Extended function menu bar

```lua
AddMenuItemA("Pentest", null)
AddMenuItemB("GetIPInfo", "", function() Nopowershell("ipconfig", "1") end)
```

- AddMenuItemB比AddMenuItemA多了一个点击事件的参数（类似回调函数），lua好像不支持重载，所以我用函数A和B来区分。

- Nopowershell可以在内存中执行非托管的powershell，不需要启动Powershell.exe进程，其实可以参考[nopowershell](https://github.com/INotGreen/Nopowershell)的代码示例。

- 值得注意的是Nopowershell执行是否创建子进程取决于Profile.json中的参数配置，如果Fork为false，则powershell无进程执行。

```json
{
"TeamServerIP": "192.168.1.250",
"TeamServerPort": "8880",
"Password": "123456",
"StagerPort": "4050",
"Telegram_Token": "",
"Telegram_chat_ID": "",
"Fork": false,
"Route": "www",
"Process64": "C:\\windows\\system32\\notepad.exe",
"Process86": "C:\\Windows\\SysWOW64\\notepad.exe",
"WebServers": [],
"listeners": [],
"rdiShellcode32": "",
"rdiShellcode64": "",
}
```

## 4. Menu bar arrangement

```lua
AddMenuItemA("Pentest", null)
AddMenuItemA("CollectInfo", null) --
AddMenuItemA("Grab browser Passwords", null)
AddMenuItemA("Persistence", null)
AddMenuItemA("Scheduled Tasks", null)
AddMenuItemB("Installation", "", SchTaskForm)
AddMenuItemB("Privilege", null, function() Sessionlog("Message") end)

AddMenuItemB("4.0", "", function() Nopowershell("ipconfig", "1") end)

local menuStructure = {
["Pentest"] = {"CollectInfo", "Persistence", "Privilege"},
["CollectInfo"] = {"Grab browser Passwords"},
["Persistence"] = {"Scheduled Tasks"},
["Scheduled Tasks"] = {"Installation"},
["Privilege"] = {"4.0"}
}
for parent, subs in pairs(menuStructure) do AddMenuItemsAsSubItems(parent, subs) end
```

In this way, you can organize the parent-child relationship of the menu bar

<img src="Image\image-20240308150949896.png" />

## 5. Extend the form using the built-in API

```lua
local function SchTaskForm()
local IsOK = false
local Form1 = CreateForm("sch", 422, 355)

local Label1 = Addlabel(Form1, "Interval(min):", 17, 33, 133, 25)
local Label2 = Addlabel(Form1, "Select File:", 31, 103, 114, 25)
local Label3 = Addlabel(Form1, "Directory:", 28, 174, 114, 25)

local addButton = AddSelectFileButton(Form1, "Select", 162, 100, 181, 33)
local texBox1 = AddTextBox(Form1, 162, 31, 181, 33)
local ComBox1 = AddComBox(Form1, 162, 174, 181, 33)
local Button1 = AddButton(Form1, "Ok", 36, 234, 106, 37, function()
if texBox1.Text ~= "" and ComBox1.Text ~= "" and addButton.Text ~=
"Select" then -- The values of texBox1 and ComBox1 can't be empty strings, otherwise this window
IsOK = true
Form1:Hide()

else
IsOK = false
MessageBoxA("adas")
end
end)

local Button2 = AddButton(Form1, "close", 236, 234, 107, 37,
function() Form1:Close() end)
Form1:ShowDialog()
if IsOK then
local FileName = GetFileName(addButton.Text)
local UploadFilePath = ComBox1.Text .. "\\" .. FileName
Upload(UploadFilePath, addButton.Text)
InlineAssembly("Plugins\\Scheduled.exe", texBox1.Text)
end
end

AddMenuItemB("Task installer", "", SchTaskForm)
```
