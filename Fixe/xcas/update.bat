set PATH=.;%PATH%
rm.exe -f xcasexe.zip
wget.exe 'http://www-fourier.ujf-grenoble.fr/~parisse/giac/xcasexe.zip'
mkdir unpack
cd unpack
..\unzip.exe -o ..\xcasexe.zip
cd ..
cp.exe -Rf unpack/* .
rm.exe -rf unpack
rm.exe -f xcasexe.zip

