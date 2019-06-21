#Get Parameters from aqua
param($variables, $aquaCallback)
	
$currentScriptDirectory = Get-Location 
$gitLocalPath = Split-Path -Path $currentScriptDirectory -Parent 
$gitLocalPath = [string]$gitLocalPath+"\GITCheckout\"

$nunit           =$gitLocalPath+"NUnit-3.2.1\bin\nunit3-console.exe"
$outputdir       =$gitLocalPath+"output\"
$testsDll        =$gitLocalPath+"selenium-tests\bin\Debug\selenium-tests.dll"


$aquaCallback.SendMessage("gitLocalPath:$gitLocalPath", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::InformationalInfo, "PowerShell");
# get test id from aqua
###########################################################################################
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
# define more precise namespace of tests if needed
#$testCaseName = "selenium-tests.tests.TC" + [string]$testCaseId
$aquaCallback.SendMessage("will search test by next word in testCaseName:$testCaseName", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::InformationalInfo, "PowerShell"); 


Write-Host "testCaseName: $testCaseName"


# check that output directory exists for nunit test results . delete it
###########################################################################################
####################################################################################################
if (Test-Path $outputdir){

    Write-Host "gitLocalPath:$gitLocalPath"
    $aquaCallback.SendMessage("gitLocalPath:$gitLocalPath", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::InformationalInfo, "PowerShell"); 
	$outputdirClean = $outputdir+"*"
	 Write-Host "gitBufCleanPath:$gitBufCleanPath"
	$aquaCallback.SendMessage("gitBufCleanPath:$gitBufCleanPath", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::InformationalInfo, "PowerShell"); 
	Try{
	 Remove-Item -Path $outputdirClean -Recurse -Force
}
Catch{
	$errorMessage = $_.Exception.Message
	Write-Host "Could not delete old git local folder:$gitLocalPath"
	$aquaCallback.SendMessage("no local folder is found:$outputdirClean", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::ExecutionError, "PowerShell");
	return "Fail"
}
}




# start unit test containing aqua ID in his name
###########################################################################################
Try{
    #works but starts all the tests
	#$output = & $nunit $testsDll  --work=$outputdir
	#works but starts tests only by special pattern
	$output = & $nunit  $testsDll --where="class=~$testCaseName" --work=$outputdir
    #$output = & $nunit $testDll --test=$testCaseName 2>&1
	
	#$output = & $nunit  $testsDll --where="cat=~$testCaseName" --work=$outputdir
	$result = $LastExitCode

	$aquaCallback.SendMessage("finished with result:$result", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::InformationalInfo, "PowerShell"); 
}
Catch{
	
	$aquaCallback.SendMessage( "Error in execution testcase. Errormessage: $output", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::ExecutionError, "PowerShell");
	Write-Host "Error in execution testcase. Errormessage: $output"
	return "Fail"
}




# give results back
###########################################################################################
$test_results=Get-ChildItem -Path $outputdir  -Recurse
	$aquaCallback.SendMessage("test_results:$test_results", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::InformationalInfo, "PowerShell"); 


if ($test_results.Count>0) 
{
     foreach ($res in $test_results) 
	 {
			$aquaCallback.AddExecutionAttachment($res)
	 }
}



if ($result -gt 0)
{
    $aquaCallback.SendMessage("Failures detected. See attached log for details.", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::ExecutionError, "PowerShell"); 
    return "Fail";
}
else
{
    $aquaCallback.SendMessage("All tests passed.", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::InformationalDebug, "PowerShell"); 
    return "Ready"
}
