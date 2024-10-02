#!/bin/bash
###################################################################################
##                                                                               ##
##                          Enhaced by Barry Zea H.                              ##
##                                                                               ##
##                                                                               ##
###################################################################################



## *********************
## Receives argument from .conky-Audacious-cover
conkyMode=$1

StateFile=~/.conky/Conky-Audacious-Cover/pix/state.txt

Corners=0 # 14 original for background
CoverCorners=84 # for cover art not work very well
Opacity=0.5
# Opacity=0.2 # original
BGColor='black'
AlbumArt="cover.jpg"
EmptyCover="audacious-empty-cover.png"


CharLength=7
StaticWidth=150
MinWidth=350
Height=138
WordCount=0

ListPosition=$(audtool playlist-position)
Status=$(audtool playback-status)
EchoStatus="Audacious $Status"

Title=$(audtool playlist-tuple-data title "$ListPosition")
if [ -z "$Title" ];then
    Title=$(basename "$(audtool playlist-song-filename \
            "$ListPosition")" .mp3 | sed 's/%20/ /g')
fi
TitleCount=$(echo "Title: "$Title"" | wc -m)

Album=$(audtool playlist-tuple-data album "$ListPosition")
AlbumCount=$(echo "Album: "$Album"" | wc -m)

Artist=$(audtool playlist-tuple-data artist "$ListPosition")
ArtistCount=$(echo "Artist: "$Artist"" | wc -m)

for varcount in $TitleCount $AlbumCount $ArtistCount
do
    if [ $varcount -gt $WordCount ];then
        WordCount=$varcount
    fi
done

VarWidth=$(echo "${WordCount}*${CharLength}" | bc)
Width=$(echo ""$StaticWidth"+"$VarWidth"" | bc)

if [ $Width -le $MinWidth ];then
    Width=$MinWidth
fi

#mkdir -p ~/.conky/Conky-Audacious-Cover/pix/

# DrawBG(){
#     convert -size ${Width}x${Height} xc:${BGColor} \
#         png:- | convert - \
#          \( +clone  -threshold -1 \
#             -draw "fill black polygon 0,0 0,"$Corners" "$Corners",0 \
#             fill white circle "$Corners","$Corners" "$Corners",0" \
#             \( +clone -flip \) -compose Multiply -composite \
#             \( +clone -flop \) -compose Multiply -composite \
#          \) +matte -compose CopyOpacity -composite  \
#         -alpha on -channel RGBA -evaluate multiply ${Opacity} \
#          ~/.conky/pix/audbg.png
#
# }


GetArt(){

    Directory=$(audtool playlist-tuple-data file-path "$ListPosition" | sed 's/file:\/\///')
    File=$(basename "$(audtool playlist-song-filename \
            "$ListPosition")")
    if [[ "$Directory" == "~/"* ]]; then
        Directory="$HOME${Directory#"~"}"
    fi

    FilePath="$Directory/$File"

    # Create state file if not exist
    if [ ! -f "$StateFile" ]; then
        touch "$StateFile"
    fi

    # Read current song path of state file
    current_song=$(cat "$StateFile" 2>/dev/null)

   if [ "$FilePath" != "$current_song" ]; then
        # Save current song path in the state file
        echo "$FilePath" > "$StateFile"

        # Create a temporary cover file
        temp_cover=~/.conky/Conky-Audacious-Cover/pix/temp_cover.jpg

        # Extract cover art from audio file using ffmpeg
        ffmpeg -i "$FilePath" -an -vcodec copy -f image2 ~/.conky/Conky-Audacious-Cover/pix/temp_cover.jpg >/dev/null 2>&1

        # If the file does not have a cover in its metadata, look for the following
        # inside the file directory

        if [ $? -ne 0 ]; then

            # Some directories may have cover files with a different name,
            # so regardless of their name, we will look for them by their
            # extension.
            cover_img_file=$(find "$Directory" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" \) | head -n 1)

            if [ -n "$cover_img_file" ]; then
            # Copy the first .jpg  or .png file found to cover.jpg
            cp "$cover_img_file" ~/.conky/Conky-Audacious-Cover/pix/cover.jpg

            else
            # If it does not exist, copy the EmptyCover file to cover.jpg
            cp ~/.conky/Conky-Audacious-Cover/pix/"$EmptyCover" ~/.conky/Conky-Audacious-Cover/pix/cover.jpg

            fi
        else
            # Move the temporary cover to the final location
            mv "$temp_cover" ~/.conky/Conky-Audacious-Cover/pix/cover.jpg


         fi
    fi

}
GetProgress(){
    CurrLen=$(audtool current-song-output-length-seconds)
    TotLen=$(audtool current-song-length-seconds)
    if (( $TotLen )); then
        ProgLen=$(expr $CurrLen \* 100  / $TotLen)
    fi
}

AudaciousInfo(){

  case "$1" in
        #bg)         DrawBG ;;
        art)        GetArt ;;
        status)     echo "$EchoStatus" ;;
        title)
            TitleText=$(echo "$Title" | cut -c 1-80)
            if [ "${#Title}" -gt 80 ]; then
                TitleText+="..."
            fi
            # A font is used that allows displaying Japanese and Chinese characters
            echo "\${font Noto Sans CJK JP:bold:italic:size=11}$TitleText"
            ;;
        artist)
            ArtistText=$(echo "$Artist" | cut -c 1-80)
            if [ "${#Artist}" -gt 80 ]; then
                ArtistText+="..."
            fi
            echo "\${font Noto Sans CJK JP:bold:size=8}$ArtistText"
            ;;
        album)
            AlbumText=$(echo "$Album" | cut -c 1-100)
             if [ "${#Album}" -gt 100 ]; then
                 AlbumText+="..."
             fi
             echo "\${font Noto Sans CJK JP:normal:size=8}$AlbumText"
             ;;
        progress)   GetProgress ;;
    esac
}

    case "$conkyMode" in

    1)# If vinyl type conky was chosen
    AudaciousInfo bg
    AudaciousInfo art

    #echo -n "\${image ~/.conky/Conky-Audacious-Cover/pix/audbg.png -p 0,0}" # background for default
    echo -n "\${image ~/.conky/Conky-Audacious-Cover/pix/vinyl_bg.png -p -20,-4 -s 266x190}" # Vinyl cover background
    echo -n "\${image ~/.conky/Conky-Audacious-Cover/pix/"$AlbumArt" -p 28,35 -s 121x122}"

    echo ""
    echo -n "                          "
    echo -e "   \${font Ubuntu:bold:size=10}\${color}$EchoStatus"
    echo ""
    echo -n "                  "


    #echo -e -n "   \${color}Title: "
    echo -e -n "                                                  "
    echo -n "\${color0}"
    AudaciousInfo title
    echo -n "                "
    #echo -e -n "   \${color}Artist: "

    echo -e -n "                                                    "
    echo -n "\${color0}"
    AudaciousInfo artist
    echo -n "                                          "
    #echo -e -n "   \${color}Album: "
    echo -e -n "                          "

    echo -n "\${color0}"
    AudaciousInfo album
    AudaciousInfo progress
    echo -n "                 "
    #echo -e "   \${execbar echo "$ProgLen"}" # optional but need adjust

    echo "";;

    2) # conky minimalist style, only cover and info
    AudaciousInfo bg
    AudaciousInfo art
    #echo -n "\${image ~/.conky/Conky-Audacious-Cover/pix/audbg.png -p 0,0}" # background for default
    echo -n "\${image ~/.conky/Conky-Audacious-Cover/pix/"$AlbumArt" -p 28,24 -s 120x120}"

    echo ""
    echo -n "                     "
    echo -e "   \${font Ubuntu:bold:size=10}\${color}$EchoStatus"
    echo ""
    echo -n "                  "


    #echo -e -n "   \${color}Title: "
    echo -e -n "                                     "
    echo -n "\${color0}"
    AudaciousInfo title
    echo -n "                "
    #echo -e -n "   \${color}Artist: "

    echo -e -n "                                       "
    echo -n "\${color0}"
    AudaciousInfo artist
    echo -n "                             "
    #echo -e -n "   \${color}Album: "
    echo -e -n "                          "

    echo -n "\${color0}"
    AudaciousInfo album
    AudaciousInfo progress
    echo -n "                 "
    #echo -e "   \${execbar echo "$ProgLen"}" # optional but need adjust

    echo "";;
    3)# conky cd style
    AudaciousInfo bg
    AudaciousInfo art

    echo -n "\${image ~/.conky/Conky-Audacious-Cover/pix/cd_bg.png -p 9,20-s 142x128}"
    echo -n "\${image ~/.conky/Conky-Audacious-Cover/pix/"$AlbumArt" -p 28,22 -s 120x120}"

    echo ""
    echo -n "                     "
    echo -e "   \${font Ubuntu:bold:size=10}\${color}$EchoStatus"
    echo ""
    echo -n "                  "


    #echo -e -n "   \${color}Title: "
    echo -e -n "                                     "
    echo -n "\${color0}"
    AudaciousInfo title
    echo -n "                "
    #echo -e -n "   \${color}Artist: "

    echo -e -n "                                       "
    echo -n "\${color0}"
    AudaciousInfo artist
    echo -n "                             "
    #echo -e -n "   \${color}Album: "
    echo -e -n "                          "

    echo -n "\${color0}"
    AudaciousInfo album
    AudaciousInfo progress
    echo -n "                 "
    #echo -e "   \${execbar echo "$ProgLen"}" # optional but need adjust

    echo "";;
    esac

