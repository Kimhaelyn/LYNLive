@echo off
cls
title LYNLive Forensic Shell
prompt $T$S$P$G$S

echo ------------------------------------------------- 
echo             NYLEAH Live Response Kit v1.7       
echo ------------------------------------------------- 

:: -----------------------------------------------------
:: VARIABLEs
:: -----------------------------------------------------
set _CPU=""
set _CASE=""
set _EXAMINER=""
set _OSARCH=""
set _CASE_DIR=""
set _TARGET_DIR=""

set _NOWTIME=""
set _IS_MEMORY=""
set _IS_NONVOLATILE=""
set _IS_PACKET=""
set _MD5=""
set _LOG=""

:: -----------------------------------------------------
:: Check the windows version
:: -----------------------------------------------------

:: Get the Windows version number
for /f "tokens=2 delims=[]" %%i in ('ver') do set VERSION=%%i
for /f "tokens=2-3 delims=. " %%i in ("%VERSION%") do set VERSION=%%i.%%j

set "OS_CAPTION=%OS_CAPTION:~1%"

:: Handle versions from 5.0 to 6.3 as per the initial script
if "%VERSION%" == "5.00" if "%VERSION%" == "5.0" echo Windows 2000 is not supported! 
if "%VERSION%" == "5.1" (
	echo - OS: Windows XP
	set PATH=0S-winxp\;
	GOTO:CPU_TYPE
)
if "%VERSION%" == "5.2" (
	echo Windows Server 2003
	set PATH=0S-win2k3\;
	GOTO:CPU_TYPE
)
if "%VERSION%" == "6.0" (
	echo Windows Vista or Windows Server 2008
	set PATH=0S-winvista\;
	GOTO:CPU_TYPE
)
if "%VERSION%" == "6.1" (
	echo Windows 7 or Windows Server 2008 R2
	set PATH=0S-win7\;
	GOTO:CPU_TYPE
)
if "%VERSION%" == "6.2" (
	echo Windows 8
	set PATH=0S-win8\;
	GOTO:CPU_TYPE
)
if "%VERSION%" == "6.3" (
	echo Windows 8.1
	set PATH=0S-win8\;
	GOTO:CPU_TYPE
)

:: Handle Windows 10 and Windows 11
for /f "tokens=2 delims==" %%k in ('wmic os get Caption /value') do set OS_NAME=%%k
:: set OS_NAME=%OS_NAME:~10%

:: Check for Windows 10
if not "%OS_NAME%" == "%OS_NAME:Windows 10=%" (
    echo - OS: Windows 10
    set PATH=0S-win10\;
    GOTO:CPU_TYPE
)

:: Check for Windows 11
if not "%OS_NAME%" == "%OS_NAME:Windows 11=%" (
    echo - OS: Windows 11
    set PATH=0S-win11\;
    GOTO:CPU_TYPE
)

GOTO:END

:: -----------------------------------------------------
:: Check the CPU Architecture
:: -----------------------------------------------------
:CPU_TYPE
if /i "%PROCESSOR_ARCHITECTURE:~-2%"=="86" (
	echo - CPU: 32 bit
	set PATH=%PATH%nirsoft\;sysinternals\;
)
if /i "%PROCESSOR_ARCHITECTURE:~-2%"=="64" (
	echo - CPU: 64 bit
	set PATH=%PATH%x64\nirsoft\;x64\sysinternals\;
)

echo - Username: %username%
echo - Computername: %computername%

:: PATH RESET
set PATH=%PATH%mandiant\;microsoft\;others\;unxutils\;velocidex\;vidstromlabs\;winfingerprint\;wireshark\;
echo.
	
:: -----------------------------------------------------
:: Enter the case name
:: -----------------------------------------------------
:ENTER_CASE
	set /p _CASE=# Please enter the case name : || GOTO:ENTER_CASE

:: -----------------------------------------------------
:: Create CASE directory
:: -----------------------------------------------------
	set _CASE_DIR=%~d0\%_CASE%
	if not exist %_CASE_DIR% mkdir %_CASE_DIR%
	echo - Case Root: %_CASE_DIR%
	echo.
	
:: -----------------------------------------------------
:: Enter the examiner name
:: -----------------------------------------------------
:ENTER_EXAMINER
	set /p _EXAMINER=# Please enter the examiner's name : || GOTO:ENTER_EXAMINER
	echo - Examiner: %_EXAMINER%
	echo.
	
:: -----------------------------------------------------
:: Check whether physical memory is acquire or not...
:: -----------------------------------------------------
:ACQUIRE_MEMORY
	set /p _IS_MEMORY=# Do you want to acquire physical memory? (y or n) || GOTO:ACQUIRE_MEMORY
	if /i "%_IS_MEMORY%" == "Y" GOTO:ACQUIRE_NONVOLATILE
	if /i "%_IS_MEMORY%" == "N" GOTO:ACQUIRE_NONVOLATILE
	GOTO:ACQUIRE_MEMORY

:: -----------------------------------------------------
:: Check whether non-volatile data is acquire or not...
:: -----------------------------------------------------
:ACQUIRE_NONVOLATILE
	set /p _IS_NONVOLATILE=# Do you want to acquire Non-volatile data? (y or n) || GOTO:ACQUIRE_NONVOLATILE
	if /i "%_IS_NONVOLATILE%" == "Y" GOTO:START
	if /i "%_IS_NONVOLATILE%" == "N" GOTO:START
	GOTO:ACQUIRE_NONVOLATILE

:START
echo.
:: -----------------------------------------------------
:: Create TARGET directory (using current time)
:: -----------------------------------------------------
	set _TIME=%TIME::=%
	set _NOWTIME=%DATE%_%_TIME%
	set _TARGET_DIR=%_CASE_DIR%\%COMPUTERNAME%
	if not exist %_TARGET_DIR% mkdir %_TARGET_DIR%

:: -----------------------------------------------------
:: Create LOG file
:: -----------------------------------------------------
	set _LOG=%_TARGET_DIR%\LYNLive_win.log
	if not exist %_LOG% (
	echo ************************************************* > %_LOG%
	echo *         NYLEAH Live Response Kit v1.7       * >> %_LOG%
	echo ************************************************* >> %_LOG%
	echo CASE : %_CASE% >> %_LOG%
	echo EXAMINER : %_EXAMINER% >> %_LOG%
	echo START TIME : %DATE% %TIME% >> %_LOG%
	echo. >> %_LOG%
)

:: -----------------------------------------------------
:: FIRST OF ALL, Acquire PREFETCH files and RecentFileCache.bcf, Amcache.hve
:: -----------------------------------------------------
	echo.
	echo ## FIRST OF ALL, START ACQUIRING PREFETCH AND RECENTFILECACHE
	set _NONVOLATILE_DIR=%_TARGET_DIR%\non_volatile
	mkdir %_NONVOLATILE_DIR%
	echo Created "non_volatile" directory in %_TARGET_DIR%\
	echo Created "non_volatile" directory in %_TARGET_DIR%\ >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo # Prefetch, Superfetch                    >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring Prefetch files ...
	echo %DATE% %TIME% [Start] Acquiring Prefetch files ... >> %_LOG%
	forecopy_handy -p %_NONVOLATILE_DIR%
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring Prefetch files ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring Prefetch files ... >> %_LOG%
	)

	set _APPCOMPAT_DIR=%_NONVOLATILE_DIR%\appcompat
	mkdir %_APPCOMPAT_DIR%
	echo ----------------------------------------- >> %_LOG%
	echo # RecentFileCache.bcf, Amcache.hve        >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring RecentFileCache.bcf, Amcache.hve ...
	echo %DATE% %TIME% [Start] Acquiring RecentFileCache.bcf, Amcache.hve ... >> %_LOG%
	forecopy_handy -r "%SystemRoot%\AppCompat\Programs" %_APPCOMPAT_DIR%
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring RecentFileCache.bcf, Amcache.hve ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring RecentFileCache.bcf, Amcache.hve ... >> %_LOG%
	)
	
:: -----------------------------------------------------
:: Acquire VOLATILE data 
:: -----------------------------------------------------
	set _VOLATILE_DIR=%_TARGET_DIR%\volatile
	mkdir %_VOLATILE_DIR%
	echo.
	echo ## START ACQUIRING VOLATILE
	echo Created "volatile" directory in %_TARGET_DIR%\
	echo Created "volatile" directory in %_TARGET_DIR%\ >> %_LOG%

:: NETWORK INFORMATION
	echo ----------------------------------------- >> %_LOG%
	echo # NETWORK INFORMATION                     >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	set _NETWORK_DIR=%_VOLATILE_DIR%\network_information
	mkdir %_NETWORK_DIR%
	echo.
	echo # START ACQUIRING NETWORK INFORMATION
	echo Created "network_information" directory in %_VOLATILE_DIR%\
	echo Created "network_information" directory in %_VOLATILE_DIR%\ >> %_LOG%

	echo %DATE% %TIME% - Acquiring arp cache table ...
	echo %DATE% %TIME% [Start] Acquiring arp cache table ... >> %_LOG%
	arp -a > %_NETWORK_DIR%\arp-a.txt
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring arp cache table ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring arp cache table ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring network Status ...
	echo %DATE% %TIME% [Start] Acquiring network Status ... >> %_LOG%
	netstat -nao > %_NETWORK_DIR%\netstat-nao.txt
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring network Status ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring network Status ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring routing Table ...
	echo %DATE% %TIME% [Start] Acquiring routing Table ... >> %_LOG%
	route PRINT > %_NETWORK_DIR%\route_PRINT.txt
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring routing Table ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring routing Table ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring currently opened TCP/IP and UDP ports ...
	echo %DATE% %TIME% [Start] Acquiring currently opened TCP/IP and UDP ports ... >> %_LOG%
	cports /scomma %_NETWORK_DIR%\cports.csv
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring currently opened TCP/IP and UDP ports ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring currently opened TCP/IP and UDP ports ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring url protocols ...
	echo %DATE% %TIME% [Start] Acquiring url protocols ... >> %_LOG%
	urlprotocolview /stext %_NETWORK_DIR%\urlprotocolview.txt
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring url protocols ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring url protocols ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring network connected sessions ...
	echo %DATE% %TIME% [Start] Acquiring network connected sessions ... >> %_LOG%
	net sessions > %_NETWORK_DIR%\net_sessions.txt
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring network connected sessions ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring network connected sessions ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring network opened files ...
	echo %DATE% %TIME% [Start] Acquiring network opened files ... >> %_LOG%
	net file > %_NETWORK_DIR%\net_file.txt
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring network opened files ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring network opened files ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring network shared information ...
	echo %DATE% %TIME% [Start] Acquiring network shared information ... >> %_LOG%
	net share > %_NETWORK_DIR%\net_share.txt
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring network shared information ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring network shared information ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring NBT cache ...
	echo %DATE% %TIME% [Start] Acquiring NBT cache ... >> %_LOG%
	nbtstat -c > %_NETWORK_DIR%\nbtstat-c.txt
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring NBT cache ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring NBT cache ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring NBT sessions ...
	echo %DATE% %TIME% [Start] Acquiring NBT sessions ... >> %_LOG%
	nbtstat -s > %_NETWORK_DIR%\nbtstat-s.txt
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring NBT sessions ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring NBT sessions ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring All endpoints information ...
	echo %DATE% %TIME% [Start] Acquiring All endpoints information ... >> %_LOG%
	tcpvcon -a -c /accepteula > %_NETWORK_DIR%\tcpvcon-a-c.txt
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring All endpoints information ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring All endpoints information ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring list of all files that are currently opened by other computers ...
	echo %DATE% %TIME% [Start] Acquiring list of all files that are currently opened by other computers ... >> %_LOG%
	networkopenedfiles /scomma %_NETWORK_DIR%\networkopenedfiles.csv
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring list of all files that are currently opened by other computers ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring list of all files that are currently opened by other computers ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring history of connections to wireless networks ...
	echo %DATE% %TIME% [Start] Acquiring history of connections to wireless networks ... >> %_LOG%
	wifihistoryview /scomma %_NETWORK_DIR%\wifihistoryview.txt
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring history of connections to wireless networks ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring history of connections to wireless networks ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring the activity of wireless networks ...
	echo %DATE% %TIME% [Start] Acquiring the activity of wireless networks ... >> %_LOG%
	wirelessnetview /scomma %_NETWORK_DIR%\wirelessnetview.csv
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring the activity of wireless networks ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring the activity of wireless networks ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring the list of all routes on current network ...
	echo %DATE% %TIME% [Start] Acquiring the list of all routes on current network ... >> %_LOG%
	netrouteview /scomma %_NETWORK_DIR%\netrouteview.csv
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring the list of all routes on current network ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring the list of all routes on current network ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring the network usage information stored in the SRUDB.dat database of Windows 8 and Windows 10 ...
	echo %DATE% %TIME% [Start] Acquiring the network usage information stored in the SRUDB.dat database of Windows 8 and Windows 10 ... >> %_LOG%
	networkusageview /scomma %_NETWORK_DIR%\networkusageview.csv
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring the network usage information stored in the SRUDB.dat database of Windows 8 and Windows 10 ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring the network usage information stored in the SRUDB.dat database of Windows 8 and Windows 10 ... >> %_LOG%
	)
	
:: PHYSICAL MEMORY
	if /i "%_IS_MEMORY%" == "N" GOTO:PROCESS
	echo ----------------------------------------- >> %_LOG%
	echo # PHYSICAL MEMORY                         >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	set _MEMORY_DIR=%_TARGET_DIR%\memory
	mkdir %_MEMORY_DIR%
	echo.
	echo ## START ACQUIRING PHYSICAL MEMORY
	echo Created "memory" directory in %_TARGET_DIR%\ >> %_LOG%
	echo %DATE% %TIME% - Acquiring physical memory ...
	echo %DATE% %TIME% [Start] Acquiring physical memory ... >> %_LOG%
	winpmem_mini_x64_rc2.exe -2 %_MEMORY_DIR%\winpmem_dump.raw
	echo %ERRORLEVEL%
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring physical memory ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring physical memory ... >> %_LOG%
	)

	::
	:: MANDIANT MEMORIZE
	:: echo ^<?xml version=^"1.0^" encoding=^"utf-8^"?^> > %_MEMORY_DIR%\config.txt
	:: echo ^<script xmlns:xsi=^"http://www.w3.org/2001/XMLSchema-instance^" xmlns:xsd=^"http://www.w3.org/2001/XMLSchema^" chaining=^"implicit^"^> >> %_MEMORY_DIR%\config.txt
	:: echo  ^<commands^> >> %_MEMORY_DIR%\config.txt
	:: echo    ^<command xsi:type=^"ExecuteModuleCommand^"^> >> %_MEMORY_DIR%\config.txt
	:: echo      ^<module name=^"w32memory-acquisition^" version=^"1.3.22.2^" /^> >> %_MEMORY_DIR%\config.txt
	:: echo      ^<config xsi:type=^"ParameterListModuleConfig^"^> >> %_MEMORY_DIR%\config.txt
	:: echo        ^<parameters^> >> %_MEMORY_DIR%\config.txt 
	:: echo        ^</parameters^> >> %_MEMORY_DIR%\config.txt
	:: echo      ^</config^> >> %_MEMORY_DIR%\config.txt
	:: echo    ^</command^> >> %_MEMORY_DIR%\config.txt
	:: echo  ^</commands^> >> %_MEMORY_DIR%\config.txt
	:: echo ^</script^> >> %_MEMORY_DIR%\config.txt
	:: START /WAIT Memoryze.exe -o %_MEMORY_DIR% -script %_MEMORY_DIR%\config.txt -encoding none -allowmultiple

:PROCESS
:: PROCESS INFORMATION
	echo ----------------------------------------- >> %_LOG%
	echo # PROCESS INFORMATION                     >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	set _PROCESS_DIR=%_VOLATILE_DIR%\process_information
	mkdir %_PROCESS_DIR%
	echo.
	echo # START ACQUIRING PROCESS INFORMATION
	echo Created "process_information" directory in %_VOLATILE_DIR%\
	echo Created "process_information" directory in %_VOLATILE_DIR%\ >> %_LOG%

	echo %DATE% %TIME% - Acquiring list of all processes_1 ...
	echo %DATE% %TIME% [Start] Acquiring list of all processes_1 ... >> %_LOG%
	pslist /accepteula > %_PROCESS_DIR%\pslist.txt
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring list of all processes_1 ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring list of all processes_1 ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring list of all processes_2 ...
	echo %DATE% %TIME% [Start] Acquiring list of all processes_2 ... >> %_LOG%
	cprocess /stext %_PROCESS_DIR%\cprocess.txt
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring list of all processes_2 ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring list of all processes_2 ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring list of all processes_3 ...
	echo %DATE% %TIME% [Start] Acquiring list of all processes_3 ... >> %_LOG%
	procinterrogate -ps > %_PROCESS_DIR%\procinterrogate-ps.txt
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring list of all processes_3 ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring list of all processes_3 ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring list of all processes_4 ...
	echo %DATE% %TIME% [Start] Acquiring list of all processes_4 ... >> %_LOG%
	procinterrogate -list -md5 -ver -o %_PROCESS_DIR%\procinterrogate-list-md5-ver-o.txt
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring list of all processes_4 ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring list of all processes_4 ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring list of task details ...
	echo %DATE% %TIME% [Start] Acquiring list of task details ... >> %_LOG%
	tasklist -V > %_PROCESS_DIR%\tasklist-V.txt
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring list of task details ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring list of task details ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring command lines for each process ...
	echo %DATE% %TIME% [Start] Acquiring command lines for each process ... >> %_LOG%
	tlist -c > %_PROCESS_DIR%\tlist-c.txt
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring command lines for each process ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring command lines for each process ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring task tree ...
	echo %DATE% %TIME% [Start] Acquiring task tree ... >> %_LOG%
	tlist -t > %_PROCESS_DIR%\tlist-t.txt
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring task tree ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring task tree ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring services active in each process ...
	echo %DATE% %TIME% [Start] Acquiring services active in each process ... >> %_LOG%
	tlist -s > %_PROCESS_DIR%\tlist-s.txt
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring services active in each process ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring services active in each process ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring list of loaded DLLs ...
	echo %DATE% %TIME% [Start] Acquiring list of loaded DLLs ... >> %_LOG%
	listdlls /accepteula > %_PROCESS_DIR%\listdlls.txt
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring list of loaded DLLs ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring list of loaded DLLs ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring list of injected DLLs for any process ...
	echo %DATE% %TIME% [Start] Acquiring list of injected DLLs for any process ... >> %_LOG%
	injecteddll /stext %_PROCESS_DIR%\injecteddll.txt
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring list of injected DLLs for any process ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring list of injected DLLs for any process ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring list of all DLL files loaded by all running processes ...
	echo %DATE% %TIME% [Start] Acquiring list of all DLL files loaded by all running processes ... >> %_LOG%
	loadeddllsview /scomma %_PROCESS_DIR%\loadeddllsview.csv
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring list of all DLL files loaded by all running processes ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring list of all DLL files loaded by all running processes ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring list of all loaded device drivers ...
	echo %DATE% %TIME% [Start] Acquiring list of all loaded device drivers ... >> %_LOG%
	driverview /scomma %_PROCESS_DIR%\driverview.csv
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring list of all loaded device drivers ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring list of all loaded device drivers ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring opened handles for any process ...
	echo %DATE% %TIME% [Start] Acquiring opened handles for any process ... >> %_LOG%
	handle /accepteula > %_PROCESS_DIR%\handle.txt
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring opened handles for any process ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring opened handles for any process ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring list of all opened files ...
	echo %DATE% %TIME% [Start] Acquiring list of all opened files ... >> %_LOG%
	openedfilesview /scomma %_PROCESS_DIR%\openfilesview.csv
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring list of all opened files ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring list of all opened files ... >> %_LOG%
	)

:: LOGON USER INFORMATION
	echo ----------------------------------------- >> %_LOG%
	echo # LOGON USER INFORMATION                  >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	set _LOGONUSER_DIR=%_VOLATILE_DIR%\logon_user_information
	mkdir %_LOGONUSER_DIR%
	echo.
	echo # START ACQUIRING LOGON USER INFORMATION
	echo Created "logon_user_information" directory in %_VOLATILE_DIR%\
	echo Created "logon_user_information" directory in %_VOLATILE_DIR%\ >> %_LOG%

	echo %DATE% %TIME% - Acquiring logged on users ...
	echo %DATE% %TIME% [Start] Acquiring logged on users ... >> %_LOG%
	psloggedon /accepteula > %_LOGONUSER_DIR%\psloggedon.txt
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring logged on users ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring logged on users ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring logon sessions ...
	echo %DATE% %TIME% [Start] Acquiring logon sessions ... >> %_LOG%
	logonsessions /accepteula > %_LOGONUSER_DIR%\logonsessions.txt
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring logon sessions ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring logon sessions ... >> %_LOG%
	)

	:: echo %DATE% %TIME% - Acquiring user logged on in the past ...
	:: echo %DATE% %TIME% [Start] Acquiring user logged on in the past ... >> %_LOG%
	:: netusers > %_LOGONUSER_DIR%\netusers_local_history.txt
	:: if %ERRORLEVEL% neq 0 (
    	::	echo %DATE% %TIME% [Error] Acquiring user logged on in the past ... >> %_LOG%
	::) else (
    	::	echo %DATE% %TIME% - [End] Acquiring user logged on in the past ... >> %_LOG%
	::)

	echo %DATE% %TIME% - Acquiring user account details ...
	echo %DATE% %TIME% [Start] Acquiring user account details ... >> %_LOG%
	net user > %_LOGONUSER_DIR%\net_user.txt
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring user account details ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring user account details ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring date/time that users logged on/off ...
	echo %DATE% %TIME% [Start] Acquiring date/time that users logged on/off ... >> %_LOG%
	winlogonview /scomma %_LOGONUSER_DIR%\winlogonview.csv
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring date/time that users logged on/off ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring date/time that users logged on/off ... >> %_LOG%
	)
	
:: SYSTEM INFORMATION
	echo ----------------------------------------- >> %_LOG%
	echo # SYSTEM INFORMATION                      >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	set _SYSTEM_DIR=%_VOLATILE_DIR%\system_information
	mkdir %_SYSTEM_DIR%
	echo.
	echo # START ACQUIRING SYSTEM INFORMATION
	echo Created "system_information" directory in %_VOLATILE_DIR%\
	echo Created "system_information" directory in %_VOLATILE_DIR%\ >> %_LOG%

	echo %DATE% %TIME% - Acquiring local and remote system information ...
	echo %DATE% %TIME% [Start] Acquiring local and remote system information ... >> %_LOG%
	psinfo /accepteula > %_SYSTEM_DIR%\psinfo.txt
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring local and remote system information ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring local and remote system information ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring disk volume information ...
	echo %DATE% %TIME% [Start] Acquiring disk volume information ... >> %_LOG%
	psinfo -d > %_SYSTEM_DIR%\psinfo_d.txt
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring disk volume information ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring disk volume information ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring list of installed software ...
	echo %DATE% %TIME% [Start] Acquiring list of installed software ... >> %_LOG%
	psinfo -s > %_SYSTEM_DIR%\psinfo_s.txt
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring list of installed software ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring list of installed software ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring list of installed hotfixes ...
	echo %DATE% %TIME% [Start] Acquiring list of installed hotfixes ... >> %_LOG%
	psinfo -h > %_SYSTEM_DIR%\psinfo_h.txt
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring list of installed hotfixes ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring list of installed hotfixes ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring the history of Windows updates ...
	echo %DATE% %TIME% [Start] Acquiring the history of Windows updates ... >> %_LOG%
	winupdatesview /scomma %_SYSTEM_DIR%\winupdatesview.csv
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring the history of Windows updates ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring the history of Windows updates ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring applied group policies ...
	echo %DATE% %TIME% [Start] Acquiring applied group policies ... >> %_LOG%
	gplist > %_SYSTEM_DIR%\gplist.txt
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring applied group policies ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring applied group policies ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring applied RSoP group policies ...
	echo %DATE% %TIME% [Start] Acquiring applied RSoP group policies ... >> %_LOG%
	gpresult /Z > %_SYSTEM_DIR%\gpresult_Z.txt
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring applied RSoP group policies ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring applied RSoP group policies ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring configured services ...
	echo %DATE% %TIME% [Start] Acquiring configured services ... >> %_LOG%
	psservice /accepteula > %_SYSTEM_DIR%\psservice.txt
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring configured services ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring configured services ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring time ranges that your computer was turned on ...
	echo %DATE% %TIME% [Start] Acquiring time ranges that your computer was turned on ... >> %_LOG%
	turnedontimesview /scomma %_SYSTEM_DIR%\turnedontimesview.csv
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring time ranges that your computer was turned on ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring time ranges that your computer was turned on ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring last activity on this system ...
	echo %DATE% %TIME% [Start] Acquiring last activity on this system ... >> %_LOG%
	lastactivityview /scomma %_SYSTEM_DIR%\lastactivityview.csv
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring last activity on this system ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring last activity on this system ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring a list of programs and batch files that you previously executed ...
	echo %DATE% %TIME% [Start] Acquiring a list of programs and batch files that you previously executed ... >> %_LOG%
	executedprogramslist /scomma %_SYSTEM_DIR%\executedprogramslist.csv
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring a list of programs and batch files that you previously executed ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring a list of programs and batch files that you previously executed ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring list of files that you previously opened with the standard open/save dialog-box ...
	echo %DATE% %TIME% [Start] Acquiring list of files that you previously opened with the standard open/save dialog-box ... >> %_LOG%
	opensavefilesview /scomma %_SYSTEM_DIR%\opensavefilesview.csv
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring list of files that you previously opened with the standard open/save dialog-box ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring list of files that you previously opened with the standard open/save dialog-box ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring information about all programs installed on your system ...
	echo %DATE% %TIME% [Start] Acquiring information about all programs installed on your system ... >> %_LOG%
	uninstallview /scomma %_SYSTEM_DIR%\uninstallview.csv
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring information about all programs installed on your system ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring information about all programs installed on your system ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring user log on/log off ...
	echo %DATE% %TIME% [Start] Acquiring user log on/log off ... >> %_LOG%
	winlogonview /scomma %_SYSTEM_DIR%\winlogonview.csv
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring user log on/log off ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring user log on/log off ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring the list of all software packages installed on your system with Windows Installer ...
	echo %DATE% %TIME% [Start] Acquiring the list of all software packages installed on your system with Windows Installer ... >> %_LOG%
	installedpackagesview /scomma %_SYSTEM_DIR%\installedpackagesview.csv
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring the list of all software packages installed on your system with Windows Installer ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring the list of all software packages installed on your system with Windows Installer ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring the list of all registered dll/ocx/exe files COM registration ...
	echo %DATE% %TIME% [Start] Acquiring the list of all registered dll/ocx/exe files COM registration ... >> %_LOG%
	regdllview /scomma %_SYSTEM_DIR%\regdllview.csv
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring the list of all registered dll/ocx/exe files COM registration ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring the list of all registered dll/ocx/exe files COM registration ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring all search queries with the most popular search engines Google, Yahoo and MSN and with popular social networking sites Twitter, Facebook, MySpace ...
	echo %DATE% %TIME% [Start] Acquiring all search queries with the most popular search engines Google, Yahoo and MSN and with popular social networking sites Twitter, Facebook, MySpace ... >> %_LOG%
	mylastsearch /scomma %_SYSTEM_DIR%\mylastsearch.csv
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring all search queries with the most popular search engines Google, Yahoo and MSN and with popular social networking sites Twitter, Facebook, MySpace ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring all search queries with the most popular search engines Google, Yahoo and MSN and with popular social networking sites Twitter, Facebook, MySpace ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring the history data of different Web browsers Mozilla Firefox, Google Chrome, Internet Explorer, Microsoft Edge, Opera ...
	echo %DATE% %TIME% [Start] Acquiring the history data of different Web browsers Mozilla Firefox, Google Chrome, Internet Explorer, Microsoft Edge, Opera ... >> %_LOG%
	browsinghistoryview /HistorySource 1 /VisitTimeFilterType 1 /LoadIE 1 /LoadFirefox 1 /LoadChrome 1 /LoadSafari 1 /scomma %_SYSTEM_DIR%\browsinghistoryview.csv
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring the history data of different Web browsers Mozilla Firefox, Google Chrome, Internet Explorer, Microsoft Edge, Opera ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring the history data of different Web browsers Mozilla Firefox, Google Chrome, Internet Explorer, Microsoft Edge, Opera ... >> %_LOG%
	)

:: NETWORK INTERFACE INFORMATION
	echo ----------------------------------------- >> %_LOG%
	echo # NETWORK INTERFACE INFORMATION           >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	set _INTERFACE_DIR=%_VOLATILE_DIR%\interface_information
	mkdir %_INTERFACE_DIR%
	echo.
	echo # START ACQUIRING INTERFACE INFORMATION
	echo Created "interface_information" directory in %_VOLATILE_DIR%\
	echo Created "interface_information" directory in %_VOLATILE_DIR%\ >> %_LOG%

	:: echo %DATE% %TIME% - Acquiring promiscuous mode information ...
	:: echo %DATE% %TIME% [Start] Acquiring promiscuous mode information ... >> %_LOG%
	:: promiscdetect > %_INTERFACE_DIR%\promiscdetect.txt
	:: if %ERRORLEVEL% neq 0 (
    	:: 	echo %DATE% %TIME% [Error] Acquiring promiscuous mode information ... >> %_LOG%
	:: ) else (
    	:: 	echo %DATE% %TIME% - [End] Acquiring promiscuous mode information ... >> %_LOG%
	:: )

	echo %DATE% %TIME% - Acquiring detaild information for each interface ...
	echo %DATE% %TIME% [Start] Acquiring detaild information for each interface ... >> %_LOG%
	ipconfig /all > %_INTERFACE_DIR%\ipconfig_all.txt 
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring detaild information for each interface ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring detaild information for each interface ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring contents of the DNS resolver cache ...
	echo %DATE% %TIME% [Start] Acquiring contents of the DNS resolver cache ... >> %_LOG%
	ipconfig /displaydns > %_INTERFACE_DIR%\ipconfig_displaydns.txt 
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring contents of the DNS resolver cache ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring contents of the DNS resolver cache ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring MAC address for each interface ...
	echo %DATE% %TIME% [Start] Acquiring MAC address for each interface ... >> %_LOG%
	getmac > %_INTERFACE_DIR%\getmac.txt 
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring MAC address for each interface ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring MAC address for each interface ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring list of all network interfaces ...
	echo %DATE% %TIME% [Start] Acquiring list of all network interfaces ... >> %_LOG%
	networkinterfacesview /stext %_INTERFACE_DIR%\networkinterfacesview.txt
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring list of all network interfaces ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring list of all network interfaces ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring list of all network interfaces ...
	echo %DATE% %TIME% [Start] Acquiring list of all network interfaces ... >> %_LOG%
	wifiinfoview /scomma %_INTERFACE_DIR%\wifiinfoview.csv
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring list of all network interfaces ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring list of all network interfaces ... >> %_LOG%
	)

:: PASSWORD
::	echo ----------------------------------------- >> %_LOG%
::	echo # STORED PASSWORD INFORMATION             >> %_LOG%
::	echo ----------------------------------------- >> %_LOG%
::	set _PASSWORD_DIR=%_VOLATILE_DIR%\password_information
::	mkdir %_PASSWORD_DIR%
::	echo.
::	echo # START ACQUIRING PASSWORD INFORMATION
::	echo Created "password_information" directory in %_VOLATILE_DIR%\
::	echo Created "password_information" directory in %_VOLATILE_DIR%\ >> %_LOG%
::
::	echo %DATE% %TIME% - Acquiring passwords stored by Internet Explorer ...
::	echo %DATE% %TIME% [Start] Acquiring passwords stored by Internet Explorer ... >> %_LOG%
::	iepv /stext %_PASSWORD_DIR%\iepv.txt
::	if %ERRORLEVEL% neq 0 (
::    		echo %DATE% %TIME% [Error] Acquiring passwords stored by Internet Explorer ... >> %_LOG%
::	) else (
::    		echo %DATE% %TIME% - [End] Acquiring passwords stored by Internet Explorer ... >> %_LOG%
::	)
::
::	echo %DATE% %TIME% - Acquiring passwords stored by Chrome ...
::	echo %DATE% %TIME% [Start] Acquiring passwords stored by Chrome ... >> %_LOG%
::	chromepass.exe /stext %_PASSWORD_DIR%\chromepass.txt
::	if %ERRORLEVEL% neq 0 (
::    		echo %DATE% %TIME% [Error] Acquiring passwords stored by Chrome ... >> %_LOG%
::	) else (
::    		echo %DATE% %TIME% - [End] Acquiring passwords stored by Chrome ... >> %_LOG%
::	)
::
::	echo %DATE% %TIME% - Acquiring passwords stored by Firefox ...
::	echo %DATE% %TIME% [Start] Acquiring passwords stored by Firefox ... >> %_LOG%
::	passwordfox.exe /stext %_PASSWORD_DIR%\passwordfox.txt
::	if %ERRORLEVEL% neq 0 (
::    		echo %DATE% %TIME% [Error] Acquiring passwords stored by Firefox ... >> %_LOG%
::	) else (
::    		echo %DATE% %TIME% - [End] Acquiring passwords stored by Firefox ... >> %_LOG%
::	)
::
::	echo %DATE% %TIME% - Acquiring password for various email clients ...
::	echo %DATE% %TIME% [Start] Acquiring password for various email clients ... >> %_LOG%
::	mailpv /stext %_PASSWORD_DIR%\mailpv.txt
::	if %ERRORLEVEL% neq 0 (
::    		echo %DATE% %TIME% [Error] Acquiring password for various email clients ... >> %_LOG%
::	) else (
::    		echo %DATE% %TIME% - [End] Acquiring password for various email clients ... >> %_LOG%
::	)
::
::	echo %DATE% %TIME% - Acquiring passwords stored behind the bullets in the standard password text-box ...
::	echo %DATE% %TIME% [Start] Acquiring passwords stored behind the bullets in the standard password text-box ... >> %_LOG%
::	bulletspassview /stext %_PASSWORD_DIR%\bulletspassview.txt
::	if %ERRORLEVEL% neq 0 (
::    		echo %DATE% %TIME% [Error] Acquiring passwords stored behind the bullets in the standard password text-box ... >> %_LOG%
::	) else (
::    		echo %DATE% %TIME% - [End] Acquiring passwords stored behind the bullets in the standard password text-box ... >> %_LOG%
::	)
::
::	echo %DATE% %TIME% - Acquiring network passwords stored on your system for the current logged-on user ...
::	echo %DATE% %TIME% [Start] Acquiring network passwords stored on your system for the current logged-on user ... >> %_LOG%
::	netpass /stext %_PASSWORD_DIR%\netpass.txt
::	if %ERRORLEVEL% neq 0 (
::  		echo %DATE% %TIME% [Error] Acquiring network passwords stored on your system for the current logged-on user ... >> %_LOG%
::	) else (
::  		echo %DATE% %TIME% - [End] Acquiring network passwords stored on your system for the current logged-on user ... >> %_LOG%
::	)
::
::	echo %DATE% %TIME% - Acquiring passwords stored by the web browsers (IE, Firefox, Chrome, Safari, Opera) ...
::	echo %DATE% %TIME% [Start] Acquiring passwords stored by the web browsers (IE, Firefox, Chrome, Safari, Opera) ... >> %_LOG%
::	webbrowserpassview /scomma %_PASSWORD_DIR%\webbrowserpassview.csv
::	if %ERRORLEVEL% neq 0 (
::    		echo %DATE% %TIME% [Error] Acquiring passwords stored by the web browsers (IE, Firefox, Chrome, Safari, Opera) ... >> %_LOG%
::	) else (
::    		echo %DATE% %TIME% - [End] Acquiring passwords stored by the web browsers (IE, Firefox, Chrome, Safari, Opera) ... >> %_LOG%
::	)
::
::	echo %DATE% %TIME% - Acquiring all wireless network security keys/passwords (WEP/WPA) ...
::	echo %DATE% %TIME% [Start] Acquiring all wireless network security keys/passwords (WEP/WPA) ... >> %_LOG%
::	wirelesskeyview /stext %_PASSWORD_DIR%\wirelesskeyview.txt
::	if %ERRORLEVEL% neq 0 (
::    		echo %DATE% %TIME% [Error] Acquiring all wireless network security keys/passwords (WEP/WPA) ... >> %_LOG%
::	) else (
::    		echo %DATE% %TIME% - [End] Acquiring all wireless network security keys/passwords (WEP/WPA) ... >> %_LOG%
::	)
::
::	echo %DATE% %TIME% - Acquiring password stored by Microsoft Remote Desktop Connection utility inside the .rdp files ...
::	echo %DATE% %TIME% [Start] Acquiring password stored by Microsoft Remote Desktop Connection utility inside the .rdp files ... >> %_LOG%
::	rdpv /stext %_PASSWORD_DIR%\rdpv.txt
::	if %ERRORLEVEL% neq 0 (
::    		echo %DATE% %TIME% [Error] Acquiring password stored by Microsoft Remote Desktop Connection utility inside the .rdp files ... >> %_LOG%
::	) else (
::    		echo %DATE% %TIME% - [End] Acquiring password stored by Microsoft Remote Desktop Connection utility inside the .rdp files ... >> %_LOG%
::	)
::
::	echo %DATE% %TIME% - Acquiring passwords from instant messenger applications ...
::	echo %DATE% %TIME% [Start] Acquiring passwords from instant messenger applications ... >> %_LOG%
::	mspass.exe /stext %_PASSWORD_DIR%\messengerpass.txt
::	if %ERRORLEVEL% neq 0 (
::    		echo %DATE% %TIME% [Error] Acquiring passwords from instant messenger applications ... >> %_LOG%
::	) else (
::    		echo %DATE% %TIME% - [End] Acquiring passwords from instant messenger applications ... >> %_LOG%
::	)

:: MISCs
	echo ----------------------------------------- >> %_LOG%
	echo # MISCs                                   >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	set _MISC_DIR=%_VOLATILE_DIR%\misc_information
	mkdir %_MISC_DIR%
	echo.
	echo # START ACQUIRING MISCELLANEOUS INFORMATION
	echo Created "misc_information" directory in %_VOLATILE_DIR%\
	echo Created "misc_information" directory in %_VOLATILE_DIR%\ >> %_LOG%

	echo %DATE% %TIME% - Acquiring all Web browser addons/plugins ...
	echo %DATE% %TIME% [Start] Acquiring all Web browser addons/plugins ... >> %_LOG%
	browseraddonsview /scomma %_MISC_DIR%\browseraddonsview.csv
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring all Web browser addons/plugins ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring all Web browser addons/plugins ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring list of all tasks from the Task Scheduler ...
	echo %DATE% %TIME% [Start] Acquiring list of all tasks from the Task Scheduler ... >> %_LOG%
	taskschedulerview /scomma %_MISC_DIR%\taskschedulerview.csv
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring list of all tasks from the Task Scheduler ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring list of all tasks from the Task Scheduler ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring schedule tasks ...
	echo %DATE% %TIME% [Start] Acquiring schedule tasks ... >> %_LOG%
	at > %_MISC_DIR%\at.txt 
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring schedule tasks ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring schedule tasks ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring detailed property list for all tasks ...
	echo %DATE% %TIME% [Start] Acquiring detailed property list for all tasks ... >> %_LOG%
	schtasks /query /fo list /v > %_MISC_DIR%\schtasks_query_fo_list_v.txt 
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring detailed property list for all tasks ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring detailed property list for all tasks ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring clipboard text ...
	echo %DATE% %TIME% [Start] Acquiring clipboard text ... >> %_LOG%
	pclip > %_MISC_DIR%\pclip.txt
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring clipboard text ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring clipboard text ... >> %_LOG%
	)

	echo %DATE% %TIME% - Acquiring autoruns information ...
	echo %DATE% %TIME% [Start] Acquiring autoruns information ... >> %_LOG%
	autorunsc /accepteula > %_MISC_DIR%\autorunsc.txt
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring autoruns information ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring autoruns information ... >> %_LOG%
	)

:: -----------------------------------------------------
:: Acquire NON-VOLATILE data
:: -----------------------------------------------------
if /i "%_IS_NONVOLATILE%" == "N" GOTO:PACKET
	echo.
	echo ## START ACQUIRING NON-VOLATILE

:: MBR (Master Boot Record)
	set _MBR=%_NONVOLATILE_DIR%\mbr
	mkdir %_MBR%
	echo ----------------------------------------- >> %_LOG%
	echo # MBR                                     >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring MBR ...
	echo %DATE% %TIME% [Start] Acquiring MBR ... >> %_LOG%
	dd if=\\.\PhysicalDrive0 of=%_MBR%\MBR bs=512 count=1
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring MBR ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring MBR ... >> %_LOG%
	)
	
:: VBR (Volume Boot Record)
	set _VBR=%_NONVOLATILE_DIR%\vbr
	mkdir %_VBR%
	echo ----------------------------------------- >> %_LOG%
	echo # VBR                                     >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring VBR ...
	echo %DATE% %TIME% [Start] Acquiring VBR ... >> %_LOG%
	forecopy_handy -f %SystemDrive%\$Boot %_VBR%
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring VBR ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring VBR ... >> %_LOG%
	)
	
:: $MFT
	echo ----------------------------------------- >> %_LOG%
	echo # $MFT                                    >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring $MFT ...
	echo %DATE% %TIME% [Start] Acquiring $MFT ... >> %_LOG%
	forecopy_handy -m %_NONVOLATILE_DIR%
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring $MFT ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring $MFT ... >> %_LOG%
	)

:: $LogFile
	set _FSLOG=%_NONVOLATILE_DIR%\fslog
	mkdir %_FSLOG%
	echo ----------------------------------------- >> %_LOG%
	echo # $LogFile                                >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring $LogFile ...
	echo %DATE% %TIME% [Start] Acquiring $LogFile ... >> %_LOG%
	forecopy_handy -f %SystemDrive%\$LogFile %_FSLOG%
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring $LogFile ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring $LogFile ... >> %_LOG%
	)
	
:: REGISTRY
	echo ----------------------------------------- >> %_LOG%
	echo # REGISTRY                                >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring Registry Hives ...
	echo %DATE% %TIME% [Start] Acquiring Registry Hives ... >> %_LOG%
	forecopy_handy -g %_NONVOLATILE_DIR%
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring Registry Hives ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring Registry Hives ... >> %_LOG%
	)

:: EVENT LOGS
	echo ----------------------------------------- >> %_LOG%
	echo # EVENT LOGS                              >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring Event Logs ...
	echo %DATE% %TIME% [Start] Acquiring Event Logs ... >> %_LOG%
	forecopy_handy -e %_NONVOLATILE_DIR%
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring Event Logs ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring Event Logs ... >> %_LOG%
	)

:: RECENT LNKs and JUMPLIST
	echo ----------------------------------------- >> %_LOG%
	echo # RECENT FOLDER                           >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring Recent LNKs and JumpLists ...
	echo %DATE% %TIME% [Start] Acquiring Recent LNKs and JumpLists ... >> %_LOG%
	forecopy_handy -r "%AppData%\microsoft\windows\recent" %_NONVOLATILE_DIR%
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring Recent LNKs and JumpLists ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring Recent LNKs and JumpLists ... >> %_LOG%
	)

:: SYSTEM32/drivers/etc files
	echo ----------------------------------------- >> %_LOG%
	echo # system32/drivers/etc                    >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring system32/drivers/etc ...
	echo %DATE% %TIME% [Start] Acquiring system32/drivers/etc ... >> %_LOG%
	forecopy_handy -t %_NONVOLATILE_DIR%
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring system32/drivers/etc ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring system32/drivers/etc ... >> %_LOG%
	)
	
:: systemprofile (\Windows\system32\config\systemprofile)
	echo ----------------------------------------- >> %_LOG%
	echo # system32/config/systemprofile           >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring system32/config/systemprofile ...
	echo %DATE% %TIME% [Start] Acquiring system32/config/systemprofile ... >> %_LOG%
	forecopy_handy -r "%SystemRoot%\system32\config\systemprofile" %_NONVOLATILE_DIR%
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring system32/config/systemprofile ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring system32/config/systemprofile ... >> %_LOG%
	)

:: IE Artifacts
	echo ----------------------------------------- >> %_LOG%
	echo # IE Artifacts                            >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring IE Artifacts ...
	echo %DATE% %TIME% [Start] Acquiring IE Artifacts ... >> %_LOG%
	forecopy_handy -i %_NONVOLATILE_DIR%
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring IE Artifacts ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring IE Artifacts ... >> %_LOG%
	)
	
:: Firefox Artifacts
	echo ----------------------------------------- >> %_LOG%
	echo # Firefox Artifacts                       >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring Firefox Artifacts ...
	echo %DATE% %TIME% [Start] Acquiring Firefox Artifacts ... >> %_LOG%
	forecopy_handy -x %_NONVOLATILE_DIR%	
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring Firefox Artifacts ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring Firefox Artifacts ... >> %_LOG%
	)

:: Chrome Artifacts
	echo ----------------------------------------- >> %_LOG%
	echo # Chrome Artifacts                        >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring Chrome Artifacts ...
	echo %DATE% %TIME% [Start] Acquiring Chrome Artifacts ... >> %_LOG%
	forecopy_handy -c %_NONVOLATILE_DIR%
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring Chrome Artifacts ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring Chrome Artifacts ... >> %_LOG%
	)
	
:: IconCache
	set _ICONCACHE=%_NONVOLATILE_DIR%\iconcache
	mkdir %_ICONCACHE%
	echo ----------------------------------------- >> %_LOG%
	echo # IconCache                               >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring IconCache.db ...
	echo %DATE% %TIME% [Start] Acquiring IconCache.db ... >> %_LOG%
	forecopy_handy -f %LocalAppData%\IconCache.db %_ICONCACHE%	
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring IconCache.db ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring IconCache.db ... >> %_LOG%
	)
	
:: Thumbcache
	echo ----------------------------------------- >> %_LOG%
	echo # Thumbcache                              >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring Thumbcache_###.db ...
	echo %DATE% %TIME% [Start] Acquiring Thumbcache_###.db ... >> %_LOG%
	forecopy_handy -r "%LocalAppData%\microsoft\windows\explorer" %_NONVOLATILE_DIR%	
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring Thumbcache_###.db ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring Thumbcache_###.db ... >> %_LOG%
	)
	
:: Downloaded Program Files
	echo ----------------------------------------- >> %_LOG%
	echo # Downloaded Program Files                >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring Downloaded Program Files ...
	echo %DATE% %TIME% [Start] Acquiring Downloaded Program Files ... >> %_LOG%
	forecopy_handy -r "%SystemRoot%\Downloaded Program Files" %_NONVOLATILE_DIR%	
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring Downloaded Program Files ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring Downloaded Program Files ... >> %_LOG%
	)
	
:: Java IDX cache
	echo ----------------------------------------- >> %_LOG%
	echo # Java IDX Cache                          >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring Java IDX Cache ...
	echo %DATE% %TIME% [Start] Acquiring Java IDX Cache ... >> %_LOG%
	forecopy_handy -r "%UserProfile%\AppData\LocalLow\Sun\Java\Deployment" %_NONVOLATILE_DIR%	
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring Java IDX Cache ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring Java IDX Cache ... >> %_LOG%
	)
	
:: WER (Windows Error Reporting)
	echo ----------------------------------------- >> %_LOG%
	echo # Windows Error Reporting                 >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring Windows Error Reporting ...
	echo %DATE% %TIME% [Start] Acquiring Windows Error Reporting ... >> %_LOG%
	forecopy_handy -r "%LocalAppData%\Microsoft\Windows\WER" %_NONVOLATILE_DIR%
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring Windows Error Reporting ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring Windows Error Reporting ... >> %_LOG%
	)
	
:: Windows Timeline
	echo ----------------------------------------- >> %_LOG%
	echo # Windows Timeline                        >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring Windows Timeline ...
	echo %DATE% %TIME% [Start] Acquiring Windows Timeline ... >> %_LOG%
	forecopy_handy -r "%LocalAppData%\ConnectedDevicesPlatform" %_NONVOLATILE_DIR%
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring Windows Timeline ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring Windows Timeline ... >> %_LOG%
	)
	
:: Windows Search Database
	echo ----------------------------------------- >> %_LOG%
	echo # Windows Search Database                 >> %_LOG%
	echo ----------------------------------------- >> %_LOG%
	echo %DATE% %TIME% - Acquiring Windows Search Database ...
	echo %DATE% %TIME% [Start] Acquiring Windows Search Database ... >> %_LOG%
	forecopy_handy -r "%ProgramData%\Microsoft\Search\Data\Applications\Windows" %_NONVOLATILE_DIR%
	if %ERRORLEVEL% neq 0 (
    		echo %DATE% %TIME% [Error] Acquiring Windows Search Database ... >> %_LOG%
	) else (
    		echo %DATE% %TIME% - [End] Acquiring Windows Search Database ... >> %_LOG%
	)

:: Calculate MD5
	::echo %DATE% %TIME% - Calculating MD5 values of acquiring files ...
	::echo %DATE% %TIME% [Start] Calculating MD5 values of acquiring files ... >> %_LOG%
	::set _MD5=%_TARGET_DIR%\MD5.log
	::echo The md5 values of acquiring files > %_MD5%
	::echo ****************************************************** >> %_MD5%
	::md5deep -r %_TARGET_DIR% >> %_MD5%
	::if %ERRORLEVEL% neq 0 (
    	::	echo %DATE% %TIME% [Error] Calculating MD5 values of acquiring files ... >> %_LOG%
	::) else (
    	::	echo %DATE% %TIME% - [End] Calculating MD5 values of acquiring files ... >> %_LOG%
	::)



:: -----------------------------------------------------
:: END
:: -----------------------------------------------------
:END
echo END TIME : %DATE% %TIME% >> %_LOG%
echo.
echo It's done!