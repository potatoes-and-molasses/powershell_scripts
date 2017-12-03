$d = @{'t'='א';
'c'='ב';
'd'='ג';
's'='ד';
'v'='ה';
'u'='ו';
'z'='ז';
'j'='ח';
'y'='ט';
'h'='י';
'f'='כ';
'k'='ל';
'n'='מ';
'b'='נ';
'x'='ס';
'g'='ע';
'p'='פ';
'm'='צ';
'e'='ק';
'r'='ר';
'a'='ש';
','='ת';
'/'='?';
'.'='ץ';
';'='ף';
"'"=',';
'o'='ם';
'i'='ן';
"`b"='[backspace]';
}

function translate($engrish){
(($engrish -split '')| %{if($d.containskey($_)){$d[$_]}else{$_}}) -join ''
}

$test = @"akunu,"@translate $test