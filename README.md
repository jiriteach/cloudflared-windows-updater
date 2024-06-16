<img src="https://www.cloudflare.com/img/logo-cloudflare.svg" width="150">  

# `cloudflared` Windows Updater

`cloudflared` is the Cloudflare Tunnel client which can be found here - https://github.com/cloudflare/cloudflared.

For those running `cloudflared` on Windows and as noted by Cloudflare here - https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/.

```
Instances of cloudflared do not automatically update on Windows. You will need to perform manual updates.
```

This PowerShell scripts automates the update process for `cloudflared` on Windows. 

The script checks for the latest version (using `datecreated`) on the `cloudflared` repository (https://github.com/cloudflare/cloudflared) on GitHub. The script then compares the `datecreated` with the locally installed version. If a later version exists - the script will stop the `cloudflared` service and download and install the new version and start the `cloudflared` service again.

## Requirements & Setup
1. Requires to be run as `administrator`
2. Requires `PowerShellForGitHub` module installed. Download and install from here - https://www.powershellgallery.com/packages/powershellforgithub
3. Set `CLOUDFLARED_INSTALL_PATH` to the locally installed `cloudflared` version. Example - `"C:\Program Files (x86)\cloudflared\cloudflared.exe"`
4. Execute script as required or setup a `Scheduled Task` in Windows for automatic updates.

## Example - New `cloudflared` version found!

```
PS C:\Scripts> .\update-cloudflared.ps1

---------------------------
cloudflared Windows Updater
---------------------------

Checking Github for cloudflared version ...
Latest cloudflared version -  4/06/2024 06:29:11

Checking installed cloudflared version ...
Installed cloudflared version -  8/05/2024 09:44:13

------------------------------
New cloudflared version found!
------------------------------
Update required ...
-------------------

Stopping cloudflared service ...
cloudflared service stopped successfully.

Downloading and installing latest cloudflared version from GitHub ...

    Directory: C:\Program Files (x86)\cloudflared


Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----        16/06/2024     14:40       64393462 cloudflared.exe

Download and installation completed successfully.

Starting cloudflared service ...
cloudflared services start successfully.

PS C:\Scripts> .\cloudflared-auto-update.ps1

---------------------------
cloudflared Windows Updater
---------------------------

Checking Github for cloudflared version ...
Latest cloudflared version -  4/06/2024 06:29:11

Checking installed cloudflared version ...
Installed cloudflared version -  16/06/2024 14:40:33

Latest cloudflared version already installed. No update required!
```

## Example - No updated required! 

```
PS C:\Scripts> .\update-cloudflared.ps1

---------------------------
cloudflared Windows Updater
---------------------------

Checking Github for cloudflared version ...
Latest cloudflared version -  4/06/2024 06:29:11

Checking installed cloudflared version ...
Installed cloudflared version -  16/06/2024 14:40:33

Latest cloudflared version already installed. No update required!
```