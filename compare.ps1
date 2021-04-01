param(
    $resource,
    $version = "1.0",
	[switch]$force = $false
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

function Sanitize($resource, $json, $side)
{
    $sharedFilterPath = "$($resource.Replace("/", "_")).jq"
    $sharedDetailsPath = [regex]::Replace($sharedFilterPath, "_[^_.]*\.jq", "_details.jq")
    if (Test-Path $sharedFilterPath)
    {
        $json = $json | jq -s -f $sharedFilterPath
    }
    elseif (Test-Path $sharedDetailsPath)
    {
        $json = $json | jq -f $sharedDetailsPath
    }
    else
    {
        $json = $json | jq "."
    }

    $sideFilterPath = "$($resource.Replace("/", "_"))_$side.jq"
    $sideDetailsPath = [regex]::Replace($sideFilterPath, "_[^_.]*\.jq", "_details_$side.jq")
    if (Test-Path $sideFilterPath)
    {
        $json = $json | jq -f $sideFilterPath
    }
    elseif (Test-Path $sideDetailsPath)
    {
        $json = $json | jq -f $sideDetailsPath
    }

    SanitizeUrl($json)
}

function SanitizeUrl($json)
{
    $json `
        |% { $_.Replace("$PY_URL", "{{url}}") } `
        |% { $_.Replace('/"', '"') } `
        |% { $_.Replace("$GO_URL", "{{url}}") } `
        |% { $_.Replace("N-", "") } `
        |% { $_.Replace("/?", "?") } `
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


	if ($force)
	{
		rm $aPath -ErrorAction SilentlyContinue
	}
    rm $bPath -ErrorAction SilentlyContinue

    # fetch $GO_URL "$resource" > $bPath
    # fetch $PY_URL "$resource" > $bPath

    $PY_URL = $PY_URL.Replace("{{version}}", $version)
    $GO_URL = $GO_URL.Replace("{{version}}", $version)

	if (Test-Path $aPath)
	{
		Write-Host "Skipping Brink download..."
	}
	else
	{
		Sanitize $resource $(fetch $PY_URL "$resource") "a" > $aPath
	}
    Sanitize $resource $(fetch $GO_URL  "$resource") "b" > $bPath
    kdiff3 $aPath $bPath
}

. .\env.ps1
run $resource
