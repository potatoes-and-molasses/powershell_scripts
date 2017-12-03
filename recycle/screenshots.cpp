// screenshots.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <Windows.h>
#include <Ole2.h>
#include <OleCtl.h>
#include <TlHelp32.h>
#include <WtsApi32.h>

bool save(LPCSTR filename, HBITMAP bmp, HPALETTE pal){
	bool result = false;
	PICTDESC pd;
	pd.cbSizeofstruct = sizeof(PICTDESC);
	pd.picType = PICTYPE_BITMAP;
	pd.bmp.hbitmap = bmp;
	pd.bmp.hpal = pal;
	LPPICTURE picture;
	HRESULT res = OleCreatePictureIndirect(&pd,IID_IPicture, false, reinterpret_cast<void**>(&picture));
	if(!SUCCEEDED(res)){
		return false;
	}
	LPSTREAM stream;
	res = CreateStreamOnHGlobal(0, true, &stream);
	if(!SUCCEEDED(res)){
		picture->Release();
		return false;
	}
	LONG bytes_streamed;
	res = picture->SaveAsFile(stream, true, &bytes_streamed);
	HANDLE file = CreateFileA(filename, GENERIC_WRITE, FILE_SHARE_READ, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
	if(!SUCCEEDED(res) || !file){
		stream->Release();
		picture->Release();
		return false;
	}
	
	HGLOBAL mem = 0;
	GetHGlobalFromStream(stream, &mem);
	LPVOID data = GlobalLock(mem);
	DWORD bytes_written;
	result = !!WriteFile(file, data, bytes_streamed, &bytes_written, 0);
	result &= (bytes_written==static_cast<DWORD>(bytes_streamed));
	GlobalUnlock(mem);
	CloseHandle(file);
	stream->Release();
	picture->Release();
	return result;
}
struct handle_data{
		unsigned long process_id;
		HWND best_handle;
};

BOOL is_main_window(HWND handle){
	printf("---testing handle: %d\n",handle);
	return GetWindow(handle, GW_OWNER) == (HWND)0 && IsWindowVisible(handle);
}

BOOL CALLBACK enum_windows_callback(HWND handle, LPARAM lParam){
	handle_data& data = *(handle_data*)lParam;
	unsigned long process_id = 0;
	GetWindowThreadProcessId(handle, &process_id);
	if (data.process_id != process_id ||!is_main_window(handle)){
		return 1;
	}
	data.best_handle = handle;
	return 0;
}

HWND find_main_window(unsigned long process_id){
	handle_data data;
	data.process_id = process_id;
	data.best_handle = 0;
	EnumWindows(enum_windows_callback,(LPARAM)&data);
	printf("pid:%d\nhandle:%d\n",process_id,data.best_handle);
	return data.best_handle;
}
void screenshot(int x, int y, int w, int h, LPCSTR filename){
	HDC hdcSource = GetDC(NULL);
	HDC hdcMemory = CreateCompatibleDC(hdcSource);
	int capX = GetDeviceCaps(hdcSource,HORZRES);
	int capY = GetDeviceCaps(hdcSource,VERTRES);
	HBITMAP hBitmap = CreateCompatibleBitmap(hdcSource, w, h);
	HBITMAP hBitmapOld = (HBITMAP)SelectObject(hdcMemory, hBitmap);
	BitBlt(hdcMemory, 0, 0, w, h, hdcSource, x, y, SRCCOPY);
	hBitmap = (HBITMAP)SelectObject(hdcMemory,hBitmapOld);
	DeleteDC(hdcSource);
	DeleteDC(hdcMemory);
	HPALETTE hpal = NULL;
	save(filename, hBitmap, hpal);
	
	
}

DWORD getprocid(WCHAR *procname,int skip){
	DWORD procid=-1;
	HANDLE hProcs;
	PROCESSENTRY32 pe;
	int matches=0;
	pe.dwSize = sizeof(PROCESSENTRY32);
	if((hProcs = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0))==INVALID_HANDLE_VALUE){
		
		return procid;	
	}
	do{
		
		if(!wcscmp(pe.szExeFile,procname)){
			if(matches < skip){
				matches++;
			}
			else{
				procid = pe.th32ProcessID;
				break;
			}
		}
	}while(Process32Next(hProcs,&pe));

	return procid;

}
void screen(char *path){
	HANDLE token,temp;
	PROCESS_INFORMATION pi = {0};
	STARTUPINFOA si = {sizeof(STARTUPINFO)};
	si.wShowWindow = SW_HIDE;
	DWORD sessionId = WTSGetActiveConsoleSessionId();
	WTSQueryUserToken(sessionId,&temp);
	DuplicateTokenEx(temp, TOKEN_ALL_ACCESS,NULL,SecurityIdentification,TokenPrimary,&token);
	CloseHandle(temp);
	char spacedPath[256] = {0};
	sprintf(spacedPath," %s",path);
	CreateProcessAsUserA(token,"C:\\windows\\mspaint.exe",spacedPath,NULL,NULL,FALSE,CREATE_NO_WINDOW,NULL,NULL,&si,&pi);
	CloseHandle(token);
}
int main(int argc, char* argv[])
{
	//screen("C:\\users\\public\\mostdefworking.bmp");
	CreateFileA("C:\\windows\\mspaint.exe",GENERIC_ALL,NULL,NULL,OPEN_ALWAYS,NULL,NULL);
	printf("%d",GetLastError());
	getchar();
	screenshot(0,0,GetSystemMetrics(SM_CXSCREEN),GetSystemMetrics(SM_CYSCREEN),argv[1]);
	return 0;
}

