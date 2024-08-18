function Convert-ExeToBase64Lua {
    param (
        [Parameter(Mandatory = $true)]
        [string]$PePath, # .NET 可执行文件的路径
        
        [Parameter(Mandatory = $true)]
        [string]$Output, # 输出的 Base64 文本文件路径

        [string]$Command = "fscan", # Lua 中的命令名称，默认为 "fscan"
        [string]$LoadModule = "RunBin", # 模块名称，默认为 "RunBin"
        [string]$Description = "Process Migration", # 命令描述
        [string]$Usage = "fscan <args>"  # 命令的使用语法
    )

    # 检查输入文件路径是否有效
    if (-not (Test-Path -Path $PePath)) {
        Write-Host "Error: The input file path '$PePath' does not exist."
        return
    }

    # 读取 .exe 文件内容
    try {
        $fileBytes = [System.IO.File]::ReadAllBytes($PePath)
    }
    catch {
        Write-Host "Error: Failed to read the input file. $_"
        return
    }

    # 压缩文件内容使用 GZIP
    try {
        $memoryStream = New-Object System.IO.MemoryStream
        $gzipStream = New-Object System.IO.Compression.GZipStream($memoryStream, [System.IO.Compression.CompressionMode]::Compress)
        $gzipStream.Write($fileBytes, 0, $fileBytes.Length)
        $gzipStream.Close()
    }
    catch {
        Write-Host "Error: Failed to compress the file. $_"
        return
    }

    # 将压缩后的字节数组转换为 Base64 字符串
    $base64String = [Convert]::ToBase64String($memoryStream.ToArray())

    # 构建 Lua 脚本内容
    $context = @"
$Command = [[$base64String]]
AddCommand_W(
    `"$Command`",
    $Command,
    `"$LoadModule`",
    `"$Description`",
    `"$Usage`"
);
"@

    try {
        Set-Content -Path $Output -Value $context
        Write-Host "The file was successfully compressed and converted to Base64 and saved in $OutputFilePath"
    }
    catch {
        Write-Host "An error occurred while writing the output file: $_"
    }
}

# 示例调用函数
#Convert-ExeToBase64Lua -PePath "a.bin" -Output "fscan.lua"
