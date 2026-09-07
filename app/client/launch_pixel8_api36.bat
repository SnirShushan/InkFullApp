@echo off
set SDK=%LOCALAPPDATA%\Android\Sdk
"%SDK%\emulator\emulator.exe" -avd Pixel_8_API_36_Play -dns-server 8.8.8.8,1.1.1.1 -netdelay none -netspeed full -gpu auto
