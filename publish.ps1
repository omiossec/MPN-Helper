
$RootDir = "."

$SrcDir = join-path -Path $RootDir -ChildPath "src"
$ModulePath = join-path -Path $SrcDir -ChildPath "SrcDir"

try {
    Publish-Module -Path $ModulePath -NuGetApiKey $env:PSGALLERY_NUGET_API_KEY
}
catch {
    Write-Error -Message " Exception Type: $($_.Exception.GetType().FullName) $($_.Exception.Message)"
}