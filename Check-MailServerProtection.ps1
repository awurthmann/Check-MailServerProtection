#powershell.exe

# Written by Aaron Wurthmann
#
# You the executor, runner, user accept all liability.
# This code comes with ABSOLUTELY NO WARRANTY.
# You may redistribute copies of the code under the terms of the GPL v3.
#
# --------------------------------------------------------------------------------------------
# Name: Check-MailServerProtection.ps1
# Date: 2022.02.01.1714
# Description:
# Checks the following email related attributes for a provided domain:
# Mail Severs (MX Records), SPF record, DMARC record, DKIM, DKIM Encryption level.
#
# Regarding the DKIM record lookup: The script checks if the mail servers are Google Workplace or Microsoft 365 and uses the default records for those services.
# If the mail servers are not Google Workplace or Microsoft 365 than the Selector will need to be provided. If DKIM is in use the selector is sent in the email header.
# Example:
#	DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=github.com; s=google;
#	The "s" in "s=google" stands for Selector, so the selector is google.
#
# Tested with: Microsoft Windows [Version 10.0.19043.1466]
# --------------------------------------------------------------------------------------------

Param ([string]$Domain,[string]$Selector)

$NameExchange=(Resolve-DnsName -Name $Domain -Type MX).NameExchange
$Spf=(Resolve-DnsName -Name $Domain -Type TXT | Where {$_.Strings -like "v=spf*"}).Strings
$Dmarc=(Resolve-DnsName -Name _dmarc.$Domain -Type txt).Strings

If (!($Selector)){
	If ($NameExchange -like "*google.com*"){
		$Selector="google"
	}
	ElseIf (($NameExchange -like "*outlook.com*") -or ($NameExchange -like "*onmicrosoft.com*")){
	  $Selector="selector1"
		$Dkim=(Resolve-DnsName -Name "$Selector._domainkey.$Domain" -Type txt -ErrorAction SilentlyContinue).Strings
		If (!($Dkim)){$Selector="selector2"}
	}
}

If (($Selector) -and (!($Dkim))){
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
	$Dkim="Unknown: Selector Not Found"
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
