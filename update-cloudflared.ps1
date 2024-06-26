Write-Host ""
Write-Host "---------------------------"
Write-Host "cloudflared Windows Updater"
Write-Host "---------------------------"

$CLOUDFLARED_INSTALL_PATH = "C:\Program Files (x86)\cloudflared\cloudflared.exe"

Write-Host ""

Write-Host "Checking GitHub for cloudflared version ..."
$RELEASE_DATE = Get-GitHubRelease -OwnerName cloudflare -RepositoryName cloudflared -Latest | Select-Object -ExpandProperty Created*
Write-Host "Latest cloudflared version - " $RELEASE_DATE

$EVENTLOG_MESSAGES = "GitHub cloudflared version checked - $RELEASE_DATE"

Write-Host ""

Write-Host "Checking installed cloudflared version ..."
$INSTALLED_DATE = Get-Item -Path $CLOUDFLARED_INSTALL_PATH | Select-Object -ExpandProperty LastWriteTime
Write-Host "Installed cloudflared version - " $INSTALLED_DATE

$EVENTLOG_MESSAGES = $EVENTLOG_MESSAGES + "`r`rInstalled cloudflared version checked - $INSTALLED_DATE"

if ((Get-Date $RELEASE_DATE) -gt (Get-Date $INSTALLED_DATE)) {

  Write-Host ""
  Write-Host "------------------------------"
  Write-Host "New cloudflared version found"
  Write-Host "------------------------------"
  Write-Host "Update required!"
  Write-Host "----------------"
  Write-Host ""
    
  $EVENTLOG_MESSAGES = $EVENTLOG_MESSAGES + "`r`r---------------------------------"
  $EVENTLOG_MESSAGES = $EVENTLOG_MESSAGES + "`nNew cloudflared version found`nUpdated required!"
  $EVENTLOG_MESSAGES = $EVENTLOG_MESSAGES + "`n---------------------------------"

  $EVENTLOG_MESSAGES = $EVENTLOG_MESSAGES + "`r`r-- Stopping cloudflared service"

  Write-Host "Stopping cloudflared service ..."
  Stop-Service -Name "Cloudflared agent"
  Write-Host "cloudflared service stopped successfully"
  
  $EVENTLOG_MESSAGES = $EVENTLOG_MESSAGES + "`r-- Downloading and installing latest cloudflared version from GitHub"

  Write-Host ""
  Write-Host "Downloading and installing latest cloudflared version from GitHub ..." -NoNewline
  Get-GitHubRelease -OwnerName cloudflare -RepositoryName cloudflared -Latest |
    Get-GitHubReleaseAsset |
    Where-Object name -In "cloudflared-windows-amd64.exe" |
    Get-GitHubReleaseAsset -Path $CLOUDFLARED_INSTALL_PATH -Force
  Write-Host ""
  Write-Host "Download and installation completed successfully"
  
  $EVENTLOG_MESSAGES = $EVENTLOG_MESSAGES + "`n-- Download and installation completed successfully"

  Write-Host ""
  Write-Host "Starting cloudflared service ..."
  Start-Service -Name "Cloudflared agent"
  Write-Host "cloudflared service started successfully"
  Write-Host ""
  Write-Host "cloudflared update complete"
  
  $EVENTLOG_MESSAGES = $EVENTLOG_MESSAGES + "`r-- cloudflared service started successfully"
  $EVENTLOG_MESSAGES = $EVENTLOG_MESSAGES + "`r`rcloudflared update complete"

} else {
	Write-Host ""
	Write-Host "Latest cloudflared version already installed.`nNo update required!"
	
	$EVENTLOG_MESSAGES = $EVENTLOG_MESSAGES + "`r`rLatest cloudflared version already installed`nNo update required!"

} 

Write-Host ""
Write-Host "Writing to EventLog ..."
Write-EventLog -LogName Application -Source "Update cloudflared" -EntryType Information -EventID 1 -Message $EVENTLOG_MESSAGES
Write-Host "... Done" 
Write-Host ""

exit