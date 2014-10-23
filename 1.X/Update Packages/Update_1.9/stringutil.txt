set func=%1

if %func%==trimStart (
	set string=%2
	set char=%3
	
	goto lTrim "%string%" " %char%"
)

if %func%==getLength (
    set string=%2
    set var=%3
	
    goto strLen "!string!", "!var!"
)

:lTrim string char -- strips white spaces (or other characters) from the beginning of a string
::                 -- string [in,out] - string variable to be trimmed
::                 -- char   [in,opt] - character to be trimmed, default is space
:$created 20060101 :$changed 20080227 :$categories StringManipulation
:$source http://www.dostips.com
SETLOCAL ENABLEDELAYEDEXPANSION
call set "string=%%%~1%%"
set "charlist=%~2"
if not defined charlist set "charlist= "
for /f "tokens=* delims=%charlist%" %%a in ("%string%") do set "string=%%a"
( ENDLOCAL & REM RETURN VALUES
    IF "%~1" NEQ "" SET "%~1=%string%"
)
goto:EOF

:strLen
set string=%~2
set returnvar=%~3

set eolchar=__EOL

set tmp=%string%%eolchar%

set /a %returnvar%=0

:strLen.internal_loop

if not "!tmp!"=="%eolchar%" (
	set "tmp=!tmp:~1!"
	
	set /a %returnvar%+=1
	
	goto :strLen.internal_loop
)

goto:EOF