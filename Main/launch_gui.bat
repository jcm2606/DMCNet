@echo off

REM  DMCNet Official Runtime Launcher

set version=1.2

REM  This entire source code is open and is able to be referenced

set FileListFile=%Temp%\dmcnet_file_list.txt

title DMCNet Official Runtime Launcher
setlocal EnableDelayedExpansion

set "E_CoreObjMapPath=%CD%\dmcnet.txt"

if "%1"=="nogui" (
	echo.
	goto prompt
)

call :CREATE_MOUSE

:gui

set "func="
set "args="
set "flags=-"

if exist %FileListFile% (
	del %FileListFile%
)

echo DMCNet Official Runtime Launcher
echo Version %version%
echo.

set /a line=3

set ClassesFound=false

if exist *.dmc (
	set validFilesExist=true
)

if exist *.script (
	set validFilesExist=true
)

if defined validFilesExist (
	set FilesFound=true
	set /a line+=1
	echo Files in current dir:

	for %%A in (*.dmc, *.script) do (
		call :strLen "%%~nA%%~xA"

		set tmpdata=%%~nA
		set tmpdata=!tmpdata!:%%~xA
		set tmpdata=!tmpdata!:!length!:!line!

		echo !tmpdata!>>%FileListFile%
		
		set /a line+=1
		
		echo [%%~nA%%~xA]
	)
	
	echo.
)

echo [Line]
set /a CLEntryLine=!line!
if !FilesFound!==true set /a CLEntryLine+=1
echo.
echo [Prompt]
set /a PREntryLine=!CLEntryLine!
set /a PREntryLine+=2
echo.
echo [Exit]
set /a EXEntryLine=!PREntryLine!
set /a EXEntryLine+=2

REM  Checks if the core object map exists before showing the prompt
if not exist "%E_CoreObjMapPath%" (
	echo # START CORE ENVIRONMENT VALUES>>"%E_CoreObjMapPath%"
	echo E_Debug:false>>"%E_CoreObjMapPath%"
	echo E_WorkingDirectory:CD>>"%E_CoreObjMapPath%"
	echo # END CORE ENVIRONMENT VALUES>>"%E_CoreObjMapPath%"
	echo # Place custom values you wish to be loaded into>>"%E_CoreObjMapPath%"
	echo # DMCNet's environment after here>>"%E_CoreObjMapPath%"
	
	echo Warning:
	echo The DMCNet Core Object Map could not be found. A new one has been
	echo generated.
	echo.
)

REM  Checks if the "core" directory exists before showing the prompt
if not exist core (
	echo Warning: 
	echo DMCNet is not fully installed. Please download the latest update
	echo package and build the DMCNet binaries to use DMCNet.
	echo.
)

For /f "tokens=1,2,3" %%W in ('"!Temp!\Mouse.exe"') do set /a "c=%%W,x=%%X,y=%%Y"

cls

if !y!==!CLEntryLine! (
	if !x! GEQ 1 (
		if !x! LEQ 6 (
			set func=line
			set args=InternalCommandHandling
			set flags=-debug
			
			goto handleInput
		)
	)
)

if !y!==!EXEntryLine! (
	if !x! GEQ 1 (
		if !x! LEQ 6 (
			exit
		)
	)
)

if !y!==!PREntryLine! (
	if !x! GEQ 1 (
		if !x! LEQ 8 (
			goto prompt
		)
	)
)

if exist %FileListFile% (
	for /f "tokens=1,2,3,4 delims=:" %%a in (%FileListFile%) do (
		set fileName=%%a
		set fileType=%%b
		set /a entryEndX=%%c
		set /a entryEndX+=1
		set entryY=%%d
		
		if !y!==!entryY! (
			if !x! GEQ 1 (
				if !x! LEQ !entryEndX! (
					
				
					if !fileType!==.dmc (
						set func=class
					) else (
						set func=script
					)
					
					set args=!fileName!
					
					goto handleInput
				)
			)
		)
	)
)

goto :gui

:prompt

REM  Pre-emptively sets the "flags" variable
set flags=-

set /p "cmd=> "

for /f "tokens=1,2*" %%a in ("%cmd%") do (
	set args=%%b
	
	if /i %%a==update (
		set func=update
		set args=%%b
		set args2=%%c
	)
	
	if /i %%a==exit (
		if "%1"=="nogui" (
			exit /b
		) else (
			cls
			goto gui
		)
	)
	
	if not %%a==update (
		if not exist core\core.bat (
			echo Error: DMCNet is not fully installed, this feature is not available.
			goto prompt
		)
	)
	
	if /i %%a==script (
		set func=script
		set args=%%b
	)
	if /i %%a==class set func=class
	if /i %%a==line (
		set func=line
		set args=InternalCommandHandling
		set flags=-debug
	)
	if /i %%a==properties (
		set func=properties
		set "file=%%b"
		set flags=%%c
	)
	if /i %%a==wipe (
		set func=wipe
		set args=wipe
	)
	if not "%%c"=="" (
		set flags=%flags%%%c
	)
)

:handleInput

if "%func%"=="" (
	echo Error: Command not recognised.
	goto prompt
)

REM  Handles the calling of custom launch scripts
if %func%==script (
	set "DMC_PATH=%CD%"

	for /f "usebackq tokens=1* delims= " %%A in ("%args%.script") do (
		if %%A==PATH (
			if not exist %%B (
				mkdir %%B
			)
			set "DMC_PATH=%%B"
		)
		if %%A==FUNCTION (
			set func=%%B
		)
		if %%A==ARGS (
			set args=%%B
		)
		if %%A==FLAGS (
			set flags=!flags!%%B
		)
		if %%A==LOAD (
			if "!DMC_PATH!"=="%CD%" (
				start core\core.bat !func! !args! "!DMC_PATH!" "!%%flags%%!"
			) else (
				start core\core.bat !func! !args! "!DMC_PATH!" "!%%flags%%!"
			)
		)
	)
	
	goto endFuncs
)

REM  Callback to the properties script
if %func%==properties (
	start core\property.bat "%file%" %flags%
	goto prompt
)

REM  Handles the updating (both building and installing)
if %func%==update (
	if %args%==build (
		if not exist Update_%args2% (
			mkdir Update_%args2%
		)
		
		if not exist Update_%args2%\data (
			mkdir Update_%args2%\data
		)
		
		if not exist Update_%args2%\data\template (
			mkdir Update_%args2%\data\template
		)
		
		if exist Update_%args2%\*.txt (
			del Update_%args2%\*.txt
		)
		
		for /f "tokens=1 delims=" %%a in ('dir core /b /a-d-h-s') do (
			for /f "tokens=1,2,3 delims=." %%A in ("%%a") do (
				if exist core\%%A.bat (
					echo extract:%%A>>Update_%args2%\update
			
					copy core\%%A.bat Update_%args2%
					
					ren Update_%args2%\%%A.bat %%A.txt
				)
			)
		)
		
		if not exist Update_%args2%\data\template\dev (
			mkdir Update_%args2%\data\template\dev
		)
		
		if exist Update_%args2%\data\template\dev\*.txt (
			del Update_%args2%\data\template\dev\*.txt
		)
		
		echo new:folder:data>>Update_%args2%\update
		echo new:folder:data\template>>Update_%args2%\update
		echo new:folder:data\template\dev>>Update_%args2%\update
		
		for /f "tokens=1 delims=" %%a in ('dir core\data\template\dev /b /a-d-h-s') do (
			for /f "tokens=1,2,3 delims=." %%A in ("%%a") do (
				if exist core\data\template\dev\%%A.txt (
					echo locate:data\template\dev\%%A.txt>>Update_%args2%\update
					echo move:%%A.txt:data\template\dev>>Update_%args2%\update
			
					copy core\data\template\dev\%%A.txt Update_%args2%\data\template\dev
				)
			)
		)
	)
	
	if %args%==install (
		cls
		echo Install of DMCNet Update Package %args2% commencing
		timeout /t 2 /nobreak >nul
		echo.
		echo Prepping file structure for install
		echo.
		timeout /t 1 /nobreak >nul
		if not exist core (
			mkdir core
		)
		echo Installing update %args2% for DMCNet
		echo.
		for /f "tokens=1,2,3,4 delims=:" %%a in (Update_%args2%\update) do (
			if %%a==extract (
				if exist core\%%b.bat (
					del core\%%b.bat
				)
				
				copy Update_%args2%\%%b.txt core
				
				ren core\%%b.txt %%b.bat
			)
			
			if %%a==locate (
				if exist core\%%b (
					del core\%%b
				)
				
				copy Update_%args2%\%%b core
			)
			
			if %%a==new (
				if %%b==folder (
					if not exist core\%%c (
						mkdir core\%%c
					)
				)
			)
			
			if %%a==move (
				move core\%%b core\%%c
			)
			
			if %%a==rename (
				ren core\%%b %%c
			)
		)
	)
	
	echo.
	echo Returning to prompt.
	
	timeout /t 4 /nobreak >nul
	
	cls
	
	goto prompt
)

start core\core.bat %func% %args% "%CD%" "%flags%"

:endFuncs

if "%1"=="nogui" (
	goto prompt
)

cls
goto gui

:CREATE_MOUSE
Setlocal EnableExtensions EnableDelayedExpansion
pushd "!temp!"
if exist Mouse.exe exit/b
Del /f /q /a Mouse.exe >nul 2>&1
For %%b In (
"4D53434600000000E5020000000000002C000000000000000301010001000000000000"
"00460000000100010052050000000000000000BB3CE87420004D6F7573652E65786500"
"AE44DE4B97025205434B9D54CD6B1341149F4DABC46ABB117AF1204ED05E4422E8510F"
"151D3FA0D5A1AD17A9A46B77DA0637BBCB66AA15142A6BA121047AD09B07FF88A2D14B"
"02F6500F3D7A2B9883960DF4D0839420B5DB371FE9177ED561DFFCE6FDE6CD9BF9BD9D"
"DDFE7B73A80D21D40E16C70855906ABDE8EF6D1AACEBD4872E347F64295D31FA96D243"
"13B902F6036F3CB0F278D4725D8FE3070C07932ECEB9F8DA9D419CF76C96E9ECEC38A3"
"735082509F91D893B78ECCB6A3C6E13D5CEF71E85260589F4E8C13EADC08ED204D2B5E"
"B436D9A754EC366E836C18F25DFE07AD076DC390F7DC1FE6339C4DF1D661B416B4B70C"
"42EA48C6B6B82574198A18307689DD7957B5FF3DE7DDE2B7E7AB4918CC95C90F1A8923"
"870BED66956C52E836A8F916E80AC2BD8846B386984CC92BD210DDA78F72B978977395"
"F5388E69E4404C916CC89822592E93262D419A6818F81269868BA9B05E0DEB5F147B5B"
"B2CB3335F3C52191F4357465F29D56844A5A267515761E5CF31DA987CD84395340624D"
"14360DB989F9B25654194C39917C2FD6CE261BA75B71897D711D3A2E21E3F4F6271519"
"D61266B5FFEB5831A91CE5AF80DF18027DA5969C57527DAB7EDDB2004AF26A455C3C28"
"1932A064CF643D934A4FF45855B74C56A98CA642AB285159E4B4E46C7709B8ED7DEE6F"
"C671B870AC48D64A648D46D75502D839EE19C6E21B8D7BB8C6298D4F354E6B1CD1686B"
"9CD0E848045A3EBFBB1FB378673C8FD5BD7EB38BFB09638E7FBDB60AFC22D867B015B0"
"751DD701DFE809B0B36097D2078FCD171E8D063C633B0E387E9073F9180CB2A39ECB03"
"CF19F385932D309EB57C3FCB9FF84C12E38CE7AD9C6B05E3E206B1A91C470F59E032E7"
"E2059DEA06E383DCBE69B9B6C3947BD5730B9EC3FAE1A705C4E07E628059B6666EB9FE"
"24BF227E245B") Do >>Mouse.exe (Echo.For b=1 To len^(%%b^) Step 2
Echo WScript.StdOut.Write Chr^(Clng^("&H"^&Mid^(%%b,b,2^)^)^) : Next)
Cscript /b /e:vbs Mouse.exe > Mouse.ex_
Expand -r Mouse.ex_ >nul 2>&1
Del Mouse.ex_ >nul 2>&1
popd
Exit/b

:strLen
set char=!tmp:~0,1!
set EOLChar=$
set tmp=%~1
set tmp=!tmp!%EOLChar%
set /a length=0
:loop
set tmp=!tmp:~1!

set /a length+=1

if not "!tmp!"=="%EOLChar%" goto :loop

set "tmp="

goto:EOF