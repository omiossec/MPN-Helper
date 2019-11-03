param (
    $BuildModulePath=$Env:BUILD_SOURCESDIRECTORY,
    $ModuleName = $ENV:ModuleName,
    $ModuleVersion = $ENV:ModuleVersion
)

$ModuleManifestPath = "$($BuildModulePath)\src\$($ModuleName).psd1" 

Get-Module -Name $ModuleName | remove-module

Install-Module Az -Force -AllowClobber
import-module -name AZ 


$ModuleInformation = Import-module -Name $ModuleManifestPath -PassThru

Describe "$ModuleName Testing"{

    Context "$ModuleName Module manifest" {
        It "Should contains RootModule" {
            $ModuleInformation.RootModule | Should not BeNullOrEmpty
        }

        It "Should contains Author" {
            $ModuleInformation.Author | Should -Not -BeNullOrEmpty
        }

        It "Should contains Company Name" {
             $ModuleInformation.CompanyName|Should -Not -BeNullOrEmpty
            }

        It "Should contains Description" {
            $ModuleInformation.Description | Should -Not -BeNullOrEmpty
        }

        It "Should contains Copyright information" {
            $ModuleInformation.Copyright | Should -Not -BeNullOrEmpty
        }

        It "Should have a project URI" {
            $ModuleInformation.ProjectUri | Should -Not -BeNullOrEmpty
        }

        It "Should have a License URI" {
            $ModuleInformation.LicenseUri | Should -Not -BeNullOrEmpty
        }

        It "Should have at least one tag" {
            $ModuleInformation.tags.count | Should -BeGreaterThan 0
        }
    }

    InModuleScope $ModuleName {
        Context "$($ModuleName) Cmdlet testing" {

        }

    }


}