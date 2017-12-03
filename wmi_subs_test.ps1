$query = "select * from __instanceoperationevent within 2 where targetinstance isa 'CIM_DataFile' and targetinstance.drive='C:' and targetinstance.path='\\wmitest\\'"
Register-WmiEvent -Query $query -Action {Write-Host 1;$EventArgs.NewEvent.TargetInstance.name;[io.file]::WriteAllText('C:\users\MY_USER_HEHE\desktop\resultserialize',[System.Management.Automation.PSSerializer]::Serialize($EventArgs))} -MessageData $obj -SourceIdentifier 'mytest'

#Unregister-Event -SourceIdentifier mytest
#$b = [System.Management.Automation.PSSerializer]::Deserialize([io.file]::ReadAllText('C:\users\MY_USER_HEHE\desktop\resultserialize'))