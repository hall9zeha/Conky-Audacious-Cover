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

# Getting metadata from playerctl
Title=$(playerctl -p spotify metadata title 2>/dev/null)
Artist=$(playerctl -p spotify metadata artist 2>/dev/null)
Album=$(playerctl -p spotify metadata album 2>/dev/null)
Status=$(playerctl -p spotify status 2>/dev/null)
EchoStatus="Spotify $Status"

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

# Download the Spotify cover art
GetArt() {
    # Check if the current state is already in state.txt
    # The state file is used to prevent overwriting and extracting the album artwork if it already exists, and ensures that # the cover art is not download again until a new song is played.
    current_song="$Title - $Artist"
    if [ ! -f "$StateFile" ]; then
        touch "$StateFile"
    fi

    previous_song=$(cat "$StateFile" 2>/dev/null)

    if [ "$current_song" != "$previous_song" ]; then
        echo "$current_song" > "$StateFile"

        # Path where the cover will be saved
        CoverPath=~/.conky/Conky-Audacious-Cover/pix/cover.jpg

        # Get cover URL from playerctl
        art_url=$(playerctl -p spotify metadata mpris:artUrl 2>/dev/null)

        if [[ "$art_url" =~ ^https?:// ]]; then
            curl -s -L "$art_url" -o "$CoverPath"
        fi

        # If unable to download, use default image
        if [ ! -s "$CoverPath" ]; then
            cp ~/.conky/Conky-Audacious-Cover/pix/"$EmptyCover" "$CoverPath"
        fi
    fi
}

SpotifyInfo() {
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

# -------------------------
# OUTPUT CONKY INFO
# -------------------------

    case "$conkyStyle" in

    1)# If vinyl type conky was chosen
    SpotifyInfo bg
    SpotifyInfo art

    # Cover art

    #echo -n "\${image ~/.conky/Conky-Audacious-Cover/pix/audbg.png -p 0,0}" # background for default
    echo -n "\${image ~/.conky/Conky-Audacious-Cover/pix/vinyl_bg.png -p -20,-4 -s 266x190}" # Vinyl cover background
    echo -n "\${image ~/.conky/Conky-Audacious-Cover/pix/"$AlbumArt" -p 28,35 -s 121x122}"

    # Cover art end

    # Player status
    echo ""
    echo " \${goto 220}\${font Ubuntu:bold:size=10}\${color}$EchoStatus"


    # Title
    echo ""
    echo "\${goto 220}\${color0}$(SpotifyInfo title)"

    # Artist
    echo "\${goto 220}\${color0}$(SpotifyInfo artist)"

    # Album
    echo "\${goto 220}\${color0}$(SpotifyInfo album)"

    # SpotifyInfo progress
    #echo -e "   \${execbar echo "$ProgLen"}" # optional but need adjust

    echo "";;

    2) # conky minimalist style, only cover and info
    SpotifyInfo bg
    SpotifyInfo art

    # Cover art

    echo -n "\${image ~/.conky/Conky-Audacious-Cover/pix/"$AlbumArt" -p 28,24 -s 120x120}"

    # Cover art end

    # Player status
    echo ""
    echo " \${goto 180}\${font Ubuntu:bold:size=10}\${color}$EchoStatus"

    # Title
    echo ""
    echo "\${goto 180}\${color0}$(SpotifyInfo title)"

    # Artist
    echo "\${goto 180}\${color0}$(SpotifyInfo artist)"

    # Album
    echo "\${goto 180}\${color0}$(SpotifyInfo album)"

    #echo -e "   \${execbar echo "$ProgLen"}" # optional but need adjust

    echo "";;
    3)# conky cd style

    #Cover art
    SpotifyInfo bg
    SpotifyInfo art
    # Cover art and placeholder
    echo -n "\${image ~/.conky/Conky-Audacious-Cover/pix/cd_bg.png -p 9,20-s 142x128}"
    echo -n "\${image ~/.conky/Conky-Audacious-Cover/pix/"$AlbumArt" -p 28,22 -s 120x120}"

    # Player status
    echo ""
    echo " \${goto 180}\${font Ubuntu:bold:size=10}\${color}$EchoStatus"

    # Title
    echo ""
    echo "\${goto 180}\${color0}$(SpotifyInfo title)"

    # Artist
    echo "\${goto 180}\${color0}$(SpotifyInfo artist)"

    # Album
    echo "\${goto 180}\${color0}$(SpotifyInfo album)"
    #echo -e "   \${execbar echo "$ProgLen"}" # optional but need adjust

    echo "";;
    esac
