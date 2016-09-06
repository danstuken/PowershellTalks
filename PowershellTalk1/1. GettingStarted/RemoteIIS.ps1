#
# RemoteIIS.ps1
#

#What modules have I got for looking at web stuff?
get-module -listavailable *web*

#What commands do I get from WebAdministration?
get-command -module webadministration

$targetNode = "REDACTED"
$targetSite = "CHANGEME"

Invoke-Command -ComputerName $targetNode -ScriptBlock {
    Import-Module WebAdministration

    #Let's check to see if my site is in the list of sites
    foreach($site in (get-childitem IIS:\Sites\*)){
        $site.name
    }

    #Now - which app pools do each of these use?
    foreach($site in (get-childitem IIS:\Sites\*)){
        "{0} - {1}" -f $site.name, $site.applicationPool
    }
    
    #Out of interest, what app pools are there?
    foreach($appPool in (get-childitem IIS:\AppPools\*)){
        $appPool.name
    }

    #Let's recycle that app pool to see if that helps
    $appPoolName = (get-childitem IIS:\sites\* | where {$_.name -eq $targetSite}).applicationPool
    
    #Can I do this using a pipeline?
    $appPoolName = get-childitem IIS:\sites\* | where {$_.name -eq $targetSite} | %{ $_.applicationPool }

    #Hmm, "foreach" is a bit clunky - is there a "map" like approach?
    $appPoolName = get-childitem IIS:\sites\* | where {$_.name -eq $targetSite} | .{process{$_.applicationPool}}
    "Recycling: {0}" -f $appPoolName | write-verbose -Verbose
    Restart-WebAppPool -Name $appPoolName
}
