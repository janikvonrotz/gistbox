$Admin = new-object Microsoft.SharePoint.Administration.SPSiteAdministration("http://sharepoint.vbl.ch") 
$Admin.ClearMaintenanceMode() 