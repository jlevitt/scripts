param(
    $resource,
    $Version = "1.0",
	[switch]$Force = $false,
    [int]$MaxPages = 1000
)

$selects = @{
    "menu/items" = "._embedded.menu_items[]";
    "menu/modifiers" = "._embedded.modifiers[]";
    "menu/modifier_groups" = "._embedded.modifier_groups[]"
    "menu/combos" = "._embedded.menu_combos[]"
    "tickets" = "._embedded.tickets[]"
}

function getSelect($resource)
{
    $selectEntity = $selects[$resource]
    if ($selectEntity -ne $null)
    {
        return $selectEntity
    }

    $resource = [regex]::Replace($resource, "/[^/]*$", "/{{id}}")
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
    $pages = 0

    while ($nextUrl -ne "null" -and $pages -lt $MaxPages)
    {
		Write-Host -NoNewline "Fetching $nextUrl..."
        $response = [string]::new($(curl $nextUrl -Headers @{"Api-Key" = $API_KEY}).Content)
		Write-Host " done."
        $nextUrl = $response | jq -r "._links.next.href"
        $result += $($response `
            | jq $selectEntity `
            | Join-String -NewLine)
        $pages++
    }

    $result
}

function Sanitize($resource, $json, $side)
{
	$parentResource = $resource -replace "/[^/]*$"

    $sharedFilterListPath = "$($resource.Replace("/", "_")).jq"
    $sharedFilterDetailsPath = "$($parentResource.Replace("/", "_")).jq"

	$sharedFilterPath = if (Test-Path $sharedFilterListPath) { $sharedFilterListPath } else { $sharedFilterDetailsPath }

	Write-Host "Processing side $side..."

    if (Test-Path $sharedFilterPath)
    {
		Write-Host "Using filter '$sharedFilterPath'."
        $json = $json | jq --sort-keys -s -f $sharedFilterPath
    }
    else
    {
		Write-Host "No filter found."
        $json = $json | jq --sort-keys "."
    }

    $sideFilterListPath = "$($resource.Replace("/", "_"))_$side.jq"
    $sideFilterDetailsPath = "$($parentResource.Replace("/", "_"))_$side.jq"
	$sideFilterPath = if (Test-Path $sideFilterListPath) { $sideFilterListPath } else { $sideFilterDetailsPath }
    if (Test-Path $sideFilterPath)
    {
		Write-Host "Using filter '$sideFilterPath'."
        $json = $json | jq --sort-keys -s -f $sideFilterPath
    }

    SanitizeUrl($json)

	Write-Host
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

    $aPathRaw = "diffs\$($resource.Replace("/", "_")).a.raw.json"
    $bPathRaw = "diffs\$($resource.Replace("/", "_")).b.raw.json"
    $aPathProcessed = "diffs\$($resource.Replace("/", "_")).a.json"
    $bPathProcessed = "diffs\$($resource.Replace("/", "_")).b.json"


	if ($Force)
	{
		rm $aPathRaw -ErrorAction SilentlyContinue
		rm $bPathRaw -ErrorAction SilentlyContinue
	}

    $PY_URL = $PY_URL.Replace("{{version}}", $Version)
    $GO_URL = $GO_URL.Replace("{{version}}", $Version)

	if (-not (Test-Path $aPathRaw))
	{
		fetch $PY_URL "$resource" > $aPathRaw
	}

	if (-not (Test-Path $bPathRaw))
	{
		fetch $GO_URL "$resource" > $bPathRaw
	}

	Sanitize $resource "$(gc $aPathRaw)" "a" > $aPathProcessed
    Sanitize $resource "$(gc $bPathRaw)" "b" > $bPathProcessed

    kdiff3 $aPathProcessed $bPathProcessed
}

. .\env.ps1
run $resource
