@echo off

REM Flags:
REM   -debug : Enables debugging output
REM   -showDOSOutput : Enables MS-DOS logging of pre-expansion code, useful for debugging
REM   -showBranding : Prints the environment branding (version number, flags parsed) after the configuration
REM                   map is loaded

REM Hook invoking
REM     Hook values:
REM       - "hookType": Validates the hookType variable, determining the type of hook the current read hook is.
REM       - "runMode": Determines what DMCNet core function (whether to run a class or a command line) to invoke this
REM                    hook at. Valid modes are "line", and "class", invoking only on command line or class load
REM                    respectively. Ignore to invoke regardless.

REM Declaration of flags variable
set E_Flags=%4

if not x%E_Flags:-showDOSOutput=%==x%E_Flags% (
	@echo on
)

set E_ShowEventData=false

if not x%E_Flags:-showEventData=%==x%E_Flags% (
	set E_ShowEventData=true
)

setlocal EnableDelayedExpansion

REM Input variable declaration
set function=%1
set args=%2
set loc=%3

set E_Debug=false

if not x%E_Flags:-debug=%==x%E_Flags% (
	set E_Debug=true
)

if %E_Debug%==true (
	echo [%TIME%] [DMCNet] Declaring environment variables
)



REM Environment variable declaration
set E_Version_Major=1
set E_Version_Minor=8
set E_Version=%E_Version_Major%.%E_Version_Minor%
set "E_CoreObjMapPath=%loc:"=%\dmcnet.txt"
set "E_CorePath=%loc:"=%"
set TicketFile=ticket
set TITLE_DEFAULT=DMCNet %E_Version%
set TITLE=!TITLE_DEFAULT!



if not x%E_Flags:-showBranding=%==x%E_Flags% (
	echo DMCNet Update Package %E_Version%
	echo Path: "%E_CorePath%\"
	echo Flags: %E_Flags%
)

if %E_Debug%==true (
	echo [%TIME%] [DMCNet] Declaring pathing variables
)



REM Pathing declaration
set PATH_Dev_SRC=%CD%\src
set PATH_Dev_COMPILED=%CD%\compiled
set PATH_Home=%homedrive%\
set PATH_User=%userprofile%
set PATH_UserAppdata=%appdata%
set "PATH_LibFolder=%E_CorePath%\core\lib"
set "PATH_TicketFolder=%E_CorePath%\core\ticket"

REM User variable declaration
set userName=%username%



call :coreConfigMapLoad

for /r "core\exception" %%A in (*.dmc) do (
	call :inclusion "define", "%%~nA", "core\exception\%%~nA"
	call :exception "object", "%%~nA"
)

title %TITLE%



if not exist "%PATH_LibFolder%" (
	mkdir "%PATH_LibFolder%"
)



REM 'START' hook trigger
REM Subscribe to the 'START' event to implement this hook
call :triggerHook "START"



if %function%==class goto func_run
if %function%==line title DMCNet Command Line && goto prompt
if %function%==project goto func_runProject



echo Error: Command not recognised
pause
exit



:func_run 

set class=%args%

:loadClass 

for %%A in (%E_Flags%) do (
	set "tempdata=%%A"
	set "data=!tempdata:-=!"
	
	if not !data!=="" (
		if not !data!==!%tempdata%! (
			call core\array.bat add ClassArguments !data!
		)
	)
)

if %E_Debug%==true (
	echo [%TIME%] [DMCNet] Setting class variables
)

set "C_ClassLocation=%E_WorkingDirectory%\%class%.dmc"

for /f %%a in ("%class%.dmc") do (
	set C_ClassName=%%~na
)

set C_Title=DMCNet %E_Version% - %C_ClassName%
set C_LaunchParams=%function% %args%
set C_LaunchTime=%TIME%
set C_LaunchDate=%DATE%
set C_ClassParent=DMCNet.Core

set E_ID=!C_ClassName!

if not exist "%E_WorkingDirectory%\%class%.dmc" (
	set errorclass=%class%

	call :exception "throw", "ClassNotFoundException"
)

REM 'CLASS.PREBUILD' hook trigger
REM Subscribe to the 'CLASS.PREBUILD' event to implement this hook
call :triggerHook "CLASS.PREBUILD"

call :buildClass "usebackq eol=#", " ", "%E_WorkingDirectory%\%class%.dmc", "%class%"

REM 'CLASS.POSTBUILD' hook trigger
REM Subscribe to the 'CLASS.POSTBUILD' event to implement this hook
call :triggerHook "CLASS.POSTBUILD"

set C_LineCount=0

for /F "tokens=1* delims=]" %%a in ('type "%E_WorkingDirectory%\%class%.dmc" ^| find /V /N ""') do (
	set /a C_LineCount+=1
)

if %E_Debug%==true (
	echo [%TIME%] [DMCNet] Passing class to processing
)

:class.process

call :process "usebackq eol=#", " ", "%E_WorkingDirectory%\%class%.dmc"

goto class.process

:prompt 
set /p "input=$ "

if not x%E_Flags:-debug=%==x%E_Flags% (
	set E_Debug=true
)

set class=line
set line.classDefined=true

:readInput 
if %E_Debug%==true (
	echo [%TIME%] [DMCNet] Passing string "%input%" to processing
)

call :process "eol=#", " ", "%input%"

goto prompt















REM Start common calls

:triggerHook
set hookType=%~1

for /r "%E_WorkingDirectory%" %%A in (*.hook.dmc) do (
	for /f "usebackq tokens=1,2,3" %%D in ("%%A") do (
		if %%D==# (
			if /i %%E==subscribe (
				if /i %%F==%hookType% (
					set hookValid=true
				)
			)
			
			if /i %%E==runMode (
				set hookRunmode=%%F
			)
			
			if /i %%E==path (
				set hookPath=%%F
			)
		)
	)
	
	if defined hookValid (
		if defined hookRunmode (
			if /i %func%==!hookRunmode! (
				if %E_Debug%==true (
					echo [%TIME%] [DMCNet] Hook loaded with name '%%~nA' as type '%hookType%' under run mode '!hookRunmode!'
				)
				
				call :buildClass "usebackq eol=#", " ", "%%A", "%%~nA"
				
				call :process "usebackq eol=#", " ", "%%A"
			)
		) else (
			if %E_Debug%==true (
				echo [%TIME%] [DMCNet] Hook loaded with name '%%~nA' as type '%hookType%'
			)
		
			call :buildClass "usebackq eol=#", " ", "%%A", "!hookPath!\%%~nA"
				
			call :process "usebackq eol=#", " ", "%%A"
		)
	)
	
	set "hookValid="
	set "hookRunmode="
	set "hookPath="
)

goto:EOF













REM Loads the core configuraton map for DMCNet
:coreConfigMapLoad 

if %E_Debug%==true (
	echo [%TIME%] [DMCNet] Importing data from core configuration map
)

if exist "%E_CoreObjMapPath%" (
	for /f "usebackq tokens=1,2,3,4,5,6 delims=: eol=#" %%a in ("%E_CoreObjMapPath%") do (
		set "%%a=%%b"
		
		if %%a==E_WorkingDirectory (
			set "%%a="
		
			set "E_WorkingDirectory=%E_CorePath%\%%b"
			
			if %%b==CD (
				set "E_WorkingDirectory=%E_CorePath%"
			)
		)
	)
) else (
	echo # START CORE ENVIRONMENT VALUES>>"%E_CoreObjMapPath%"
	echo E_Debug:false>>"%E_CoreObjMapPath%"
	echo E_WorkingDirectory:CD>>"%E_CoreObjMapPath%"
	echo # END CORE ENVIRONMENT VALUES>>"%E_CoreObjMapPath%"
	echo # Place custom values you wish to be loaded into>>"%E_CoreObjMapPath%"
	echo # DMCNet's environment after here>>"%E_CoreObjMapPath%"
	
	echo New DMCNet environment object map generated.
	echo Please restart DMCNet.
	pause
	exit
)

if not x%E_Flags:-debug=%==x%E_Flags% (
	set E_Debug=true
)

goto:EOF



















REM :  Called before code callback.
REM :  Called to pre-build the class, declaring functions and calling any internal class-build hooks.
:buildClass
set className=%~n4

set titlePrev=!TITLE!
title !TITLE_DEFAULT! - Building class file '!className!'

if %E_Debug%==true (
	echo [%TIME%] [DMCNet] Building class file '%className%'
)

for /f "%~1 tokens=1* delims=%~2" %%a in ("%~3") do (
	if "%%a"=="class" (
		if "%%b"=="{" (
			if %E_Debug%==true (
				echo [%TIME%] [DMCNet] Discovered class-space open clause in class '%className%'
			)
		
			set classBlockDefined=true
			
			set Class_%className%.declared=true
		)
	)
	
	if defined classBlockDefined (
		if /i %%a==function.wrap (
			for /f "tokens=1,2 delims= " %%c in ("%%b") do (
				if "%%d"=="{" (
					if %E_Debug%==true (
						echo [%TIME%] [DMCNet] Discovered function '%%c' in class '%className%', wrapping
					)
					
					call :function.wrap "%className%.%%c", "%~4"
					
					if %%c==%className%.build (
						if %E_Debug%==true (
							echo [%TIME%] [DMCNet] Discovered build function within class '%className%', invoking
						)
					
						set %className%.classDefined=true
						
						call :function.invoke "%className%.%%c"
						
						set "%className%.classDefined="
					)
					
					set functionBlockDefined=true
				)
			)
		)
		if /i %%a==function.override (
			if %E_Debug%==true (
				echo [%TIME%] [DMCNet] Discovered function override for function '%%b' in class '%className%', overriding
			)
		
			call :function.override "%%b", "%~4"
		)
		if /i %%a==function.end (
			REM :  Used to set the 'completed' variable to true to avoid false errors being thrown
			REM :  Used to set the 'isCreatingFunction' variable to false to stop line skipping when a function is being declared
		)
		if /i %%a==function.abstract (
			if not defined Function_%%b[0] (
				set FunctionName=%%b
				
				call :exception "throw", "FunctionAbstractException"
			)
		)
	) else (
		set fchar=%%a
		set val=!fchar:~1!
		set fchar=!fchar:~0,1!
		
		if "!fchar!"=="$" (
			if %E_Debug%==true (
				echo [%TIME%] [DMCNet] Discovered object modifier of type '!val!' in class '%className%'
			)
		
			if /i "!val!"=="Access" (
				set Class_%className%.globalAccess=%%b
			)
		)
		
		set "fchar="
		set "val="
	
		if /i %%a==include (
			for /f "tokens=1,2* delims= " %%c in ("%%b") do (
				call :inclusion "define", "%%c", "%%d"
			)
		)
		
		if /i %%a==build (
			call :buildClass "usebackq eol=#", " ", "%E_WorkingDirectory%\%%b.dmc", "%%b"
		)
	)
	
	if /i "%%a"=="}" (
		if defined functionBlockDefined (
			set "functionBlockDefined="
		) else (
			if %E_Debug%==true (
				echo [%TIME%] [DMCNet] Discovered class-space close clause in class '%className%'
			)
		
			set "classBlockDefined="
		)
	)
	
	
	set "completed="
)

for /f "%~1 tokens=1* delims=%~2" %%a in ("%~3") do (
	if "%%a"=="class" (
		if "%%b"=="{" (
			set classBlockDefined=true
		)
	)
	
	if defined classBlockDefined (
		if /i %%a==function.wrap (
			for /f "tokens=1,2 delims= " %%c in ("%%b") do (
				if "%%d"=="{" (
					set functionBlockDefined=true
				)
			)
		)
	) else (
		if /i %%a==inherit (
			if %E_Debug%==true (
				echo [%TIME%] [DMCNet] Class '%~3' inherits superclass '%%b', building superclass '%%b'
			)
		
			set "classBlockDefined="
		
			call :inherit "%%b"
		)
	)
	
	if /i "%%a"=="}" (
		if defined functionBlockDefined (
			set "functionBlockDefined="
		) else (
			set "classBlockDefined="
		)
	)
)

if not defined Class_%className%.declared (
	set errorClass=%~3

	call :exception "throw", "ClassNotFoundException"
)

set "classBlockDefined="

title !titlePrev!

if %E_Debug%==true (
	echo [%TIME%] [DMCNet] Built class file '%className%'
)

goto:EOF
















REM Processes class inheriting
:inherit

set inheritedClass=%~1

call :buildClass "usebackq eol=#", " ", "%E_WorkingDirectory%\%inheritedClass%.dmc", "%inheritedClass%"

set completed=true

goto:EOF
























REM Processes code
:process 

set /a line=1

for /f "%~1 tokens=1* delims=%~2" %%a in ("%~3") do (
	if "%class%"=="%~3" (
		if %E_Debug%==true (
			echo [%TIME%] [DMCNet] Processing string '%%a %%b'
		)
	)

	if not "!E_ID!"=="" (
		if exist core\Session_!E_ID!.tckt (
			if %E_Debug%==true (
				echo [%TIME%] [DMCNet] Received inter-session-communication message
			)
		
			for /f "tokens=1,2 delims==" %%A in (core\Session_!E_ID!.tckt) do (
				set %%A=%%B
			)
			
			del core\Session_!E_ID!.tckt
		)
	)

	if /i %%a==function.wrap (
		set completed=true
		
		REM :  This variable is just used to keep track of when a function is being created
		REM :  This variable determines which lines can and cannot run when declaring a function
		
		set isCreatingFunction=true
	)
	if /i %%a==function.override (
		set completed=true
		
		REM :  This variable is just used to keep track of when a function is being created
		REM :  This variable determines which lines can and cannot run when declaring a function
		
		set isCreatingFunction=true
	)
	if /i %%a==function.end (
		REM :  Used to set the 'completed' variable to true to avoid false errors being thrown
		REM :  Used to set the 'isCreatingFunction' variable to false to stop line skipping when a function is being declared
		set completed=true
		set isCreatingFunction=false
	)
	
	if /i "%%a"=="class" (
		if /i "%%b"=="{" (
			set !class!.classDefined=true
			
			set completed=true
		)
	)
	
	if not !isCreatingFunction!==true (
		if defined !class!.classDefined (
			if /i %%a==cls (
				call :clearScreen
			)
			if /i %%a==print (
				for /f "tokens=1,2 delims=." %%t in ("%%b") do (
					if "%%u"=="" (
						call :out "!%%t!"
					)
				
					if %%u==value (
						call :out "!%%t!"
					)
					
					if %%u==name (
						call :out "%%t"
					)
					
					if %%u==obj (
						echo Object[NAME="%%t", VALUE="!%%t!"]
						
						set completed=true
					)
					
					if %%u==length (
						call core\stringutil.bat getLength "!%%t!" "objlength"
						
						echo !objlength!
						
						set "objlength="
						
						set completed=true
					)
				)
			)
			if /i %%a==print.debug (
				call :outDebug "!%%b!"
			)
			if /i %%a==title (
				if not "!%%b!"=="" (
					call :setTitle "!%%b!"
				) else (
					call :setTitle "%%b"
				)
			)
			if /i %%a==def (
				for /f "tokens=1,2* delims= " %%c in ("%%b") do (
					if "%%d"=="=" (
						set varData=!%%c!
					
						call :push "normal", "%%c", "%%e"
					)
				)
			)
			if /i %%a==def.append (
				for /f "tokens=1* delims= " %%c in ("%%b") do (
					set varData=!%%c!
				
					call :push "append", "%%c", "%%d"
				)
			)
			if /i %%a==def.fromPrompt (
				for /f "tokens=1* delims= " %%c in ("%%b") do (
					set varData=!%%c!
			
					call :push "fromInput", "%%c", "%%d"
				)
			)
			if /i %%a==def.fromObject (
				for /f "tokens=1* delims= " %%c in ("%%b") do (
					set varData=!%%c!
			
					call :push "fromObject", "%%c", "%%d"
				)
			)
			if /i %%a==def.overwrite (
				for /f "tokens=1* delims= " %%c in ("%%b") do (
					set varData=!%%c!
			
					call :push "overwrite", "%%c", "%%d"
				)
			)
			if /i %%a==get (
				for /f "tokens=1,2,3 delims= " %%c in ("%%b") do (
					call :get "%%c", "%%d", "%%e"
				)
			)
			if /i %%a==pull call :pull "%%b"
			if /i %%a==waitPrompt (
				call :waitPrompt
			)
			if /i %%a==loop (
				for /f "tokens=1* delims= " %%c in ("%%b") do (
					call :loop "%%c", "%%d"
				)
			)
			if /i %%a==math (
				for /f "tokens=1,2* delims= " %%c in ("%%b") do (
					set varData=!%%d!
					set number2=!%%e!
					
					if "!number2!"=="" (
						call :math "%%c", "%%d", "%%e"
					) else (
						call :math "%%c", "%%d", "!number2!"
					)
				)
			)
			if /i %%a==if (
				for /f "tokens=1,2,3* delims= " %%c in ("%%b") do (
					set CONDITION_1=%%c
					set CONDITION_2=%%e
				
					if not %%d==ndeclared (
						if defined %%c (
							set CONDITION_1=!%%c!
						)
						
						if defined %%e (
							set CONDITION_2=!%%e!
						)
					)
				
					call :if "%%d", "!CONDITION_1!", "!CONDITION_2!", "%%f"
				)
			)
			if /i %%a==file (
				for /f "tokens=1,2* delims= " %%c in ("%%b") do (
					set fileData=!%%d!
					set writeData=!%%e!
				
					call :file "%%c", "%%d", "%%e"
				)
			)
			if /i %%a==ticket (
				for /f "tokens=1* delims= " %%c in ("%%b") do (
					set writeData=!%%d!
				
					call :ticket "%%c", "%%d"
				)
			)
			if /i %%a==@ (
				for /f "tokens=1* delims= " %%c in ("%%b") do (
					call :inclusion "invoke", "%%c", "%%d"
				)
			)
			if /i %%a==@- (
				for /f "tokens=1* delims= " %%c in ("%%b") do (
					call :inclusion "invokeFine", "%%c", "%%d"
				)
			)
			if /i %%a==@+ (
				for /f "tokens=1* delims= " %%c in ("%%b") do (
					call :inclusion "invokeFineContinue", "%%c", "%%d"
				)
			)
			if /i %%a==reload (
				goto loadClass
			)
			if /i %%a==waitFor (
				for /f "tokens=1* delims= " %%c in ("%%b") do (
					call :waitFor "%%c", "%%d"
				)
			)
			if /i %%a==reload.newInstance (
				for /f "tokens=1,2* delims= " %%c in ("%%b") do (
					set PassFlags=%E_Flags%
				
					if not "%%e"=="" (
						if not "!%%e!"=="" (
							set PassFlags="!%%e!"
						) else (
							set PassFlags="%%e"
						)
					)
				
					if defined %%d (
						start core\core.bat %%c !%%d! "%E_CorePath%" "!PassFlags!"
					) else (
						start core\core.bat %%c %%d "%E_CorePath%" "!PassFlags!"
					)
				)

				set completed=true
			)
			if /i %%a==pushLocal (
				call :pushLocal
			)
			if /i %%a==pullLocal (
				call :pullLocal
			)
			if /i %%a==map (
				for /f "tokens=1,2* delims= " %%c in ("%%b") do (
					call :map "%%d", "%%c", "%%e"
				)
			)
			if /i %%a==function.invoke (
				call :function.invoke "%%b"
			)
			if /i %%a==forEach (
				for /f "tokens=1,2* delims= " %%c in ("%%b") do (
					call :forLoop "%%c", "%%d", "%%e"
				)
			)
			if /i %%a==forEach.file (
				for /f "tokens=1,2* delims= " %%c in ("%%b") do (
					call :forLoopFile "%%c", "%%d", "%%e"
				)
			)
			if /i %%a==forEach.split (
				for /f "tokens=1,2,3* delims= " %%c in ("%%b") do (
					call :forLoopSplitArray "%%c", "%%d", "%%e", "%%f"
				)
			)
			if /i %%a==forEach.splitString (
				for /f "tokens=1,2,3* delims= " %%c in ("%%b") do (
					call :forLoopSplitString "%%c", "%%d", "%%e", "%%f"
				)
			)
			if /i %%a==while (
				for /f "tokens=1,2,3* delims= " %%c in ("%%b") do (
					call :whileLoop "%%c", "%%d", "%%e", "%%f"
				)
			)
			if /i %%a==exception (
				for /f "tokens=1,2,3 delims= " %%c in ("%%b") do (
					call :exception "%%c", "%%d", "%%e"
				)
			)
			
			for /f "tokens=1,2,3,4,5 delims=." %%A in ("%%a") do (
				if /i %%A==system (
					if /i %%B==exit (
						exit
					)
				
					if /i %%B==object (
						if /i %%C==list (
							if /i %%D==print (
								call :system.object.list.print
							)
							
							if /i %%D==clear (
								call :system.object.list.clear
							)
						)
						
						if /i %%C==getValueOf (
							for /f "tokens=1* delims= " %%c in ("%%b") do (
								call :system.object.getvalue "%%c", "%%d"
							)
						)
					)
					
					if /i %%B==session (
						if /i %%C==id (
							if /i %%D==set (
								call :system.session.id.set "%%b"
							)
							
							if /i %%D==get (
								call :system.session.id.get "%%b"
							)
						)
						
						if /i %%C==send (
							if /i %%D==interComms (
								for /f "tokens=1* delims= " %%c in ("%%b") do (
									call :system.session.send.interComms "%%c", "%%d"
								)
							)
						)
					)
					
					if /i %%B==comin (
						if not "!%%b!"=="" (
							call :cmd "!%%b!"
						) else (
							call :cmd "%%b"
						)
					)
					
					if /i %%B==object (
						for /f "tokens=1* delims= " %%c in ("%%b") do (
							call :system.object "%%C", "%%c", "%%d"
						)
					)
				)
				
				if /i %%A==class (
					if /i %%B==args (
						if /i %%C==get (
							for /f "tokens=1* delims= " %%c in ("%%b") do (
								call :class.arguments.get "%%c", "%%d"
							)
						)
					)
					
					if /i %%B==build (
						call :buildClass "usebackq eol=#", " ", "%E_WorkingDirectory%\%%b.dmc", "%%b"
						set completed=true
					)
				)
			)
		) else (			
			if /i %%a==inherit (
				set completed=true
			)
			if /i %%a==include (
				set completed=true
			)
			if /i %%a==build (
				set completed=true
			)
		)
		
		set sys.fchar=%%a
		set sys.val=!sys.fchar:~1!
		set sys.fchar=!sys.fchar:~0,1!
		
		if "!sys.fchar!"=="$" (
			if /i "!sys.val!"=="Access" (
				set completed=true
			)
		)
		
		set "sys.fchar="
		set "sys.val="
		
		if /i %%a==end call :end "%%b"
	)
	
	REM This is just a fix for a weird ass bug I found
	if /i "%%a"=="{" set completed=true
	
	if /i "%%a"=="}" (
		if !isCreatingFunction!==true (
			set completed=true
			
			set isCreatingFunction=false
		) else (
			set "%~4.classDefined="
	
			set completed=true
		)
	)
	
	if not !isCreatingFunction!==true (
		if not defined completed (
			if "%%b"=="" (
				set comm=%%a
			) else (
				set comm=%%a %%b
			)
			echo [%TIME%] [DMCNet] Error, command did not complete successfully.
			echo [%TIME%] [DMCNet] Command:
			echo [%TIME%] [DMCNet]          '!comm!' IN CLASS '{E_WorkPlace}\%class%.dmc' @ LINE !line!
			echo.
		)
	)
	
	set /a line=line+1
	set "completed="
)

set "line="

goto:EOF



:system.object
set function=%~1
set objectValue=%~2
set objectName=%~3

if /i %function%==create (
	if /i %objectValue%==this (
		set Object_%objectName%=Object.Class[ Name: "%class%" ]
	) else (
		set Object_%objectName%=Object.%objectValue%
	)
	
	set completed=true
)

goto:EOF

:system.object.list.print 

call core\array.bat tostring OBJECT_LIST string

set "string=%string:[=%"
set "string=%string:]=%"
set "string=%string:,= %"

for %%A in (%string%) do (
	echo [ Key: "%%A", Value: "!%%A!" ]
)

set completed=true

goto:EOF

:system.object.list.clear 

call core\array.bat tostring OBJECT_LIST string

set "string=%string:[=%"
set "string=%string:]=%"
set "string=%string:,= %"

for %%A in (%string%) do (
	set "%%A="
)

set completed=true

goto:EOF

:system.session.id.set
set value=%~1

set E_ID=%value%

set completed=true

goto:EOF

:system.session.id.get
set value=%~1

if not "!E_ID!"=="" (
	set %value%=!E_ID!
	
	set completed=true
)

goto:EOF

:system.session.send.interComms
set sessionID=%~1
set data=%~2

echo %data%>>core\Session_%sessionID%.tckt

if %E_Debug%==true (
	echo [%TIME%] [DMCNet] Sent inter-session-communication message '%data%' to session '%sessionID%'
)

set completed=true

goto:EOF

:class.arguments.get 
set index=%~1
set varname=%~2

if defined ClassArguments[ (
	call core\array.bat getitem ClassArguments %index% %varname%
) else (
	set %varname%=null
)

set completed=true

goto:EOF

:system.object.getvalue 
set objectName=%~1
set objectName=!%objectName%!
set varName=%~2

set "%varName%=!%objectName%!"

set completed=true

goto:EOF

:get
set func=%~1
set value=%~2
set variable=%~3

if %func%==length (
	call core\stringutil.bat getLength "%value%" "%variable%"
	
	set completed=true
)

goto:EOF

:waitPrompt

set completed=true

pause

goto:EOF

:waitFor
set varName=%~1
set varData=%~2

if %E_Debug%==true (
	echo [%TIME%] [DMCNet] Waiting for object '%varName%' to have a value of '%varData%'
)

:waitFor.INTERNAL_LABEL

if not "!E_ID!"=="" (
	if exist core\Session_!E_ID!.tckt (
		if %E_Debug%==true (
			echo [%TIME%] [DMCNet] Received inter-session-communication message
		)
	
		for /f "tokens=1,2 delims==" %%A in (core\Session_!E_ID!.tckt) do (
			set %%A=%%B
		)
		
		del core\Session_!E_ID!.tckt
	)
)

if not !%varName%!==%varData% (
	goto waitFor.INTERNAL_LABEL
)

if %E_Debug%==true (
	echo [%TIME%] [DMCNet] Object '%varName%' has a value of '%varData%', continuing code callback
)

set completed=true

goto:EOF

:clearScreen

cls

set completed=true

goto:EOF

:out 
set data=%~1

if not "%data%"=="" (
	echo %data%
	
	set completed=true
)

goto:EOF

:outDebug 
set data=%~1

if not "%data%"=="" (
	if %E_Debug%==true (
		echo %data%
	)
	
	set completed=true
)

goto:EOF

:setTitle
set data=%~1

title %data%

set completed=true

goto:EOF

:push 
set func=%~1
set object=%~2
set data=%~3

if %func%==normal (
	if "%data%"=="/separate" (
		set "%object%= "
		
		call core\array.bat add OBJECT_LIST %object%

		if defined LOG_OBJECT_PUSHES (
			call core\array.bat add OBJECT_POOL %object%
		)
		
		if %E_Debug%==true (
			echo [%TIME%] [DMCNet] Pushed data ' ' to object '%object%'
		)
		
		set Event.Object.Push.Data=Event.Object.Push[OBJECT='%object%'; DATA=' ']End
		
		if %E_ShowEventData%==true (
			echo !Event.Object.Push.Data!
		)
		
		set completed=true
	) else (
		set "%object%=%data%"
		
		call core\array.bat add OBJECT_LIST %object%
		
		if defined LOG_OBJECT_PUSHES (
			call core\array.bat add OBJECT_POOL %object%
		)
		
		if %E_Debug%==true (
			echo [%TIME%] [DMCNet] Pushed data '%data%' to object '%object%'
		)
		
		set Event.Object.Push.Data=Event.Object.Push[OBJECT='%object%'; DATA='%data%']End
		
		if %E_ShowEventData%==true (
			echo !Event.Object.Push.Data!
		)
		
		set completed=true
	)
)

if %func%==append (
	if "%data%"=="/separate" (
		if defined %object% (
			set "%object%=!varData! "
			
			if %E_Debug%==true (
				echo [%TIME%] [DMCNet] Appended data ' ' to object '%object%'
			)
			
			set Event.Object.Append.Data=Event.Object.Append[OBJECT='%object%'; DATA=' ']End
			
			if %E_ShowEventData%==true (
				echo !Event.Object.Append.Data!
			)
			
			set completed=true
		) else (
			set "%object%= "
			
			call core\array.bat add OBJECT_LIST %object%

			if defined LOG_OBJECT_PUSHES (
				call core\array.bat add OBJECT_POOL %object%
			)
			
			if %E_Debug%==true (
				echo [%TIME%] [DMCNet] Appended data ' ' to object '%object%'
			)
			
			set Event.Object.Append.Data=Event.Object.Append[OBJECT='%object%'; DATA=' ']End
			
			if %E_ShowEventData%==true (
				echo !Event.Object.Append.Data!
			)
			
			set completed=true
		)
	) else (
		if defined %object% (
			set "%object%=!varData!%data%"
			
			if %E_Debug%==true (
				echo [%TIME%] [DMCNet] Appended data '%data%' to object '%object%'
			)
			
			set Event.Object.Append.Data=Event.Object.Append[OBJECT='%object%'; DATA='%data%']End
			
			if %E_ShowEventData%==true (
				echo !Event.Object.Append.Data!
			)
			
			set completed=true
		) else (
			set "%object%=%data%"
			
			call core\array.bat add OBJECT_LIST %object%
			
			if defined LOG_OBJECT_PUSHES (
				call core\array.bat add OBJECT_POOL %object%
			)
			
			if %E_Debug%==true (
				echo [%TIME%] [DMCNet] Appended data '%data%' to object '%object%'
			)
			
			set Event.Object.Append.Data=Event.Object.Append[OBJECT='%object%'; DATA='%data%']End
			
			if %E_ShowEventData%==true (
				echo !Event.Object.Append.Data!
			)
			
			set completed=true
		)
	)
)

if %func%==overwrite (
	set Event.Object.Overwrite.Data=Event.Object.Overwrite[OBJECT='%object%'; PREDATA='!%object%!'; DATA='%data%']End

	if %E_ShowEventData%==true (
		echo !Event.Object.Overwrite.Data!
	)
	
	set "%object%=%data%"
	
	call core\array.bat add OBJECT_LIST %object%
	
	if defined LOG_OBJECT_PUSHES (
		call core\array.bat add OBJECT_POOL %object%
	)
	
	if %E_Debug%==true (
		echo [%TIME%] [DMCNet] Overwritten data within object '%object%' with data '%data%'
	)
	
	set completed=true
)

if %func%==fromInput (
	set /p %object%=%data%
	
	call core\array.bat add OBJECT_LIST %object%
			
	if %E_Debug%==true (
		echo [%TIME%] [DMCNet] Pushed data '!%object%!' from user input to object '%object%'
	)
	
	set Event.Object.PushFromPrompt.Data=Event.Object.PushFromPrompt[OBJECT='%object%'; DATA='!%object%!']End
	
	if %E_ShowEventData%==true (
		echo !Event.Object.PushFromPrompt.Data!
	)
	
	set completed=true
)

if %func%==fromObject (
	set %object%=!varData!!%data%!
	
	if %E_Debug%==true (
		echo [%TIME%] [DMCNet] Pushed data '!%data%!' from object '%data%' to object '%object%'
	)
	
	set Event.Object.PushFromObject.Data=Event.Object.PushFromObject[OBJECT='%object%'; OBJECTEXTERNAL='%data%[!%data%!]']End
	
	if %E_ShowEventData%==true (
		echo !Event.Object.PushFromObject.Data!
	)
	
	set completed=true
)

if %func%==toclipboard (
	echo %object% | clip
	
	if %E_Debug%==true (
		echo [%TIME%] [DMCNet] Pushed data '!%object%!' from object '%object%' to clipboard
	)
	
	set completed=true
)

goto:EOF

:math 
set func=%~1
set object=%~2
set "data=%~3"

if /i %func%==add (
	set /a %object%+=%data%
	
	if %E_Debug%==true (
		echo [%TIME%] [DMCNet] Incremented value in object '%object%' by '%data%'
	)
	
	set completed=true
)

if /i %func%==sub (
	set /a %object%=!varData!-%data%
	
	if %E_Debug%==true (
		echo [%TIME%] [DMCNet] Decremented value in object '%object%' by '%data%'
	)
	
	set completed=true
)

if /i %func%==multiply (
	set /a %object%=!varData!*%data%
	
	if %E_Debug%==true (
		echo [%TIME%] [DMCNet] Multiplied value in object '%object%' by '%data%'
	)
	
	set completed=true
)

if /i %func%==divide (
	set /a %object%=!varData!/%data%
	
	if %E_Debug%==true (
		echo [%TIME%] [DMCNet] Divided value in object '%object%' by '%data%'
	)
	
	set completed=true
)

if /i %func%==nullify (
	set /a %object%=0
	
	if %E_Debug%==true (
		echo [%TIME%] [DMCNet] Nullified value in object '%object%'
	)
	
	set completed=true
)

if /i %func%==set (
	if defined %data% (
		set data=!data!
	)

	set /a %object%=%data%
	
	if %E_Debug%==true (
		echo [%TIME%] [DMCNet] Set data in object '%object%' to '%data%'
	)
	
	set completed=true
)

goto:EOF

:pull 
set object=%~1

set "%object%="

if %E_Debug%==true (
	echo [%TIME%] [DMCNet] Pulled data from object '%object%'
)

set completed=true

goto:EOF

:end 
set Mode=%~1

if "%Mode%"=="" (
	set Mode=showPrompt
)

if %function%==line (
	if not "%ProjectEndHandlerClass%"=="" (
		call :process "usebackq tokens=1,2,3,4,5,6,7,8,9 delims=> eol=#", "%E_WorkingDirectory%\%ProjectEndHandlerClass%.dmcclass"
	)

	if not %Mode%==ignorePrompt (
		echo.
		echo [%TIME%] [DMCNet] Class has ended
	)
	
	goto prompt
) else (
	if not "%ProjectEndHandlerClass%"=="" (
		call :process "usebackq tokens=1,2,3,4,5,6,7,8,9 delims=> eol=#", "%E_WorkingDirectory%\%ProjectEndHandlerClass%.dmcclass"
	)

	if not %Mode%==ignorePrompt (
		echo.
		echo [%TIME%] [DMCNet] Class has ended
		pause
	)
	
	exit
)

goto:EOF

:cmd 
set data=%~1

%data%

if %E_Debug%==true (
	echo [%TIME%] [DMCNet] Executed command '%data%' in Windows Command Prompt
)

set completed=true

goto:EOF

:loop 
set data1=%~1
set data2=%~2

set TimesLooped=0
set TimesToLoop=%data1%

if %E_Debug%==true (
	echo [%TIME%] [DMCNet] Looping of command '%data2%' %TimesToLoop% times commenced
)
		
:LOOP_INTERNAL_LABEL 

if not %TimesLooped%==%TimesToLoop% (
	call :process "tokens=1* eol=#", " ", "%data2%"

	set /a TimesLooped+=1
	
	goto LOOP_INTERNAL_LABEL
)

if %E_Debug%==true (
	echo [%TIME%] [DMCNet] Looping of command '%data2%' ended
)

set completed=true

goto:EOF

:if 
set op=%~1
set data1=%~2
set data2=%~3
set code=%~4

if /i %op%==eq (
	if %data1%==%data2% (
		call :process "tokens=1* eol=#", " ", "%code%"
	)
	
	set completed=true
)

if /i %op%==neq (
	if not %data1%==%data2% (
		call :process "tokens=1* eol=#", " ", "%code%"
	)
	
	set completed=true
)

if /i %op%==gtr (
	if %data1% GTR %data2% (
		call :process "tokens=1* eol=#", " ", "%code%"
	)
	
	set completed=true
)

if /i %op%==lss (
	if %data1% LSS %data2% (
		call :process "tokens=1* eol=#", " ", "%code%"
	)
	
	set completed=true
)

if /i %op%==geq (
	if %data1% GEQ %data2% (
		call :process "tokens=1* eol=#", " ", "%code%"
	)
	
	set completed=true
)

if /i %op%==leq (
	if %data1% LEQ %data2% (
		call :process "tokens=1* eol=#", " ", "%code%"
	)
	
	set completed=true
)

if /i %op%==declared (
	if defined %data1% (
		call :process "tokens=1* eol=#", " ", "%code%"
	)
	
	set completed=true
)

if /i %op%==ndeclared (
	if not defined %data1% (
		call :process "tokens=1* eol=#", " ", "%code%"
	)
	
	set completed=true
)

if /i %op%==ex (
	if exist %data1% (
		call :process "tokens=1* eol=#", " ", "%code%"
	)
	
	set completed=true
)

if /i %op%==nex (
	if not exist %data1% (
		call :process "tokens=1* eol=#", " ", "%code%"
	)
	
	set completed=true
)

if /i %op%==inRange (
	for /f "tokens=1* delims= " %%A in ("%code%") do (
		set RANGE1=%data2%
		set RANGE2=%%A
		set code=%%B
	
		if %data1% GEQ !RANGE1! (
			if %data1% LEQ !RANGE2! (
				call :process "tokens=1* eol=#", " ", "!code!"
			)
		)
		
		set completed=true
	)
)

if /i %op%==notInRange (
	for /f "tokens=1* delims= " %%A in ("%code%") do (
		set RANGE1=%data2%
		set RANGE2=%%A
		set code=%%B

		set tempVar=false
		
		if not %data1% GEQ !RANGE1! set tempVar=true
		if not %data1% LEQ !RANGE2! set tempVar=true
	
		if !tempVar!==true (
				call :process "tokens=1* eol=#", " ", "!code!"
		)
		
		set completed=true
	)
)

goto:EOF

:file 
set func=%~1
set "file=%~2"
set data=%~3

if /i %func%==write (
	if not "!writeData!"=="" (
		if not "!fileData!"=="" (
			echo !writeData!>>!fileData!
		
			if %E_Debug%==true (
				echo [%TIME%] [DMCNet] Written data '!writeData!' to file '!fileData!'
			)
		) else (
			echo !writeData!>>%file%
			
			if %E_Debug%==true (
				echo [%TIME%] [DMCNet] Written data '!writeData!' to file '%file%'
			)
		)
	) else (
		if not "%fileData%"=="" (
			echo %data%>>!fileData!
			
			if %E_Debug%==true (
				echo [%TIME%] [DMCNet] Written data '%data%' to file '!fileData!'
			)
		) else (
			echo %data%>>%file%
			
			if %E_Debug%==true (
				echo [%TIME%] [DMCNet] Written data '%data%' to file '%file%'
			)
		)
	)
	
	set completed=true
)

if /i %func%==writeBlank (
	if not "!fileData!"=="" (
		echo.>>!fileData!
	
		if %E_Debug%==true (
			echo [%TIME%] [DMCNet] Written a blank line to file '!fileData!'
		)
	) else (
		echo.>>%file%
		
		if %E_Debug%==true (
			echo [%TIME%] [DMCNet] Written a blank line to file '%file%'
		)
	)
	
	set completed=true
)

if /i %func%==delete (
	if not "!fileData!"=="" (
		del !fileData!
		
		if %E_Debug%==true (
			echo [%TIME%] [DMCNet] Deleted file '!fileData!'
		)
	) else (
		del %file%
		
		if %E_Debug%==true (
			echo [%TIME%] [DMCNet] Deleted file '%file%'
		)
	)
	
	set completed=true
)

if /i %func%==execute (
	if not "!fileData!"=="" (
		start !fileData!
	) else (
		start %file%
	)
	
	set completed=true
)

if /i %func%==load (
	if not "!fileData!"=="" (
		call !fileData!
	) else (
		call %file%
	)
	
	set completed=true
)

goto:EOF

:cmd 
set data=%~1

%data%

goto:EOF

:ticket 
set func=%~1
set data=%~2

if not exist core\ticket (
	mkdir core\ticket
)

if /i %func%==write (
	if not "!writeData!"=="" (
		echo !writeData!>>core\ticket\%TicketFile%.txt
		
		if %E_Debug%==true (
			echo [%TIME%] [DMCNet] Written data '!writeData!' to ticket file '%TicketFile%'
		)
	) else (
		echo %data%>>core\ticket\%TicketFile%.txt
		
		if %E_Debug%==true (
			echo [%TIME%] [DMCNet] Written data '%data%' to ticket file '%TicketFile%'
		)
	)
	
	set completed=true
)

if /i %func%==file (
	if not "!%data%!"=="" (
		set TicketFile=!%data%!

		if %E_Debug%==true (
			echo [%TIME%] [DMCNet] Set ticket file to '!%data%!'
		)
	) else (
		set TicketFile=%data%
		
		if %E_Debug%==true (
			echo [%TIME%] [DMCNet] Set ticket file to '%data%'
		)
	)
	
	set completed=true
)

if /i %func%==finalise (
	if not exist core\ticket\%TicketFile%.tckt (
		if exist core\ticket\%TicketFile%.txt (
			ren core\ticket\%TicketFile%.txt %TicketFile%.tckt
			
			if %E_Debug%==true (
				echo [%TIME%] [DMCNet] Finalised ticket file '%TicketFile%'
			)
		)
	)
	
	set completed=true
)

if /i %func%==execute (
	if exist core\ticket\%TicketFile%.tckt (
		call :process "usebackq tokens=1* eol=#", " ", "core\ticket\%TicketFile%.tckt"
		
		if %E_Debug%==true (
			echo [%TIME%] [DMCNet] Executed ticket '%TicketFile%'
		)
	)
	
	set completed=true
)

if /i %func%==pull (
	if exist core\ticket\%TicketFile%.tckt (
		del core\ticket\%TicketFile%.tckt
	)
	
	set completed=true
)

if /i %func%==pullRaw (
	if exist core\ticket\%TicketFile%.txt (
		del core\ticket\%TicketFile%.txt
	)
	
	set completed=true
)

if /i %func%==importObjectMap (
	if exist core\ticket\%TicketFile%.tckt (
		for /f "tokens=1* eol=# delims==" %%A in (core\ticket\%TicketFile%.tckt) do (
			set %%A=%%B
		)
	)
	
	set completed=true
)

goto:EOF

:inclusion 
set func=%~1
set commandName=%~2
set commandScript=%~3

REM echo %func% %commandName% %commandScript%

if %func%==define (
	if not defined Inclusion_%commandName% (
		set Inclusion_%commandName%=%commandScript%.dmc
		
		if exist %commandScript%.dmc (
			call :buildClass "usebackq tokens=1* eol=#", " ", "%commandScript%.dmc", "%commandScript%"
		
			if %E_Debug%==true (
				echo [%TIME%] [DMCNet] Inclusion class '%commandScript%' declared
			)
		) else (
			set errorclass=%commandScript%.dmc
			
			call :exception "throw", "ClassNotFoundException"
		)
	)
	
	set completed=true
)

if %func%==invoke (
	if not defined FineInvokeCalled (
		if defined InclusionArguments[0] (
			call core\array.bat clear InclusionArguments
		)
		
		for %%A in (%~3) do (
			call core\array.bat add InclusionArguments %%A
		)
	
		call :process "usebackq tokens=1* eol=#", " ", "!Inclusion_%commandName%!"

		call core\array.bat clear InclusionArguments
	)
	
	set completed=true
)

if %func%==invokeFine (
	if exist !Inclusion_%commandName%! (
		set FineInvokeCalled=true
	
		call core\array.bat clear InclusionArguments
	
		for %%A in (%~3) do (
			call core\array.bat add InclusionArguments %%A
		)
	)
	
	set completed=true
)

if %func%==invokeFineContinue (
	set "FineInvokeCalled="
	
	call :process "usebackq tokens=1* eol=#", " ", "!Inclusion_%commandName%!"
	
	call core\array.bat clear InclusionArguments
	
	set completed=true
)

goto:EOF

:pushLocal 

set LOG_OBJECT_PUSHES=true

set completed=true

goto:EOF

:pullLocal 

set "LOG_OBJECT_PUSHES="

call core\array.bat tostring OBJECT_POOL string

set "string=%string:[=%"
set "string=%string:]=%"
set "string=%string:,= %"

for %%A in (%string%) do (
	set "%%A="
)

set completed=true

goto:EOF

:map 
set func=%~1
set arrayName=%~2
set data=%~3

if /i %func%==add (
	if not "!%data%!"=="" (
		call core\array.bat add %arrayName% !%data%!
	) else (
		call core\array.bat add %arrayName% %data%
	)
	
	set completed=true
)

if /i %func%==get (
	for /f "tokens=1,2* delims= " %%A in ("%data%") do (
		call core\array.bat getitem %arrayName% %%A %%B
	)
	
	set completed=true
)

if /i %func%==set (
	for /f "tokens=1,2* delims= " %%A in ("%data%") do (
		call core\array.bat set %arrayName% %%A %%B
	)
	
	set completed=true
)

if /i %func%==toString (
	call core\array.bat tostring %arrayName% %data%
	
	set completed=true
)

goto:EOF

:function.wrap 
set functionName=%~1
set functionClass=%~2

set FunctionCreateBoolean=false

for /f "usebackq tokens=* delims= " %%A in ("%E_WorkingDirectory%\%functionClass%.dmc") do (
	if !FunctionCreateBoolean!==true (
		if "%%A"=="}" (
			set FunctionCreateBoolean=false
			
			goto function.wrap_EXIT_LOOP
		)
	)

	if !FunctionCreateBoolean!==true (
		call core\array.bat add Function_%functionName% "%%A"
	)
	
	for /f "tokens=1 delims=." %%C in ("%functionName%") do (
		if defined Class_%%C.globalAccess (
			set Function_%functionName%.access=!Class_%%C.globalAccess!
		)
	)

	for /f "tokens=1,2,3 eol=#" %%B in ("%%A") do (
		for /f "tokens=1* delims=." %%E in ("%functionName%") do (
			if "%%B"=="function.wrap" (
				if "%%C"=="%%F" (
					if "%%D"=="{" (
						set Function_%functionName%.declared=true
					
						set FunctionCreateBoolean=true
					)
				)
			)
		)
	)
) 

:function.wrap_EXIT_LOOP

set FunctionCreateBoolean=false

for /f "usebackq tokens=* delims= " %%A in ("%E_WorkingDirectory%\%functionClass%.dmc") do (
	if "%%A"=="class {" (
		set classBlockDeclared=true
	)
	
	if defined classBlockDeclared (
		for /f "tokens=1,2 delims= " %%L in ("%%A") do (
			set fchar=%%L
			set val=!fchar:~1!
			set fchar=!fchar:~0,1!
			
			if "!fchar!"=="$" (
				if "!val!"=="Access" (
					set modifierDeclared=true
					set modifierType=!val!
					set modifierValue=%%M
				)
			)
			
			set "fchar="
			set "val="
		)
	)
	
	if defined modifierDeclared (
		for /f "tokens=1,2,3 eol=#" %%B in ("%%A") do (
			for /f "tokens=1* delims=." %%E in ("%functionName%") do (
				if %%B==function.wrap (
					if %%C==%%F (
						if "%%D"=="{" (
							if /i "!modifierType!"=="Access" (
								for /f "tokens=1 delims=." %%C in ("%functionName%") do (
									if defined Class_%%C.globalAccess (
										set Function_%functionName%.access=!modifierValue!
									)
								)
							)
							
							set "modifierDeclared="
							set "modifierType="
							set "modifierValue="
							
							goto function.wrap_EXIT_MODIFIER_LOOP
						)
					)
				)
			)
		)
	)
	
	if !FunctionCreateBoolean!==false (
		if "%%A"=="}" (
			set "classBlockDeclared="
		)
	)
	
	for /f "tokens=1,2,3 eol=#" %%B in ("%%A") do (
		for /f "tokens=1* delims=." %%E in ("%functionName%") do (
			if %%B==function.wrap (
				if %%C==%%F (
					if "%%D"=="{" (
						set FunctionCreateBoolean=true
					)
				)
			)
		)
	)
	
	if !FunctionCreateBoolean!==true (
		if "%%A"=="}" (
			set FunctionCreateBoolean=false
		)
	)
)

:function.wrap_EXIT_MODIFIER_LOOP

set completed=true

goto:EOF

:function.override

set functionName=%~1
set functionClass=%~2

if not defined Function_%functionName%[0] (
	if %E_Debug%==true (
		echo [%TIME%] [DMCNet] The function '%functionName%' could not be found, overriding cannot commence, aborting
	)

	goto:EOF
)

set FunctionCreateBoolean=false

call core\array.bat clear Function_%functionName%

for /f "usebackq tokens=* delims= " %%A in ("%E_WorkingDirectory%\%functionClass%.dmc") do (
	for /f "tokens=1 eol=#" %%B in ("%%A") do (
		if !FunctionCreateBoolean!==true (
			if %%B==function.end (
				set FunctionCreateBoolean=false
				goto function.wrap_EXIT_LOOP
			)
		)
	)

	if !FunctionCreateBoolean!==true (
		call core\array.bat add Function_%functionName% "%%A"
	)

	for /f "tokens=1,2 eol=#" %%B in ("%%A") do (
		if %%B==function.override (
			if %%C==%functionName% (
				set FunctionCreateBoolean=true
			)
		)
	)
) 

:function.override_EXIT_LOOP

set completed=true

goto:EOF

:function.invoke 
set functionName=%~1

for /f "tokens=1* delims=." %%h in ("%functionName%") do (
	if %%h==this (
		set functionName=%class%.%%i
	)
)

if defined Function_!functionName!.access (
	call :getFunctionAccess "!functionName!"

	if /i "!faccess!"=="private" (
		for /f "tokens=1 delims=." %%h in ("!functionName!") do (
			if not %%h==%class% (
				set errorFunction=!functionName!

				call :exception "throw", "FunctionNotFoundException"
			)
		)
	)
	
	set "faccess="
)

if not defined Function_!functionName!.declared (
	set errorFunction=!functionName!

	call :exception "throw", "FunctionNotFoundException"
)

call :getFunctionLength "!functionName!"

for /l %%n in (0, 1, !flength!) do (
	call :getFunctionEntryAt "!functionName!", "%%n"

	call :process "tokens=1* eol=#", " ", "!fentry!"
	
	set "fentry="
)

set "flength="

set completed=true

goto:EOF

:getFunctionAccess
set functionName=%~1

set faccess=!Function_%functionName%.access!

goto:EOF

:getFunctionLength
set functionName=%~1

set flength=!Function_%functionName%.length!

goto:EOF

:getFunctionEntryAt
set functionName=%~1
set index=%~2

set fentry=!Function_%functionName%[%index%]!

goto:EOF

:forLoop
set arrayName=%~1
set varName=%~2
set code=%~3

set /a len=!%arrayName%.length!

for /l %%n in (0, 1, !len!) do (
	set data=!%arrayName%[%%n]!
	
	if not "!data!"=="" (
		set %varName%=!data!

		call :process "tokens=1* eol=#", " ", "%code%"
	)
)

set completed=true

goto:EOF

:forLoopFile
set fileName=%~1
set varName=%~2
set code=%~3

if not "!%fileName%!"=="" (
	if exist !%fileName%! (
		for /f "usebackq tokens=*" %%A in ("!%fileName%!") do (
			set %varName%=%%A

			call :process "tokens=1* eol=#", " ", "%code%"
		)
	)
) else (
	if exist %fileName% (
		for /f "usebackq tokens=*" %%A in ("%fileName%") do (
			set %varName%=%%A

			call :process "tokens=1* eol=#", " ", "%code%"
		)
	)
)

set completed=true

goto:EOF

:whileLoop
set VarName=%~1
set VarOper=%~2
set Value=%~3
set Code=%~4
set Var=%VarName%

:whileLoop_InternalLabel
if %VarOper%==eq (
	if !%Var%!==%Value% (
		call :process "tokens=1* eol=#", " ", "%Code%"
		
		goto whileLoop_InternalLabel
	)
)

if %VarOper%==neq (
	if not !%Var%!==%Value% (
		call :process "tokens=1* eol=#", " ", "%Code%"
		
		goto whileLoop_InternalLabel
	)
)

if %VarOper%==gtr (
	if !%Var%! GTR %Value% (
		call :process "tokens=1* eol=#", " ", "%Code%"
		
		goto whileLoop_InternalLabel
	)
)

if %VarOper%==lss (
	if !%Var%! LSS %Value% (
		call :process "tokens=1* eol=#", " ", "%Code%"
		
		goto whileLoop_InternalLabel
	)
)

if %VarOper%==geq (
	if !%Var%! GEQ %Value% (
		call :process "tokens=1* eol=#", " ", "%Code%"
		
		goto whileLoop_InternalLabel
	)
)

if %VarOper%==leq (
	if !%Var%! LEQ %Value% (
		call :process "tokens=1* eol=#", " ", "%Code%"
		
		goto whileLoop_InternalLabel
	)
)

set completed=true

goto:EOF

:forLoopSplitArray
set arrayName=%~1
set delimeters=%~2
set tokens=%~3
set code=%~4

for /f "tokens=1,2* delims=[=]" %%A in ('set %arrayName%[') do (
	for /f "tokens=%tokens% delims=%delimeters%" %%1 in ("%%C") do (
		call :process "tokens=1* eol=#", " ", "%code%"
	)
)

set completed=true

goto:EOF

:forLoopSplitString
set string=%~1
set delimeters=%~2
set tokens=%~3
set code=%~4

if not "!%string%!"=="" (
	set string=!%string%!
)

for /f "tokens=%tokens% delims=%delimeters%" %%A in ("%string%") do (
	call :process "tokens=1* eol=#", " ", "%code%"
)

set completed=true

goto:EOF

:exception
set Func=%~1
set Arg1=%~2
set Arg2=%~3

if %Func%==object (
	set Exception_%Arg1%=!Inclusion_%Arg1%!
	
	set completed=true
)

if %Func%==throw (
	title DMCNet %E_Version% - CRASHED "%Arg1%"

	set exceptionThrown=true
	
	if not defined EXCEPTION_TRIGGER (
		set EXCEPTION_TRIGGER=UnexpectedErrorException
	)

	for /f "usebackq tokens=1,2* eol=# delims= " %%A in ("!Exception_%Arg1%!") do (
		if %%A==exception (
			if %%B==trigger (
				set EXCEPTION_TRIGGER=%%C
			)
		)
	)
	
	echo [%TIME%] [DMCNet] An unexpected error has occurred.
	echo [%TIME%] [DMCNet] An exception has been thrown.
	echo.
	echo [%TIME%] [DMCNet] Exception class: "!Exception_%Arg1%!"
	echo [%TIME%] [DMCNet] Exception trigger: "!EXCEPTION_TRIGGER!"
	echo [%TIME%] [DMCNet] Errored class: "%class%.dmc"
	echo.
	echo [%TIME%] [DMCNet] START CUSTOM EXCEPTION OUPUT
	echo.
	
	call :process "usebackq tokens=1* eol=#", " ", "!Exception_%Arg1%!"
	
	echo.
	echo [%TIME%] [DMCNet] END CUSTOM EXCEPTION OUPUT
	
	call :process "tokens=1* eol=#", " ", "end"
)

if %Func%==trigger (
	set completed=true
)

goto:EOF