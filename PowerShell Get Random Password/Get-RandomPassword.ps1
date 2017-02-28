function Get-RandomPassword{
    
    $numbers = 1..9
    $consonants = "b","c","d","f","g","h","k","l","m","n","p","r","s","t","v","w","x","z"
    $nopeletters = "j","q","y"
    $vocals = "a","e","i","o","u"
    $dotsandstuff = ",",".","-"
    $nopedotsandstuff = ";",":","_"

    return (Get-Random $consonants).ToString().ToUpper() + 
    (Get-Random $vocals) + 
    (Get-Random $consonants) + 
    (Get-Random $vocals) + 
    (Get-Random $consonants) + 
    (Get-Random $vocals) + 
    (Get-Random $numbers) +  
    (Get-Random $numbers) + 
    (Get-Random $numbers) + 
    (Get-Random $dotsandstuff)
}