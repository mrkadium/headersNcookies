#!/bin/bash
#https://dev.to/ifenna__/adding-colors-to-bash-scripts-48g4
#https://quickref.me/awk.html

INPUT="input.txt"
HEADERS=("Strict-Transport-Security" "X-Frame-Options")
RED="\e[31m"
GREEN="\e[32m"
MAGENTA="\e[35m"
ENDCOLOR="\e[0m"

# HEADERS PART
echo -e "${MAGENTA}SECURITY HEADERS${ENDCOLOR}"
while read app
do
    echo $app
    for header in "${HEADERS[@]}"
    do
        url=${app::-1}
        result=$(curl -s -I $url | grep -i "$header")
        
        if [ -z "$result" ]
        then
            echo -e "  ${RED}$header not configured${ENDCOLOR}"
        else
            echo -e "  ${GREEN}Configured: $result${ENDCOLOR}"
        fi
    done
    echo
done < $INPUT



# COOKIES PART
echo
echo
echo
echo -e "${MAGENTA}COOKIES' SECURITY ATTRIBUTES${ENDCOLOR}"
COOKIES=("secure" "httpOnly")
COOKIES+=("sameSite")

while read app
do
    echo $app
    for cookie in "${COOKIES[@]}"
    do
        url=${app::-1}
        cookies_names=$(curl -s -I $url | grep -i "set-cookie" | awk -F: '{ print $2 }' | awk -F\; '{ 
        var1=match($1,"=")
        print substr($1,1,var1-1) }')
        cookies_attributes=$(curl -s -I $url | grep -i "set-cookie" | awk -F: '{ print $2 }')

        if [[ -z "$cookies_attributes" ]]; then #if no cookies found
            echo "  No cookies found"
            continue #go to next app
        fi
        echo "-$cookie"
        
        cookies_found=()
        attributes=()
        
        while IFS= read -r line; do
            cookies_found+=($(echo $line | tr '[:upper:]' '[:lower:]'))
        done <<< "$cookies_names"

        while IFS= read -r line; do
            lowerlines=$(echo $line | tr '[:upper:]' '[:lower:]')
            attributes+=("$lowerlines")
        done <<< "$cookies_attributes"

        for cook in "${cookies_found[@]}"; do
            for att in "${attributes[@]}"; do
                if [[ $att == *"$cook"* ]]; then #if it's the cookie
                    if [[ $att == *"$cookie"* ]]; then #and if it has the attribute
                        echo -e "  ${GREEN}$cookie attribute found in $cook${ENDCOLOR}"
                    else
                        echo -e "  ${RED}$cookie attribute NOT found in $cook${ENDCOLOR}"
                    fi
                fi
            done
        done

    done
    echo
done < $INPUT



# function read_stdin() 
# { 
# cat > file.txt 
# } 
# read_stdin