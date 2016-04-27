function Install-ChocolateyIsoPackage {
<#
.SYNOPSIS
Installs program from an ISO (cd/dvd image file).

.DESCRIPTION
Downloads an ISO file from a url, mounts the iso and installs a program on your machine.

.PARAMETER PackageName
The name of the VisualStudio package - this is arbitrary.
It's recommended you call it the same as your nuget package id.

.PARAMETER UninstallerName
This name of the installer executable - i.e. 'vs_community.exe'.

.PARAMETER SilentArgs
OPTIONAL - These are the parameters to pass to the native installer.
Try any of these to get the silent installer - /s /S /q /Q /quiet /silent /SILENT /VERYSILENT

Please include the notSilent tag in your chocolatey nuget package if you are not setting up a silent package.

.PARAMETER Url
This is the url to download the file from.

.PARAMETER Url64bit
OPTIONAL - If there is an x64 installer to download, please include it here. If not, delete this parameter

.PARAMETER Checksum
OPTIONAL (Right now) - This allows a checksum to be validated for files that are not local

.PARAMETER Checksum64
OPTIONAL (Right now) - This allows a checksum to be validated for files that are not local

.PARAMETER ChecksumType
OPTIONAL (Right now) - 'md5' or 'sha1' - defaults to 'md5'

.PARAMETER ChecksumType64
OPTIONAL (Right now) - 'md5' or 'sha1' - defaults to ChecksumType

.PARAMETER MountDrive
This is the name for the drive to mount the ISO to - defaults to W.

.EXAMPLE
Uninstall-ChocolateyIsoPackage 'VisualStudio2015Community' 'vs_community.exe' 'https://go.microsoft.com/fwlink/?LinkId=691978&clcid=0x409' '/NoWeb /NoRestart /NoRefresh /force /Quiet' 'F:' -validExitCodes @(0, 3010)

.OUTPUTS
None

.NOTES
This helper make it easier to install products using ISO CD/DVD images.

.LINK
Install-ChocolateyIsoPackage
#>
param(
    [string] $packageName,
    [string] $installerName,
    [string] $silentArgs = '', 
    [string] $url, 
    [string] $url64bit = '', 
    $validExitCodes = @(0), 
    [string] $checksum = '', 
    [string] $checksumType = '', 
    [string] $checksum64 = '', 
    [string] $checksumType64 = '',
    [string] $mountDrive = 'W:'

)
    Write-Debug "Running 'Install-VS' for $packageName with url:`'$url`'";

    $chocTempDir = Join-Path $env:TEMP "chocolatey" 
    $tempDir = Join-Path $chocTempDir "$packageName" 
 
    if (![System.IO.Directory]::Exists($tempDir)) { [System.IO.Directory]::CreateDirectory($tempDir) | Out-Null } 
    $file = Join-Path $tempDir "$($packageName)Install.iso" 
 
    $installerType = [System.IO.Path]::GetExtension($uninstallerName)
    $installerPath = Join-Path $mountDrive $uninstallerName

    Get-ChocolateyWebFile $packageName $file $url $url64bit -checksum $checksum -checksumType $checksumType -checksum64 $checksum64 -checksumType64 $checksumType64       
    
    Write-Debug "Mounting ISO $iso to drive $drive";
    
    try{
        imdisk -a -f $file -m $drive

        Write-Debug "Installing $packageName using iso."
        Install-ChocolateyInstallPackage $packageName $installerType $silentArgs $installerPath -validExitCodes $validExitCodes
    }
    finally
    {
        Write-Debug "Unmounting ISO $iso from drive $drive";
        imdisk -D -m $drive
    }
}