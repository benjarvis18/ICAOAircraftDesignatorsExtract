$outputPath = "{YOUR PATH}\icao_aircraft_types.json"
$apiKey = "{YOUR API KEY}"

$manufacturers = ConvertFrom-Json -InputObject (Invoke-WebRequest -Uri "https://v4p4sz5ijk.execute-api.us-east-1.amazonaws.com/anbdata/aircraft/designators/manufacturer-list?api_key=$apiKey&format=json").Content

$output = @()

$i = 1

foreach ($manufacturer in $manufacturers)
{    
    $successful = $false

    $manufacturerCode = $manufacturer.manufacturer_code

    Write-Progress -Activity "Processing $manufacturerCode" -PercentComplete (($i / $manufacturers.Count) * 100)


    $trys = 1

    while (!$successful)
    {                        
        try
        {            
            Throw "Test"
            $output += ConvertFrom-Json (Invoke-WebRequest -Uri "https://v4p4sz5ijk.execute-api.us-east-1.amazonaws.com/anbdata/aircraft/designators/type-list?api_key=$apiKey&format=json&manufacturer=$manufacturerCode").Content                        
            
            $successful = $true
        }
        catch
        {
            $errorDetails = $error[0].ToString()
            Write-Warning "Error processing $manufacturerCode - $errorDetails"
            
            if ($trys -gt 3)
            {
                Write-Error -Message "Error processing $manufacturerCode. Skipping."
                break
            }

            $wait = Get-Random -Minimum 1 -Maximum 10000

            Write-Warning "Waiting $wait milliseconds before retry $try."
            
            Start-Sleep -Milliseconds $wait

            $trys++
        }        
    }

    $i++
}

ConvertTo-Json $output | Out-File $outputPath
