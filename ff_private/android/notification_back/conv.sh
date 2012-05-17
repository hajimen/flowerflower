#!/bin/sh
convert -geometry 17x17 $1 -colorspace gray temp.png
convert icon_back_ldpi.png temp.png -gravity center -composite ../res/drawable-ldpi/notification.png
cp ../res/drawable-ldpi/notification.png ../res/drawable-mdpi/notification.png
convert -geometry 30x30 $1 -colorspace gray temp.png
convert icon_back_hdpi.png temp.png -gravity center -composite ../res/drawable-hdpi/notification.png
convert -geometry 42x42 $1 -colorspace gray temp.png
convert icon_back_xhdpi.png temp.png -gravity center -composite ../res/drawable-xhdpi/notification.png
convert -geometry 18x18 $1 -colorspace gray ../res/drawable-ldpi-v11/notification.png
convert -geometry 24x24 $1 -colorspace gray ../res/drawable-mdpi-v11/notification.png
convert -geometry 32x32 $1 -colorspace gray temp.png
convert -border 2x2 -bordercolor transparent temp.png ../res/drawable-hdpi-v11/notification.png
convert -geometry 44x44 $1 -colorspace gray temp.png
convert -border 2x2 -bordercolor transparent temp.png ../res/drawable-xhdpi-v11/notification.png
rm temp.png
