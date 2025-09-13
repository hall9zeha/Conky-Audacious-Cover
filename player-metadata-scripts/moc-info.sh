#!/bin/bash
###################################################################################
##                                                                               ##
##                          Created by Barry Zea H.                              ##
##                                                                               ##
##                                                                               ##
###################################################################################



conkyStyle=$1

StateFile=~/.conky/Conky-Audacious-Cover/pix/state.txt

Corners=0
CoverCorners=84
Opacity=0.5
BGColor='black'
AlbumArt="cover.jpg"
EmptyCover="audacious-empty-cover.png"

CharLength=7
StaticWidth=150
MinWidth=350
Height=138
WordCount=0

# Get metadata from mocp
Title=$(mocp -Q %song 2>/dev/null)
Artist=$(mocp -Q %artist 2>/dev/null)
Album=$(mocp -Q %album 2>/dev/null)
Status=$(mocp -Q %state 2>/dev/null)
EchoStatus="MOC $Status"

Title=${Title:-"Desconocido"}
Artist=${Artist:-"Desconocido"}
Album=${Album:-"Desconocido"}

TitleCount=$(echo -n "Title: $Title" | wc -m)
ArtistCount=$(echo -n "Artist: $Artist" | wc -m)
AlbumCount=$(echo -n "Album: $Album" | wc -m)

for varcount in $TitleCount $AlbumCount $ArtistCount; do
    if [ "$varcount" -gt "$WordCount" ]; then
        WordCount=$varcount
    fi
done

VarWidth=$(echo "${WordCount}*${CharLength}" | bc)
Width=$(echo "$StaticWidth + $VarWidth" | bc)
if [ "$Width" -le "$MinWidth" ]; then
    Width=$MinWidth
fi

# Get cover from the same directory as the file, if it does not exist, extract it from the same file if it has a cover
GetArt(){

    # Get the full path of the current file from mocp
    FilePath=$(mocp -Q %file 2>/dev/null)
    Directory=$(dirname "$FilePath")

    # Create the state file if it does not exist
    # The state file is used to prevent overwriting and extracting the album artwork if it already exists, and ensures that # the cover art is not extracted again until a new song is played.
    if [ ! -f "$StateFile" ]; then
        touch "$StateFile"
    fi

    # Read the previously saved path
    current_song=$(cat "$StateFile" 2>/dev/null)

    if [ "$FilePath" != "$current_song" ]; then
        # Save the new current song
        echo "$FilePath" > "$StateFile"

        # Temporary route to extract cover
        temp_cover=~/.conky/Conky-Audacious-Cover/pix/temp_cover.jpg

        # Extract embedded cover art (if any) using ffmpeg
        ffmpeg -i "$FilePath" -an -vcodec copy -f image2 "$temp_cover" >/dev/null 2>&1

        # If the cover could not be extracted, search the directory
        if [ $? -ne 0 ]; then
            cover_img_file=$(find "$Directory" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | head -n 1)

            if [ -n "$cover_img_file" ]; then
                cp "$cover_img_file" ~/.conky/Conky-Audacious-Cover/pix/cover.jpg
            else
                cp ~/.conky/Conky-Audacious-Cover/pix/"$EmptyCover" ~/.conky/Conky-Audacious-Cover/pix/cover.jpg
            fi
        else
            mv "$temp_cover" ~/.conky/Conky-Audacious-Cover/pix/cover.jpg
        fi
    fi
}


MocInfo() {
    case "$1" in
        art)        GetArt ;;
        status)     echo "$EchoStatus" ;;
        title)
            TitleText=$(echo "$Title" | cut -c 1-80)
            [ "${#Title}" -gt 80 ] && TitleText+="..."
            echo "\${font Noto Sans CJK JP:bold:italic:size=11}$TitleText"
            ;;
        artist)
            ArtistText=$(echo "$Artist" | cut -c 1-80)
            [ "${#Artist}" -gt 80 ] && ArtistText+="..."
            echo "\${font Noto Sans CJK JP:bold:size=8}$ArtistText"
            ;;
        album)
            AlbumText=$(echo "$Album" | cut -c 1-100)
            [ "${#Album}" -gt 100 ] && AlbumText+="..."
            echo "\${font Noto Sans CJK JP:normal:size=8}$AlbumText"
            ;;
    esac
}

case "$conkyStyle" in

    1) # Vinyl style
        MocInfo bg
        MocInfo art
        echo -n "\${image ~/.conky/Conky-Audacious-Cover/pix/vinyl_bg.png -p -20,-4 -s 266x190}"
        echo -n "\${image ~/.conky/Conky-Audacious-Cover/pix/$AlbumArt -p 28,35 -s 121x122}"

        echo ""
        echo -n "                          "
        echo -e "   \${font Ubuntu:bold:size=10}\${color}$EchoStatus"
        echo ""
        echo -n "                  "
        echo -e -n "                                                  "
        echo -n "\${color0}"
        MocInfo title
        echo -n "                "
        echo -e -n "                                                    "
        echo -n "\${color0}"
        MocInfo artist
        echo -n "                                          "
        echo -e -n "                          "
        echo -n "\${color0}"
        MocInfo album
        echo -n "                 "
        echo "";;

    2) # Minimalist style
        MocInfo bg
        MocInfo art
        echo -n "\${image ~/.conky/Conky-Audacious-Cover/pix/$AlbumArt -p 28,24 -s 120x120}"

        echo ""
        echo -n "                     "
        echo -e "   \${font Ubuntu:bold:size=10}\${color}$EchoStatus"
        echo ""
        echo -n "                  "
        echo -e -n "                                     "
        echo -n "\${color0}"
        MocInfo title
        echo -n "                "
        echo -e -n "                                       "
        echo -n "\${color0}"
        MocInfo artist
        echo -n "                             "
        echo -e -n "                          "
        echo -n "\${color0}"
        MocInfo album
        echo -n "                 "
        echo "";;

    3) # CD style
        MocInfo bg
        MocInfo art
        echo -n "\${image ~/.conky/Conky-Audacious-Cover/pix/cd_bg.png -p 9,20 -s 142x128}"
        echo -n "\${image ~/.conky/Conky-Audacious-Cover/pix/$AlbumArt -p 28,22 -s 120x120}"

        echo ""
        echo -n "                     "
        echo -e "   \${font Ubuntu:bold:size=10}\${color}$EchoStatus"
        echo ""
        echo -n "                  "
        echo -e -n "                                     "
        echo -n "\${color0}"
        MocInfo title
        echo -n "                "
        echo -e -n "                                       "
        echo -n "\${color0}"
        MocInfo artist
        echo -n "                             "
        echo -e -n "                          "
        echo -n "\${color0}"
        MocInfo album
        echo -n "                 "
        echo "";;

    *)
        echo ""
        ;;
esac
