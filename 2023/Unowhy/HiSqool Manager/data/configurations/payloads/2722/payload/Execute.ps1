# Start setup
if (Test-Path -LiteralPath 'C:\Program Files\Drive monlycee.net') {
    Stop-Process -Name 'drivemonlyceenet' -Force -ErrorAction SilentlyContinue
    if (Test-Path -LiteralPath 'C:\Program Files\Drive monlycee.net\uninstall000.exe') {
        & 'C:\Program Files\Drive monlycee.net\uninstall000.exe' purge --am --c
    }
}

.\drivemonlycee_installer --default-answer --confirm-command install AllUsers=true