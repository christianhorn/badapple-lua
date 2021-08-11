# badapple-lua

## What's this?
An implementation of the 'Bad Apple' animation for the Lua
language, written for the FiiO M3K player running [Rockbox](https://rockbox.org).

I tried out various implementations, this repo has them all:
drawing complete single frames one after another, or drawing only the
pixels which changed since the last frame.  That means, that besides
deploying the Lua scripts, you will also need a different system to
run various tools and C-code to prepare the media content which the
Lua scripts use on the M3K player.

All of the Lua scripts try to accomplish the same, but with 
different performance specifics: framerate and sync of the frames
to the music.  ba\_120x-ani.lua works best for me.

I use Fedora34 incl. rpmfusion repos on an AMD64 system as base, but 
can be run on other distros.  

A blog article with some details on this project is 
[here](https://blog.fluxcoil.net/posts/2021/08/rockbox-badapple-m3k/).

## Compiling and media preparation

```
sudo dnf -y install git-core youtube-dl ImageMagick automake \
  gcc ffmpeg

git clone https://github.com/christianhorn/badapple-lua
cd badapple-lua/bamedia

# Let's prepare the media
youtube-dl -f 18 https://www.youtube.com/watch?v=FtutLA63Cp8
mv *mp4 badapple.mp4
ffmpeg -i badapple.mp4 badapple.mp3

# Grab all single frames of the animation
mkdir tiny_120x90 tiny_240x180
ffmpeg -i badapple.mp4 -vf scale=240:180 tiny_240x180/image-%07d.bmp
ffmpeg -i badapple.mp4 -vf scale=120:90 tiny_120x90/image-%07d.bmp

# Build our content files
cd ../code
# builds our binaries
make
# If that worked, this will generate our media
make media
# these are then called explicitly:
for i in {2..6571}; do ./prep_240x_diffs $i; done
for i in $(seq 4 2 6570); do ./prep_240x_diffs_half $i; done
cd ..
```

## Setup on the sdcard
You should then have your microsd-card mounted on /mnt/tmp.
Rockbox should already be setup with the default directory 
/mnt/tmp/.rockbox .  The card should have 1.4GB free space.
```
sudo cp -r bamedia /mnt/tmp/
sudo cp -r lua/* /mnt/tmp/.rockbox/rocks/demos/lua_scripts
sudo umount /mnt/tmp
```

You can then start the M3K with the microsd-card, go to
plugins/demos/lua\scripts and run the single scripts.

## Bugs

* No button control implenented, as I did not see an example
  with non-blocking queries for the buttons.  So press
  5 seconds the off-button to turn off the device.
* Improper handling of the last frame(s)
* Sync of video/sound not good.  If video is to fast, one could
  increase rb.sleep() in the main loop.
