<#
	Microsoft AD DNS Backup (maddb)

	Scripts creates a holding container in Active Directory an moves the DnsZone objects to it.
	This prevents MS DNS server from laoding the AD intergrated zones on startup.
	Since this script only moves the zone definitions no ACL or other metadata is modified.

	Run as Domain Admin or Enterprise Admin on PDC
	Not fit for any purpose, Run at own risk

	v1 March 2017, Nathan Evans, nevans@showrunint.com
	v1.2 April 2017, Nathan Evans, nevans@showrunint.com
		Added support for server 2000 ADI dns stores

	This is free and unencumbered software released into the public domain.

	Anyone is free to copy, modify, publish, use, compile, sell, or
	distribute this software, either in source code form or as a compiled
	binary, for any purpose, commercial or non-commercial, and by any
	means.

	In jurisdictions that recognize copyright laws, the author or authors
	of this software dedicate any and all copyright interest in the
	software to the public domain. We make this dedication for the benefit
	of the public at large and to the detriment of our heirs and
	successors. We intend this dedication to be an overt act of
	relinquishment in perpetuity of all present and future rights to this
	software under copyright law.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
	IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
	OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
	ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	OTHER DEALINGS IN THE SOFTWARE.

	For more information, please refer to <http://unlicense.org/>

#>
## Begin Script

## Parameters
<#
	-domain "DC=example,DC=com"	#[required]	domain to perform operations on, yes "" required
	-backup	#backup domain dns zones to holding location
	-restore	#restore domain dns zones from holding location
	-moveForest	#perform operations on forest root as well
	-holding "somestring"	#[optional]	name of holding location
#>
param (
	[Parameter(Mandatory=$true)][string]$domain,
	[switch]$backup = $false,
	[switch]$restore = $false,
	[switch]$moveForest = $false,
	[switch]$server2k = $false,
	[string]$holding = "DnsHolding",
	[string]$DomainPath = "CN=MicrosoftDNS,DC=DomainDnsZones,$domain",
	[string]$ForestPath = "CN=MicrosoftDNS,DC=ForestDnsZones,$domain",
	[string]$Server2kPath = "CN=MicrosoftDNS,CN=system,$domain",
	[string]$Filter = 'ObjectClass -eq "DnsZone"'
)

## Imports
import-module activedirectory


## Main
if($backup){
	New-ADObject -name $holding -type "Container" -path $DomainPath
	Get-ADObject -filter $Filter -searchbase $DomainPath | Move-ADObject -targetpath "CN=$holding,$DomainPath"
	if($moveForest){
		New-ADObject -name $holding -type "Container" -path $ForestPath
		Get-ADObject -filter $Filter -searchbase $ForestPath | Move-ADObject -targetpath "CN=$holding,$ForestPath"
	}
	if($server2k){
		New-ADObject -name $holding -type "Container" -path $Server2kPath
		Get-ADObject -filter $Filter -searchbase $Server2kPath | Move-ADObject -targetpath "CN=$holding,$Server2kPath"
	}
}
ElseIf($restore){
	Get-ADObject -filter $Filter -searchbase "CN=$holding,$DomainPath" | Move-ADObject -targetpath $DomainPath
	if($moveForest){
		Get-ADObject -filter $Filter -searchbase "CN=$holding,$ForestPath" | Move-ADObject -targetpath $ForestPath
	}
	if($server2k){
		Get-ADObject -filter $Filter -searchbase "CN=$holding,$Server2kPath" | Move-ADObject -targetpath $Server2kPath
	}
}
Else{
	Get-ADObject -filter $Filter -searchbase $DomainPath
	if($moveForest){
		Get-ADObject -filter $Filter -searchbase $ForestPath
	}
	if($server2k){
		Get-ADObject -filter $Filter -searchbase $Server2kPath
	}
}
## End script
