#!/bin/sh
xdotool windowactivate $(xdotool search --limit 1 --onlyvisible --class "$1")
