#!/bin/sh
convert -geometry 72x72 $1 Resources/icons/icon-72.png
convert -geometry 57x57 $1 Resources/icons/icon.png
convert -geometry 114x114 $1 Resources/icons/icon@2x.png
