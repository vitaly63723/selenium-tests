# TODO change to aqua
$currentScriptDirectory = Get-Location 
$gitLocalPath = Split-Path -Path $currentScriptDirectory -Parent 
$gitLocalPath = [string]$gitLocalPath+"\GITCheckout\"
$nunit           =$gitLocalPath+"NUnit-3.2.1\bin\nunit3-console.exe"
$outputdir       =$gitLocalPath+"output\"
$packagesdir     =$gitLocalPath+"packages\"
$testsDll        =$gitLocalPath+"selenium-tests\bin\Debug\selenium-tests.dll"

######################################################################
## checking that nunit console exist, 
## project.dll file exist in  "../bin/Debug/..." as solutionName.dll 
## output dir  for test results
if (Test-Path $nunit) 
{
  Write-Host "nunit  FOUND :"+ $nunit
  	
}
else 
{
   $aquaCallback.SendMessage("nunit  FOUND: $nunit", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::ExecutionError, "PowerShell");
	Write-Host "nunit not found :" + $nunit
	return "Fail"
}

if (Test-Path $testsDll) 
{
  Write-Host "testsDll  FOUND :"+ $testsDll
}
else 
{
$aquaCallback.SendMessage("tests dll data not fiund : $testsDll", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::ExecutionError, "PowerShell");
	Write-Host "testsDll not found :" + $testsDll
	return "Fail"
}



if ( Test-Path $outputdir )
{
    $aquaCallback.SendMessage("no output dir. creating it$outputdir  :", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::InformationalInfo, "PowerShell");
}
else 
{
  $aquaCallback.SendMessage("creating outputdir for test results:  $outputdir ", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::InformationalInfo, "PowerShell"); 
  New-Item -ItemType directory -Path $outputdir 
}



######################################################################
# get id of current test

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
$aquaCallback.SendMessage("will search test by next word in testCaseName:$testCaseName", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::InformationalInfo, "PowerShell"); 


Write-Host "testCaseName: $testCaseName"
Try{
    #works but starts all the tests
	#$output = & $nunit $testsDll  --work=$outputdir
	#works but starts tests only by special pattern
	$output = & $nunit  $testsDll --where="class=~$testCaseName" --work=$outputdir
	#$output = & $nunit  $testsDll --where="cat=~$testCaseName" --work=$outputdir
	$result = $LastExitCode
}
Catch{
	
	$aquaCallback.SendMessage( "Error in execution testcase. Errormessage: $output", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::ExecutionError, "PowerShell");
	Write-Host "Error in execution testcase. Errormessage: $output"
	return "Fail"
}


if ($result -gt 0)
{
    aquaCallback.SendMessage("Failures detected. See attached log for details.", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::ExecutionError, "PowerShell"); 
    return "Fail";
}
else
{
    $aquaCallback.SendMessage("All tests passed.", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::InformationalDebug, "PowerShell"); 
    return "Ready"
}
