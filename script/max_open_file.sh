#!/bin/sh

# find the max number of file have open in a process
lsof -n|awk '{print $2}'|sort|uniq -c |sort -nr|head -n 1   
