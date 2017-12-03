

function parseacls($dn){
#for example: parseacls "OU=Apps,DC=LOL"
#returns permissions on an AD object in a nice powershell format
#kinda slow because dsacls.exe is slow... but what can you do:(
$badformat = (dsacls.exe $dn)
foreach($i in 1..$badformat.length){
    $obj = New-Object psobject -Property @{'Type'='';'Group'='';'Permissions'=''}
    if($badformat[$i] -match 'Permissions inherited to subobjects are:'){#part2 inheritable..
        break
    }
    if($badformat[$i] -match 'Allow (.*)'){
        $obj.type = 'Allow'
        
        
    }

    else{
        if($badformat[$i] -match 'Deny (.*)'){
            $obj.type = 'Deny'
            
        }
        else{
            continue;
        }
    }
    $maybegroupname = $matches[1]
    if($maybegroupname -match '(.*?)\s\s+(.*)'){
        
        $obj.group = $matches[1]
        $obj.permissions = ($matches[2] -replace ' {2,}','')+ ';'
    }
    else{
        $obj.group = $maybegroupname
    }
    $c = 1;
    while($badformat[$i+$c][0] -eq ' '){
        #$temp = $badformat[$i+$c]
        
        
        $obj.permissions = $obj.permissions + ($badformat[$i+$c] -replace ' {2,}','')+ ';'
        $c++;
        
    }
    $obj


    
}

}

