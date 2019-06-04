# Get Parameters from aqua
#param($variables, $aquaCallback)
$username="vitaly63723"
$password = "Andagon1"
# switch to not master branch by giving branch name
$gitbranch="master"
$gitExe ="C:\Program Files\Git\cmd\git.exe"
$gitUrl= "https://"+$username+":"+$password+"@github.com/"+$username+"/selenium-tests.git"
#TODO: set it by aqua agent
$gitLocalPath ="C:\Users\ZagrebVi\Desktop\aquaPowerShellAgent\temp\GITCheckout\"
$msbuild 		 =$gitLocalPath+"MSBuild.exe"
$projectFilePath =$gitLocalPath +"selenium-tests.sln"


# clean old checkout data 
####################################################################################################
if (Test-Path $gitLocalPath){
	$gitBufCleanPath = $gitLocalPath+"*"
	Write-Host "gitBufCleanPath:$gitBufCleanPath"
	Try{
	 Remove-Item -Path $gitBufCleanPath -Recurse -Force
}
Catch{
	$errorMessage = $_.Exception.Message
	Write-Host "Could not delete old git local folder:$gitLocalPath"
	return "Fail"
}
}

#create folder for cloning project from github to local disc
####################################################################################################
if (-Not(Test-Path $gitLocalPath)) 
{
   Write-Host "$JsonContent.gitLocalPath"
   New-Item -ItemType directory -Path $JsonContent.gitLocalPath
}

# cloning given branch
Try{
git clone -b $gitbranch $gitUrl $gitLocalPath
}
Catch{
	$errorMessage = $_.Exception.Message
	Write-Host "error by cloning git repo: $errorMessage"
	return "Fail"
}
######################################################################

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
	return "Fail"
}
}
else
{
	Write-Host "no gitExe: $gitExe"
	return "Fail"
}


Start-Sleep -Seconds 2

if (Test-Path $msbuild){}
else 
{
	Write-Host "NO msbuild: $msbuild"
	return "Fail"
}

if (Test-Path $projectFilePath){}
else 
{
	Write-Host "NO projectFilePath: $projectFilePath"
	return "Fail"
}


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
	return "Fail"
}
else{
# start nunit test
	return "Ready"
	{
	
	}
}  













