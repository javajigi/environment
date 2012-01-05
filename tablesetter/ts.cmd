@echo off

set TABLESETTER_HOME=%~dp0

set CONFIG=%1
set APP=%2
call rake -f %TABLESETTER_HOME%Rakefile -I %TABLESETTER_HOME%lib config=%CONFIG%.config app=%APP% %3 %4 %5 %6 %7 %8 %9
