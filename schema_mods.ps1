ipmo ac*

function new-oid{
    
    $prefix = "1.2.840.113556.1"
    $guid = [system.guid]::NewGuid().guid
    $parts = @(0,4,9,14,19,24,30) | %{[uint64]::Parse($guid.substring($_,4),'AllowHexSpecifier')}
    $prefix+'.'+($parts -join '.')
}

$attributes = @{
lDAPDisplayName = 'msExchAddressListData';
attributeId = (new-oid);
oMSyntax = 64;
attributeSyntax = "2.5.5.12";
isSingleValued = $true;
searchflags = 1;
adminDescription = 'ms-Exch-Address-List-Data';
showInAdvancedViewOnly = $true;
}
$schema = (Get-ADRootDSE).schemaNamingContext

#creating attribute and adding it to an object class.
New-ADObject -Name "ms-Exch-Address-List-Data" -Type attributeSchema -Path $schema -OtherAttributes $attributes -Server DC_SERVER
$a = Get-ADObject -SearchBase $schema -Filter 'name -eq "Organizational-Unit"'
$a | Set-ADObject -Server DC_SERVER -Add @{mayContain = 'msExchAddressListData'} 

#and no permissions for this...(yet)
Get-ADObject -SearchBase $schema -Filter 'name -eq "ms-Exch-Address-List-Data"'
Get-ADObject  "SOME_OU" | Set-ADObject -Add @{msExchAddressListData = 'test'}

#setting default sddl on an object class 
#added to - group-policy-container, user, computer, organizational-unit, group
$a = Get-ADObject -SearchBase $schema -Server DC_SERVER -Filter 'name -eq "Group"' -Properties *
$sid = (Get-ADGroup MYGROUP).sid.value
$newsd = $a.defaultSecurityDescriptor + "(A;;RPWPCRCCDCLCLORCWOWDSDDTSW;;;$sid)"
$a | Set-ADObject -Server DC_SERVER -Replace @{defaultSecurityDescriptor=$newsd}
