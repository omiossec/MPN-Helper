
$RootDir = "."

$SrcDir = join-path -Path $RootDir -ChildPath "src"

 new-item -name "mpn-helper" -ItemType Directory

 $publishPath =  join-path -Path $RootDir -ChildPath "mpn-helper"

 copy-item -path $SrcDir -Destination  $publishPath -Recurse


try {
    Publish-Module -Path $publishPath -NuGetApiKey $env:PSGALLERY_NUGET_API_KEY
}
catch {
    Write-Error -Message " Exception Type: $($_.Exception.GetType().FullName) $($_.Exception.Message)"
}