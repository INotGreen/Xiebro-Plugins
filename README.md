# 目录

- [1.扩展外部窗体](#1扩展外部窗体)
- [2.扩展Session 命令](#2扩展session-命令)
- [3.扩展功能菜单栏](#3扩展功能菜单栏)
- [4.菜单栏整理](#4菜单栏整理)
- [5.使用内置API扩展窗体](#5使用内置api扩展窗体)



在编写插件时，请仔细参考函数原型：[XiebroC2-PluginsFunctions](https://github.com/INotGreen/Xiebro-Plugins/blob/main/Function.md)



## 1.扩展外部窗体

xiebroC2提供了简单的插件接口，它可以降低插件编写的门槛，并且实现CobaltStrike那样的插件体系

例如要在控制端的顶部菜单栏添加一个shellcode分离加载器：

<video src="https://private-user-images.githubusercontent.com/89376703/311126700-913d66d5-fe82-459a-8b3d-ea73682a9bb7.mp4?" width="640" height="480" controls></video>



- 将Winform .Net程序转成XiebroC2的lua插件

```powershell
 Import-Module .\Convert-NetToLua.ps1
 Convert-NetToLua -infile .\Plugins.exe -Output a.lua -Name loader
```

在编写winform的时候需要注意的是，你要将入口点修改成下面这样，如果是Application.EnableVisualStyles启动，在被转成lua插件时，主控端加载会报错

```C#
internal static class Program
{
    /// <summary>
    /// 应用程序的主入口点。
    /// </summary>
    [STAThread]
    static void Main()
    {
         Form1 form1 = new Form1();
         form1.ShowDialog();
    }
}
```



## 2.扩展Session 命令

<img src="Image\\image-20240308134300864.png"  />



在命令列表中添加外部命令

```lua
AddCommand(
    "SharpKatz", --Name
    "Plugins\\SharpKatz.exe", -- FilePath
    "execute-assembly", --load type
    "Steal domain login credentials",  --Descripttion
    "SharpKatz -h" --Usage
)
```

- AddCommand第三个参数有三种加载方式，如果是.net 程序集则选择“execute-assembly”、“Inline-assembly” ，如果是C/C++/Golang/rust/nim编写的PE文件则选择RunPE
- SharpKatz命令添加成功

<img src="Image\\image-20240308144452120.png"  />



## 3.扩展功能菜单栏



```lua
AddMenuItemA("Pentest", null)
AddMenuItemB("GetIPInfo", "", function() Nopowershell("ipconfig", "1") end)
```

- AddMenuItemB比AddMenuItemA多一个点击事件的参数(类似回调函数)，lua中似乎无法支持重载，因此我用函数的A和B进行区分。


- Nopowershell可以在内存中执行非托管的powershell而无需启动Powershell.exe进程，实际上你可以参考[nopowershell](https://github.com/INotGreen/Nopowershell)的代码例子。


- 值得注意的是Nopowershell执行是否要创建子进程取决于Profile.json中的参数配置，如果Fork为flase则为无进程执行powershell


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



## 4.菜单栏整理

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

通过这样的方式您可以整理菜单栏的父子关系

<img src="Image\image-20240308150949896.png" />



## 5.使用内置API扩展窗体

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

