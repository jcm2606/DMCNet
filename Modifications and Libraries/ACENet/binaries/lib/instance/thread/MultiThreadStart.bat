for /f "tokens=1,2,3 delims=," %%A in ("!MThread_!%ThreadName%!!") do (
	set MTIFunction=%%A
	set MTIArgs=%%B
	set MTIFlags=%%C
)

start /b core\core.bat !MTIFunction! !MTIArgs! "%E_CorePath%" "- !MTIFlags!"

set "MTIFunction="
set "MTIArgs="
set "MTIFlags="