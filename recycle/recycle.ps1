$keyname="Microsoft.Windows.Binfile"
$exepath = "C:\Users\lol\Documents\Visual Studio 2012\Projects\recyclebin\Debug\recyclebin.exe"
$fullrecycleicon = 'C:\windows\syswow64\imageres.dll,49'
New-PSDrive -name HKCR -PSProvider registry -Root HKEY_CLASSES_ROOT

Set-ItemProperty "HKCR:\.bin\" -Name '(Default)' -Value $keyname
New-Item "HKCR:\$keyname"
New-Item "HKCR:\$keyname\DefaultIcon"
New-Item "HKCR:\$keyname\shell"
New-Item "HKCR:\$keyname\shell\Empty Recycle Bin"
New-Item "HKCR:\$keyname\shell\Empty Recycle Bin\command"
New-Item "HKCR:\$keyname\shell\Open"
New-Item "HKCR:\$keyname\shell\Open\command"


Set-ItemProperty -path "HKCR:\$keyname\DefaultIcon" -Name '(Default)' -Value $fullrecycleicon
Set-ItemProperty -path "HKCR:\$keyname\Empty Recycle Bin" -Name 'Icon' -Value $fullrecycleicon
Set-ItemProperty -path "HKCR:\$keyname\Empty Recycle Bin\command" -Name '(Default)' -Value $exepath
Set-ItemProperty -path "HKCR:\$keyname\open\command" -Name '(Default)' -Value 'cmd /c start shell:recyclebinfolder'



