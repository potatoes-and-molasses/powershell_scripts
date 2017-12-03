$res = dsquery * -filter '(&(objectCategory=person)(objectClass=user))'-attr pwdLastSet, samaccountname -limit 0
$pw = $res | ?{$_ -match ' \d+ +.*'}
$real = $pw | %{if($_ -match ' +(\d+) +(.+) '){New-Object psobject -Property @{'time'=$matches[1];'samaccountname'=$matches[2].trim()}}}
$real = $real | ?{$_.samaccountname -notmatch '\$'} | ?{$_.samaccountname -ne ' '}

$base = (Get-Date -Year 1601 -Month 1 -Day 1 -Hour 0 -Minute 0 -Second 0)
$time = (Get-Date -Year 2017 -Month 8 -Day 13 -Hour 0 -Minute 0 -Second 0)
$time - $base


$unforced = dsquery * -filter '(&(objectCategory=person)(objectClass=user)(!(userAccountControl:1.2.840.113556.1.4.803:=262144)))' -attr samaccountname -limit 0
$unforced = $unforced | %{$_.trim()}
$final = $real | ?{$_.time -gt ($time - $base).ticks}

$final | Sort-Object -Property time | ft

