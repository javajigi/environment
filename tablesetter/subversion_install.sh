#!/bin/sh

wget -nc http://svn.bds.nhncorp.com/devenv/installer/trunk/packages/subversion-1.4.5-linux.tar.gz -P /tmp --http-user=BDS_INSTALLER --http-password=nhn135\!#%
tar xvzf /tmp/subversion-1.4.5-linux.tar.gz -C /home1/irteam/app --overwrite
