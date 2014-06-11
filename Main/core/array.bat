@echo off

set array.return=goto :eof
set array.func=%1
set array.func.args=%2 %3 %4 %5 %6 %7 %8 %9
call :%array.func% %array.func.args%
goto :eof


:add
REM Adds a new item at the end of an array
REM Arguments: (
REM name As "Array Name",
REM value As "New value"
REM )
set array.name=%1
set array.value=%2
set "array.value=%array.value:"=%"
if defined %array.name%[0] (
	set /a array.index=%array.name%.length
	set /a array.index+=1
) else (
	set array.index=0
)
set /a "%array.name%.length+=1"
set %array.name%[%array.index%]=%array.value%
set /a array.index=0
goto :eof


:getitem
REM Get value of index in array.
REM Arguments: (
REM name As "Array Name",
REM index As "Item Index",
REM var As "Output Variable"
REM )
set array.name=%1
set array.index=%2
set array.var=%3
for /f "delims=[=] tokens=1,2*" %%a in ('set %array.name%[') do (
if %%b==%array.index% set %array.var%=%%c
)
goto :eof

:tostring
REM Get a string value of the array
REM Arguments: (
REM name AS "Array Name"
REM var AS "Output Variable"
REM )
set array.name=%1
set array.var=%2
set data=[
for /f "tokens=1,2,3 delims=[=]" %%a in ('set %array.name%[') do (
	set data=!data!%%c,
)
set data=%data%]
set %array.var%=%data%
goto :eof

:clear
REM Clears out all entries in the array
REM Arguments: (
REM name AS "Array Name"
REM )
set array.name=%1
if defined %array.name%[0] (
	for /f "tokens=1,2,3 delims=[=]" %%a in ('set %array.name%[') do ( set "%array.name%[%%b]=" )
)
goto :eof

:set
REM Sets the given index of the array to the given value
REM Arguments: (
REM name AS "Array Name"
REM index AS "Index"
REM data AS "Data"
REM )
set array.name=%1
set array.index=%2
set data=%3
set "%array.name%[%array.index%]=%data%"
goto :eof

:loop
REM Loops through all array values and allows you to do what you wish with them
REM Arguments: (
REM name AS "Array Name"
REM code AS "MS-DOS Code"
REM )
set array.name=%1
set code=%2
for /f "tokens=1,2,3 delims=[=]" %%a in ('set %array.name%[') do (
	echo %%c
)
goto :eof