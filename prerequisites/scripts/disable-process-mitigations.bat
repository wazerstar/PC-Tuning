@echo off

SETLOCAL EnableDelayedExpansion

:: initialize mask to get mask length
PowerShell Set-ProcessMitigation -System -Disable CFG
if not %errorlevel% == 0 (
	echo error: unsupported windows version
	pause
	exit /b 1
)

:: get current mask
for /f "tokens=3 skip=2" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "MitigationAuditOptions"') do set mitigation_mask=%%a

echo info: current mask - !mitigation_mask!

:: set all values in current mask to 2 (disable all mitigations)
for /L %%a in (0,1,9) do (
    set mitigation_mask=!mitigation_mask:%%a=2!
)

echo info: modified mask - !mitigation_mask!

:: apply mask to kernel
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "MitigationOptions" /t REG_BINARY /d "!mitigation_mask!" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "MitigationAuditOptions" /t REG_BINARY /d "!mitigation_mask!" /f

echo info: done
pause
exit /b 0
