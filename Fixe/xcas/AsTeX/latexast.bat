set EMTEXDIR=%ASTEXBAS%\emtex
set TEXINPUT=%EMTEXDIR%\texinput!!
set TEXFMT=%EMTEXDIR%\btexfmts!!
%EMTEXDIR%\bin\btex ^&latex2e %1 %2 %3
