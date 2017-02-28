PS C:\Users\su-adfs> Set-ADFSProperties -ExtendedProtectionTokenCheck:None
WARNING: PS0038: This action requires a restart of the AD FS Windows Service. If you have deployed a federation server
farm, restart the service on every server in the farm.
PS C:\Users\su-adfs> iisreset.exe
Attempting stop...
Internet services successfully stopped
Attempting start...
Internet services successfully restarted
