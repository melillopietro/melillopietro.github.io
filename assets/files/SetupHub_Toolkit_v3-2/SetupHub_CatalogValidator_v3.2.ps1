<#
.SYNOPSIS
    SetupHub Catalog Validator v3.2
.DESCRIPTION
    Validates the WinGet package IDs contained in SetupHub_Setup_v3.2.ps1 before running installations.
    It executes winget show --id <PackageId> --exact --source winget for each software entry and creates CSV/JSON/HTML reports.
.NOTES
    Run from the same folder as SetupHub_Setup_v3.2.ps1.
#>

$ErrorActionPreference = 'Stop'
$ScriptFile = Join-Path $PSScriptRoot 'SetupHub_Setup_v3.2.ps1'
$ReportFolder = Join-Path $PSScriptRoot 'reports'
New-Item -Path $ReportFolder -ItemType Directory -Force | Out-Null

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host 'WinGet is not available on this system.' -ForegroundColor Red
    exit 1
}
if (-not (Test-Path $ScriptFile)) {
    Write-Host "Script not found: $ScriptFile" -ForegroundColor Red
    exit 1
}

function Get-SetupHubCatalog {
    param([string]$Path)
    $content = Get-Content -Path $Path -Raw
    $start = $content.IndexOf('$installPackages = @(')
    $end = $content.IndexOf('$bloatwarePackages = @(', $start)
    if ($start -lt 0 -or $end -lt 0) { throw 'Unable to locate install package catalog.' }
    $block = $content.Substring($start, $end - $start)

    $items = New-Object System.Collections.Generic.List[object]
    $pattern = "@\{\s*Name\s*=\s*'(?<name>[^']+)'\s*;\s*Id\s*=\s*'(?<id>[^']+)'(?<rest>.*?)\}"
    foreach ($m in [regex]::Matches($block, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)) {
        $name = $m.Groups['name'].Value
        $id = $m.Groups['id'].Value
        $rest = $m.Groups['rest'].Value
        $category = ''
        $catMatch = [regex]::Match($rest, "Category\s*=\s*'(?<cat>[^']+)'")
        if ($catMatch.Success) { $category = $catMatch.Groups['cat'].Value }
        $alts = @()
        $altMatch = [regex]::Match($rest, "AlternateIds\s*=\s*@\((?<alts>.*?)\)", [System.Text.RegularExpressions.RegexOptions]::Singleline)
        if ($altMatch.Success) {
            $alts = [regex]::Matches($altMatch.Groups['alts'].Value, "'([^']+)'") | ForEach-Object { $_.Groups[1].Value }
        }
        $notes = ''
        $notesMatch = [regex]::Match($rest, "Notes\s*=\s*'(?<notes>[^']*)'")
        if ($notesMatch.Success) { $notes = $notesMatch.Groups['notes'].Value }
        $items.Add([pscustomobject]@{ Name=$name; Id=$id; AlternateIds=$alts; Category=$category; Notes=$notes }) | Out-Null
    }
    return $items
}

function Invoke-WinGetShow {
    param([string]$Id)
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = 'winget'
    $psi.Arguments = "show --id `"$Id`" --exact --source winget --accept-source-agreements --disable-interactivity"
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $p = [System.Diagnostics.Process]::Start($psi)
    $stdout = $p.StandardOutput.ReadToEnd()
    $stderr = $p.StandardError.ReadToEnd()
    $p.WaitForExit()
    $combined = (($stderr + "`n" + $stdout) -split "`r?`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ })
    $message = if ($combined) { ($combined | Select-Object -First 10) -join ' | ' } else { "ExitCode=$($p.ExitCode) without textual output" }
    return [pscustomobject]@{ ExitCode=$p.ExitCode; StdOut=$stdout; StdErr=$stderr; Message=$message }
}

$catalog = Get-SetupHubCatalog -Path $ScriptFile
$results = New-Object System.Collections.Generic.List[object]
$total = $catalog.Count
$i = 0
foreach ($pkg in $catalog) {
    $i++
    Write-Progress -Activity 'Validating SetupHub WinGet catalog' -Status "$i/$total - $($pkg.Name)" -PercentComplete (($i/$total)*100)
    $idsToTry = New-Object System.Collections.Generic.List[string]
    [void]$idsToTry.Add($pkg.Id)
    foreach ($alt in @($pkg.AlternateIds)) { if ($alt -and -not $idsToTry.Contains($alt)) { [void]$idsToTry.Add($alt) } }

    $resolvedId = ''
    $last = $null
    foreach ($candidate in $idsToTry) {
        $last = Invoke-WinGetShow -Id $candidate
        if ($last.ExitCode -eq 0) { $resolvedId = $candidate; break }
    }
    $status = if ($resolvedId) { 'Available' } else { 'NotAvailable' }
    $results.Add([pscustomobject]@{
        CheckedAt = (Get-Date).ToString('s')
        Name = $pkg.Name
        Category = $pkg.Category
        PrimaryId = $pkg.Id
        ResolvedId = $resolvedId
        AlternateIds = (@($pkg.AlternateIds) -join ', ')
        Status = $status
        ExitCode = if ($last) { $last.ExitCode } else { '' }
        Message = if ($last) { $last.Message } else { '' }
        Notes = $pkg.Notes
    }) | Out-Null
}
Write-Progress -Activity 'Validating SetupHub WinGet catalog' -Completed

$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$csv = Join-Path $ReportFolder "SetupHub_catalog_validation_$stamp.csv"
$json = Join-Path $ReportFolder "SetupHub_catalog_validation_$stamp.json"
$html = Join-Path $ReportFolder "SetupHub_catalog_validation_$stamp.html"
$results | Export-Csv -Path $csv -NoTypeInformation -Encoding UTF8
$results | ConvertTo-Json -Depth 5 | Set-Content -Path $json -Encoding UTF8
$available = @($results | Where-Object Status -eq 'Available').Count
$missing = @($results | Where-Object Status -ne 'Available').Count
$body = $results | Sort-Object Status,Category,Name | ConvertTo-Html -Fragment
@"
<html>
<head>
<meta charset='utf-8'>
<title>SetupHub Catalog Validation</title>
<style>
body{font-family:Segoe UI,Arial,sans-serif;background:#111827;color:#e5e7eb;padding:24px}table{border-collapse:collapse;width:100%;font-size:12px}th,td{border:1px solid #374151;padding:6px;vertical-align:top}th{background:#1f2937}.Available{color:#10b981}.NotAvailable{color:#f87171}
</style>
</head>
<body>
<h1>SetupHub Catalog Validation</h1>
<p>Checked at: $(Get-Date)</p>
<p>Total: $total | Available: $available | Not available: $missing</p>
$body
</body>
</html>
"@ | Set-Content -Path $html -Encoding UTF8

Write-Host "Validation completed." -ForegroundColor Green
Write-Host "Available: $available / $total" -ForegroundColor Green
Write-Host "Not available: $missing" -ForegroundColor Yellow
Write-Host "CSV : $csv"
Write-Host "JSON: $json"
Write-Host "HTML: $html"
