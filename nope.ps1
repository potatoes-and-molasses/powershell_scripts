param(
[string]$cmd
)

$lol=[reflection.assembly]::LoadWithPartialName('system.windows.forms')
$lol=[reflection.assembly]::LoadWithPartialName('system.drawing')




function screenxd(){

$sig1=@'
[DllImport("user32.dll", CharSet=CharSet.Auto)] 
public static extern IntPtr SendMessage(IntPtr hWnd, UInt32 Msg,IntPtr wParam, IntPtr lParam);
'@
$sc = add-type -memberdefinition $sig1  -name "Cool" -Namespace Win32Functions -PassThru
$sc::SendMessage(0xffff,0x0112,0xf170,0x0002)

}






function Move-Mouse([int]$x,[int]$y){
[System.Windows.Forms.cursor]::Position=New-Object system.drawing.point($x,$y)
}

function Click-Mouse([string]$button){
$sig1=@'
[DllImport("user32.dll", CharSet=CharSet.Auto, CallingConvention=CallingConvention.StdCall)] 
public static extern void mouse_event(long dwFlags, long dx, long dy, long cButtons, long dwExternalInfo);
'@
$mouseclick = add-type -memberdefinition $sig1  -name "Win32MouseEventNew" -Namespace Win32Functions -PassThru

if ($button -like 'l' -or $button -like 'left' -or 'cool')
{
$mouseclick::mouse_event(0x0000002, 0, 0, 0, 0)
Move-Mouse 0 0
$mouseclick::mouse_event(0x0000004, 0, 0, 0, 0)

}

if ($button -like 'r' -or $button -like 'right')
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



function screenshot([string]$folder){

$screensize = ([system.windows.forms.screen]::PrimaryScreen).bounds
$p = New-Object drawing.pen red

$size = [drawing.rectangle]::fromltrb(0,0,$screensize.width,$screensize.height)
$mousepos = [System.Windows.Forms.cursor]::Position
$bitmap = New-Object drawing.bitmap $size.width, $size.height
$graphics = [drawing.graphics]::FromImage($bitmap)
$graphics.copyfromscreen($size.location,[drawing.point]::empty, $size.size)
$rec = $graphics.DrawEllipse($p,$mousepos.x-5,$mousepos.y-5,10,10)
$fname = $folder+"/x="+$mousepos.x+",y="+$mousepos.y+".gif"
$tempname = 'C:\users\public\Pictures\temp.gif'
$bitmap.save($tempname, [system.drawing.imaging.imageformat]::Gif)
move-Item $tempname $fname
$graphics.dispose()
$bitmap.dispose()

}

function sendkeys([string]$keys){
#~=enter
$keys | %{[system.windows.forms.sendkeys]::SendWait($_); Start-Sleep -Milliseconds 5}
}


if($cmd){
iex $cmd
}




