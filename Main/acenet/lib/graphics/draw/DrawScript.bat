set x=!XCoord!
set y=!YCoord!

set MODE=none

if not "!YCoord2!"=="" (
	if not "!XCoord2!"=="" (
		set MODE=INLINE
	)
)

if !Shape!==BOX (
	set Char=#
)

if !Shape!==CUSTOM (
	set Char=!ShapeValue!
)

if %MODE%==INLINE (
	set x2=!XCoord2!
	set y2=!YCoord2!
	
	goto :drawInline
)

:draw

for /l %%a in (1, 1, %x%) do (
	if not %%a==%x% (
		set "DrawData=!DrawData! "
	)
)

set "DrawData=!DrawData!%Char%"

for /l %%b in (1, 1, %y%) do (
	if %%b==%y% (
		echo !DrawData!
	) else (
		echo.
	)
)

set "DrawData="

goto:EOF

:drawInline

for /l %%a in (1, 1, !x2!) do (
	if %%a GEQ !x! (
		if %%a LEQ !x2! (
			set "DrawData=!DrawData!%Char%"
		) else (
			set "DrawData=!DrawData! "
		)
	) else (
		set "DrawData=!DrawData! "
	)
)



for /l %%a in (1, 1, !y2!) do (
	if %%a GEQ !y! (
		if %%a LEQ !y2! (
			echo !DrawData!
		) else (
			echo.
		)
	) else (
		echo.
	)
)

set "DrawData="

goto:EOF