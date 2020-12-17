param(
    $resource
)

function goapi($resource, $fields)
{
    if ($fields)
    {
        $fields = "?fields=$fields"
    }

    [string]::new($(curl "$GO_URL/1.0/locations/brink/$resource$fields" -Headers @{"Api-Key" = $API_KEY}).Content) `
        | jq . `
        |% { $_.Replace("$GO_URL/1.0/locations/brink", "{{url}}") }
}

function pyapi($resource, $fields="")
{
    if ($fields)
    {
        $fields = "?fields=$fields"
    }

    [string]::new($(curl "$PY_URL/1.0/locations/BGTzMTMk/$resource$fields" -Headers @{"Api-Key" = $API_KEY}).Content) `
        | jq . `
        |% { $_.Replace("$PY_URL/1.0/locations/BGTzMTMk", "{{url}}") } `
        |% { $_.Replace("/?", "?") } `
        |% { $_.Replace('/"', '"') }
}

function Filter-MenuItems($json)
{
    $json | jq "._embedded.menu_items | sort_by(.id) | .[] | del(._embedded.option_sets) | del(._embedded.price_levels[].barcodes) | del(.barcodes)"
}

function Filter-MenuModifiers($json)
{
    $json | jq "._embedded.modifiers | sort_by(.id) | .[] | del(._embedded.option_sets) | del(._embedded.price_levels[].barcodes) | del(.barcodes)"
}

function Filter-MenuModifierGroups($json)
{
    $json | jq -f modifier-groups.jq
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

    if ($resource -eq "menu/modifiers")
    {
        Filter-MenuModifiers $(pyapi "/$resource") > $aPath
        Filter-MenuModifiers $(goapi "/$resource") > $bPath
    }
    elseif ($resource -eq "menu/items")
    {
        Filter-MenuItems $(pyapi "/$resource") > $aPath
        Filter-MenuItems $(goapi "/$resource") > $bPath
    }
    elseif ($resource -eq "menu/modifier_groups")
    {
        Filter-MenuModifierGroups $(pyapi "/$resource") > $aPath
        Filter-MenuModifierGroups $(goapi "/$resource") > $bPath
    }
    else
    {
        $(pyapi "/$resource") > $aPath
        $(goapi "/$resource") > $bPath
    }
    kdiff3 $aPath $bPath
}

. .\env.ps1
run $resource
