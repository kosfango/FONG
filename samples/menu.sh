#!/bin/bash

PS3='Please enter your choice: '
options=("Run QFE" "Tossing" "Poll" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Run QFE")
            qfe &
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
