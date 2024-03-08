
function Convert-NetToLua {
    param (
        $infile,

        $Output
     

    )
    $base64stub = [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes($infile))

    $stub = @'
local function load()
    local data = [[ReplaceBase64]]
    Assemblyloadbase64(data)
end
MenuStripExpand("loader", null, load)
'@.Replace("ReplaceBase64", $base64stub)

    [System.IO.File]::WriteAllText($Output, $stub)
}
