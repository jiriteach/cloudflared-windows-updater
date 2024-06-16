Write-Host ""
Write-Host "---------------------------"
Write-Host "cloudflared Windows Updater"
Write-Host "---------------------------"

$CLOUDFLARED_INSTALL_PATH = "C:\Program Files (x86)\cloudflared\cloudflared.exe"

Write-Host ""

Write-Host "Checking Github for cloudflared version ..."
$RELEASE_DATE = Get-GitHubRelease -OwnerName cloudflare -RepositoryName cloudflared -Latest | Select-Object -ExpandProperty Created*
Write-Host "Latest cloudflared version - " $RELEASE_DATE

Write-Host ""

Write-Host "Checking installed cloudflared version ..."
$INSTALLED_DATE = Get-Item -Path $CLOUDFLARED_INSTALL_PATH | Select-Object -ExpandProperty LastWriteTime
Write-Host "Installed cloudflared version - " $INSTALLED_DATE


if ((Get-Date $RELEASE_DATE) -gt (Get-Date $INSTALLED_DATE)) {

  Write-Host ""
  Write-Host "------------------------------"
  Write-Host "New cloudflared version found!"
  Write-Host "------------------------------"
  Write-Host "Update required ..."
  Write-Host "-------------------"
  Write-Host ""
  Write-Host "Stopping cloudflared service ..."
  Stop-Service -Name "Cloudflared agent"
  Write-Host "cloudflared service stopped successfully."
  
  Write-Host ""
  Write-Host "Downloading and installing latest cloudflared version from GitHub ..." -NoNewline
  Get-GitHubRelease -OwnerName cloudflare -RepositoryName cloudflared -Latest |
    Get-GitHubReleaseAsset |
    Where-Object name -In "cloudflared-windows-amd64.exe" |
    Get-GitHubReleaseAsset -Path $CLOUDFLARED_INSTALL_PATH -Force
  Write-Host ""
  Write-Host "Download and installation completed successfully."
  
  Write-Host ""
  Write-Host "Starting cloudflared service ..."
  Start-Service -Name "Cloudflared agent"
  Write-Host "cloudflared services start successfully." -NoNewline

} else {
	Write-Host ""
	Write-Host "Latest cloudflared version already installed. No update required!"
	Write-Host ""
}
 
exit