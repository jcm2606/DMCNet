@echo off
setlocal enabledelayedexpansion

set filePath=%1
set flags=%2

set propType=normal
set printFileData=false

echo Flags: %flags%

if not x%flags:c=%==x%flags% (
	set propType=class
)

if not x%flags:F=%==x%flags% (
	set printFileData=true
)

echo Property roundup type: %propType%
echo.
echo Begin property roundup
echo.

set "file=%filePath:"=%"

for %%? in (%file%) do (
	echo File Name Only       : %%~n?
	echo File Extension       : %%~x?
	echo File Attributes      : %%~a?
	echo Located on Drive     : %%~d?
	echo File Size            : %%~z?
	echo Last-Modified Date   : %%~t?
	echo Parent Folder        : %%~dp?
)

if %propType%==class (
	set "file=%CD%\%filePath%.dmcclass"
	
	if exist "%CD%\%filePath%.dmcclass.dmcmeta" (
		echo Has metadata         : TRUE
	) else (
		echo Has metadata         : FALSE
	)
)

if %printFileData%==true (
	echo Begin file content dump
	echo.
	type %filePath%
	echo.
	echo.
	echo End file content dump
)

echo.
echo End property roundup
pause
exit