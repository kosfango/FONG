#!/bin/bash

PS3='Please enter your choice: '
options=("Run QFE" "Run Golded" "Tossing" "Poll" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Run QFE")
            qfe &
            ;;
        "Run Golded")
            /usr/local/fido/golded/golded -c/home/fido/golded/cfgs/config/golded.cfg
            ;;
        "Tossing")
	    ~/lib/toss.sh
            ;;
        "Poll")
	    ~/lib/poll.sh
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
