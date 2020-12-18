param(
    $resource
)

$selects = @{
    "menu/items" = "._embedded.menu_items[]";
    "menu/modifiers" = "._embedded.modifiers[]";
    "menu/modifier_groups" = "._embedded.modifier_groups[]"
}

function fetch($baseUrl, $resource)
{
    $result = @()
    $nextUrl = "$baseUrl/$resource"

    $selectEntity = $selects[$resource]

    while ($nextUrl -ne "null")
    {
        Write-Host "Fetching $nextUrl"
        $response = [string]::new($(curl $nextUrl -Headers @{"Api-Key" = $API_KEY}).Content)
        $nextUrl = $response | jq -r "._links.next.href"
        $result += $($response `
            | jq $selectEntity `
            | Join-String -NewLine)
    }

    $result
}

function Sanitize($resource, $json)
{
    $filterPath = "$($resource.Replace("/", "_")).jq"
    $json `
        | jq -f $filterPath `
        |% { $_.Replace("$PY_URL", "{{url}}") } `
        |% { $_.Replace('/"', '"') } `
        |% { $_.Replace("$GO_URL", "{{url}}") } `
}

function run($resource)
{
    mysql -h 127.0.0.1 -u root -P 3310 --password=$MYSQL_PASSWORD -e "update agent_master.store_scheduled_tasks set next_run=now(), start_time=null where store_id=5 and name = 'menu';"

    $dir = [System.IO.Path]::GetDirectoryName($resource)
    if ($dir)
    {
        mkdir -Force -p $dir | Out-Null
    }

    mkdir -p diffs -force | Out-Null
    rm -r diffs\*

    $aPath = "diffs\$($resource.Replace("/", "_")).a.json"
    $bPath = "diffs\$($resource.Replace("/", "_")).b.json"

    #fetch $GO_URL "$resource" > $bPath
    #fetch $PY_URL "$resource" > $bPath

    Sanitize $resource $(fetch $PY_URL "$resource") > $aPath
    Sanitize $resource $(fetch $GO_URL  "$resource") > $bPath
    kdiff3 $aPath $bPath
}

. .\env.ps1
run $resource
