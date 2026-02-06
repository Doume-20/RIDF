Do { $status = Get-Process msedge -ErrorAction SilentlyContinue
  If (!($status)) {  Start-process "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"  "--no-first-run --kiosk https://ent.iledefrance.fr/pages/p/website#/website/demarrer-avec-mon-ordinateur-unowhy --kiosk-idle-timeout-minutes=30 --edge-kiosk-type=public-browsing --start-fullscreen" }
  Else {  }
}until( 0 )
