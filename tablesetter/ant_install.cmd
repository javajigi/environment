wget -nc http://apache.tt.co.kr/ant/binaries/apache-ant-1.7.1-bin.zip -P %TEMP%
unzip -o %TEMP%\apache-ant-1.7.1-bin.zip -d D:\app
setx ANT_HOME D:\app\apache-ant-1.7.1
set PATH=%PATH%;%ANT_HOME%\bin
