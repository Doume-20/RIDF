mount -f -s -b "c:/cygwin/bin" "/usr/bin"
mount  -f -u -b "c:/cygwin/bin" "/usr/bin"
mount -f -s -b "c:/cygwin/lib" "/usr/lib"
mount  -f -u -b "c:/cygwin/lib" "/usr/lib"
mount -f -s -b "c:/cygwin" "/"
mount  -f -u -b "c:/cygwin" "/"
mount -s -b --change-cygdrive-prefix "/cygdrive"
mount  -u -b --change-cygdrive-prefix "/cygdrive"

