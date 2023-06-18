@echo off
set "scriptver=0.0.4"
title Yuzu-Updater %scriptver%
set dlfile=%temp%\yuzu.zip
set dirmain=yuzu
set ddmain=yuzu-windows-msvc
set linkmain=yuzu-emu/yuzu-mainline
set dirpine=yuzu-ea
set ddpine=yuzu-windows-msvc-early-access
set linkpine=pineappleEA/pineapple-src
set shaderp=user\shader
set shadera=%AppData%\yuzu\shader
goto :START

:START
set "bp=x"
set "cc=_"
set "it=standard"
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
IF NOT EXIST .\%diryuzu%\ver.txt (set oldv=none)
set /p oldv=<%yuzulastverpath%
for /f "tokens=2 delims=, " %%a in ('curl -s %link% ^| findstr /L "tag_name"' ) do ( set v=%%a )
cls
echo.
echo                    **You choose - %diryuzu%** [%it%]
echo     (press "4" to toggle between standard and portable installation)     
echo.
echo     Current online %diryuzu% version - %v%
echo     Current file version - %oldv%
echo.
echo     [%cc%] - Clean Shader Folder (press "5" to toggle activate/deactivate)
echo     [%bp%] - Backup Profile Folder (press "6" to toggle activate/deactivate)
echo.
choice /C:123456 /N /M " Do you want update %diryuzu% to ver - %v%? [1 - Yes, 2 - No, 3 - Exit]: "
if errorlevel 6 goto:SWITCH_BP
if errorlevel 5 goto:SWITCH_CC
if errorlevel 4 goto:PORTABLE
if errorlevel 3 goto exit
if errorlevel 2 goto:START
if errorlevel 1 goto:DOWNLOAD

:DOWNLOAD
if %bp%==x call :BACKUP
for /f "tokens=2 delims= " %%a in ('curl -s %link% ^| findstr /L "browser_download_url" ^|findstr /V "debug" ^| findstr /L ".zip"' ) do ( set dl=%%a )
if not exist %dlfile% (
    powershell -command "& {Invoke-WebRequest -Uri %dl% -OutFile %dlfile% } 
)
tar -xf %dlfile%
Xcopy .\%defdir%\ .\%diryuzu% /E /H /C /I /Y
del /f /q %dlfile%
rmdir /s /q .\%defdir%
echo %v% > .\%diryuzu%\ver.txt
if %it%==portable (
    if not exist .\%diryuzu%\user mkdir .\%diryuzu%\user
)
if %cc%==x call :SHADERCLEAN
goto :START

:PORTABLE
if %it% ==standard (
        set "it=portable"
    ) else (
        set "it=standard"
    )
goto :CHECK_VER

:SWITCH_BP
if %bp% ==x (
        set "bp=_"
    ) else (
        set "bp=x"
    )
goto :CHECK_VER

:BACKUP
if %it%==portable (
   tar -a -cf .\profile-backup.zip -C .\%diryuzu%\ user 
    ) else (
    tar -a -cf .\profile-backup.zip -C %APPDATA% yuzu
)
goto :EOF

:SWITCH_CC
if %cc% ==_ (
        set "cc=x"
    ) else (
        set "cc=_"
    )
goto :CHECK_VER

:SHADERCLEAN
if %it%==portable (
    rmdir /s /q .\%diryuzu%\%shaderp%
    ) else (
    rmdir /s /q %shadera%    
)
goto :EOF
