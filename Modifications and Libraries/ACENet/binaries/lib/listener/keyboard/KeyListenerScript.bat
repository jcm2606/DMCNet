@echo off

pushd acenet\lib\listener\keyboard

if %E_Debug%==true echo [%TIME%] [ACENet] Waiting and listening for keyboard input...

bg.exe kbd

if %E_Debug%==true echo [%TIME%] [ACENet] Key pressed! Key code: %errorlevel%

set KeyPressed=%errorlevel%
set Event.Keyboard.Data=Event.Keyboard[KEY='%KeyPressed%']End

popd