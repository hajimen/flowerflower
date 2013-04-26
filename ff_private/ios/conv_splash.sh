#!/bin/sh
# Draw 1024x1024 object in 2048x2048
convert -geometry 512x512 $1 temp.png
convert -gravity center -crop 480x320+0+0 temp.png Resources/splash/Default_LS.png
convert -gravity center -crop 320x480+0+0 temp.png Resources/splash/Default.png
rm temp.png
convert -geometry 1024x1024 $1 temp.png
convert -gravity center -crop 1024x748+0+0 temp.png Resources/splash/Default-Landscape~ipad.png
convert -gravity center -crop 768x1004+0+0 temp.png Resources/splash/Default-Portrait~ipad.png
convert -gravity center -crop 960x640+0+0 temp.png Resources/splash/Default@2x_LS.png
convert -gravity center -crop 640x960+0+0 temp.png Resources/splash/Default@2x.png
rm temp.png
convert -gravity center -crop 640x1136+0+0 $1 Resources/splash/Default-568h@2x.png
convert -gravity center -crop 2048x1496+0+0 $1 Resources/splash/Default-Landscape@2x~ipad.png
convert -gravity center -crop 1536x2008+0+0 $1 Resources/splash/Default-Portrait@2x~ipad.png
