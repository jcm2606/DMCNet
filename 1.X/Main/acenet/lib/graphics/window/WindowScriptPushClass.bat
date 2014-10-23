REM  This MS-DOS Batch script is part of ACENet, and belongs to the ACENet developer.
REM  This script just writes the class push line to the instance ticket.
REM  Handled through a MS-DOS Batch script due to limitations in DMCNet with variables and nested-variables.

@echo off

if defined %WData% (
	set WData=!%WData%!
)

echo %WData%

echo class %WData%>> core\ticket\%TicketFile%.txt
