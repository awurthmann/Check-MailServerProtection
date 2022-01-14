###VERSION DRAFT CODE

#powershell.exe

# Written by Aaron Wurthmann
#
# You the executor, runner, user accept all liability.
# This code comes with ABSOLUTELY NO WARRANTY.
# You may redistribute copies of the code under the terms of the GPL v3.
#
# --------------------------------------------------------------------------------------------
# Name: Check-MailServerProtection.ps1
# Date: 2022.01.13 ver 0
# Description:
# 
#
# Tested with: Microsoft Windows [Version 10.0.19043.1466]
# --------------------------------------------------------------------------------------------

Param ([string]$Domain,[string]$Selector)

$NameExchange=(Resolve-DnsName -Name $Domain -Type MX).NameExchange
$Spf=(Resolve-DnsName -Name $Domain -Type TXT | Where {$_.Strings -like "v=spf*"}).Strings
$Dmarc=(Resolve-DnsName -Name _dmarc.$Domain -Type txt).Strings

If ($NameExchange -like "*google.com*"){
	$Selector="google"
}
ElseIf (($NameExchange -like "*outlook.com*") -or ($NameExchange -like "*onmicrosoft.com*")){
  $Selector="selector1"
	If (!($Dkim)){$Selector="selector2"}
}

If ($Selector){
	$Dkim=(Resolve-DnsName -Name "$Selector._domainkey.$Domain" -Type txt -ErrorAction SilentlyContinue).Strings
}

If ($Dkim) {
	$DkimCharCount=($Dkim.Split('=')[-2,-1] | Measure-Object -Character).Characters
	
	If ($DkimCharCount) {
		If ($DkimCharCount -ge 736) {$DkimEncryption=4096} 
		ElseIf ($DkimCharCount -ge 564) {$DkimEncryption=3072}
		ElseIf ($DkimCharCount -ge 392) {$DkimEncryption=2048}
		ElseIf ($DkimCharCount -ge 216) {$DkimEncryption=1024}
	}

}
Else{
	$Dkim="Unknown"
}

$myObject = [PSCustomObject]@{
    Domain = $Domain
    MailServers = $NameExchange
    SPF = $Spf
    DMARC = $Dmarc
    DKIM = $Dkim
    DkimEncryption = $DkimEncryption
}

return $myObject
