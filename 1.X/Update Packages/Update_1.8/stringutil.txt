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

:strLen string len -- returns the length of a string
::                 -- string [in]  - variable name containing the string being measured for length
::                 -- len    [out] - variable to be used to return the string length
:: Many thanks to 'sowgtsoi', but also 'jeb' and 'amel27' dostips forum users helped making this short and efficient
:$created 20081122 :$changed 20101116 :$categories StringOperation
:$source http://www.dostips.com
(
    set "str=A!%~2!"&rem keep the A up front to ensure we get the length and not the upper bound
                     rem it also avoids trouble in case of empty string
    set "len=0"
    for /L %%A in (12,-1,0) do (
        set /a "len|=1<<%%A"
        for %%B in (!len!) do if "!str:~%%B,1!"=="" set /a "len&=~1<<%%A"
    )
)
( REM RETURN VALUES
    IF "%~3" NEQ "" SET /a %~3=%len%
)
goto:EOF