@echo off

echo DMCNet Official SDK
echo.

if not exist bin (
	echo ERROR: The SDK binaries have not been built. Please build them by either typing in "build" into this prompt or starting this script with the "build" argument.
	
	echo.
)

if not "%1"=="" (
	goto %1
)

pause
exit /b

:build

if exist bin (
	echo ERROR: The SDK binaries have already been built. Aborting.
	pause
	exit /b
)

echo Building SDK environment...

mkdir bin

(
	echo @echo off
	echo if not exist src mkdir src
	echo if not exist src\core mkdir src\core
	echo for /r "core" %%a in (*.bat) do copy %%a
	echo copy core\core.bat src
	echo ren src\core.bat core.txt
)>>bin\decompile.bat

(
	echo @echo off
	echo if not exist compiled mkdir compiled
	echo copy src\core.txt compiled
	echo ren compiled\core.txt core.bat
)>>bin\recompile.bat

echo Built SDK environment

goto:EOF