#!/bin/sh
mkdir build
cp -r ../../ff_html/* build/
cp -rf ../www_private/* build/
cp -rf www_base/* build/
rm $1_base.zip
cd build
zip -r $1_base.zip *
mv $1_base.zip ../
cd ..
rm -rf build
