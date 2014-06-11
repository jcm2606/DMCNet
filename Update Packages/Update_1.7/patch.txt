@echo off

setlocal EnableDelayedExpansion

set patchFile=%1.patchset

if not exist %patchFile% (
	echo ERROR: Patch file does not exist.
)

for /f "usebackq tokens=1* eol=#" %%a in ("%patchFile%") do (
	if %%a==FILE (
		set file=%%b
	)
	
	if %%a==PATH (
		set filePath=%%b
	)
)

if "!file!"=="" (
	echo ERROR: You must specify a file to manipulate within your patch file.
)

if  "!filePath!"=="" (
	echo ERROR: You must specify a file path to write to within your patch file.
)

set line=0

for /f "usebackq tokens=1* eol=#" %%a in ("%patchFile%") do (
	for /f "usebackq tokens=*" %%c in ("!file!") do (
		set /a line+=1
		
		if %%a==ADD (
			for /f "tokens=1*" %%A in ("%%a") do (
				if %%B==!line! (
					echo !line!
					echo %%C>>!filePath!
				)
			)
		)
		
		echo %%c>>!filePath!
	)
)