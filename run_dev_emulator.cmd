@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "PROJECT_DIR=%~dp0"
set "AVD_NAME=Greco_Test"
set "FLUTTER_FLAVOR=dev"
set "FLUTTER_TARGET=lib\_main\main_dev.dart"
set "DEFAULT_ANDROID_SDK=C:\Users\Admin\AppData\Local\Android\sdk"

pushd "%PROJECT_DIR%" >nul

if defined ANDROID_SDK_ROOT (
    set "ANDROID_SDK=%ANDROID_SDK_ROOT%"
) else if defined ANDROID_HOME (
    set "ANDROID_SDK=%ANDROID_HOME%"
) else (
    set "ANDROID_SDK=%DEFAULT_ANDROID_SDK%"
)

set "ADB=%ANDROID_SDK%\platform-tools\adb.exe"
set "EMULATOR=%ANDROID_SDK%\emulator\emulator.exe"

if not exist "%ADB%" (
    echo Khong tim thay adb tai "%ADB%".
    goto :fail
)

if not exist "%EMULATOR%" (
    echo Khong tim thay emulator tai "%EMULATOR%".
    goto :fail
)

where flutter >nul 2>nul
if errorlevel 1 (
    echo Khong tim thay lenh flutter trong PATH.
    goto :fail
)

call :find_emulator
if not defined DEVICE_ID (
    echo Dang mo AVD "%AVD_NAME%"...
    start "" "%EMULATOR%" -avd "%AVD_NAME%"
    "%ADB%" wait-for-device >nul
    call :find_emulator
)

if not defined DEVICE_ID (
    echo Khong lay duoc ma thiet bi emulator sau khi khoi dong.
    goto :fail
)

if /I "%~1"=="--dry-run" (
    echo PROJECT_DIR=%PROJECT_DIR%
    echo ANDROID_SDK=%ANDROID_SDK%
    echo DEVICE_ID=!DEVICE_ID!
    echo flutter run -d !DEVICE_ID! --flavor %FLUTTER_FLAVOR% -t %FLUTTER_TARGET%
    goto :success
)

echo Dang chay app tren !DEVICE_ID!...
flutter run -d !DEVICE_ID! --flavor %FLUTTER_FLAVOR% -t %FLUTTER_TARGET%
if errorlevel 1 goto :fail
goto :success

:find_emulator
set "DEVICE_ID="
for /f "skip=1 tokens=1,2" %%A in ('"%ADB%" devices') do (
    if /I "%%B"=="device" (
        echo %%A | findstr /B /C:"emulator-" >nul
        if not errorlevel 1 (
            set "DEVICE_ID=%%A"
        )
    )
)
exit /b 0

:fail
popd >nul
exit /b 1

:success
popd >nul
exit /b 0