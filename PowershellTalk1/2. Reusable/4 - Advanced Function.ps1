#
# _4___Advanced_Function.ps1
#

#Right - what can we achieve with one of these things?

Function Restart-AppPool{
    <# 
      .SYNOPSIS 
        Restarts app pools locally or on a remote host.
      .DESCRIPTION 
        Restarts app pools locally or on a remote host. Can accept either the name of a web site or the app pool name directly
      .EXAMPLE 
        Restart-AppPool -appPoolName "myAppPoolName"

        restarts the "myAppPoolName" app pool on local host
      .EXAMPLE 
        Restart-AppPool -appPoolName "myAppPoolName" -computerName "myRemoteHost"

        restarts the "myAppPoolName" app pool on myRemoteHost
      .EXAMPLE 
        Restart-AppPool -webSite "myWebSiteName" -computerName "myRemoteHost"

        restarts the app pool used by "myWebSiteName" on myRemoteHost
      .PARAMETER appPoolName
        Name of the app pool to restart
      .PARAMETER webSite
        Name of the web site to query to get the name of the app pool to restart
      .PARAMETER computername 
        The computer name to target, optional. Targets localhost if omitted
    #> 
    [cmdletbinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="Medium"
    )]
    param(
        [parameter(Mandatory=$True, ParameterSetName="AppPool")]
        [string]$appPoolName,

        [parameter(Mandatory=$True, ParameterSetName="Site")]
        [string]$webSite,

        [parameter(Mandatory=$False, ValueFromPipeline=$true)]
        [string]$computerName=$null
    )

    begin{
        $restartAppPoolBlock = {
            param($appPoolName)
        
            Import-Module WebAdministration
            Restart-WebAppPool -Name $appPoolName
        }

        $getWebSiteAppPoolNameBlock = {
            param($siteName)

            Import-Module WebAdministration
            get-childitem IIS:\sites\* | where {$_.name -eq $siteName} | .{process{$_.applicationPool}}
        }
    }

    process{
        if($PSCmdlet.ParameterSetName -eq "Site"){
            if($computerName -eq $null){
                "Getting app pool for site {0} locally" -f $webSite | Write-Verbose
                $appPoolName = &$getWebSiteAppPoolNameBlock $webSite
            }else{
                "Getting app pool for site {0} on {1}" -f $webSite, $computerName | Write-Verbose
                $appPoolName = Invoke-Command -ComputerName $computerName -ScriptBlock $getWebSiteAppPoolNameBlock -ArgumentList $webSite
            }
            "App pool for site {0} : {1}" -f $webSite, $appPoolName | Write-Verbose
        }
    
        if($pscmdlet.ShouldProcess($appPoolName,"restart")){
            if($computerName -eq $null){
                "Restarting app pool {0} locally" -f $appPoolName | Write-Verbose
                &$restartAppPoolBlock $appPoolName
            }else{
                "Restarting app pool {0} on {1}" -f $appPoolName, $computerName | Write-Verbose
                Invoke-Command -ComputerName $computerName -ScriptBlock $restartAppPoolBlock -ArgumentList $appPoolName
            }
        }
    }
}

#Help now available on the function
Get-Help Restart-AppPool

#Confirm before restarting the app pool
$oldConfirmPref = $ConfirmPreference
$ConfirmPreference = "Low"
Restart-AppPool -appPoolName "myAppPoolName" -computerName "myRemoteHost" -Verbose
$ConfirmPreference = $oldConfirmPref

#Run without making a change
Restart-AppPool -appPoolName "myAppPoolName" -computerName "myRemoteHost" -WhatIf
Restart-AppPool -webSite "myWebSiteName" -computerName "myRemoteHost" -WhatIf

#Just do it
Restart-AppPool -appPoolName "myAppPoolName" -computerName "myRemoteHost" -Verbose
Restart-AppPool -webSite "myWebSiteName" -computerName "myRemoteHost" -Verbose

#Pipe in the target servers
$computers = "myRemoteHost1","myRemoteHost2"
$computers | Restart-AppPool -appPoolName "myAppPoolName" -Verbose