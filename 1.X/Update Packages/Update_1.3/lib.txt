@echo off
set func=%1
set args=%2

set PATH_LibFolder=core\lib

if %func%==build goto buildLibrary
if %func%==pull goto deleteLibrary

echo Error: Command not recognised
pause
exit


:buildLibrary

if exist %PATH_LibFolder%\%args% (
	echo Error: Library has already been built in this current installation
	pause
	exit
)

mkdir %PATH_LibFolder%\%args%

for /f "tokens=1,2,3,4 delims=>" %%a in (%args%_Lib\%args%.libset) do (
	if %%a==extract (
		timeout /t 2 /nobreak >nul
		copy %args%_Lib\%%b.src.txt %PATH_LibFolder%\%args%
		
		ren %PATH_LibFolder%\%args%\%%b.src.txt %%b.%%c
	)
	
	if %%a==locate (
		timeout /t 1 /nobreak >nul
		copy %args%_Lib\%%b %PATH_LibFolder%\%args%
	)
	
	if %%a==new (
		if %%b==folder (
			timeout /t 1 /nobreak >nul
			mkdir %PATH_LibFolder%\%args%\%%c
		)
	)
	
	if %%a==move (
		timeout /t 1 /nobreak >nul
		move %PATH_LibFolder%\%args%\%%b %PATH_LibFolder%\%args%\%%c
	)
	
	if %%a==rename (
		timeout /t 1 /nobreak >nul
		ren %PATH_LibFolder%\%args%\%%b %%c
	)
)
exit

:deleteLibrary
if exist %PATH_LibFolder%\%args% (
	rmdir /s /q %PATH_LibFolder%\%args%
) else (
	echo Error: Library does not exist
	pause
)
exit