# Load
[xml]$XmlContent = (get-content $PathToXmlFile)

# Manipulate
$XmlContent.Content.Attribut1 = $Value

# Save
$XmlContent.Save($PathToXmlFile)
