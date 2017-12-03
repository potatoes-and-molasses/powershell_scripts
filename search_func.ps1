function findmatches($folder,$regex){
"searching for `"$regex`" in $folder..."
gci $folder -Recurse | %{$filename=$_.fullname;gc $filename -ea si | %{if($_ -match $regex){$filename}} | group | select name, count}
}

#findmatches 'C:\users\public' 'trollololol'