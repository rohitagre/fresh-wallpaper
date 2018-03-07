#!/bin/sh
PATH=/usr/local/bin:/usr/local/sbin:~/bin:/usr/bin:/bin:/usr/sbin:/sbin
cd /tmp
if [[ $EUID -eq 0 ]]; then
   echo "This script must not be run as root"  1>&2
   exit 1
fi

echo "This Script will create a new directory 'unsplash-wallpapers' \n under the Pictures Folder for the current user (~/Pictures/)"

read -r -p "Do you wish to Continue? [y/N] " response
if [[ $response =~ ^[Yy]$ ]];
then
mkdir -p ~/Pictures/unsplash-wallpapers
echo "\nSelect The category (search term) from which you want images to be downloaded? [ex. adventure, nature, business, love etc]"

crontab -l > mycron.txt

echo "Searching and removing old cron jobs set by this script (if any)"

sed -i "" '/fresh-wallpaper/d' 'mycron.txt'

read -r -p "Leave blank to fetch daily picture : " cat

if [[ -z "$cat" ]];
then
echo "30 11 * * * curl -L --compressed "https://source.unsplash.com/1920x1080/daily" -o ~/Pictures/unsplash-wallpapers/\`date +"\\%d\\%m\\%Y\\%H"\`.jpg  >/dev/null 2>&1 #fresh-wallpaper" >> mycron.txt
else
echo "35 11 * * * curl -L --compressed "https://source.unsplash.com/1920x1080/?$cat" -o ~/Pictures/unsplash-wallpapers/\`date +"\\%d\\%m\\%Y\\%H"\`.jpg  >/dev/null 2>&1 #fresh-wallpaper" >> mycron.txt
fi

echo "* * * * * osascript -e 'tell application \"System Events\" to tell every desktop to set picture to \"~/Pictures/unsplash-wallpapers/\`date +'\\%d\\%m\\%Y\\%H'\`.jpg\"' #fresh-wallpaper" >> mycron.txt

#install new cron file

echo "Setting New cron"
crontab mycron.txt
rm mycron.txt


echo "Done!"

else
exit 1
fi