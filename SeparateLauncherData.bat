@echo off

if exist "Launcher Data" (
	rmdir /s /q "Launcher Data"
)

mkdir "Launcher Data"

copy Main\launch_gui.bat "Launcher Data"
copy README.txt "Launcher Data"