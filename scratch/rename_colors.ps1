$files = Get-ChildItem -Path lib -Filter *.dart -Recurse
foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $newContent = $content -replace 'AppTheme\.emerald', 'AppTheme.primaryCyan'
    $newContent = $newContent -replace 'AppTheme\.indigo', 'AppTheme.secondaryBlue'
    if ($content -ne $newContent) {
        [IO.File]::WriteAllText($file.FullName, $newContent)
        Write-Host "Updated $($file.FullName)"
    }
}
