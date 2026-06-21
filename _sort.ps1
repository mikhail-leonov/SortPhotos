# 
# Entry point
#
cls
Set-StrictMode -Version Latest
#
# Determine the directory the script is running from
#   - $PSScriptRoot = folder containing the .ps1 file (when run as a script)
#   - fallback to current working directory (when pasted into a console)
#
$BasePath = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
if (-not $BasePath.EndsWith("\")) { $BasePath += "\" }
#
# Process-Photo-File function
#
function Process-Photo-File {
    [CmdletBinding()]
    Param([Parameter(ValueFromPipeline)][System.Object]$file)
    $date = $file.LastWriteTime
    $culture = $culture = New-Object system.globalization.cultureinfo("en-US")
    $dir = $DstPath + $date.ToString("yyyy", $culture) + "\" + $date.ToString("yyyy-MM-dd", $culture) + "\" 
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    $name = $dir + $file.Name
    if ([System.IO.File]::Exists($name)) { 
       $size1 = $file.length
       $size2 = (Get-Item $name).length
       if ($size1 -eq $size2) {
#          Remove-Item -Path $file.FullName -Force
	  Write-Host ""
       } else {
	  $index = 1
          while ([System.IO.File]::Exists($name)) { 
             $name = $dir + $file.basename + "." + $index + $file.extension
             $index++
          }
          Write-Host $file.FullName, " -> ", $name 
          Move-Item -Path $file.FullName -Destination $name
       }
    } else {
       Write-Host $file.FullName, " -> ", $name 
       Move-Item -Path $file.FullName -Destination $name
    }
}
#
# Process-Photo-Files function
#
function Process-Photo-Files {
    [CmdletBinding()]
    Param([Parameter(ValueFromPipeline)][System.Object[]]$files)
    
    if ($files -eq $null) {
        return
    }
    if ($files.length -eq 0) {
        return
    }
    $counter = 1;
    foreach ($file in $files) {
        Write-Host -NoNewline "[ ", $counter, " / ", $files.length, " ] "
        ($file) | Process-Photo-File
        $counter++
    }
}
#
# Initialization
#
$SrcPath = $BasePath + "_sort\"
$DstPath = $BasePath + "_test\Photos\"

#
# Collecting and processing the photos
#
Write-Host "Searching photos..." 
$ext = "*.jpg"
$files = Get-ChildItem -Recurse -Force -LiteralPath $SrcPath -filter $ext
Write-Host "Found ", @($files).count, " ", $ext, " files..." 
Process-Photo-Files -files $files
Write-Host "Searching photos..." 
$ext = "*.jpeg"
$files = Get-ChildItem -Recurse -Force -LiteralPath $SrcPath -filter $ext
Write-Host "Found ", @($files).count, " ", $ext, " files..." 
Process-Photo-Files -files $files


$DstPath = $BasePath + "_test\Videos\"
#
# Collecting and processing the videos
#
Write-Host "Searching videos..." 
$ext = "*.mp4"
$files = Get-ChildItem -Recurse -Force -LiteralPath $SrcPath -filter $ext
Write-Host "Found ", @($files).count, " ", $ext, " files..." 
Process-Photo-Files -files $files
Write-Host "Searching videos..." 
$ext = "*.3gp"
$files = Get-ChildItem -Recurse -Force -LiteralPath $SrcPath -filter $ext
Write-Host "Found ", @($files).count, " ", $ext, " files..." 
Process-Photo-Files -files $files
Write-Host "Searching videos..." 
$ext = "*.avi"
$files = Get-ChildItem -Recurse -Force -LiteralPath $SrcPath -filter $ext
Write-Host "Found ", @($files).count, " ", $ext, " files..." 
Process-Photo-Files -files $files
Write-Host "Searching videos..." 
$ext = "*.mov"
$files = Get-ChildItem -Recurse -Force -LiteralPath $SrcPath -filter $ext
Write-Host "Found ", @($files).count, " ", $ext, " files..." 
Process-Photo-Files -files $files
Write-Host "Searching videos..." 
$ext = "*.mpg"
$files = Get-ChildItem -Recurse -Force -LiteralPath $SrcPath -filter $ext
Write-Host "Found ", @($files).count, " ", $ext, " files..." 
Process-Photo-Files -files $files
Write-Host "Searching videos..." 
$ext = "*.mkv"
$files = Get-ChildItem -Recurse -Force -LiteralPath $SrcPath -filter $ext
Write-Host "Found ", @($files).count, " ", $ext, " files..." 
Process-Photo-Files -files $files