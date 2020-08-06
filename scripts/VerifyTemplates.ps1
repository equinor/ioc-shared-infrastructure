Invoke-WebRequest -Uri https://aka.ms/arm-ttk-latest -OutFile "armttk.zip"
Expand-Archive -Path "armttk.zip" -DestinationPath .
Import-Module .\arm-ttk\arm-ttk.psd1

$totalErrorCount = 0;
$files = Get-ChildItem "../resources"

foreach ($file in $files) {
    Write-Host "Testing $file"
    Copy-Item -Path $file.FullName -Destination "azuredeploy.json"
    $r = Test-AzTemplate
    
    # Dump test results
    $r

    # Counting errors
    foreach ($i in $r) {
        $totalErrorCount = $totalErrorCount + $i.Errors.Count
    }
}

Write-Host "Total errors found $totalErrorCount"
exit $totalErrorCount