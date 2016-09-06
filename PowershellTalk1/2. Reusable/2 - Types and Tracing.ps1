#
# _2___Restart_AppPool.ps1
#

#ok cool, let's provide some tracing and type the parameter.

Function Restart-AppPool{
    param(
        [string]$appPoolName
    )

    Import-Module WebAdministration

    "Going to restart App Pool {0}" -f $appPoolName | Write-Output
    Restart-WebAppPool -Name $appPoolName
}

Restart-AppPool -appPoolName "SOMEAPPPOOLNAME"