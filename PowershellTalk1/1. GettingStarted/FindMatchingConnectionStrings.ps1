#
# FindMatchingConnectionStrings.ps1
#

#Let's find all those config files....oh my
Get-ChildItem -Recurse -Path . -Filter *.config

#Just how big is this problem? How can I count all of this stuff...ooh pipelines
Get-ChildItem -Recurse -Path . -Filter *.config | Measure-Object

#Ok, so let's use this pipeline to find what I'm looking for
Get-Help Select-String
Get-ChildItem -Recurse -Path . -Filter *.config | Where-Object { Select-String -Path $_.FullName -Pattern '\<add.*connectionstring=".*CaseData\.' -Quiet }

#Cool - so how many will need updating?
Get-ChildItem -Recurse -Path . -Filter *.config | Where-Object { Select-String -Path $_.FullName -Pattern '\<add.*connectionstring=".*CaseData\.' -Quiet } | Measure-Object

#Now let's get this stuff into something I can pop into a report
Get-ChildItem -Recurse -Path . -Filter *.config | Where-Object { Select-String -Path $_.FullName -Pattern '\<add.*connectionstring=".*CaseData\.' -Quiet } | Get-Member
Get-ChildItem -Recurse -Path . -Filter *.config | Where-Object { Select-String -Path $_.FullName -Pattern '\<add.*connectionstring=".*CaseData\.' -Quiet } | Select-Object -Property FullName

#Hang on, this is a scripting language, shouldn't it be terse?
gci . -Recurse -Filter *.config | ?{sls $_.FullName -Pattern '\<add.*connectionstring=".*CaseData\.' -Quiet } | select -Property FullName