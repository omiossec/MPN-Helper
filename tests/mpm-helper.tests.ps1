param (
    $BuildModulePath=$Env:BUILD_SOURCESDIRECTORY,
    $ModuleName = "mpn-helper"
)

$ModuleManifestPath = "./src/mpn-helper.psd1"


Get-Module -Name $ModuleName | remove-module




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

            Mock get-MPNHelperLocalID -MockWith { "44444" }

           function get-AzContext () {
                [pscustomobject]@{
                    "Name"          = "Microsoft Azure Sponsorship"
                    "Account"       = "olivier@pester.test"
                    "Environment"   = "AzureCloud"
                    "Subscription"  = "xxxxx-xxxxx-xxxxx-xxxx"
                    "Tenant"        = "xxxxx-xxxxx-xxxxx-xxxx"
                }
            }

            Mock Get-InstalledModule -MockWith {
                [pscustomobject]@{
                    "Name"        = "Az"
                    "Version"     = "2.8.0"
                    "Repository"  = "PSGallery"
                    "Description" = "Microsoft Azure PowerShell"
                }
            } -ParameterFilter { $Name -eq "Az" }

            Mock Get-InstalledModule -MockWith {
                [pscustomobject]@{
                    "Name"        = "Az.ManagementPartner"
                    "Version"     = "0.7.1"
                    "Repository"  = "PSGallery"
                    "Description" = "Microsoft Azure PowerShell"
                }
            } -ParameterFilter { $Name -eq "Az.ManagementPartner" }

            It "test-MPNHelperAzModule should return true" { 
                test-MPNHelperAzModule | should -BeTrue
            }

            It "test-MPNHelperAzConnexion should return true" {
                test-MPNHelperAzConnexion | should -BeTrue
            }

            It "LocalPartnerRegistered must false with when PartnerId is not 44444" {

                function Get-AzManagementPartner () {
                    [pscustomobject]@{
                        "PartnerId"     = "333333"
                        "PartnerName"   = "test"
                        "TenantId"      = "xxxxx-xxxxx-xxxxx-xxxx"
                        "ObjectId"      = "xxxxx-xxxxx-xxxxx-xxxx"
                        "State"         = "Active"
                    }
                }

                $Result = get-MPNHelperID 

                $Result.LocalPartnerRegistered | Should -BeFalse

            }

            It "LocalPartnerRegistered must true with when PartnerId is  44444" {

                function Get-AzManagementPartner () {
                    [pscustomobject]@{
                        "PartnerId"     = "44444"
                        "PartnerName"   = "test"
                        "TenantId"      = "xxxxx-xxxxx-xxxxx-xxxx"
                        "ObjectId"      = "xxxxx-xxxxx-xxxxx-xxxx"
                        "State"         = "Active"
                    }
                }

                $Result = get-MPNHelperID 

                $Result.LocalPartnerRegistered | Should -BeTrue

            }


        }

    }


}