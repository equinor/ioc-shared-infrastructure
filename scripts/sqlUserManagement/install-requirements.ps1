if (!(Test-Path .\.psyaml\source\PSYaml\PSYaml.psd1)) {
    Write-Host 'Getting PSYaml module from GitHub'
    Invoke-WebRequest -Uri https://github.com/Phil-Factor/PSYaml/archive/master.zip -OutFile (New-Item -Path ".\.psyaml\master.zip" -Force)

    Expand-Archive -Path ".\.psyaml\master.zip" -DestinationPath .\.psyaml

    Get-Item .\.psyaml\PSYaml-master | Rename-Item -newName source
}

## TODO : Add support for direct query towards database
## in a secure way.
# if(!(Get-Module -ListAvailable -Name SqlServer)) {
#     Write-Host 'SqlServer module was not found and must be installed.'
#     Install-Module -Name SqlServer -Scope CurrentUser
# }