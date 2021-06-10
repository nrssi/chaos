#! /bin/env bash






src_file=sample.txt;
n=1;
IFS=$'\n'
theme_dir='/home/chanti/.config/'
theme='message.rasi'
while true
do
  readarray lines < $src_file
  time=$(date +%I:%M);
  for line in ${lines[@]}
  do
    if [[ $time == ${line:0:5} ]]
    then
      echo this is done;
      #executing the display script
      rofi -theme "$theme_dir/$theme" -e ${line:6}
      sleep 1m;
      killall rofi
    fi
  done
done
