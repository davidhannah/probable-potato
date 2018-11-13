clear

$inputDetails = Import-Csv -Path '.\UnsortedNamesWithDuplicates.txt'
$inputDetails | % { $_.UPN = [int]$_.UPN }
foreach($input in $inputDetails)
{
    write-host "$($input.UPN) : $($input.Name)"
}
write-host
$inputSortedByUPN = $inputDetails | sort UPN
foreach($input in $inputSortedByUPN)
{
    write-host "$($input.UPN) : $($input.Name)"
}
write-host
$hash = @{}
foreach($input in $inputDetails)
{
    $hash[$input.Name] = $input
}
foreach($key in $hash.Keys)
{
    $input = $hash[$key]
    write-host "$($input.UPN) : $($input.Name)"
}
write-host
$hash = @{}
foreach($input in $inputSortedByUPN)
{
    $Name = $input.Name
    $test = $hash[$input.Name]
    if($test)
    {
        $hash[$Name] = "DestructCode-1-1A-2B"
    }
    else
    {
        $hash[$Name] = $input
    }
}
foreach($key in $hash.Keys)
{
    $input = $hash[$key]
    if($input -eq "DestructCode-1-1A-2B" )
    {
        write-host $input
    }
    else
    {
        write-host "$($input.UPN) : $($input.Name)"
    }
}