@echo off
setlocal EnableDelayedExpansion

REM Ultimate Server-Side Build & Deploy Script (Windows CMD Edition)
REM Usage: deploy.cmd [jumpstartscaling|chrisamaya|both] [--dry-run] [--force] [--issue-ssl "domain.com ..."]

set "SERVER=opc@193.122.168.215"
set "EMAIL=admin@jumpstartscaling.com"

echo ========================================================
echo 🚀 Jumpstart Scaling Deployment (Windows)
echo ========================================================

REM --- Defaults ---
set "TARGET=both"
set "DRY_RUN=false"
set "FORCE=false"
set "ISSUE_SSL=false"
set "SSL_DOMAINS="

REM --- Argument Parsing ---
:parse_args
if "%~1"=="" goto :done_args

if /i "%~1"=="jumpstartscaling" set "TARGET=jumpstartscaling" & shift & goto :parse_args
if /i "%~1"=="chrisamaya" set "TARGET=chrisamaya" & shift & goto :parse_args
if /i "%~1"=="both" set "TARGET=both" & shift & goto :parse_args

if /i "%~1"=="--dry-run" set "DRY_RUN=true" & shift & goto :parse_args
if /i "%~1"=="--force" set "FORCE=true" & shift & goto :parse_args
if /i "%~1"=="--issue-ssl" (
    set "ISSUE_SSL=true"
    set "SSL_DOMAINS=%~2"
    shift
    shift
    goto :parse_args
)
shift
goto :parse_args
:done_args

echo Target:      %TARGET%
echo Dry Run:     %DRY_RUN%
echo Issue SSL:   %ISSUE_SSL% %SSL_DOMAINS%
echo.

if "%DRY_RUN%"=="true" goto :dry_run_msg

if not "%FORCE%"=="true" (
    set /p "Confirm=Continue with deployment? (y/N): "
    if /i not "!Confirm!"=="y" (
        echo Deployment aborted.
        exit /b 0
    )
)

REM --- Step 1: Package Source Code ---
echo.
echo 📦 Packaging source code (tar)...
REM We use native tar (available in Win10/11) to create a deployment package
REM Excluding node_modules, dist, .git to save bandwidth
tar -czf deployment.tar.gz --exclude "node_modules" --exclude "dist" --exclude ".git" --exclude ".env" sites

if errorlevel 1 (
    echo ❌ Failed to create tar package. Check if 'tar' is in your PATH.
    exit /b 1
)

REM --- Step 2: Upload Files ---
echo.
echo 📤 Uploading package and scripts (SCP)...
scp deployment.tar.gz server-deploy-runner.sh %SERVER%:/home/opc/

if errorlevel 1 (
    echo ❌ Upload failed. Check your SSH connection.
    del deployment.tar.gz
    exit /b 1
)

REM --- Step 3: Remote Execution ---
echo.
echo 🔨 Executing remote build script...
ssh %SERVER% "bash server-deploy-runner.sh '%TARGET%' '%ISSUE_SSL%' '%SSL_DOMAINS%' '%EMAIL%'"

if errorlevel 1 (
    echo ❌ Remote execution failed.
) else (
    echo.
    echo ✅ Deployment Complete!
)

REM --- Cleanup ---
del deployment.tar.gz
exit /b 0

:dry_run_msg
echo.
echo 🚧 DRY RUN MODE ACTIVE
echo    - Would package 'sites' folder (excluding node_modules)
echo    - Would SCP to %SERVER%
echo    - Would SSH and run server-deploy-runner.sh
echo.
exit /b 0
