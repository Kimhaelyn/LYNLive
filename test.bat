@echo off

:: Set log file path (optional, if not already set elsewhere)
set _LOG=logfile.log

:: PHYSICAL MEMORY
echo ----------------------------------------- >> %_LOG%
echo # PHYSICAL MEMORY                         >> %_LOG%
echo ----------------------------------------- >> %_LOG%
echo. >> %_LOG%
echo ## START ACQUIRING PHYSICAL MEMORY >> %_LOG%
echo %DATE% %TIME% - Acquiring physical memory ... >> %_LOG%
velocidex\winpmem_mini_x64_rc2.exe -2 "test.raw"
echo %ERRORLEVEL%

if %ERRORLEVEL% neq 0 (
    echo %DATE% %TIME% [Error] Acquiring physical memory ... >> %_LOG%
) else (
    echo %DATE% %TIME% - [End] Acquiring physical memory ... >> %_LOG%
)

:END
echo END TIME : %DATE% %TIME% >> %_LOG%
echo.
echo It's done!
