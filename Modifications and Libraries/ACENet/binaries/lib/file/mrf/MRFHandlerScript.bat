REM  This MS-DOS Batch script is part of ACENet, and belongs to the ACENet developer.
REM  This script sets the passed register name to the value of the entry requested.

set "EntryFound="

cd %E_WorkingDirectory%

for /f "usebackq tokens=* eol=#" %%A in ("%MRFName%") do (
	for /f "tokens=1,2 delims=: eol=#" %%B in ("%%A") do (
		if %%B==%MRFEntryID% (
			set %MRFEntryData%=%%C
			set EntryFound=true
		)
	)
)

if not defined EntryFound (
	if %E_Debug%==true (
		echo [ACENet] Error, entry '%MRFEntryID%' could not be found within MRF '%MRFName%'
	)
)