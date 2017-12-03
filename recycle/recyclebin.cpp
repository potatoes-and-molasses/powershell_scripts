// recyclebin.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <Windows.h>
#include <ShlObj.h>

void dothings(){
	//whatever
	MessageBox(NULL,L"things are done",L"a window of information conveyance",NULL);
}
int _tmain(int argc, _TCHAR* argv[])
{
	LONG res;
	HKEY key;
	LPWSTR data=(LPWSTR)malloc(1024);
	LONG size;
	
	
	res = RegOpenKey(HKEY_CLASSES_ROOT,L"binfile\\DefaultIcon",&key);
	
	if(!res){
		RegQueryValue(key,NULL,data,&size);
		
		
		if(wcscmp(data+(size-4)/2,L"9")==0){//icon is full recycle bin
			data=L"C:\\windows\\syswow64\\imageres.dll,50";	
			
		}
		else{
			data=L"C:\\windows\\syswow64\\imageres.dll,49";
		}
		RegSetValue(key,NULL,REG_SZ,data,size);
		RegCloseKey(key);
	}
	dothings();
	SHEmptyRecycleBin(NULL,NULL,NULL);
	SHChangeNotify(SHCNE_ASSOCCHANGED,SHCNF_IDLIST,NULL,NULL);
	

	return 0;
}

