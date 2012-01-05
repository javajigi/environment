wget -nc http://apache.tt.co.kr/maven/binaries/apache-maven-2.2.0-bin.zip -P %TEMP%
unzip -o %TEMP%\apache-maven-2.2.0-bin.zip -d D:\app
setx M2_HOME D:\app\apache-maven-2.2.0
set M2_HOME=D:\app\apache-maven-2.2.0
setx MAVEN_OPTS -Xmx128m
set MAVEN_OPTS=-Xmx128m
set PATH=%PATH%;%M2_HOME%\bin
