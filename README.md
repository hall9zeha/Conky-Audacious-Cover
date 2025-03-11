# Conky-Audacious-Cover
A simple conky for show cover art of your music in audacious media player on Linux distributions.

## Requirements

have installed:
* conky
* ffmpeg
* imagemagick
## Features
- Only show if audacious is open.
- It has three styles of displaying audio covers:
  - Minimal cover
  - Vinyl cover
  - Cd cover
- Shows album art, title, artist and album.

To change the style of conky change the following argument in ```.conky-audacious-cover```
```
# conky_vinyl cover = 1
# conky_minimal cover = 2
# after audacious-info.sh -> 1 or 2

${if_running audacious}${execpi 2 ~/.conky/Conky-Audacious-Cover/audacious-info.sh 1}${endif}

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
  - 5     
    ```bash
    sudo chmod +x audacious-info.sh
    ```
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
<p align="left" width="30%"><img src="https://github.com/hall9zeha/Conky-Audacious-Cover/blob/main/screenshots/screen1.png"  alt="drawing" width="50%" height="50%"/></p>

* Minimal style
<p align="left" width="30%"><img src="https://github.com/hall9zeha/Conky-Audacious-Cover/blob/main/screenshots/screen2.png"  alt="drawing" width="50%" height="50%"/></p>

* Compact Disc style
<p align="left" width="30%"><img src="https://github.com/hall9zeha/Conky-Audacious-Cover/blob/main/screenshots/screen3.png"  alt="drawing" width="50%" height="50%"/></p>

<p align="left" width="50%"><img src="https://github.com/hall9zeha/Conky-Audacious-Cover/blob/main/screenshots/screen5.png"  alt="drawing" width="70%" height="70%"/></p>
<p align="left" width="50%"><img src="https://github.com/hall9zeha/Conky-Audacious-Cover/blob/main/screenshots/screen4.png"  alt="drawing" width="70%" height="70%"/></p>
