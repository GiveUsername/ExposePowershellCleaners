$userName = ($env:USERPROFILE -split '\\')[2]

Write-Output "Stopping processes (Prism Release, Prism Executor, Windows Runtime, nexusloader, prism, nyfcwl)"
Stop-Process -Name "Prism Release V1.5", "Prism Release V1.3", "Prism Executor", "Windows Runtime", "nexusloader", "prism", "nyfcwl", "Intel Graphics Processor" -Force -ErrorAction SilentlyContinue
Write-Output "Processes stopped"

Write-Output "Deleting executables"
$executables = @(
    "C:\Users\$userName\AppData\Local\Temp\Prism Release\Prism Release V1.5.exe",
    "C:\Users\$userName\AppData\Local\Temp\Prism Release\Prism Release V1.3.exe",
    "C:\Users\$userName\Prism Executor.exe",
    "C:\Users\$userName\AppData\Local\Temp\prism.exe",
    "C:\Users\$userName\AppData\Local\Temp\onefile_924_133630461016085588\nexusloader.exe",
    "C:\Users\$userName\AppData\Local\Temp\nyfcwl.exe",
    "C:\Users\$userName\AppData\Local\Temp\onefile_540_133630461712021276\svchost.exe",
)
foreach ($exe in $executables) {
    Remove-Item -Path $exe -Force -ErrorAction SilentlyContinue
}
Write-Output "Deleted executables"

Write-Output "Removing registry entries (Persistence)"
$registryPaths = @("HKCU:\Software\Microsoft\Windows\CurrentVersion\Run", "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run")
foreach ($path in $registryPaths) {
    $keys = Get-Item -Path $path
    foreach ($key in $keys.Property) {
        if ((Get-ItemProperty -Path $path -Name $key).$key -match "Prism Release V1.5.exe" -or 
            (Get-ItemProperty -Path $path -Name $key).$key -match "Prism Release V1.3.exe" -or 
            (Get-ItemProperty -Path $path -Name $key).$key -match "Prism Executor.exe" -or 
            (Get-ItemProperty -Path $path -Name $key).$key -match "prism.exe" -or 
            (Get-ItemProperty -Path $path -Name $key).$key -match "nexusloader.exe" -or 
            (Get-ItemProperty -Path $path -Name $key).$key -match "nyfcwl.exe" {
            Remove-ItemProperty -Path $path -Name $key -Force -ErrorAction SilentlyContinue
            Write-Output "Removed registry entry: $key"
        }
    }
}
Write-Output "Entries Removed"

Write-Output "Removing scheduled tasks (Persistence)"
$tasks = Get-ScheduledTask | Where-Object {$_.Actions -match "Prism Release V1.5.exe" -or 
                                           $_.Actions -match "Prism Release V1.3.exe" -or 
                                           $_.Actions -match "Prism Executor.exe" -or 
                                           $_.Actions -match "prism.exe" -or 
                                           $_.Actions -match "nexusloader.exe" -or 
                                           $_.Actions -match "nyfcwl.exe"}
foreach ($task in $tasks) {
    Unregister-ScheduledTask -TaskName $task.TaskName -Confirm:$false -ErrorAction SilentlyContinue
    Write-Output "Removed scheduled task: $($task.TaskName)"
}
Write-Output "Tasks removed"

Write-Output "Removing startup items (Persistence)"
$startupPaths = @("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup", "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup")
foreach ($path in $startupPaths) {
    $files = Get-ChildItem -Path $path -Filter "*.lnk"
    foreach ($file in $files) {
        if ((Get-ItemProperty -Path $file.FullName).Target -match "Prism Release V1.5.exe" -or 
            (Get-ItemProperty -Path $file.FullName).Target -match "Prism Release V1.3.exe" -or 
            (Get-ItemProperty -Path $file.FullName).Target -match "Prism Executor.exe" -or 
            (Get-ItemProperty -Path $file.FullName).Target -match "prism.exe" -or 
            (Get-ItemProperty -Path $file.FullName).Target -match "nexusloader.exe" -or 
            (Get-ItemProperty -Path $file.FullName).Target -match "nyfcwl.exe" {
            Remove-Item -Path $file.FullName -Force -ErrorAction SilentlyContinue
            Write-Output "Removed startup item: $($file.FullName)"
        }
    }
}
Write-Output "Startup items removed"

foreach ($exclusion in $defenderExclusions) {
    Remove-MpPreference -ExclusionPath $exclusion -ErrorAction SilentlyContinue
}
Write-Output "WinDefender Reverted"

Write-Output "Blocking C2 communication using firewall rule"
New-NetFirewallRule -DisplayName "Block C2 Communication Outbound" -Direction Outbound -LocalPort Any -RemoteAddress 91.92.241.69 -Action Block -Profile Any
New-NetFirewallRule -DisplayName "Block C2 Communication Inbound" -Direction Inbound -LocalPort Any -RemoteAddress 91.92.241.69 -Action Block -Profile Any
Write-Output "Firewall rules created to block C2 communication"

Write-Output "Cleaning temp files"
$ErrorActionPreference = "SilentlyContinue"
if (Test-Path "C:\Users$userName\AppData\Local\Temp") {
Get-ChildItem -Path "C:\Users$userName\AppData\Local\Temp" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}
Write-Output "Temp files cleaned"
$ErrorActionPreference = "Continue"

Write-Output "Cleaning roaming and cached files"
Remove-Item -Path "C:\Users$userName\AppData\Roaming\encabezado" -Recurse -Force -ErrorAction SilentlyContinue
Write-Output "Finished cleaning roaming and cached"

Write-Output "ggez bye bye frinkle"
Write-Output "credit to nspe lol"
Write-Output "------------------"
Write-Output "JOIN THE DISCORD: discord.gg/2fSx3nBzxb"
