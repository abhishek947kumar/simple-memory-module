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

if not exist "vivado_proj\simple_memory_module.xpr" (
    echo Project not found. Creating project first...
    call %VIVADO_CMD% -mode batch -source "scripts\create_project.tcl" -nolog -nojournal
)

echo Opening project in Vivado GUI...
start "" %VIVADO_CMD% "vivado_proj\simple_memory_module.xpr"
