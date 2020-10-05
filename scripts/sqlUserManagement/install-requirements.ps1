if (!(Test-Path .\.psyaml\source\PSYaml\PSYaml.psd1)) {
    Write-Host 'Getting PSYaml module from GitHub'
    Invoke-WebRequest -Uri https://github.com/Phil-Factor/PSYaml/archive/master.zip -OutFile (New-Item -Path ".\.psyaml\master.zip" -Force)

    Expand-Archive -Path ".\.psyaml\master.zip" -DestinationPath .\.psyaml

    Get-Item .\.psyaml\PSYaml-master | Rename-Item -newName source
}

if(!(Get-Module -ListAvailable -Name MSAL.PS)) {
    Write-Host 'MSAL.PS module was not found'
    Install-Module -Name MSAL.PS -Scope CurrentUser
}