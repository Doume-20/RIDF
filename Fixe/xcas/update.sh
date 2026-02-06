#! /bin/bash
set > log
sleep 5
rm -f xcasexe.zip
wget 'http://www-fourier.ujf-grenoble.fr/~parisse/giac/xcasexe.zip' 
mkdir unpack 
cd unpack 
../unzip -o ../xcasexe.zip >> log
cd ..
cp -R unpack/* . 
rm -rf unpack 
rm -f xcasexe.zip
