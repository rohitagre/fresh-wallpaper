#!/bin/sh
PATH=/usr/local/bin:/usr/local/sbin:~/bin:/usr/bin:/bin:/usr/sbin:/sbin
cd /tmp


echo '
     _ ___  ___    -------------------
    (_) _ \/ _ \   | gimme wallpaper |
    | \_, /\_, /   -------------------
   _/ |/_/  /_/         \   ^__^
  |__/                   \  (oo)\_______
                            (__)\       )\/\
                                ||----w |
                                ||     ||
'
if [[ $EUID -eq 0 ]]; then
    echo "This script must not be run as root"  1>&2
    exit 1
fi

echo "This Script will create a new directory 'unsplash-wallpapers' \n under the Pictures Folder for the current user (~/Pictures/)"

read -r -p "Do you wish to Continue? [y/N] " response
if [[ $response =~ ^[Yy]$ ]]; then
    mkdir -p ~/Pictures/unsplash-wallpapers
    echo "How Often do you want to get new wallpaper?"
    echo "1. Every Hour"
    echo "2. Twice a day"
    echo "3. Once Every Day"
    read -r -p "Choose an option: " frequency
    
    
    case "$frequency" in
	1) 
            echo "Every Hour"
            freq="1 * * * *"
            fchg="2 * * * *";;
	2) 
            echo "Twice a Day"
            freq="1 11,19 * * *"
            fchg="2 11,19 * * *";;
	3) 
            echo "Once Every Day"
            freq="30 11 * * *"
            fchg="32 11 * * *";;
        *)
            echo "Once Every Day"
            freq="30 11 * * *"
            fchg="32 11 * * *";;
    esac

    
    crontab -l > mycron.txt

    sed -i "" '/fresh-wallpaper/d' 'mycron.txt'

    echo "\nSelect The category (search term) from which you want images to be downloaded? [ex. adventure, nature, business, love etc]"
    echo "Refer unsplash.com for possible categories (there are hundreds!)"

    read -r -p "Leave blank to fetch daily picture : " cxt

    if [[ -z "$cxt" ]]; then
        echo "$freq curl -L --compressed "https://source.unsplash.com/1920x1080/daily" -o ~/Pictures/unsplash-wallpapers/\`date +"\\%Y\\%m\\%d\\%H"\`.jpg  >/dev/null 2>&1 #fresh-wallpaper" >> mycron.txt
        curl -s -L --compressed "https://source.unsplash.com/1920x1080/daily" -o ~/Pictures/unsplash-wallpapers/`date +"\%Y\%m\%d\%H"`.jpg
   
    else
        echo "$freq curl -L --compressed "https://source.unsplash.com/1920x1080/?$cxt" -o ~/Pictures/unsplash-wallpapers/\`date +"\\%Y\\%m\\%d\\%H"\`.jpg  >/dev/null 2>&1 #fresh-wallpaper" >> mycron.txt
        curl -s -L --compressed "https://source.unsplash.com/1920x1080/?$cxt" -o ~/Pictures/unsplash-wallpapers/`date +"\%Y\%m\%d\%H"`.jpg
    fi

    echo "$fchg osascript -e 'tell application \"System Events\" to tell every desktop to set picture to \"~/Pictures/unsplash-wallpapers/\`date +'\\%Y\\%m\\%d\\%H'\`.jpg\"' #fresh-wallpaper" >> mycron.txt

#install new cron file

    echo "Setting New cron"
    crontab mycron.txt
    rm mycron.txt

    echo "Changing wallpaper now!"
    osascript -e 'tell application "System Events" to tell every desktop to set picture to "~/Pictures/unsplash-wallpapers/`date +'\%Y\%m\%d\%H'`.jpg"'
    echo "Done!"

else
    exit 1
fi
