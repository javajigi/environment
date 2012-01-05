wget -nc http://rubyforge.org/frs/download.php/29263/ruby186-26.exe -P %TEMP%
start /wait %TEMP%\ruby186-26.exe /S /D="%SystemDrive%\ruby"
set PATH=%SystemDrive%\ruby\bin;%PATH%
set RUBYOPT=-rubygems
call gem update --system
call gem update rake
