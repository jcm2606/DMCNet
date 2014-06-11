


set ObjectType=Object

if not "%1"=="" (
	set ObjectType=DObject
)

set %ObjectType%_%ObjName%=!%ObjArgs%!