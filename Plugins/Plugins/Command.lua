whoami = [[
function Get-UserInfo {
    try {
        # Get the current user object
        $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()

        # Get the username
        $username = $currentUser.Name

        # Get the user SID
        $userSid = $currentUser.User.Value

        # Get the domain name
        $domainName = $env:USERDOMAIN

        # Display the user information
        Write-Output "用户信息"
        Write-Output "----------------"
        Write-Output ""
        Write-Output ("用户名                 SID")
        Write-Output ("====================== ==============================================")
        Write-Output ("{0} {1}" -f $username, $userSid)
        Write-Output ""
    } catch {
        Write-Error "An error occurred while retrieving user information: $_"
    }
}

function Get-GroupInfo {
    try {
        # Get the current user object
        $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()

        # Get the groups
        $groups = $currentUser.Groups | ForEach-Object {
            $group = $_.Translate([System.Security.Principal.NTAccount])
            $sid = $_.Value
            [PSCustomObject]@{
                Name = $group.Value
                Type = "已知组"
                SID = $sid
                Attributes = "必需的组, 启用于默认, 启用 的组"
            }
        }

        # Display the group information
        Write-Output "组信息"
        Write-Output "-----------------"
        Write-Output ""
        Write-Output ("组名                                   类型   SID                                            属性")
        Write-Output ("====================================== ====== ============================================== ==============================")
        $groups | ForEach-Object {
            Write-Output ("{0} {1} {2} {3}" -f $_.Name.PadRight(38), $_.Type.PadRight(6), $_.SID.PadRight(45), $_.Attributes)
        }
        Write-Output ""
    } catch {
        Write-Error "An error occurred while retrieving group information: $_"
    }
}

function Get-PrivilegeInfo {
    try {
        # Get the current user object
        $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()

        # Get the privileges
        $privileges = $currentUser.Claims | Where-Object { $_.ClaimType -eq "http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsuserclaim" } | ForEach-Object {
            $privilege = $_.Value
            [PSCustomObject]@{
                Name = $privilege
                Description = "未提供"
                State = "已禁用"
            }
        }

        # Display the privilege information
        Write-Output "特权信息"
        Write-Output "----------------------"
        Write-Output ""
        Write-Output ("特权名                        描述                 状态")
        Write-Output ("============================= ==================== ======")
        $privileges | ForEach-Object {
            Write-Output ("{0} {1} {2}" -f $_.Name.PadRight(29), $_.Description.PadRight(20), $_.State)
        }
        Write-Output ""
    } catch {
        Write-Error "An error occurred while retrieving privilege information: $_"
    }
}

# Execute the functions
Get-UserInfo
]]

AddCommand_N
(
    "whoami",
    whoami,
    "nopowershell",
    "levate service privileges to System",
    "whoami"
)
