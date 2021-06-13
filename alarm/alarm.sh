#! /bin/env bash
###################################################################
# ╔═╗ ╔╗╔═══╗╔═══╗╔═══╗╔══╗                                       #
# ║║╚╗║║║╔═╗║║╔═╗║║╔═╗║╚╣╠╝  N R Shyamsundar Iyanger              #
# ║╔╗╚╝║║╚═╝║║╚══╗║╚══╗ ║║   nrshyamsundariyanger@protonmail.com  #
# ║║╚╗║║║╔╗╔╝╚══╗║╚══╗║ ║║   https://github.com/nrssi/chaos       #
# ║║ ║║║║║║╚╗║╚═╝║║╚═╝║╔╣╠╗                                       #
# ╚╝ ╚═╝╚╝╚═╝╚═══╝╚═══╝╚══╝                                       #
###################################################################
#
# This script need rofi installed in ur system
#
# Ubuntu:
# sudo add-apt-repository ppa:jasonpleau/rofi
# sudo apt update
# sudo apt install rofi
#
# Arch :
# sudo pacman -S rofi
#
# I know it's dumb to implement a alarm for a desktop and dumb too
# but nobody's stopping me ⊂(◉‿◉)つ
# if you have any ideas to make this dumb idea more dumb... I'm all ears
#
# provide the path to the configuration file
# configuration file has a specific syntax
# the configuration must be written in the following format
# time=message(notification text to be displayed)
# now the time must be of the form hh:mm include seconds if you want
# default for seconds is 00. Message can be text with any valid characters
#
#
# provide the full path to the configuration file
src_file=/home/chanti/.scripts/sample.config;
# provide a theme for rofi (optional but still I don't want my notification to pop up
# at the center of the screen so..... ¯\(o_o)/¯
theme_dir='/home/chanti/.config/';
theme='message.rasi'


declare -a periods messages diff;
# function reads the input from the given config file 
# writes all the values available into 2 different arrays Periods for time and message for messages
read_input(){
  IFS=$'='
  while read -re period message
  do
    periods+=($period);
    messages+=($message);
  done < $src_file
}
# function returns the index of the parameter passed
# pretty normal function Lol
get_index(){
  index=0;
  for i in ${!diff[@]}
  do
    if (( $1 == ${diff[$i]} ))
    then
      index=$i;
    fi
  done
  echo "$index";
}
# function returns the minimum non negative numbers in the periods array
# another normie
get_min(){
  min=86460;
  for i in ${diff[@]}
  do
    if [ $i -lt 0 ] 
    then
      continue;
    fi
    if [ $i -lt $min ]
    then
      min=$i;
    fi
  done
  if [ $min -eq 86400 ]
  then 
    min=0;
  fi
  index=$(get_index $min);
  echo  "$min $index";
}
# calculates the difference between the time in the config and the time invoked
# and writes it to diff array
diff(){
  now=`date +%I:%M:%S`;
  for period in ${periods[@]}
  do
    IFS=: read hour_now min_now sec_now <<< "$now";
    IFS=: read hour_nxt min_nxt sec_nxt <<< "$period";
    # defaulting sec_nxt value to 0 if uninitialized
    if [ -z "$sec_nxt" ] 
    then
      sec_nxt=0;
    fi
    # the 10# is there to avoid errors with leading zeros
    # by telling bash that we use base 10
    total_minutes_now=$((10#$hour_now*3600 + 10#$min_now*60 + 10#$sec_now ));
    total_minutes_nxt=$((10#$hour_nxt*3600 + 10#$min_nxt*60 + 10#$sec_nxt ));
    ((res=$total_minutes_nxt-$total_minutes_now));
    diff+=($res);
  done
}
# this shell scripts sleeps it's way through the time till notification needs to be executed
# so much like me Hahaha
# function provides a wrap around for sleep command(for easier parameter passing)
sleep_in(){
  sleep $1; 
}
# debug function to print content of all the buffers
debug(){
  for i in ${!periods[@]}
  do
    echo ${periods[$i]} ------- ${diff[$i]} ------ ${messages[$i]};
  done
}
# the main guy :-)
main(){
  while true
  do
    read_input;
    diff;
    IFS=$" ";
    read res index <<< $(get_min);
    get_min;
    # debug;
    sleep_in $res;
    string=${messages[$index]};
    echo string contains : $string;
    exec rofi -theme "$theme_dir/$theme" -e "$string";
  done
}
main #call to main
