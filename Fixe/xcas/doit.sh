#! /bin/bash
export PATH=$PATH:.
msgfmt.exe el.po -o locale/el/LC_MESSAGES/giac.mo
msgfmt.exe fr.po -o locale/fr/LC_MESSAGES/giac.mo
msgfmt.exe es.po -o locale/es/LC_MESSAGES/giac.mo
msgfmt.exe pt.po -o locale/pt/LC_MESSAGES/giac.mo
msgfmt.exe zh.po -o locale/zh/LC_MESSAGES/giac.mo
msgfmt.exe de.po -o locale/de/LC_MESSAGES/giac.mo
