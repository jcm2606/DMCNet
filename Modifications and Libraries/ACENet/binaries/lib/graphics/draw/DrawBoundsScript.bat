set x=!DRWBX!
set y=!DRWBY!
set x2=!DRWBX2!
set y2=!DRWBY2!

set CharCorner1=/
set CharCorner2=\

for /l %%a in (1, 1, !x2!) do (
	set /a t1=%%a-1
	set /a t2=%%a+1

	if %%a GEQ !x! (
		if %%a LEQ !x2! (
			if !t1! LSS !x! (
				set Char=%CharCorner1%
			) else (
				if !t2! GTR !x2! (
					set Char=%ChatCorner2%
				)
			)
		)
	)
	
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