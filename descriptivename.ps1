




function gettasks([string]$current)
{
$tasks = @()
$test.GetFolder("$current").gettasks(0) | %{$x = [xml]$_.xml;$tasks += New-Object psobject -Property @{"Name" = $_.Name
"Path" = $_.Path
"Enabled" = $_.Enabled
"NextRunTime" = $_.NextRunTime
"Command" = ($x.task.actions.exec | %{"$($_.command) $($_.arguements)"}) -join "`n"

}}
$test.GetFolder("$current").getfolders(0) |%{gettasks $_.path} 

$tasks
}
function get-scheduledtasks([string]$computer,[string]$location='\'){

$test = New-Object -ComObject "Schedule.Service"
$test.Connect("$computer")
$a = gettasks -current "$location"
$a
}

function get-badtasks([string]$computer){
$a = get-scheduledtasks $computer
$a | ?{$_.command[0] -ne '"' -and $_.command -match ".* .*\."}

}


function testwrite([string]$path){
try{
[io.file]::openwrite("$path\temp123temp").close()
1
Remove-Item -Force "$path\temp123temp"
}
catch{
0
}
}

function get-badservices([string]$computer)
{
$s = Get-WmiObject -ComputerName $computer -Query 'select * from win32_service'
$s | ?{$_.pathname[0] -ne '"' -and $_.pathname -match ".* .*\."} | %{New-Object psobject -Property @{"Name"=$_.name
"Path"=$_.pathname}}

}



