if (!(Test-Path .\arm-ttk\arm-ttk.psd1)) {
    Invoke-WebRequest -Uri https://aka.ms/arm-ttk-latest -OutFile "armttk.zip"
    Expand-Archive -Path "armttk.zip" -DestinationPath .
}

Import-Module .\arm-ttk\arm-ttk.psd1

$totalErrorCount = 0;
$files = Get-ChildItem "../resources" | ?{ $_.PSIsContainer }

foreach ($file in $files) {
    $directory = $file.FullName

    if ((Test-Path "$directory\azuredeploy.jsonc")) {
        $fileName = "$directory\azuredeploy.jsonc"
    } elseif ((Test-Path "$directory\azuredeploy.json")) {
        $fileName = "$directory\azuredeploy.json"
    } else {
        Write-Host "Could not find azuredeploy.jsonc or azuredeploy.json in $directory"
        exit $totalErrorCount
    }

    Write-Host "Testing $fileName"
    Copy-Item -Path $fileName -Destination "azuredeploy.json"

    if (("*resourceAzureSql*", "*resourceAzureSqlDatabase*", "*resourceServiceBus*", "*resourceAppInsights*", "*resourceAppDockerCompose*", "*resourceApplicationGateway*" | %{$directory -like $_} ) -contains $true) {
        $r = Test-AzTemplate  -Skip "apiVersions_Should_Be_Recent"
    } else {
        $r = Test-AzTemplate
    }

    # Dump test results
    $r

    # Counting errors
    foreach ($i in $r) {
        $totalErrorCount = $totalErrorCount + $i.Errors.Count
    }
}

Write-Host "Total errors found $totalErrorCount"
exit $totalErrorCount