It is typically best practice when developing .NET applications, including SharePoint customizations, to create an event source for Windows Event Logging while installing the application. Each event source on a Windows computer is tied to a specific log upon registration. I recently provided guidance on how to move an event source to use its own brand new event log. The following lines of PowerShell can do this quickly. Unless your .NET application has the event log hardcoded into itself, which it shouldn’t because the event source should be registered to a log during installation, then the move shouldn’t require any code changes.

    Remove-EventLog -Source MyCustomApplicationSource
    New-EventLog -Source MyCustomApplicationSource -LogName MyNewOrExistingWindowsEventLog
    
I found that I had to reboot the machine after executing the above lines of PowerShell for this change to fully take effect.