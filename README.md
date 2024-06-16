<img src="https://www.cloudflare.com/img/logo-cloudflare.svg" width="150">  

# `cloudflared` Windows Updater

`cloudflared` is the Cloudflare Tunnel client which can be found here - https://github.com/cloudflare/cloudflared.

For those running `cloudflared` on Windows - Automatic updates is not currently possible as noted by Cloudflare here - https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/.

```
Instances of cloudflared do not automatically update on Windows. 
You will need to perform manual updates.
```

This PowerShell script automates the update process for `cloudflared` on Windows. 

The script checks for the latest version (using `datecreated`) on the `cloudflared` GitHub repository (https://github.com/cloudflare/cloudflared). The script compares the `datecreated` between the GitHub respository and the locally installed version. If a later version exists - the script will stop the `cloudflared` service and download and install the new version then start the `cloudflared` service again.

## Requirements & setup
1. Requires PowerShell to be run as `administrator`.

2. Requires `PowerShellForGitHub` module (https://www.powershellgallery.com/packages/powershellforgithub) installed. Run `Install-Module -Name PowerShellForGitHub`.

3. Set `CLOUDFLARED_INSTALL_PATH` to the path of the locally installed `cloudflared` version.  
Example - `"C:\Program Files (x86)\cloudflared\cloudflared.exe"`.

4. Register a new `EventLog` `source` in order for messages from the script to be written to the `Application` log in the Event Viewer.  
Run `New-EventLog –LogName Application –Source “Update cloudflared”`.    
Test the source is working by running - `Write-EventLog –LogName Application –Source “Update cloudflared” –EntryType Information –EventID 1 –Message “HelloWorld”`. The message should appear under the `Application` log in the Event Viewer.

5. Execute script as needed or setup a `task` using Task Scheduler in Windows for automatic updates.

## Example output - New `cloudflared` version found!

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

## Example output - No updated required! 

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

## Task Scheduler

A new `task` can be created in Task Scheduler to check for and update `cloudflared` daily for example.

1. Create a Basic Task
2. Name - `Update cloudflared`
3. Task Trigger - `daily`
4. Action - `Start a program`  
Program/script - `powershell`  
Add arguments - `-File "C:\Program Files (x86)\cloudflared\update-cloudflared.ps1"`
5. Finish

Once created - edit the properties of the newly created `Update cloudflared` task. Under Security Options - 
- Select - `Run whether user is logged on or not`
- Select - `Run with highest privileges`
- Enter Windows `username` and `password` when prompted

Run the newly created `Update cloudflared` task and check the `Last Run Result` shows `(0x0)` which means its sucessful.