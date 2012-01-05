#!/bin/sh

wget -nc http://svn.bds.nhncorp.com/devenv/installer/trunk/packages/httpd-2.2.10-linux.tar.gz -P /tmp --http-user=BDS_INSTALLER --http-password=nhn135\!#%
tar xvzf /tmp/httpd-2.2.10-linux.tar.gz -C /home1/irteam/app --overwrite
