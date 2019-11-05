function test-MPNHelperAzModule {

    $azModuleInstalled = Get-InstalledModule -name "AZ" -ErrorAction SilentlyContinue 

    If (-not[string]::IsNullOrEmpty($azModuleInstalled)) { 
        $AzManagementPartnerModuleInstalled = Get-InstalledModule -name "AZ.managementPartner" -ErrorAction SilentlyContinue 

        If ([string]::IsNullOrEmpty($AzManagementPartnerModuleInstalled)) {  
            try {
                install-module -name "AZ.managementPartner" -Scope CurrentUser -Force
                return $true
            }
            catch  {
                return $false
            }
        } else {
            return $true
        }
    } else {

        Write-Error -Message "No Az module installed, please install AZ module using install-module -name AZ -scope CurrentUser"
    }
}

function test-MPNHelperAzConnexion {
    try {

        $void= get-AzContext 
        return $true
    }
    catch {
        Write-Error -Message "No connection to an Azure contextn Please open a connection before trying to set a MPN ID"
    }

}


<#
    .SYNOPSIS
        retreive the Microsoft Partner ID on the local workstation from the registry
        Path HKEY_CURRENT_USER\Software\MPNID key name MPNID
        return 0 if no key is found
    .NOTES
        To be able to set MPN ID on any Azure subscription you need to use set-MPNHelperLocalID first
        Author: Olivier Miossec https://www.linkedin.com/in/omiossec/
        Module: MPN-Helper
        https://dev.to/omiossec
        @omiossec_med
#>
function get-MPNHelperLocalID {

    try {
        return (Get-ItemProperty -path "HKCU:\software\MPNID" -name MPNID).MPNID
    }
    catch {
        Write-Error -Message "No MPNID registry key fonnd please use set-MPNHelperLocalID before"
    }
}

<#
    .SYNOPSIS
        Save the Microsoft Partner ID on the local workstation in the registry
        Path HKEY_CURRENT_USER\Software\MPNID key name MPNID
    .PARAMETER MPNID
        Integer, the MPN ID you want to add to each Azure Tenant from this computer 
    .NOTES
        To be able to set MPN ID on any Azure subscription you need to use this cmdlet first
        Author: Olivier Miossec https://www.linkedin.com/in/omiossec/
        Module: MPN-Helper
        https://dev.to/omiossec
        @omiossec_med
#>
function set-MPNHelperLocalID {
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory = $true
        )]
        [ValidateNotNullorEmpty()]
        [Int] $MPNID
    )
    
    try {
        $void = New-Item -Path HKCU:\Software -Name MPNID -Force
        $void = New-ItemProperty -Path "HKCU:\software\MPNID" -Name "MPNID" -Value $MPNID  -PropertyType "String" -Force
    }
    catch {
        Write-Error -Message " Exception Type: $($_.Exception.GetType().FullName) $($_.Exception.Message)"
    }
}

<#
    .SYNOPSIS
        Retreive the Microsoft Partner info from current Azure connection and compare it to the ID stored locally
        Az Context must return a connection object and the localpartnerID must be set
    .OUTPUT
        pscustomobject
        MPNID, the MPN ID on the current Azure Connection
        ParnterName, The partnair name on the current Azure Connection
        TenantID, The partnair Tenant ID on the current Azure Connection
        State, The state (actived or disabled) on the current Azure Connection
        LocalPartnerRegistered, $true if the MPN ID is alligned with the MPNID in the current connection and $false in any other case
    .NOTES
        To be able to set MPN ID on any Azure subscription you need to use set-MPNHelperLocalID first
        Author: Olivier Miossec https://www.linkedin.com/in/omiossec/
        Module: MPN-Helper
        https://dev.to/omiossec
        @omiossec_med
#>
function get-MPNHelperID {

    $LocalMPNID = get-MPNHelperLocalID
    $LocalPartnerEnabled = $false

    if ((test-MPNHelperAzModule) -AND (test-MPNHelperAzConnexion)) {

        try {
           $PartnerInfo =  Get-AzManagementPartner  

            if ($LocalMPNID -eq $PartnerInfo.PartnerId) {
                $LocalPartnerRegistered = $true
            }

           return [pscustomobject]@{
            MPNID                   = $PartnerInfo.PartnerId
            ParnterName             = $PartnerInfo.PartnerName
            TenantID                = $PartnerInfo.TenantId
            State                   = $PartnerInfo.State  
            LocalPartnerRegistered  = $LocalPartnerRegistered
            }

        } 
        catch [Microsoft.Azure.Commands.ManagementPartner.GetManagementPartner] {
            return $null
        }
        catch {
            Write-Error -Message " Exception Type: $($_.Exception.GetType().FullName) $($_.Exception.Message)"
        }
    }

}

<#
    .SYNOPSIS
        Set the Microsoft Partner ID in the current Azure connection and compare it to the ID stored locally
    .OUTPUT
        pscustomobject
    .NOTES
        To be able to set MPN ID on any Azure subscription you need to use set-MPNHelperLocalID first
        Author: Olivier Miossec https://www.linkedin.com/in/omiossec/
        Module: MPN-Helper
        https://dev.to/omiossec
        @omiossec_med
#>
function set-MPNHelperID {
    
    $PartnerInfo = get-MPNHelperID 
    $LocalMPNID = get-MPNHelperLocalID

    if ($null -eq $PartnerInfo){
        try {
            new-AzManagementPartner -PartnerId $LocalMPNID
        }
        catch {
            Write-Error -Message " Exception Type: $($_.Exception.GetType().FullName) $($_.Exception.Message)"
        }
        
    } else {
        try {
            update-AzManagementPartner -PartnerId $LocalMPNID
        }
        catch {
            Write-Error -Message " Exception Type: $($_.Exception.GetType().FullName) $($_.Exception.Message)"
        }
    }
}