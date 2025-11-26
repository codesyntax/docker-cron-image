#!/bin/sh
crontab crontab.txt
crontab -l
date
crond -f
