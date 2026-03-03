@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"
chcp 65001 >nul
echo ==========================================
echo      📝 Markdown笔记系统更新工具
echo ==========================================
echo.

echo 🔄 正在更新笔记索引...
echo 💻 当前工作目录: %CD%
echo.

REM 检查必要文件是否存在
if not exist "update_readme.py" (
    echo ❌ 错误：未找到 update_readme.py 文件
    echo - 请确保在正确的目录下运行此脚本
    echo.
    pause
    exit /b 1
)

if not exist "docs" (
    echo ❌ 错误：未找到 docs 目录
    echo - 请确保在项目根目录下运行此脚本
    echo.
    pause
    exit /b 1
)

REM 尝试多种Python路径
set PYTHON_CMD=
echo 🔍 正在查找Python...

REM 首先尝试系统PATH中的python
where python >nul 2>&1
if !errorlevel! equ 0 (
    set PYTHON_CMD=python
    echo ✅ 在系统PATH中找到Python
) else (
    echo ⚠️  系统PATH中未找到Python，尝试常见安装路径...
    
    REM 尝试常见的Python安装路径
    if exist "C:\Python312\python.exe" (
        set PYTHON_CMD=C:\Python312\python.exe
        echo ✅ 找到Python: C:\Python312\python.exe
    ) else if exist "C:\Python311\python.exe" (
        set PYTHON_CMD=C:\Python311\python.exe
        echo ✅ 找到Python: C:\Python311\python.exe
    ) else if exist "C:\Python310\python.exe" (
        set PYTHON_CMD=C:\Python310\python.exe
        echo ✅ 找到Python: C:\Python310\python.exe
    ) else if exist "C:\Python39\python.exe" (
        set PYTHON_CMD=C:\Python39\python.exe
        echo ✅ 找到Python: C:\Python39\python.exe
    ) else if exist "C:\Python_396\python.exe" (
        set PYTHON_CMD=C:\Python_396\python.exe
        echo ✅ 找到Python: C:\Python_396\python.exe
    ) else (
        echo ❌ 未找到Python安装，请检查Python是否已安装
        echo.
        echo - 请确保Python已安装并：
        echo    1. 添加到系统PATH中，或
        echo    2. 安装在以下路径之一：
        echo       - C:\Python312\
        echo       - C:\Python311\
        echo       - C:\Python310\
        echo       - C:\Python39\
        echo       - C:\Python_396\
        echo.
        pause
        exit /b 1
    )
)

echo 📍 使用Python: %PYTHON_CMD%
echo.

REM 检查Python是否能正常运行
echo [*] 测试 Python 环境...
%PYTHON_CMD% --version
if %errorlevel% neq 0 (
    echo ❌ Python无法正常运行
    echo.
    pause
    exit /b 1
)

echo.
echo 🚀 开始执行Python脚本...
echo.

REM 执行 update_readme.py：更新 index.md、mkdocs.yml、README.md
REM README 导览链接统一为 .md 文件路径（如 docs/notes/AI相关/R-shiny-with-AI.md）
set PYTHONIOENCODING=utf-8
%PYTHON_CMD% update_readme.py
set PYTHON_EXIT_CODE=%errorlevel%

echo.
echo 📋 Python脚本执行完成，退出代码: %PYTHON_EXIT_CODE%

if %PYTHON_EXIT_CODE% neq 0 (
    echo.
    echo ❌ 更新失败，Python脚本执行出错（退出代码: %PYTHON_EXIT_CODE%）
    echo.
    echo 🔧 可能的解决方案：
    echo    1. 检查Python依赖是否已安装（如 pyyaml）
    echo    2. 检查文件路径和权限
    echo    3. 检查markdown文件格式是否正确
    echo.
    pause
    exit /b 1
)

echo.
echo ✅ 笔记索引更新完成！
echo.

REM 检查是否有未提交的更改
echo 🔍 检查Git状态...
git status --porcelain >temp_status.txt 2>nul
if exist temp_status.txt (
    set git_changes=
    for /f "usebackq tokens=*" %%i in ("temp_status.txt") do set git_changes=%%i
    del temp_status.txt
) else (
    set git_changes=
)

if "!git_changes!"=="" (
    echo ℹ️  没有检测到文件更改，无需Git操作。
    echo.
    echo ==========================================
    echo           ✅ 操作完成！
    echo ==========================================
    pause
    exit /b 0
)

echo 📋 检测到以下文件有更改：
git status -s 2>nul
echo.

REM 自动模式处理Git操作
echo 🤔 检测到文件更改，准备Git操作...
echo.
echo 🚀 使用自动模式：提交并推送（使用默认提交信息）
echo - 如需其他操作方式，请手动运行相关Git命令
echo.

set CHOICE_RESULT=1

if %CHOICE_RESULT%==1 (
    echo.
    echo 🚀 执行自动模式：提交并推送...
    goto auto_commit
) else if %CHOICE_RESULT%==2 (
    echo.
    echo 📦 执行提交模式：只提交不推送...
    goto commit_only
) else if %CHOICE_RESULT%==3 (
    echo.
    echo ⏩ 跳过Git操作
    goto skip_git
) else (
    echo.
    echo 🔧 进入交互模式...
    goto interactive_mode
)

:auto_commit
echo 📦 添加文件到暂存区...
git add .
if %errorlevel% neq 0 (
    echo ❌ Git add 失败
    goto end_with_error
)

set commit_msg=更新笔记索引 - %date% %time:~0,8%
echo 💾 提交更改（信息：%commit_msg%）...
git commit -m "%commit_msg%"
if %errorlevel% neq 0 (
    echo ❌ Git提交失败
    goto end_with_error
)

echo 🌐 推送到GitHub...
git push
if %errorlevel% equ 0 (
    echo ✅ 推送成功！
    goto end_success
) else (
    echo ⚠️  推送失败，但本地提交成功
    goto end_with_warning
)

:commit_only
echo 📦 添加文件到暂存区...
git add .
if %errorlevel% neq 0 (
    echo ❌ Git add 失败
    goto end_with_error
)

set commit_msg=更新笔记索引 - %date% %time:~0,8%
echo 💾 提交更改（信息：%commit_msg%）...
git commit -m "%commit_msg%"
if %errorlevel% equ 0 (
    echo ✅ 本地提交成功！您可以稍后手动推送: git push
    goto end_success
) else (
    echo ❌ Git提交失败
    goto end_with_error
)

:interactive_mode
REM 询问是否提交到Git
set /p commit_choice="🤔 是否要提交这些更改到Git？[Y/n]: "
if /i "%commit_choice%"=="n" (
    goto skip_git
)

echo 📦 添加文件到暂存区...
git add .
if %errorlevel% neq 0 (
    echo ❌ Git add 失败
    goto end_with_error
)

REM 询问提交信息
set /p commit_msg="💬 请输入提交信息（直接回车使用默认信息）: "
if "%commit_msg%"=="" (
    set commit_msg=更新笔记索引 - %date% %time:~0,8%
)

echo 💾 提交更改...
git commit -m "%commit_msg%"
if %errorlevel% neq 0 (
    echo ❌ Git提交失败
    goto end_with_error
)

REM 询问是否推送到远程仓库
set /p push_choice="🚀 是否要推送到GitHub？[Y/n]: "
if /i "%push_choice%"=="n" (
    echo ✅ 本地提交成功！您可以稍后手动推送: git push
    goto end_success
)

echo 🌐 推送到GitHub...
git push
if %errorlevel% equ 0 (
    echo ✅ 推送成功！
    goto end_success
) else (
    echo ⚠️  推送失败，但本地提交成功
    goto end_with_warning
)

:skip_git
echo ⏩ 跳过Git操作
echo - 您可以稍后手动提交和推送更改
goto end_success

:end_success
echo.
echo 🎉 操作成功完成！
echo.
echo 📱 如果推送成功，更改将在几分钟内反映到GitHub Pages
echo    https://github.com/jingya221/SharingNotes
echo.
goto end_script

:end_with_warning
echo.
echo ⚠️  操作完成但有警告
echo - 您可以稍后手动推送: git push
echo.
goto end_script

:end_with_error
echo.
echo ❌ 操作失败
echo - 请检查错误信息并手动执行Git操作
echo.
goto end_script

:end_script
echo ==========================================
echo           操作完成！
echo ==========================================
pause 