# LYNLive

## 프로젝트 개요
이 프로젝트는 [BITLive/BITLive_win](https://github.com/Plainbit/BITLive)에서 제공하는 원본 프로그램을 기반으로,  
Windows 11과의 호환성을 개선하고, 실행 로그 및 오류 처리 기능을 추가하는 등의 개선을 진행한 버전입니다.

## 개선 사항
본 프로젝트에서는 다음과 같은 개선이 이루어졌습니다:
- **Windows 11 지원 추가**: Windows 11을 감지하고, 적절한 실행 파일을 사용하도록 개선
- **로그 기능 추가**: 실행된 프로그램 및 오류를 기록하는 로깅 기능 추가
- **오류 처리 강화**: 기존 스크립트에서 발생할 수 있는 오류를 방지하기 위한 예외 처리 추가
- **비호환 프로그램 정리**: Windows 11에서 실행되지 않는 일부 도구를 제외하거나 대체

## 사용 방법
1. `BITLive_win.bat`을 **관리자** 권한으로 실행하세요.
2. 로그 파일은 `logs/` 폴더에 저장됩니다.
3. Windows 11 환경에서 실행되면 `OS-win11/` 디렉토리의 도구가 사용됩니다.

## 원본 프로젝트 출처
- Original repository: [BITLive/BITLive_win](https://github.com/Plainbit/BITLive)

## 사용한 툴
### mandiant, https://www.fireeye.com/services/freeware/memoryze.html
	Memoryze
	
### microsoft
	tlist, http://msdn.microsoft.com/en-us/library/windows/hardware/ff558901(v=vs.85).aspx
	uptime, http://support.microsoft.com/kb/232243
	
### nirsoft, https://www.nirsoft.net/utils/index.html
	BrowserAddonsView
	BrowsingHistoryView
	BulletsPassView
	ChromePass
	cports
	CProcess
	DriverView
	ExecutedProgramsList
	iepv
	InjectedDLL
	InstalledPackagesView
	LastActivityView
	LoadedDllsView
	mailpv
	mspass
	MyLastSearch
	netpass
	NetRouteView
	NetworkInterfacesView
	NetworkOpenedFiles
	NetworkUsageView
	OpenedFilesView
	OpenSaveFilesView
	PasswordFox
	rdpv
	RegDllView
	TaskSchedulerView
	TurnedOnTimesView
	UninstallView
	URLProtocolView
	WebBrowserPassView
	WifiHistoryView
	WifiInfoView
	WinLogOnView
	WinUpdatesView
	WirelessKeyView
	WirelessNetView
	
### sysinternals, https://docs.microsoft.com/en-us/sysinternals/downloads/
	autorunsc
	handle
	listdlls
	logonsessions
	psinfo
	pslist
	psloggedon
	psservice
	tcpvcon
	
### unxutils, http://unxutils.sourceforge.net/
	mkdir
	pclip

### velocidex, https://winpmem.velocidex.com/
	winpmem
	
### vidstromlabs, https://vidstromlabs.com/freetools/
	gplist
	
### winfingerprint
	procinterrogate, http://winfingerprint.sourceforge.net/wininterrogate.php
	
### other
	forecopy_handy, https://code.google.com/p/proneer/downloads/list
	md5deep, http://md5deep.sourceforge.net/
	dd, http://www.chrysocome.net/dd

## 라이선스 (License)
이 프로젝트는 [BITLive/BITLive_win](https://github.com/Plainbit/BITLive) 프로젝트를 기반으로 수정된 버전이며,  
사용된 도구들의 라이선스는 각 도구의 공식 웹사이트를 참고하시기 바랍니다.  
