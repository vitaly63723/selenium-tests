##########################################################################################################################################################################
# Get Parameters from aqua
param($variables, $aquaCallback)



### STEPS BEFORE EXECUTE SCRIPTS
#
# 1. install github for windows  https://git-scm.com/downloads to have console client here:    C:\Program Files\Git\cmd\git.exe 
# 1.1. write path C:\Program Files\Git\cmd\git.exe  to variable PATH in enviroment windows variables if it is not there by default.
# 2. create account on https://github.com/ 
#
#https://git-scm.com/downloads
###### next actions you can do also github desktop-windows-client or in visual studio (2019) where github plugin is integrated
#
#
# 2.1. create link on  https://github.com/  for new repo like https://github.com/username/myproject.git  . Here https://github.com/vitaly63723/selenium-tests.git
#
# TO USE AQUA AGENT IT SHOULD LAY IN /aquaPowerShellAgent/temp/myproject/    IN OTHER CASE YOU SHOULD PROVIDE LOCAL PATH $gitLocalPath AND COMMENT ALL AQUA COMMANDS (aquaCallback)
# 2.2 create folder .../myproject/ with all needable project files. In visual studio user creates project with its solution file with name "myproject". 
# Here for comfortability to have same names  the project folder (and solution file accordingly) is named /selenium-tests/ (selenium-tests.sln)  
#
# 3. start C:\Program Files\Git\cmd\git.exe and navigate by console commands to folder  where your project files lay. 
# According to  https://help.github.com/en/articles/adding-an-existing-project-to-github-using-the-command-line 
# 4. create through console C:\Program Files\Git\cmd\git.exe  new repo :  
#
# git init
# git add "filename"
# git commit -m "your comment for commit"
# git push origin branchname  (usually first branchname is "master": git push origin master )
#
# to add and commit all new changes: git add -A && git commit -m "Your Message"
#
# after this you should have your repo which is visible on github.com 
##########################################################################################################################
## 5. (optional) . additional files for building project and starting nunits:
# 5.1. put in folder with project  Nunit adapter :  .\NUnit-3.2.1\bin\nunit3-console.exe   (installed by nuget.exe or integrated nuget manager in Visual studio),
# 5.2. put in folder with project  msbuild.exe  . here was taken : C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild.exe
#
# 5.3. give your credentials from github and other fixed names (here directories of project and config files)
######################################################################

# Get Parameters for  git repo
$username="vitaly63723"
$password = "Andagon1"
# switch to not master branch by giving branch name
$gitbranch="master"
$gitUrl= "https://"+$username+":"+$password+"@github.com/"+$username+"/selenium-tests.git"
$gitHttpUrl="https://github.com/"+$username+"/selenium-tests.git"
# define other packages, msbuild, solutionfile.sln
$gitExe ="C:\Program Files\Git\cmd\git.exe"
$currentScriptDirectory = Get-Location 
$gitLocalPath = Split-Path -Path $currentScriptDirectory -Parent 
##### for debug give here your local path
##$gitLocalPath= ""
$gitLocalPath =   $gitLocalPath+"\GITCheckout\"
$projectFilePath =$gitLocalPath +"selenium-tests.sln"
$msbuild 		 =$gitLocalPath+"MSBuild.exe"
$nunit           =$gitLocalPath+"NUnit-3.2.1\bin\nunit3-console.exe"
$outputdir       =$gitLocalPath+"output\"
$packagesdir     =$gitLocalPath+"packages\"
$testsDll        =$gitLocalPath+"selenium-tests\bin\Debug\selenium-tests.dll"
# needed to give parameters like outputdir for nunit ps script.
# KEEP SAME NAME of config FOR NUNIT
$configName = "aqua-config-powershell.json"
$configPath      = $gitLocalPath+"selenium-tests\bin\Debug\"+$configName
######################################################################






$aquaCallback.SendMessage("clean old checkout data", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::InformationalInfo, "PowerShell"); 

### clean previous local folder with repository(checkout folder)
####################################################################################################
if (Test-Path $gitLocalPath){

    Write-Host "gitLocalPath:$gitLocalPath"
    $aquaCallback.SendMessage("gitLocalPath:$gitLocalPath", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::InformationalInfo, "PowerShell"); 
	$gitBufCleanPath = $gitLocalPath+"*"
	 Write-Host "gitBufCleanPath:$gitBufCleanPath"
	$aquaCallback.SendMessage("gitBufCleanPath:$gitBufCleanPath", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::InformationalInfo, "PowerShell"); 
	Try{
	 Remove-Item -Path $gitBufCleanPath -Recurse -Force
	 Remove-Item -Path $gitLocalPath    -Recurse -Force
}
Catch{
	$errorMessage = $_.Exception.Message
	Write-Host "Could not delete old git local folder:$gitLocalPath"
	$aquaCallback.SendMessage("no local folder is found:$gitLocalPath", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::ExecutionError, "PowerShell");
	return "Fail"
}
}

# checking existance of git.exe , git-url
####################################################################################################
$aquaCallback.SendMessage("checking existance of git.exe , git-url", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::InformationalInfo, "PowerShell"); 
 
if (Test-Path $gitExe)
{
Write-Host "gitExe: $gitExe"

## check if correct git url repo for project was given
################################################################################################
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


# cloning given branch
######################################################################
$aquaCallback.SendMessage("cloning given branch:$gitbranch from url:$gitUrl", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::InformationalInfo, "PowerShell"); 
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

#output dir create
New-Item -ItemType Directory -Path $outputdir

if (Test-Path $outputdir){}
else 
{
	Write-Host "NO outputdir for test results created: $outputdir"
	$aquaCallback.SendMessage("NO outputdir for test results created: $outputdir", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::ExecutionError, "PowerShell");
	return "Fail"
}


# checking existance of msbuild.exe , project.sln file , nunit console . 
####################################################################################################
$aquaCallback.SendMessage("checking existance of msbuild.exe , project.sln file , nunit console ", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::InformationalInfo, "PowerShell"); 

if (Test-Path $msbuild){}
else 
{
	Write-Host "NO msbuild: $msbuild"
	$aquaCallback.SendMessage("no msbuild: $msbuild", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::ExecutionError, "PowerShell");
	return "Fail"
}

if (Test-Path $projectFilePath){}
else 
{
	Write-Host "NO projectFilePath: $projectFilePath"
	$aquaCallback.SendMessage("NO projectFilePath: $projectFilePath", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::ExecutionError, "PowerShell");
	return "Fail"
}

if (Test-Path $nunit) 
{
  Write-Host "nunit  FOUND :"+ $nunit
  	
}
else 
{
   $aquaCallback.SendMessage("nunit   NOT FOUND: $nunit", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::ExecutionError, "PowerShell");
	Write-Host "nunit not found :" + $nunit
	return "Fail"
}

# start to build the solution
# by problems with build find info in buildlog.txt file
###########################################################################################
$aquaCallback.SendMessage("start to build the solution", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::InformationalInfo, "PowerShell"); 

Try{	
	$output =   & $msbuild $projectFilePath >>buildlog.txt
	$buildResult = $LastExitCode
	
	
	
	
}
Catch{
	$errorMessage = $_.Exception.Message
	$aquaCallback.SendMessage("nuld with errors :$errorMessage ", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::ExecutionError, "PowerShell");	
	return "Fail"
}

# check built soulution file.dll
###########################################################################################
$aquaCallback.SendMessage("check built soulution file.dll", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::InformationalInfo, "PowerShell"); 



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


#config file with info from script into nunit tests  started by nunit test script
# comment this block if you dont want to use it in your unit tests.
########################################


    $outputdir=$outputdir.replace("\","/")
    New-Item $configPath 
	Add-Content -Path $configPath  "{" 
    Add-Content -Path $configPath -Value "`"gitbranch`" : `"$gitbranch`",";
    Add-Content -Path $configPath -Value "`"outputdir`" : `"$outputdir`"";	
	Add-Content $configPath  "}" 


if (Test-Path $configPath) 
{
  Write-Host "configPath  FOUND :"+ $configPath
}
else 
{
$aquaCallback.SendMessage("configPath not fiund : $configPath", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::ExecutionError, "PowerShell");
	Write-Host "configPath not found :" + $configPath
	return "Fail"
}





# check built status
###########################################################################################################################
	$aquaCallback.SendMessage("finished with built result:  $buildResult", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::InformationalInfo, "PowerShell"); 
	
if ($buildResult -gt 0){
	Write-Host "Could not build project. Errormessage: $output"
	$aquaCallback.SendMessage("can not build: $projectFilePath with $msbuild", [aqua.ProcessEngine.WebServiceProxy.ExecutionLogMessageType]::ExecutionError, "PowerShell");
	return "Fail"
}
else{
# start HERE nunit test in next script OR OTHER SCRIPT if you need to continue here.
#.../ps-start-nunit.ps1
	return "Ready"
	{
	
	}
}  













