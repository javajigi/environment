#!/bin/bash

cd /usr/apps/git-repositories/iminbak
pwd
git pull

cd /usr/apps/git-repositories/environment
ts iminbak iminbak-web build

cd /usr/apps/git-repositories/environment
ts iminbak iminbak-web restart