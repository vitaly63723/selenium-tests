# Get Parameters from aqua
param($variables, $aquaCallback)
# Get Parameters for  git repo
$username="vitaly63723"
$password = "Andagon1"
# switch to not master branch by giving branch name
$gitbranch="master"
$gitUrl= "https://"+$username+":"+$password+"@github.com/"+$username+"/selenium-tests.git"
# define other packages, msbuild, solutionfile.sln
$gitExe ="C:\Program Files\Git\cmd\git.exe"
$currentScriptDirectory = Get-Location 
$gitLocalPath = Split-Path -Path $currentScriptDirectory -Parent 
$gitLocalPath = [string]$gitLocalPath+"\GITCheckout\"
$msbuild 		 =$gitLocalPath+"MSBuild.exe"
$projectFilePath =$gitLocalPath +"selenium-tests.sln"



# clean old checkout data 
####################################################################################################
if (Test-Path $gitLocalPath){

    Write-Host "gitBufCleanPath:$gitBufCleanPath"
    $aquaCallback.SendMessage("gitLocalPath:$gitLocalPath", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::InformationalInfo, "PowerShell"); 
	$gitBufCleanPath = $gitLocalPath+"*"
	
	Try{
	 Remove-Item -Path $gitBufCleanPath -Recurse -Force
}
Catch{
	$errorMessage = $_.Exception.Message
	Write-Host "Could not delete old git local folder:$gitLocalPath"
	$aquaCallback.SendMessage("no local folder is found:$gitLocalPath", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::ExecutionError, "PowerShell");
	return "Fail"
}
}

#create folder for cloning project from github to local disc
####################################################################################################
# checking existance of git.exe , git-url
if (Test-Path $gitExe)
{
Write-Host "gitExe: $gitExe"

# check if correct git url repo for project was given
Try{
	git ls-remote $gitUrl
}
Catch{
	$errorMessage = $_.Exception.Message
	Write-Host "invalid git url: $gitUrl :$errorMessage = "
	$aquaCallback.SendMessage("no gitExe: $gitExe", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::ExecutionError, "PowerShell");
	return "Fail"
}
}
else
{
    
	Write-Host "no git.exe on local computer: $gitExe"
	$aquaCallback.SendMessage("no gitExe: $gitExe", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::ExecutionError, "PowerShell");
	return "Fail"
}
# clean old checkout data 
####################################################################################################
if (Test-Path $gitLocalPath){

    Write-Host "gitBufCleanPath:$gitBufCleanPath"
    $aquaCallback.SendMessage("gitLocalPath:$gitLocalPath", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::InformationalInfo, "PowerShell"); 
	$gitBufCleanPath = $gitLocalPath+"*"
	
	Try{
	 Remove-Item -Path $gitBufCleanPath -Recurse -Force
}
Catch{
	$errorMessage = $_.Exception.Message
	Write-Host "Could not delete old git local folder:$gitLocalPath"
	$aquaCallback.SendMessage("no local folder is found:$gitLocalPath", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::ExecutionError, "PowerShell");
	return "Fail"
}
}
######################################################################
# cloning given branch
Try{
git clone -b $gitbranch $gitUrl $gitLocalPath
}
Catch{
	$errorMessage = $_.Exception.Message
	Write-Host "error by cloning git repo: $errorMessage"
	$aquaCallback.SendMessage("could not clone repo to :$gitLocalPath from : $gitUrl", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::ExecutionError, "PowerShell");
	return "Fail"
}
Start-Sleep -Seconds 2
####################################################################################################
# checking existance of msbuild.exe , project.sln file to make build
if (Test-Path $msbuild){}
else 
{
	Write-Host "NO msbuild: $msbuild"
	$aquaCallback.SendMessage("no gitExe: $gitExe", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::ExecutionError, "PowerShell");
	return "Fail"
}

if (Test-Path $projectFilePath){}
else 
{
	Write-Host "NO projectFilePath: $projectFilePath"
	$aquaCallback.SendMessage("NO projectFilePath: $projectFilePath", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::ExecutionError, "PowerShell");
	return "Fail"
}
###########################################################################################
# start to build the solution
Try{	
	$output =   & $msbuild $projectFilePath  2>&1
	$buildResult = $LastExitCode
}
Catch{
	$errorMessage = $_.Exception.Message
		
	return "Fail"
}

if ($buildResult -gt 0){
	Write-Host "Could not build project. Errormessage: $output"
	$aquaCallback.SendMessage("can not build: $projectFilePath with $msbuild", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::ExecutionError, "PowerShell");
	return "Fail"
}
else{
# start nunit test
	return "Ready"
	{
	
	}
}  













