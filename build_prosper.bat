@echo off
echo Building Prosper for Web...
flutter build web --release
echo.
echo Building Prosper for Windows...
flutter build windows --release
echo.
echo Builds completed! 
echo Web: build/web
echo Windows: build/windows/runner/Release
pause
