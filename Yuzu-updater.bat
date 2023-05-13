@echo off
set dlfile=%temp%\yuzu.zip
set dirmain=yuzu
set ddmain=yuzu-windows-msvc
set linkmain=yuzu-emu/yuzu-mainline
set dirpine=yuzu-ea
set ddpine=yuzu-windows-msvc-early-access
set linkpine=pineappleEA/pineapple-src
goto :START

:START
cls
echo.
echo          **Yuzu Installer/Updater**
echo.
echo     1 - Yuzu Mainline
echo     2 - Yuzu EA (pineappleEA release)
echo     3 - Exit
echo.
choice /C:123 /N /M "   Choose [1,2,3]: "
if errorlevel 3 goto exit
if errorlevel 2 goto:pineappleEA
if errorlevel 1 goto:mainline

:mainline
set diryuzu=%dirmain%
set defdir=%ddmain%
set br=%linkmain%
goto :CHECK_VER

:pineappleEA
set diryuzu=%dirpine%
set defdir=%ddpine%
set br=%linkpine%
goto :CHECK_VER

:CHECK_VER
set link=https://api.github.com/repos/%br%/releases/latest
set yuzulastverpath=.\%diryuzu%\ver.txt
IF NOT EXIST %yuzulastverpath% (set oldv=none)
set /p oldv=<%yuzulastverpath%
for /f "tokens=2 delims=, " %%a in ('curl -s %link% ^| findstr /L "tag_name"' ) do ( set v=%%a )
cls
echo.
echo          **You choose - %diryuzu%**
echo.
echo     Current online %diryuzu% version - %v%
echo     Current file version - %oldv%
echo.
choice /C:123 /N /M "   Do you want update %diryuzu% to ver - %v%? [1 - Yes, 2 - No, 3 - Exit]: "
if errorlevel 3 goto exit
if errorlevel 2 goto:START
if errorlevel 1 goto:DOWNLOAD

:DOWNLOAD
for /f "tokens=2 delims= " %%a in ('curl -s %link% ^| findstr /L "browser_download_url" ^|findstr /V "debug" ^| findstr /L ".zip"' ) do ( set dl=%%a )
if not exist %dlfile% (
    powershell -command "& {Invoke-WebRequest -Uri %dl% -OutFile %dlfile% } 
)
tar -xf %dlfile%
Xcopy .\%defdir%\ .\%diryuzu% /E /H /C /I /Y
del /f /q %dlfile%
rmdir /s /q .\%defdir%
echo %v% > .\%diryuzu%\ver.txt
goto :START
