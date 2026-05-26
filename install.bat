@echo off
chcp 65001 > nul
echo ========================================
echo   WeChat Video Downloader Installer
echo ========================================
echo.

:: Check admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: Please run as Administrator
    echo Right click the file and select "Run as administrator"
    pause
    exit /b 1
)

:: Get script directory
set "SCRIPT_DIR=%~dp0"
set "INSTALL_DIR=%PROGRAMFILES%\WeChatVideoDownloader"

:: Create install directory
echo Creating install directory...
mkdir "%INSTALL_DIR%" 2>nul

:: Copy files
echo Copying files...
copy "%SCRIPT_DIR%wx_video_download.exe" "%INSTALL_DIR%\" > nul
copy "%SCRIPT_DIR%config.yaml" "%INSTALL_DIR%\" > nul

:: Create batch launcher
echo @echo off > "%INSTALL_DIR%\launch.bat"
echo cd /d "%%~dp0" >> "%INSTALL_DIR%\launch.bat"
echo .\wx_video_download.exe >> "%INSTALL_DIR%\launch.bat"

:: Create desktop shortcut
echo Creating desktop shortcut...
powershell -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%USERPROFILE%\Desktop\WeChatVideoDownloader.lnk'); $s.TargetPath='%INSTALL_DIR%\launch.bat'; $s.WorkingDirectory='%INSTALL_DIR%'; $s.Save()"

:: Create Start Menu shortcut
mkdir "%APPDATA%\Microsoft\Windows\Start Menu\Programs\WeChatVideoDownloader" 2>nul
powershell -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%APPDATA%\Microsoft\Windows\Start Menu\Programs\WeChatVideoDownloader\Launch.lnk'); $s.TargetPath='%INSTALL_DIR%\launch.bat'; $s.WorkingDirectory='%INSTALL_DIR%'; $s.Save()"

:: Configure system proxy
echo.
echo Configuring system proxy...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 /f > nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /t REG_SZ /d "127.0.0.1:2023" /f > nul

:: Create uninstaller
echo.
echo Creating uninstaller...
echo @echo off > "%INSTALL_DIR%\uninstall.bat"
echo reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /f ^> nul 2^>^&1 >> "%INSTALL_DIR%\uninstall.bat"
echo del /q "%USERPROFILE%\Desktop\WeChatVideoDownloader.lnk" 2^>nul >> "%INSTALL_DIR%\uninstall.bat"
echo rd /s /q "%APPDATA%\Microsoft\Windows\Start Menu\Programs\WeChatVideoDownloader" 2^>nul >> "%INSTALL_DIR%\uninstall.bat"
echo rd /s /q "%INSTALL_DIR%" 2^>nul >> "%INSTALL_DIR%\uninstall.bat"
echo echo Uninstall completed! >> "%INSTALL_DIR%\uninstall.bat"
echo pause >> "%INSTALL_DIR%\uninstall.bat"
rename "%INSTALL_DIR%\uninstall.bat" "uninstall.exe" > nul

echo.
echo ========================================
echo   INSTALLATION COMPLETE!
echo ========================================
echo.
echo How to use:
echo   1. Double click "WeChatVideoDownloader" on desktop
echo   2. First run will install certificate, click YES
echo   3. Open WeChat PC, play any video
echo   4. Click the download button that appears
echo.
echo To uninstall:
echo   Run "uninstall.exe" in the install folder
echo.
pause
