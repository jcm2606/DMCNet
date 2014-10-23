@echo off

if %1==define (
	set !KYVarName!=!KYCode!
)

if %1==getKeyCode (
	for /f "tokens=1,2 delims=:" %%a in (!PATH_ACENET_Lib!\util\keyboard\KeyCodeList.txt) do (
		if %%a==!KYCode! (
			set !KYVarName!=%%b
			goto:EOF
		)
	)
)