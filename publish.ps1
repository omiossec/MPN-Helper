
$RootDir = "."

$SrcDir = join-path -Path $RootDir -ChildPath "src"


try {
    Publish-Module -Path $SrcDir -NuGetApiKey $env:PSGALLERY_NUGET_API_KEY
}
catch {
    Write-Error -Message " Exception Type: $($_.Exception.GetType().FullName) $($_.Exception.Message)"
}