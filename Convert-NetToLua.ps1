
function Convert-NetToLua {
    param (
        $infile,
        $Output,
        $Name

    )
    $base64stub = [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes($infile))

    $stub = @'
local function load()
    local data = [[ReplaceBase64]]
    Assemblyloadbase64(data)
end
MenuStripExpand("RPName", null, load)
'@.Replace("ReplaceBase64", $base64stub).Replace("RPName", $Name)

    [System.IO.File]::WriteAllText($Output, $stub)
}
