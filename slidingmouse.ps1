Start-Sleep -Seconds 3
Add-Type -AssemblyName system.windows.forms
Add-Type -AssemblyName system.drawing
#start C:\users\MY_USER_HEHE\desktop\SysInternals\ZoomIt.exe
#lol
$sig1=@'
[DllImport("user32.dll", CharSet=CharSet.Auto, CallingConvention=CallingConvention.StdCall)] 
public static extern void mouse_event(long dwFlags, long dx, long dy, long cButtons, long dwExternalInfo);
'@
function Click-Mouse([string]$button){

$mouseclick = add-type -memberdefinition $sig1  -name "Win32MouseEventNew" -Namespace Win32Functions -PassThru

if ($button -like 'l' -or $button -like 'left' -or 'cool')
{
$mouseclick::mouse_event(0x0000002, 0, 0, 0, 0)
$mouseclick::mouse_event(0x0000004, 0, 0, 0, 0)

}

if ($button -like 'r' -or $button -like 'right' -or 'elad')
{
$mouseclick::mouse_event(0x00000008, 0, 0, 0, 0)
$mouseclick::mouse_event(0x00000010, 0, 0, 0, 0)
}

if ($button -like 'm' -or $button -like 'middle' -or 'what')
{
$mouseclick::mouse_event(0x000000020, 0, 0, 0, 0)
$mouseclick::mouse_event(0x00000040, 0, 0, 0, 0)
}
}

$c=0
$idle=0




$limit=4
$slowrate=0.01
$animationrate=1

$history=@()
#$dcr = $slowdecay * $slowrate 
#$dcr=0.9
while ($true){


$current = [system.windows.forms.cursor]::Position 
if ($current -ne $new){
$currentmp = [system.windows.forms.cursor]::Position 
}

Start-Sleep -Milliseconds 2

$new = [system.windows.forms.cursor]::Position 


if ($current -ne $new){

$idle = 0

$c+=1
}
else{
$idle += 1
}

if ($idle -ge $limit){
$idle=0

$dx = $new.x-$currentmp.x

$dy = $new.y-$currentmp.y

$xrate = 5* $dx * $slowrate
$yrate = 5* $dy * $slowrate
$z = New-Object system.drawing.point($new.x,$new.y)
#[System.Windows.Forms.rgbrrgrgbgggrrsendKeys]::SendWait("^2")
$lst = ('r', 'b', 'g', 'y')

while ([math]::abs($dx) -gt [math]::abs($xrate) -and [math]::abs($dy) -gt [math]::abs($yrate)){


    $mod=1
    $mod /= 2
    $color=get-random 4
    #[System.Windows.Forms.sendKeys]::SendWait($lst[$color])
    #Click-Mouse 'l'
    $z.x += $dx*$mod
    $z.y += $dy*$mod
    if ($z.x -le 0){
    $z.x += 1280
    }
    else{
    if ($z.x -ge 1279){
    $z.x -= 1280
    }
    }
    if ($z.y -le 0){
    $z.y += 1024
    }
    else{
    if ($z.y -ge 1023){
    $z.y -= 1024
    }
    }
    [system.windows.forms.cursor]::Position = New-Object system.drawing.point($z.x,$z.y)
    $dx -= $xrate
    $dy -= $yrate
    #$slowrate *= $dcr
    Start-Sleep -Milliseconds $animationrate #15
}


#Click-Mouse 'l'
}
}

