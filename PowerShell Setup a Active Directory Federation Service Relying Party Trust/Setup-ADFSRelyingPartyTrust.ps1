# 1. Get your ADFS Federation Metadata

$FederationMetadataUrl = (Get-ADFSEndpoint  | where{$_.Protocol -eq "Federation Metadata"}).FullUrl.OriginalString

# 2. Send Url to Umantis

# 3. Add Relying Party Trust

## customer settings

$MetadataURL = "https://sso.umantis.com/multitenant-sp/saml2/metadata?metaAlias=/sp-279"
$UmantisSPIdentifier = "http://sso.umantis.com/sp-279"
$OutgoingClaimType = "userPrincipalName"

## umantis settings

$Name = "Umantis SSO"
$SignatureAlgorithm = "http://www.w3.org/2000/09/xmldsig#rsa-sha1"
$ADFSIdentifier = (Get-ADFSConfiguration).Identifier
$SSOUrl = "https://sso.umantis.com/multitenant-sp/saml2/SPInitiatedSSO?metaAlias=/sp-279&redirect_uri=https://employeeapp-279.umantis.com"

@"
@RuleTemplate = "LdapClaims"
@RuleName = "Login"
c:[Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname", Issuer == "AD AUTHORITY"]
 => issue(store = "Active Directory", types = ("http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn"), query = ";$OutgoingClaimType;{0}", param = c.Value);

@RuleName = "Identifier"
c:[Type == "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn"] 
 => issue(Type = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier", Issuer = c.Issuer, OriginalIssuer = c.OriginalIssuer, Value = c.Value, ValueType = c.ValueType, Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/format"] = "urn:oasis:names:tc:SAML:2.0:nameid-format:transient", Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/namequalifier"] = "$ADFSIdentifier", Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/spnamequalifier"] = "$UmantisSPIdentifier");
"@ | Out-File "Issuance-Transform-Rules.txt"

Add-ADFSRelyingPartyTrust -Name $Name –MetadataURL $MetadataURL -IssuanceTransformRulesFile "Issuance-Transform-Rules.txt"

Remove-Item "Issuance-Transform-Rules.txt"

Set-ADFSRelyingPartyTrust -TargetName $Name -SignatureAlgorithm $SignatureAlgorithm

Start $SSOUrl

$ADFSRelyingPartyTrust = Get-ADFSRelyingPartyTrust -Name $Name

# Remove-ADFSRelyingPartyTrust -TargetName $Name


<#
Todo 

Add Claim authorization Rule permit all user
 
#>