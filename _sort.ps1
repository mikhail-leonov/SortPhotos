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
$DstPath = $BasePath + "_done\Photos\"

#
# Collecting and processing the photos
#
$imageExtensions = @(
    "*.jpg","*.jpeg","*.png","*.bmp","*.gif","*.webp",
    "*.tif","*.tiff","*.heic","*.heif","*.avif","*.jfif",
    "*.cr2","*.cr3","*.nef","*.arw","*.orf","*.rw2",
    "*.dng","*.raf","*.pef","*.raw"
)
foreach ($ext in $imageExtensions) {
    Write-Host "Searching photos ( $ext )..."
    $files = Get-ChildItem -Recurse -Force -LiteralPath $SrcPath -Filter $ext
    Process-Photo-Files $files
}

$DstPath = $BasePath + "_done\Videos\"

#
# Collecting and processing the videos
#
$videoExtensions = @(
    "*.mp4","*.m4v","*.mov","*.avi","*.mkv","*.wmv",
    "*.flv","*.webm","*.mpeg","*.mpg","*.mpe",
    "*.ts","*.m2ts","*.mts","*.vob","*.3gp","*.3g2",
    "*.asf","*.ogv","*.rm","*.rmvb","*.f4v","*.dv",
    "*.mod","*.tod","*.mxf"
)
foreach ($ext in $videoExtensions) {
    Write-Host "Searching $ext..."
    $files = Get-ChildItem -Recurse -Force -LiteralPath $SrcPath -Filter $ext
    Process-Photo-Files $files
}