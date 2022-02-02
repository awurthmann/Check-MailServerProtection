# Check-MailServerProtection
Checks the following email related attributes for a provided domain:
Mail Severs (MX Records), SPF record, DMARC record, DKIM, DKIM Encryption level.

Regarding the DKIM record lookup: The script checks if the mail servers are Google Workplace or Microsoft 365 and uses the default records for those services.
If the mail servers are not Google Workplace or Microsoft 365 than the Selector will need to be provided. If DKIM is in use the selector is sent in the email header.
Example:
	DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=github.com; s=google;
	The "s" in "s=google" stands for Selector, so the selector is google.

## Legal:
	You the executor, runner, user accept all liability.
	This code comes with ABSOLUTELY NO WARRANTY.
	You may redistribute copies of the code under the terms of the GPL v3.

## Background:
I needed a quick way of looking this information up for assessments and reconnaissance.

## Instructions:
	  - Download Check-MailServerProtection.ps1
	  - Open PowerShell
	  - Check-MailServerProtection -Domain github.com
Examples:
```powershell
.\Check-MailServerProtection -Domain github.com
.\Check-MailServerProtection -Domain github.com -Selector google
```