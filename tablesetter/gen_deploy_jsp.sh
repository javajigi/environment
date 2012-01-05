#!/bin/sh
GENDIR=$1
CONTENTS="<%@ page contentType=\"text/html; charset=UTF-8\" %>\n <html> <head> <title>배포일자</title> </head> <body><big><strong>$(date)</strong></big> </body> </html>"
echo $CONTENTS > $1
