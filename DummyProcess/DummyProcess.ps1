$inputObjects = Import-Csv -Path '.\DummyProcess\input.csv'

$seenUPNHash = @{}
Import-Csv ".\DummyProcess\SeenUPN.csv" | % { $seenUPNHash[$_.Key] = $_.Value }

$failProbability = 50
$randomRange = 1..100

$inputData | Measure-Object
$seenUPNHash | Measure-Object

foreach($inObj in $inputObjects)
{
    $UPN = $inObj.UPN
    $seen = $seenUPNHash[$UPN]
    if( $seen )
    {
        write-host -ForegroundColor Yellow "Already Seen $inObj"
    }
    else
    {
        write-host -ForegroundColor Green "Processing $inObj"
        $random = Get-Random -InputObject $randomRange
        $random
        if($random -le $failProbability)
        {
             write-host -ForegroundColor Red "Process Failed $inObj"
        }
        else
        {
            $seenUPNHash.Add($inObj.UPN,1)
        }
    }
}
$seenUPNHash.GetEnumerator() | Export-Csv -Path ".\DummyProcess\SeenUPN.csv"