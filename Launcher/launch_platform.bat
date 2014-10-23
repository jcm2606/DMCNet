@echo off
setlocal EnableDelayedExpansion

REM DMCNet Launch Platform.

REM Acts as a bridge between a custom launcher and DMCNet itself.

set dmcnet_branch=%~1
set func=%~2
set args=%~3

if "!dmcnet_branch!"=="." (
	if exist bin (
		set dmcnet_branch=2.X
	)
)

if "!dmcnet_branch!"=="" (
	if exist bin (
		set dmcnet_branch=2.X
	)
)

set dmcnet_path=core

if /i "!dmcnet_branch!"=="2.X" (
	set dmcnet_path=bin
)

set dmcnet_script=core.bat

if /i "!dmcnet_branch!"=="2.X" (
	set dmcnet_script=main.bat
)

if "!func!"=="class" (
	if /i "!dmcnet_branch!"=="2.X" (
		set func=call_class
	)
)

start !dmcnet_path!\!dmcnet_script! !func! !args! "%CD%" "-"

exit /b