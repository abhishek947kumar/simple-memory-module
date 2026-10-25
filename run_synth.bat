@echo off
setlocal

REM Locate Vivado
where vivado >nul 2>nul
if %ERRORLEVEL% equ 0 (
    set VIVADO_CMD=vivado
) else if exist "C:\Xilinx\Vivado\2019.2\bin\vivado.bat" (
    set VIVADO_CMD="C:\Xilinx\Vivado\2019.2\bin\vivado.bat"
) else (
    echo [ERROR] Vivado not found in PATH or standard C:\Xilinx\Vivado\2019.2\bin path.
    pause
    exit /b 1
)

echo ==============================================================
echo Running Simple Memory Module Synthesis in Vivado
echo ==============================================================
call %VIVADO_CMD% -mode batch -source "scripts\run_synth.tcl" -nolog -nojournal

echo ==============================================================
echo Synthesis finished. Check reports/ directory for details.
echo ==============================================================
pause
