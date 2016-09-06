#
# _1___Restart_AppPool.ps1
#

#Let's create a simple function to encapsulate restarting a named apppool

Function Restart-AppPool{
    param($appPoolName)

    Import-Module WebAdministration

    Restart-WebAppPool -Name $appPoolName
}

Restart-AppPool -appPoolName "SOMEAPPPOOLNAME"