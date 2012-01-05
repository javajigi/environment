rem InnoSetup doesn't support slient install
wget -nc http://downloads-guests.open.collab.net/files/documents/61/2022/CollabNetSubversion-client-1.6.2-1.win32.exe -P %TEMP%
start /wait %TEMP%\CollabNetSubversion-client-1.6.2-1.win32.exe
set PATH=%ProgramFiles%\CollabNet Subversion Client;%PATH%
set APR_ICONV_PATH=%ProgramFiles%\CollabNet Subversion Client
