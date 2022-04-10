@echo off
cd C:\Program Files (x86)\Unreal Tournament GOTY\

del /q System\BTPog.u
System\ucc.exe make INI=..\BTPog\make.ini
