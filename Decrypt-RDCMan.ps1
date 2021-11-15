param(
    $file
)


function DecryptPassword($pwdString)
{
    # Adapted from https://superuser.com/a/1163345
    Import-Module 'C:\tmp\RDCMan.dll'
    $EncryptionSettings = New-Object -TypeName RdcMan.EncryptionSettings
    [RdcMan.Encryption]::DecryptString($pwdString, $EncryptionSettings)
}

function FormatCreds($node)
{
    $username = $node.logonCredentials.userName
    $password = DecryptPassword $node.logonCredentials.password

    if ([string]::IsNullOrWhiteSpace($username) -and [string]::IsNullOrWhiteSpace($password))
    {
        return ""
    }

    if ([string]::IsNullOrWhiteSpace($username))
    {
        $username = "<NONE>"
    }

    if ([string]::IsNullOrWhiteSpace($password))
    {
        $password = "<NONE>"
    }

    return "($username/$password)"
}

function WalkGroup($node, $indent)
{
    foreach ($group in $node.group)
    {
        $indentSpaces = " " * ($indent * 4)
        Write-Host "$($indentSpaces)Group: $($group.properties.name) $(FormatCreds $group)"
        $indentSpaces += "    "
        foreach ($server in $group.server)
        {
            $displayName = $server.properties.displayName
            $name = $server.properties.name
            $username = $server.logonCredentials.userName
            $password = DecryptPassword $server.logonCredentials.password
            Write-Host "$($indentSpaces)Server: $displayName/$name $(FormatCreds $server)"
        }
        WalkGroup $group ($indent + 1)
    }
}

[xml]$xml = gc $file
WalkGroup $xml.RDCMan.file 0


