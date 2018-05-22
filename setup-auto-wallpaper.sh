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
    echo "Downloading Dependencies"
    curl -L -s "https://cdn.rawgit.com/jammer99/fresh-wallpaper/master/wallpaper" -o /usr/local/bin/wallpaper
    chmod +x /usr/local/bin/wallpaper
    
    curl -L -s "https://cdn.rawgit.com/jammer99/fresh-wallpaper/master/change-wallpaper" -o /usr/local/bin/change-wallpaper
    chmod +x /usr/local/bin/change-wallpaper
    
    echo "Done"
    mkdir -p /Users/$(id -un)/Pictures/unsplash-wallpapers
    echo "How Often do you want to get new wallpaper?"
    echo "1. Every Hour"
    echo "2. Twice a day"
    echo "3. Once Every Day"
    read -r -p "Choose an option: " frequency
    
    
    case "$frequency" in
	1) 
            echo "Every Hour"
            freq="1 * * * *"
            dfrq="2"
            fchg="2 * * * *";;
	2) 
            echo "Twice a Day"
            freq="1 11,19 * * *"
            dfrq="20"
            fchg="2 11,19 * * *";;
	3) 
            echo "Once Every Day"
            freq="30 11 * * *"
            dfrq="30"
            fchg="32 11 * * *";;
	4) 
            echo "Every minute"
            freq="* * * * *"
            dfrq="30"
            fchg="* * * * *";;

        *)
            echo "Once Every Day"
            freq="30 11 * * *"
            dfrq="30"
            fchg="32 11 * * *";;

    esac

    
    crontab -l > mycron.txt

    sed -i "" '/fresh-wallpaper/d' 'mycron.txt'

    echo "\nSelect The category (search term) from which you want images to be downloaded? [ex. adventure, nature, business, love etc]"
    echo "Refer unsplash.com for possible categories (there are hundreds!)"
    echo "Type 'random' to get a random picture"

    read -r -p "Leave blank to fetch daily picture : " cxt

    if [[ -z "$cxt" ]]; then
        cxt=daily
        echo "32 11 * * *  /usr/local/bin/change-wallpaper  $cxt  #fresh-wallpaper" >> mycron.txt
    else
        echo "$fchg  /usr/local/bin/change-wallpaper $cxt #fresh-wallpaper" >> mycron.txt
    fi

    echo "0 12 * * * find /Users/$(id -un)/Pictures/unsplash-wallpapers -mtime +$dfrq -type f -delete #fresh-wallpaper" >> mycron.txt

    #install new cron file

    echo "Setting New cron"
    crontab mycron.txt
    rm mycron.txt
    
    echo "Changing wallpaper now!"

    /usr/local/bin/change-wallpaper $cxt yes

    echo "Done!"

else
    exit 1
fi
