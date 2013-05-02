#!/bin/sh
mkdir build
cp -rf www_purchased/* build/
rm $1_purchased.zip
cd build
zip -r $1_purchased.zip *
mv $1_purchased.zip ../
cd ..
rm -rf build
