# Conky-Audacious-Cover
A simple conky for show cover art of your music in audacious media player

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

${if_running audacious}${execpi 2 ~/.conky/audacious-info.sh 1}${endif}

```

## How to Install
  - 1 .- Go to your home directory.
  - 2 .- Create the ```.conky``` directory if you don't have it yet.
  - 3 .- Open a terminal inside ```.conky``` directory
  - 4 .- Inside the already created ```.conky``` directory  clone the repository typing the following in the terminal ```git clone https://github.com/hall9zeha/Conky-Audacious-Cover.git```.
  - 5 .- Give execution permissions to ```audacious-info.sh``` and ```start-audacious-conky.sh```
typing in your terminal:
```bash
sudo chmod +x audacious-info.sh
```
```bash
sudo chmod +x start-audacious-conky.sh
```
inside the conky file you can modify the startup delay of conky audacious 
```bash
sleep 15 && conky -c  ~/.conky/.conky-audacious-cover
```
 - 6 .- Finally add the script to autostart on your linux distribution so that it always starts when you turn on the computer.

To launch the conky audacious cover and test its operation, run in the terminal 
```bash
conky -c ~/.conky/.conky-audacious-cover
```
if you have copied all the files following the instructions, otherwise you can configure it at your convenience.

## Screenshots
* Vinyl style
<p align="left" width="30%"><img src="https://github.com/hall9zeha/Conky-Audacious-Cover/blob/main/screenshots/screen1.png"  alt="drawing" width="70%" height="70%"/></p>

* Minimal style
<p align="left" width="30%"><img src="https://github.com/hall9zeha/Conky-Audacious-Cover/blob/main/screenshots/screen2.png"  alt="drawing" width="70%" height="70%"/></p>

* Compact Disc style
<p align="left" width="30%"><img src="https://github.com/hall9zeha/Conky-Audacious-Cover/blob/main/screenshots/screen3.png"  alt="drawing" width="70%" height="70%"/></p>
