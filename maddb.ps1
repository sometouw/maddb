<#
	Microsoft AD DNS Backup (maddb)

	Scripts creates a holding container in Active Directory an moves the DnsZone objects to it.
	This prevents MS DNS server from laoding the AD intergrated zones on startup.
	Since this script only moves the zone definitions no ACL or other metadata is modified.

	Run as Domain Admin or Enterprise Admin on PDC
	Not fit for any purpose, Run at own risk

	v1 March 2017, Nathan Evans, nevans@showrunint.com

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
	[string]$holding = "DnsHolding"
)

## Imports
import-module activedirectory


## Main
if($backup){
	New-ADObject -name $holding -type "Container" -path "CN=MicrosoftDNS,DC=DomainDnsZones,$domain"
	Get-ADObject -filter 'ObjectClass -eq "DnsZone"' -searchbase "CN=MicrosoftDNS,DC=DomainDnsZones,$domain" | Move-ADObject -targetpath "CN=$holding,CN=MicrosoftDNS,DC=DomainDnsZones,$domain"
	if($moveForest){
		New-ADObject -name $holding -type "Container" -path "CN=MicrosoftDNS,DC=ForestDnsZones,$domain"
		Get-ADObject -filter 'ObjectClass -eq "DnsZone"' -searchbase "CN=MicrosoftDNS,DC=ForestDnsZones,$domain" | Move-ADObject -targetpath "CN=$holding,CN=MicrosoftDNS,DC=ForestDnsZones,$domain"
	}
}
ElseIf($restore){
	Get-ADObject -filter 'ObjectClass -eq "DnsZone"' -searchbase "CN=$holding,CN=MicrosoftDNS,DC=DomainDnsZones,$domain" | Move-ADObject -targetpath "CN=MicrosoftDNS,DC=DomainDnsZones,$domain"
	if($moveForest){
		Get-ADObject -filter 'ObjectClass -eq "DnsZone"' -searchbase "CN=$holding,CN=MicrosoftDNS,DC=ForestDnsZones,$domain" | Move-ADObject -targetpath "CN=MicrosoftDNS,DC=ForestDnsZones,$domain"
	}
}
Else{
	Get-ADObject -filter 'ObjectClass -eq "DnsZone"' -searchbase "CN=MicrosoftDNS,DC=DomainDnsZones,$domain"
	if($moveForest){
		Get-ADObject -filter 'ObjectClass -eq "DnsZone"' -searchbase "CN=MicrosoftDNS,DC=ForestDnsZones,$domain"
	}
}
## End script
