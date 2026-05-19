git ls-files | ForEach-Object {
    $commitDate = git log -1 --format="%ai" -- $_
    if ($commitDate) {
        (Get-Item $_).LastWriteTime = [DateTime]::Parse($commitDate)
    }
}