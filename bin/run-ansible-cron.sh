#!/bin/sh
# Emulate cron env and run ansible pull

cd $HOME
env - HOME=/home/ansible LOGNAME=ansible SHELL=/bin/sh PATH=/bin:/sbin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin ansible-pull -U https://github.com/craigjperry2/home-network 2>&1 | tee $HOME/logs/ansible-pull.manual.$$.cron.log

