if not defined MatrixSizeY set MatrixSizeY=!MatrixSize!

for /l %%A in (1, 1, !MatrixSize!) do (
	for /l %%B in (1, 1, !MatrixSizeY!) do (
		<nul set /p =#
		
		if %%B==!MatrixSizeY! (
			echo.
		)
	)
)