#!/bin/bash
###################################################################################
##                                                                               ##
##                          Created by Barry Zea H.                              ##
##                                                                               ##
##                                                                               ##
###################################################################################


conkyStyle=$1

StateFile="$HOME/.conky/Conky-Audacious-Cover/pix/state.txt"

AlbumArt="cover.jpg"
EmptyCover="audacious-empty-cover.png"

# -------------------------
# INFO DESDE MPRIS
# -------------------------

Status=$(playerctl --player=AIMP status 2>/dev/null)
EchoStatus="AIMP $Status"

Title=$(playerctl --player=AIMP metadata title 2>/dev/null)
Artist=$(playerctl --player=AIMP metadata artist 2>/dev/null)
Album=$(playerctl --player=AIMP metadata album 2>/dev/null)

# fallback if it comes empty
[ -z "$Title" ] && Title="Unknown"
[ -z "$Artist" ] && Artist="Unknown"
[ -z "$Album" ] && Album="Unknown"

# -------------------------
# COVER
# -------------------------
GetArt(){

    cover_output="$HOME/.conky/Conky-Audacious-Cover/pix/cover.jpg"
    temp_cover="$HOME/.conky/Conky-Audacious-Cover/pix/temp_cover.jpg"

    FilePath=$(playerctl --player=AIMP metadata xesam:url 2>/dev/null)
    FilePath=${FilePath#file://}
    FilePath=$(printf '%b' "${FilePath//%/\\x}")

    [ ! -f "$StateFile" ] && touch "$StateFile"
    current_song=$(cat "$StateFile" 2>/dev/null)

    if [ "$FilePath" != "$current_song" ]; then
        echo "$FilePath" > "$StateFile"

        success=0

        # -------------------------
        # 1. MPRIS
        # -------------------------
        art_url=$(playerctl --player=AIMP metadata mpris:artUrl 2>/dev/null)

        if [ -n "$art_url" ]; then
            if [[ "$art_url" == file://* ]]; then
                art_path="${art_url#file://}"

                if [ -f "$art_path" ]; then
                    resolution=$(ffprobe -v error -select_streams v:0 \
                        -show_entries stream=width,height \
                        -of csv=p=0:s=x "$art_path" 2>/dev/null)

                    width=$(echo "$resolution" | cut -d'x' -f1)
                    height=$(echo "$resolution" | cut -d'x' -f2)

                    # Filter placeholders, validate resolution to prevent the cover search from stopping (ej: < 100x100)
                    if [ "$width" -ge 100 ] && [ "$height" -ge 100 ]; then
                        cp "$art_path" "$cover_output"
                        success=1
                    fi
                fi
            else
                # Remote URL
                curl -s "$art_url" -o "$temp_cover"

                if [ -s "$temp_cover" ]; then
                    resolution=$(ffprobe -v error -select_streams v:0 \
                        -show_entries stream=width,height \
                        -of csv=p=0:s=x "$temp_cover" 2>/dev/null)

                    width=$(echo "$resolution" | cut -d'x' -f1)
                    height=$(echo "$resolution" | cut -d'x' -f2)

                    if [ "$width" -ge 100 ] && [ "$height" -ge 100 ]; then
                        mv "$temp_cover" "$cover_output"
                        success=1
                    fi
                fi
            fi
        fi

        # -------------------------
        # 2. FFMPEG embedded cover
        # -------------------------
        if [ $success -eq 0 ] && [ -n "$FilePath" ]; then
            ffmpeg -i "$FilePath" -map 0:v:0 "$temp_cover" >/dev/null 2>&1

            if [ -s "$temp_cover" ]; then
                mv "$temp_cover" "$cover_output"
                success=1
            fi
        fi

        # -------------------------
        # 3. Search in directory
        # -------------------------
        if [ $success -eq 0 ] && [ -n "$FilePath" ]; then
            Directory=$(dirname "$FilePath")

            cover_img_file=$(find "$Directory" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | head -n 1)

            if [ -n "$cover_img_file" ]; then
                cp "$cover_img_file" "$cover_output"
                success=1
            fi
        fi

        # -------------------------
        # 4. Empty cover
        # -------------------------
        if [ $success -eq 0 ]; then
            cp "$HOME/.conky/Conky-Audacious-Cover/pix/$EmptyCover" "$cover_output"
        fi
    fi
}

# -------------------------
# INFO
# -------------------------

AIMPInfo(){
    case "$1" in
        art) GetArt ;;
        status) echo "$EchoStatus" ;;

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

        progress) GetProgress ;;
    esac
}

# -------------------------
# OUTPUT CONKY
# -------------------------
   case "$conkyStyle" in

    1)# If vinyl type conky was chosen
    AIMPInfo bg
    AIMPInfo art

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
    AIMPInfo title
    echo -n "                "
    #echo -e -n "   \${color}Artist: "

    echo -e -n "                                                    "
    echo -n "\${color0}"
    AIMPInfo artist
    echo -n "                                          "
    #echo -e -n "   \${color}Album: "
    echo -e -n "                          "

    echo -n "\${color0}"
    AIMPInfo album
    AIMPInfo progress
    echo -n "                 "
    #echo -e "   \${execbar echo "$ProgLen"}" # optional but need adjust

    echo "";;

    2) # conky minimalist style, only cover and info
    AIMPInfo bg
    AIMPInfo art
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
    AIMPInfo title
    echo -n "                "
    #echo -e -n "   \${color}Artist: "

    echo -e -n "                                       "
    echo -n "\${color0}"
    AIMPInfo artist
    echo -n "                             "
    #echo -e -n "   \${color}Album: "
    echo -e -n "                          "

    echo -n "\${color0}"
    AIMPInfo album
    AIMPInfo progress
    echo -n "                 "
    #echo -e "   \${execbar echo "$ProgLen"}" # optional but need adjust

    echo "";;
    3)# conky cd style
    AIMPInfo bg
    AIMPInfo art

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
    AIMPInfo title
    echo -n "                "
    #echo -e -n "   \${color}Artist: "

    echo -e -n "                                       "
    echo -n "\${color0}"
    AIMPInfo artist
    echo -n "                             "
    #echo -e -n "   \${color}Album: "
    echo -e -n "                          "

    echo -n "\${color0}"
    AIMPInfo album
    AIMPInfo progress
    echo -n "                 "
    #echo -e "   \${execbar echo "$ProgLen"}" # optional but need adjust

    echo "";;
    esac

