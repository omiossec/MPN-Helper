$RootDir = "."

$TestsDir = join-path -Path $RootDir -ChildPath "tests"

Install-Module Pester -Force | Out-Null
Import-Module Pester

Push-Location $TestsDir

$PesterResult = invoke-pester -PassThru 

if ($PesterResult.FailedCount) {
    write-output "Fail"
    throw "Unit testing not passing"
} else {
    Write-Output "Success"
}