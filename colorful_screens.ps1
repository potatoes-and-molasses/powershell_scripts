

$things = @"
using System;
using System.Collections.Generic;
using System.Collections;
using System.Runtime.InteropServices;
using System.Threading;

namespace somethingsomething
{
public class Cool
{
    [DllImport("Gdi32.dll")]
    public static extern bool SetDeviceGammaRamp(IntPtr hDC, ref RAMP lpRamp);

    [DllImport("User32.dll")]
    public static extern IntPtr GetDC(IntPtr hWnd);

    [DllImport("User32.dll")]
    public static extern bool ReleaseDC(IntPtr hWnd, IntPtr hDC);

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Ansi)]
    public struct RAMP
    {
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 256)]
        public UInt16[] Red;
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 256)]
        public UInt16[] Green;
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 256)]
        public UInt16[] Blue;
    }

    public static bool SetColor(int r, int g, int b)
    {
        RAMP ramp = new RAMP();

        ramp.Red = new ushort[256];
        ramp.Green = new ushort[256];
        ramp.Blue = new ushort[256];
        for (int i = 0; i < 256; i++)
        {
          
            ramp.Red[i] = (ushort)(Math.Min(0xffff,i * (r + 128)));
            ramp.Green[i] = (ushort)(Math.Min(0xffff,i * (g + 128)));
            ramp.Blue[i] = (ushort)(Math.Min(0xffff,i * (b + 128)));
        }
        IntPtr dc = GetDC(IntPtr.Zero);
        bool res = SetDeviceGammaRamp(dc, ref ramp);
        ReleaseDC(IntPtr.Zero, dc);
        return res;

    }
    
    public static bool veryrandom()
    {
        RAMP ramp = new RAMP();
        
        ramp.Red = new ushort[256];
        ramp.Green = new ushort[256];
        ramp.Blue = new ushort[256];
        
        Random rnd = new Random();
        for (int i = 0; i < 256; i++)
        {
          
            ramp.Red[i] = (ushort)(i*(128+rnd.Next(0,0x80)));
            ramp.Green[i] = (ushort)(i*(128+rnd.Next(0,0x80)));
            ramp.Blue[i] = (ushort)(i*(128+rnd.Next(0,0x80)));
        }
        IntPtr dc = GetDC(IntPtr.Zero);
        bool res = SetDeviceGammaRamp(dc, ref ramp);
        ReleaseDC(IntPtr.Zero, dc);
        return res;

    }
    
    public static void Main(string[] args)
    {
     
        
     
        return;
          
    }
}

}
"@

add-type -TypeDefinition $things
function re(){[somethingsomething.cool]::SetColor(128,128,128)}

function red([int]$sleep){

$lol = (0..64)+(64..0)


$lol | %{$nl = [somethingsomething.cool]::SetColor(128+$_*2,128-$_*2,128-$_*2);if($sleep){Start-Sleep -milliseconds $sleep}}

}



function green([int]$sleep){

$lol = (0..64)+(64..0)


$lol | %{$nl = [somethingsomething.cool]::SetColor(128-$_*2,128+$_*2,128-$_*2);if($sleep){Start-Sleep -milliseconds $sleep}}

}

function blue([int]$sleep){

$lol = (0..64)+(64..0)


$lol | %{$nl = [somethingsomething.cool]::SetColor(128-$_*2,128-$_*2,128+$_*2);if($sleep){Start-Sleep -milliseconds $sleep}}

}

function black([int]$sleep){
$lol = (0..64)+(64..0)


$lol | %{$nl = [somethingsomething.cool]::SetColor(128-$_*2,128-$_*2,128-$_*2);if($sleep){Start-Sleep -milliseconds $sleep}}


}

function white([int]$sleep){
$lol = (0..64)+(64..0)


$lol | %{$nl = [somethingsomething.cool]::SetColor(128+$_*2,128+$_*2,128+$_*2);if($sleep){Start-Sleep -milliseconds $sleep}}


}

function randombrightness([int]$sleep){

$lol | %{$nl = [somethingsomething.cool]::SetColor(((0..255) | get-random),((0..255) | get-random),((0..255) | get-random));if($sleep){Start-Sleep -milliseconds $sleep}}

}

function reallyrandom([int]$sleep){

$nl = [somethingsomething.cool]::veryrandom();Start-Sleep -milliseconds $sleep
}

