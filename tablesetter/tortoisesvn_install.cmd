wget -nc http://nchc.dl.sourceforge.net/sourceforge/tortoisesvn/TortoiseSVN-1.6.2.16344-win32-svn-1.6.2.msi -P %TEMP%
start /wait %TEMP%\TortoiseSVN-1.6.2.16344-win32-svn-1.6.2.msi /passive /norestart INSTALLDIR="%ProgramFiles%\TortoiseSVN"
