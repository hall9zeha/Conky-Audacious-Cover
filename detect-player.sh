#!/bin/bash
###################################################################################
##                                                                               ##
##                          Created by Barry Zea H.                              ##
##                                                                               ##
##                                                                               ##
###################################################################################


# Script that detects the oldest active player among audacious, mocp, and spotify



STYLE="$1"  # Receives the parameter from Conky

SCRIPT_DIR=~/.conky/Conky-Audacious-Cover/player-metadata-scripts

# Function to know if the mocp client is active (and not just the server)
is_mocp_client_running() {
    ps -eo tty,comm | awk '$2=="mocp" && $1!="?"' | grep -q .
}

# Array for storing active players
declare -A players

# Check if MOC is active (client)
if is_mocp_client_running; then
    pid=$(ps -eo pid,tty,comm | awk '$3=="mocp" && $2!="?" {print $1}')
    players[$pid]="mocp"
fi

# Check if Spotify is active
if pgrep -x spotify > /dev/null; then
    for pid in $(pgrep -x spotify); do
        players[$pid]="spotify"
    done
fi

# Check if Audacious is active
if pgrep -x audacious > /dev/null; then
    for pid in $(pgrep -x audacious); do
        players[$pid]="audacious"
    done
fi

#Check if AIMP is active
if pgrep -x aimp > /dev/null; then
    for pid in $(pgrep -x aimp); do
        players[$pid]="aimp"
    done
fi

# If no player is active, exit
if [ ${#players[@]} -eq 0 ]; then
    exit 0
fi

# Find the oldest PID (earliest start time)
# We use ps to extract the start time and sort by it
# Then we select the first PID (the oldest one)
# This way, if we have Spotify, Audacious, or Moc running at the same time, only the metadata of the
# first one that was opened (the oldest) will be displayed
oldest_pid=$(ps -eo pid,lstart,comm | awk -v pids="${!players[*]}" '
BEGIN {
    split(pids, id_array, " ");
    for (i in id_array) pid_map[id_array[i]] = 1;
}
pid_map[$1] {
    printf "%s %s\n", $2" "$3" "$4" "$5" "$6, $1
}' | sort | head -n1 | awk '{print $NF}')

# Get the name of the player associated with that PID
player=${players[$oldest_pid]}

# Run the corresponding script

case "$player" in
    audacious)
        "$SCRIPT_DIR/audacious-info.sh" "$STYLE"
        ;;
   mocp)
        "$SCRIPT_DIR/moc-info.sh" "$STYLE"
        ;;
   spotify)
        "$SCRIPT_DIR/spotify-info.sh" "$STYLE"
        ;;
    aimp)
        "$SCRIPT_DIR/aimp-info.sh" "$STYLE"
        ;;
esac


