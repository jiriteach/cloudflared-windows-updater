Write-Host ""
Write-Host "---------------------------"
Write-Host "cloudflared Windows Updater"
Write-Host "---------------------------"

function Send-TelegramMessage {
	[CmdletBinding()]
	param(
		[Parameter()]
		[string] $Message
	)
  
  # Required
  # Reference - https://docs.tracardi.com/qa/how_can_i_get_telegram_bot/

	$telegram_token=""
	$telegram_chat_id=""

	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	$Response = Invoke-RestMethod -Uri "https://api.telegram.org/bot$($telegram_token)/sendMessage?chat_id=$($telegram_chat_id)&text=$($Message)&parse_mode=html" 
	return $Response    

}

$HOSTNAME = Invoke-Expression -Command 'hostname'

$TELEGRAM_MESSAGE_UPDATES_ONLY = "true"
$TELEGRAM_MESSAGE = "<b>cloudflared Windows updater on " + $HOSTNAME + "</b>"

$CLOUDFLARED_INSTALL_PATH = "C:\Program Files (x86)\cloudflared\cloudflared.exe"

Write-Host ""

Write-Host "Checking GitHub for cloudflared version ..."
$RELEASE_DATE = Get-GitHubRelease -OwnerName cloudflare -RepositoryName cloudflared -Latest | Select-Object -ExpandProperty Created*
Write-Host "Latest cloudflared version - " $RELEASE_DATE

$EVENTLOG_MESSAGES = "GitHub cloudflared version checked - $RELEASE_DATE"
$TELEGRAM_MESSAGE = $TELEGRAM_MESSAGE + "%0AGitHub cloudflared version checked - $RELEASE_DATE%0A"

Write-Host ""

Write-Host "Checking installed cloudflared version ..."
$INSTALLED_DATE = Get-Item -Path $CLOUDFLARED_INSTALL_PATH | Select-Object -ExpandProperty LastWriteTime
Write-Host "Installed cloudflared version - " $INSTALLED_DATE

$EVENTLOG_MESSAGES = $EVENTLOG_MESSAGES + "`r`rInstalled cloudflared version checked - $INSTALLED_DATE"
$TELEGRAM_MESSAGE = $TELEGRAM_MESSAGE + "%0AInstalled cloudflared version checked - $INSTALLED_DATE%0A"

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
  $TELEGRAM_MESSAGE = $TELEGRAM_MESSAGE + "%0ANew cloudflared version found%0AUpdated required!%0A"

  $EVENTLOG_MESSAGES = $EVENTLOG_MESSAGES + "`r`r-- Stopping cloudflared service"
  $TELEGRAM_MESSAGE = $TELEGRAM_MESSAGE + "%0A-- Stopping cloudflared service"

  Write-Host "Stopping cloudflared service ..."
  Stop-Service -Name "Cloudflared agent"
  Write-Host "cloudflared service stopped successfully"
  
  $EVENTLOG_MESSAGES = $EVENTLOG_MESSAGES + "`r-- Downloading and installing latest cloudflared version from GitHub"
  $TELEGRAM_MESSAGE = $TELEGRAM_MESSAGE + "%0A-- Downloading and installing latest cloudflared version from GitHub"

  Write-Host ""
  Write-Host "Downloading and installing latest cloudflared version from GitHub ..." -NoNewline
  Get-GitHubRelease -OwnerName cloudflare -RepositoryName cloudflared -Latest |
    Get-GitHubReleaseAsset |
    Where-Object name -In "cloudflared-windows-amd64.exe" |
    Get-GitHubReleaseAsset -Path $CLOUDFLARED_INSTALL_PATH -Force
  Write-Host ""
  Write-Host "Download and installation completed successfully"
  
  $EVENTLOG_MESSAGES = $EVENTLOG_MESSAGES + "`n-- Download and installation completed successfully"
  $TELEGRAM_MESSAGE = $TELEGRAM_MESSAGE + "%0A-- Download and installation completed successfully"

  Write-Host ""
  Write-Host "Starting cloudflared service ..."
  Start-Service -Name "Cloudflared agent"
  Write-Host "cloudflared service started successfully"
  Write-Host ""
  Write-Host "cloudflared update complete"
  
  $EVENTLOG_MESSAGES = $EVENTLOG_MESSAGES + "`r-- cloudflared service started successfully"
  $TELEGRAM_MESSAGE = $TELEGRAM_MESSAGE + "%0A-- cloudflared service started successfully"
  
  $EVENTLOG_MESSAGES = $EVENTLOG_MESSAGES + "`r`rcloudflared update complete"
  $TELEGRAM_MESSAGE = $TELEGRAM_MESSAGE + "%0A%0A<b>cloudflared update complete</b>"
  
  Write-Host ""
  Write-Host "Sending Telegram message ..." -NoNewline
  Send-TelegramMessage $TELEGRAM_MESSAGE
  Write-Host "... Done"
  Write-Host ""

} else {
	Write-Host ""
	Write-Host "Latest cloudflared version already installed.`nNo update required!"
	Write-Host ""
	
	$EVENTLOG_MESSAGES = $EVENTLOG_MESSAGES + "`r`rLatest cloudflared version already installed`nNo update required!"
	$TELEGRAM_MESSAGE = $TELEGRAM_MESSAGE + "%0ALatest cloudflared version already installed%0ANo update required!"
	
	if ($TELEGRAM_MESSAGE_UPDATES_ONLY -ne "true") {
	
	Write-Host "Sending Telegram message ..." -NoNewline
	Send-TelegramMessage $TELEGRAM_MESSAGE
	Write-Host "... Done"
	Write-Host ""
	
	}
} 
	
Write-Host "Writing to EventLog ..."
Write-EventLog -LogName Application -Source "Update cloudflared" -EntryType Information -EventID 1 -Message $EVENTLOG_MESSAGES
Write-Host "... Done"
Write-Host ""

exit