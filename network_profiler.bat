@echo off

set hour=%time:~0,2%
set /a hour=%hour%+100
set hour=%hour:~1,2%

set minute=%time:~3,2%
set /a minute=%minute%+100
set minute=%minute:~1,2%

set serond=%time:~6,2%
set /a serond=%serond%+100
set serond=%serond:~1,2%

set datetime=%date:~-8,4%-%date:~0,2%-%date:~3,2%-%hour%-%minute%-%serond%
set foldername=C:\netstat-profiler
set filename=%foldername%\netstat-%datetime%.log

if not exist %foldername% mkdir %foldername%

type NUL > %filename%

echo %datetime% > %filename%
netstat -anb >> %filename%
echo -- >> %filename%
echo. >> %filename%

call:countWait "CLOSE_WAIT",%filename%
call:countWait "FIN_WAIT",%filename%
call:countWait "FIN_WAIT_2",%filename%
call:countWait "TIME_WAIT",%filename%
call:countWait "ESTABLISHED",%filename%

echo -- >> %filename%
echo. >> %filename%

echo dynamic port status >> %filename%
netsh int ipv4 show dynamicport tcp >> %filename%

echo -- >> %filename%
echo. >> %filename%

echo cpu usage >> %filename%
typeperf -sc 3 "\processor(_total)\%% processor time" >> %filename%

echo -- >> %filename%
echo. >> %filename%

echo memory usage >> %filename%
set totalMem=
set availableMem=
set usedMem=
for /f "tokens=4" %%a in ('systeminfo ^| findstr Physical') do if defined totalMem (set availableMem=%%a) else (set totalMem=%%a)
set totalMem=%totalMem:,=%
set availableMem=%availableMem:,=%
set /a usedMem=totalMem-availableMem
echo Total Memory: %totalMem% MB  >> %filename%
echo Used Memory: %usedMem% MB>> %filename%
tasklist >> %filename%

:countWait
for /F "delims=" %%a in ('findstr /c:"%~1" "%~2" ^| find /c /v ""') do set count=%%a
echo %~1 >> %~2
echo %count% >> %~2