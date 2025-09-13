# Conky-Audacious-Cover
A simple conky for show cover art of your music in audacious media player on Linux distributions.
Now with support to display cover art and metadata from MOC and Spotify.

## Requirements

have installed:
* conky
* ffmpeg
* imagemagick
* playerctl (to retrieve metadata from Spotify)

## Features

The Conky cover will only be visible if the player in question (Audacious, MOC, or Spotify) is running. If more than one player is running at the same time, only the metadata of the player that was launched first will be displayed. If the oldest player is closed, the metadata of the next player in the order of launch will be shown.

- It has three styles of displaying audio covers:
  - Minimal cover
  - Vinyl cover
  - Cd cover
- Shows album art, title, artist and album.

To change the style of conky change the following argument in ```.conky-audacious-cover```. The file is hidden by default. To view it, press the key combination `Ctrl + H`.


```
# conky_vinyl cover = 1
# conky_minimal cover = 2
# conky_compact_dic cover = 3
# after detect-player.sh -> 1, 2 or 3

${execpi 2 ~/.conky/Conky-Audacious-Cover/detect-player.sh 1}

```

## How to Install

Typing on terminal:
  - 1
    ```bash
     mkdir ~/.conky
    ```
  - 2
    ```bash
    cd ~/.conky
    ```
  - 3
    ```bash
    git clone https://github.com/hall9zeha/Conky-Audacious-Cover.git
    ```
  - 4 
    ``` bash
    cd Conky-Audacious-Cover    
    ```
  - 5 Give execution permissions to all scripts within the player-metadata-scripts directory.
    ```bash
    sudo chmod +x player-metadata-scripts/*.sh
    ```
    Give execution permissions to the script for starting conky-audacious-cover.
    ```bash
    sudo chmod +x start-audacious-conky.sh
    ```
inside the conky file ```start-audacious-conky.sh``` you can modify the startup delay of conky audacious 
```bash
sleep 15 && conky -c  ~/.conky/Conky-Audacious-Cover/.conky-audacious-cover
```
 - 6 .- Finally add the script file ```start-audacious-conky.sh``` to autostart on your linux distribution so that it always starts when you turn on the computer.

To launch the conky audacious cover and test its operation, run in the terminal 
```bash
conky -c ~/.conky/Conky-Audacious-Cover/.conky-audacious-cover
```
if you have copied all the files following the instructions, otherwise you can configure it at your convenience.

## Screenshots
* Vinyl style
<p align="left" width="30%"><img src="https://github.com/hall9zeha/Conky-Audacious-Cover/blob/main/screenshots/screen1.png"  alt="drawing" width="50%"/></p>

* Minimal style
<p align="left" width="30%"><img src="https://github.com/hall9zeha/Conky-Audacious-Cover/blob/main/screenshots/screen2.png"  alt="drawing" width="50%"/></p>

* Compact Disc style
<p align="left" width="30%"><img src="https://github.com/hall9zeha/Conky-Audacious-Cover/blob/main/screenshots/screen3.png"  alt="drawing" width="50%"/></p>

<p align="left" width="50%"><img src="https://github.com/hall9zeha/Conky-Audacious-Cover/blob/main/screenshots/screen5.png"  alt="drawing" width="70%"/></p>
<p align="left" width="50%"><img src="https://github.com/hall9zeha/Conky-Audacious-Cover/blob/main/screenshots/screen4.png"  alt="drawing" width="70%"/></p>
