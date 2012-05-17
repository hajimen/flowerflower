#!/bin/sh
# Draw 512x512 object in 1024x1024
convert -geometry 512x512 $1 temp.png
convert -gravity center -crop 480x320+0+0 temp.png Resources/splash/Default_LS.png
convert -gravity center -crop 320x480+0+0 temp.png Resources/splash/Default.png
rm temp.png
convert -gravity center -crop 1024x748+0+0 $1 Resources/splash/Default-Landscape~ipad.png
convert -gravity center -crop 768x1004+0+0 $1 Resources/splash/Default-Portrait~ipad.png
convert -gravity center -crop 960x640+0+0 $1 Resources/splash/Default@2x_LS.png
convert -gravity center -crop 640x960+0+0 $1 Resources/splash/Default@2x.png
