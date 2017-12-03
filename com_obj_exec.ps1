$a = [type]::gettypefromclsid('9ba05972-f6a8-11cf-a442-00a0c90a8f39','127.0.0.1')
$b = [system.activator]::createinstance($a)
$c = $b.item().document.application
#$c.ShellExecute("cmd.exe","/c calc.exe","C:\windows\system32",$null,0)
while(1){
$pos = [System.Windows.Forms.cursor]::Position
if ($pos.x -lt 640 -and $pos.y -lt 512){
    $c.TileHorizontally()
}
else {if($pos.x -gt 640 -and $pos.y -gt 512){
    $c.TileHorizontally()#
}else{
$c.TileVertically()
}}

}

function build($clsid){
$a = [type]::gettypefromclsid($clsid)
$b = [system.activator]::createinstance($a)
return $b
}

$stuff = gc .\test.loglog
$st = $stuff | %{build($_)}
$stf = $st  | ?{($_ | gm).count -gt 6}
$very = $st | ?{($_ | gm).count -gt 7}
