@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

echo ==========================================
echo      Markdown Notes Update Tool
echo ==========================================
echo.

echo [*] Updating notes index...
echo [*] Working directory: %CD%
echo.

REM Check required files
if not exist "update_readme.py" (
    echo [ERROR] update_readme.py not found
    echo - Please run this script from the project root directory
    echo.
    pause
    exit /b 1
)

if not exist "docs" (
    echo [ERROR] docs directory not found
    echo - Please run this script from the project root directory
    echo.
    pause
    exit /b 1
)

REM Try to find Python
set PYTHON_CMD=
echo [*] Looking for Python...

where python >nul 2>&1
if !errorlevel! equ 0 (
    set PYTHON_CMD=python
    echo [OK] Found Python in system PATH
) else (
    echo [!] Python not in PATH, trying common install locations...

    if exist "C:\Python312\python.exe" (
        set PYTHON_CMD=C:\Python312\python.exe
        echo [OK] Found Python: C:\Python312\python.exe
    ) else if exist "C:\Python311\python.exe" (
        set PYTHON_CMD=C:\Python311\python.exe
        echo [OK] Found Python: C:\Python311\python.exe
    ) else if exist "C:\Python310\python.exe" (
        set PYTHON_CMD=C:\Python310\python.exe
        echo [OK] Found Python: C:\Python310\python.exe
    ) else if exist "C:\Python39\python.exe" (
        set PYTHON_CMD=C:\Python39\python.exe
        echo [OK] Found Python: C:\Python39\python.exe
    ) else if exist "C:\Python_396\python.exe" (
        set PYTHON_CMD=C:\Python_396\python.exe
        echo [OK] Found Python: C:\Python_396\python.exe
    ) else (
        echo [ERROR] Python not found. Please install Python and:
        echo   1. Add it to system PATH, or
        echo   2. Install to one of these paths:
        echo      - C:\Python312\
        echo      - C:\Python311\
        echo      - C:\Python310\
        echo      - C:\Python39\
        echo.
        pause
        exit /b 1
    )
)

echo [*] Using Python: %PYTHON_CMD%
echo.

REM Test Python
echo [*] Testing Python environment...
%PYTHON_CMD% --version
if %errorlevel% neq 0 (
    echo [ERROR] Python cannot run properly
    echo.
    pause
    exit /b 1
)

echo.
echo [*] Running Python script...
echo.

set PYTHONIOENCODING=utf-8
chcp 65001 >nul 2>&1
%PYTHON_CMD% update_readme.py
set PYTHON_EXIT_CODE=%errorlevel%
chcp 936 >nul 2>&1

echo.
echo [*] Python script finished, exit code: %PYTHON_EXIT_CODE%

if !PYTHON_EXIT_CODE! neq 0 goto python_error
goto python_ok

:python_error
echo.
echo [ERROR] Update failed (exit code: !PYTHON_EXIT_CODE!)
echo.
echo Possible solutions:
echo   1. Check Python dependencies are installed (e.g. pyyaml)
echo   2. Check file paths and permissions
echo   3. Check markdown file format
echo.
pause
exit /b 1

:python_ok

echo.
echo [OK] Notes index updated successfully!
echo.

REM Check for uncommitted changes
echo [*] Checking Git status...
git status --porcelain >temp_status.txt 2>nul
set git_changes=
if exist temp_status.txt (
    for /f "usebackq tokens=*" %%i in ("temp_status.txt") do set git_changes=%%i
    del temp_status.txt
)

if "!git_changes!"=="" (
    echo [*] No file changes detected, skipping Git operations.
    echo.
    echo ==========================================
    echo           Done!
    echo ==========================================
    pause
    exit /b 0
)

echo [*] Changed files:
git status -s 2>nul
echo.

echo [*] Changes detected, committing and pushing...
echo.

echo [*] Adding files to staging area...
git add .
if %errorlevel% neq 0 (
    echo [ERROR] git add failed
    goto end_with_error
)

set commit_msg=Update notes index - %date% %time:~0,8%
echo [*] Committing (%commit_msg%)...
git commit -m "%commit_msg%"
if %errorlevel% neq 0 (
    echo [ERROR] git commit failed
    goto end_with_error
)

echo [*] Pushing to GitHub...
git push
if %errorlevel% equ 0 (
    echo [OK] Push successful!
    goto end_success
) else (
    echo [!] Push failed, but local commit succeeded
    goto end_with_warning
)

:end_success
echo.
echo [OK] All done!
echo.
echo [*] Changes will be reflected on GitHub Pages in a few minutes:
echo     https://github.com/jingya221/SharingNotes
echo.
goto end_script

:end_with_warning
echo.
echo [!] Done with warnings
echo - You can push manually later: git push
echo.
goto end_script

:end_with_error
echo.
echo [ERROR] Operation failed
echo - Please check the error messages and run Git operations manually
echo.
goto end_script

:end_script
echo ==========================================
echo           Done!
echo ==========================================
pause
