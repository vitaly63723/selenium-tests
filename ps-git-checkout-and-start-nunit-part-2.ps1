# TODO change to aqua
$gitLocalPath ="C:\Users\ZagrebVi\Desktop\aquaPowerShellAgent\temp\GITCheckout\"
$nunit           =$gitLocalPath+"NUnit-3.2.1\bin\nunit3-console.exe"
$packagesdir     =$gitLocalPath+"packages\"
$testsDll        =$gitLocalPath+"selenium-tests\bin\Debug\selenium-tests.dll"
$outputdir       =$gitLocalPath+"selenium-tests\bin\Debug\output\"

$testCaseId="040304"


if (Test-Path $nunit) 
{
  Write-Host "nunit  FOUND :"+ $nunit
}
else 
{
	Write-Host "nunit not found :" + $nunit
	return "Fail"
}

if (Test-Path $testsDll) 
{
  Write-Host "testsDll  FOUND :"+ $testsDll
}
else 
{
	Write-Host "testsDll not found :" + $testsDll
	return "Fail"
}



 foreach ($var in $variables) {
	if (-Not $var.isAutomatic){
		$varName = $var.Name
		$varValue = $var.Value
		$stream.WriteLine($varName + ";" + $varValue)
	}
	else{
		if ($var.Name -eq "TestCaseId")
		{
			$testCaseId = $var.Value
		}
	}
}

# execute test case
#Set the ID to length 6 with leading zeros
$tmp = [convert]::ToInt32($testCaseId, 10)
$testCaseId = "{0:D6}" -f $tmp
$testCaseName="TC"+ [string]$testCaseId 
#$testCaseName = "selenium-tests.tests.TC" + [string]$testCaseId

Write-Host "testCaseName: $testCaseName"
Try{
    #works but starts all the tests
	#$output = & $nunit $testsDll  --work=$outputdir
	$output = & $nunit  $testsDll --where="class=~$testCaseName" --work=$outputdir
	#$output = & $nunit  $testsDll --where="cat=~$testCaseName" --work=$outputdir
	$result = $LastExitCode
}
Catch{
	#$aquaCallback.SendMessage("Error in execution testcase. Errormessage: $output", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::ExecutionError, "PowerShell"); 
	Write-Host "Error in execution testcase. Errormessage: $output"
	return "Fail"
}

#$aquaCallback.SendMessage($testLog, [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::InformationalDebug, "PowerShell");


# Return Result
Write-Host "output:$output"
Write-Host "result:$result"

if ($result -gt 0)
{
    #$aquaCallback.SendMessage("Failures detected. See attached log for details.", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::InformationalDebug, "PowerShell"); 
    return "Fail";
}
else
{
   # $aquaCallback.SendMessage("All tests passed.", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::InformationalDebug, "PowerShell"); 
    return "Ready"
}
