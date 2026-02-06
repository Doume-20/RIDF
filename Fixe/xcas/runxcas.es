#! /bin/bash
export LANG=es_ES.UTF-8
export XCAS_ROOT='/cygdrive/c/xcas'
# export XCAS_HOME='/cygdrive/p'
# export XCAS_AUTOSAVEFOLDER='/cygdrive/p'
export XCAS_LOCALE="$XCAS_ROOT/locale/"
export XCAS_HELP="$XCAS_ROOT/aide_cas"
"$XCAS_ROOT/xcas.exe" "$1"
