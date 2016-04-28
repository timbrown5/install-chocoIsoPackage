function Uninstall-ChocolateyIsoPackage {
<#
.SYNOPSIS
Uninstalls program from an ISO.

.DESCRIPTION
Downloads a given ISO file and uses this to uninstall a program.

.PARAMETER PackageName
The name of the chocolatey package to remove.

.PARAMETER UninstallerName
This name of the installer executable - i.e. 'vs_community.exe'.

.PARAMETER Url
This is the path to the ISO to download.

.PARAMETER SilentArgs
OPTIONAL - These are the parameters to pass to the native installer.
Try any of these to get the silent installer - /s /S /q /Q /quiet /silent /SILENT /VERYSILENT

Please include the notSilent tag in your chocolatey nuget package if you are not setting up a silent package.

.PARAMETER MountDrive
This is the name for the drive to mount the ISO to - defaults to W.

.EXAMPLE
Uninstall-ChocolateyIsoPackage 'VisualStudio2015Community' 'vs_community.exe' 'https://go.microsoft.com/fwlink/?LinkId=691978&clcid=0x409' '/Uninstall /force /Quiet' 'F:' -validExitCodes @(0, 3010)

.OUTPUTS
None

.NOTES
This helper make it easier to uninstall products using ISO CD/DVD images.

.LINK
Uninstall-ChocolateyIsoPackage
#>
param(
    [string] $packageName,
    [string] $uninstallerName,
    [string] $url,
    [string] $silentArgs = '',
    [string] $mountDrive = 'W:',
    $validExitCodes = @(0)
)

    $chocTempDir = Join-Path $env:TEMP "chocolatey" 
    $tempDir = Join-Path $chocTempDir "$packageName" 
 
 
    if (![System.IO.Directory]::Exists($tempDir)) { [System.IO.Directory]::CreateDirectory($tempDir) | Out-Null } 
    $file = Join-Path $tempDir "$($packageName)Install.$fileType" 

    $isoLocalPath = Join-Path $env:temp "$packageName.iso"
    $installerType =  [System.IO.Path]::GetExtension($uninstallerName)
    $installerPath = Join-Path $mountDrive $uninstallerName

    Get-ChocolateyWebFile $packageName $isoLocalPath $isoUrl

    try{
        Write-Debug "Mounting ISO $iso to drive $drive";
        imdisk -a -f $file -m $drive

        Write-Debug "Uninstalling $packageName using iso.";
        Uninstall-ChocolateyPackage $packageName $installerType $silentArgs $installerPath -validExitCodes $validExitCodes
    }
    finally
    {
        Write-Debug "Unmounting ISO $iso from drive $drive";
        imdisk -D -m $drive
    }
}