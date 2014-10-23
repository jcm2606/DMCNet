pushd "!PATH_ACENET_Lib!\listener\mouse"

for /f "tokens=1-3 delims= " %%A in ('colous mouse') do (
	set MouseAction=%%A
	set MouseX=%%B
	set MouseY=%%C
	set Event.Mouse.Data=Event.Mouse[BUTTON='%%A'; X='%%B'; Y='%%C']End
)

popd