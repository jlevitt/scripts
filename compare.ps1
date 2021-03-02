param(
    $resource,
    $version = "1.0"
)

$selects = @{
    "menu/items" = "._embedded.menu_items[]";
    "menu/modifiers" = "._embedded.modifiers[]";
    "menu/modifier_groups" = "._embedded.modifier_groups[]"
    "menu/combos" = "._embedded.menu_combos[]"
}

function getSelect($resource)
{
    $selectEntity = $selects[$resource]
    if ($selectEntity -ne $null)
    {
        return $selectEntity
    }

    $resource = [regex]::Replace($resource, "/[^/]*$", "/{{id}}")
    Write-Host "Resource: $resource"
    $selectEntity = $selects[$resource]
    if ($selectEntity -ne $null)
    {
        return $selectEntity
    }

    "."
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
    $detailsPath = [regex]::Replace($filterPath, "_[^_.]*\.jq", "_details.jq")
    if (Test-Path $filterPath)
    {
        $json `
            | jq -s -f $filterPath `
            |% { $_.Replace("$PY_URL", "{{url}}") } `
            |% { $_.Replace('/"', '"') } `
            |% { $_.Replace("$GO_URL", "{{url}}") } `
    }
    elseif (Test-Path $detailsPath)
    {
        $json `
            | jq -s -f $detailsPath `
            |% { $_.Replace("$PY_URL", "{{url}}") } `
            |% { $_.Replace('/"', '"') } `
            |% { $_.Replace("$GO_URL", "{{url}}") } `
    }
    else
    {
        $json `
            | jq "." `
            |% { $_.Replace("$PY_URL", "{{url}}") } `
            |% { $_.Replace('/"', '"') } `
            |% { $_.Replace("$GO_URL", "{{url}}") } `
    }
}

function run($resource)
{
    $dir = [System.IO.Path]::GetDirectoryName($resource)
    if ($dir)
    {
        mkdir -Force -p $dir | Out-Null
    }

    $aPath = "diffs\$($resource.Replace("/", "_")).a.json"
    $bPath = "diffs\$($resource.Replace("/", "_")).b.json"

    rm $aPath -ErrorAction SilentlyContinue
    rm $bPath -ErrorAction SilentlyContinue

    # fetch $GO_URL "$resource" > $bPath
    # fetch $PY_URL "$resource" > $bPath

    $PY_URL = $PY_URL.Replace("{{version}}", $version)
    $GO_URL = $GO_URL.Replace("{{version}}", $version)

    Sanitize $resource $(fetch $PY_URL "$resource") > $aPath
    Sanitize $resource $(fetch $GO_URL  "$resource") > $bPath
    kdiff3 $aPath $bPath
}

. .\env.ps1
run $resource
