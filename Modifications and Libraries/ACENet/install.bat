@echo off
echo ACENet Automated Installer
echo.
echo Commencing install...

if exist acenet (
	echo ERROR
	echo ACENET IS ALREADY INSTALLED.
)

mkdir acenet

echo Copying ACENet binaries...
echo.

xcopy "binaries" "acenet" /S /Y /Q

echo.
echo ACENet binaries copied!
echo.
echo Install completed!

pause
exit /b