Write a Windows PowerShell script that organizes photos and videos from a source folder into dated subfolders based on each file's last-modified date.

## Setup
- Start by clearing the console (`cls`) and enabling `Set-StrictMode -Version Latest`.
- Determine the base path from `$PSScriptRoot` (the folder containing the .ps1 file); if that's empty (e.g. the script was pasted into a console), fall back to the current working directory via `Get-Location`. Ensure the base path ends with a trailing backslash.
- Define:
  - `$SrcPath` = base path + `_sort\`  (where files are read from, searched recursively)
  - `$DstPath` = base path + `_test\Photos\` for images, later switched to `_test\Videos\` for videos

## Core function: Process-Photo-File
Accepts a single file object from the pipeline (`[Parameter(ValueFromPipeline)]`). For that file:
1. Read its `LastWriteTime`.
2. Using an invariant `en-US` culture for formatting, build the destination directory as:
   `$DstPath\<yyyy>\<yyyy-MM-dd>\`
   (year folder, then a day folder).
3. Create that directory if it doesn't exist (`New-Item -ItemType Directory -Force`, suppress output).
4. Target name = destination dir + original file name. Then:
   - **If no file with that name exists at the destination:** move the file there and print `<source> -> <destination>`.
   - **If a file with that name already exists:**
     - Compare the source file's size to the existing file's size.
     - **Same size →** treat it as a duplicate and skip it (do nothing / leave the source in place). Leave a clearly-marked, commented-out `Remove-Item` line for the source so the user can optionally enable deletion of duplicates.
     - **Different size →** find a non-colliding name by inserting an incrementing index before the extension (`<basename>.1.<ext>`, `<basename>.2.<ext>`, …) until a free name is found, then move the file there and print the move.

## Batch function: Process-Photo-Files
Accepts an array of file objects from the pipeline. Return immediately if the array is null or empty. Otherwise iterate with a 1-based counter, printing a progress prefix like `[ <n> / <total> ] ` (no newline) before piping each file into `Process-Photo-File`.

## Main flow
For each extension below, print `Searching photos.../videos...`, recursively collect matching files with `Get-ChildItem -Recurse -Force -LiteralPath $SrcPath -Filter <ext>`, print `Found <count> <ext> files...`, then pass them to `Process-Photo-Files`.

- **Photos** (`$DstPath` = `_test\Photos\`): `*.jpg`, then `*.jpeg`
- **Videos** (switch `$DstPath` to `_test\Videos\`): `*.mp4`, `*.3gp`, `*.avi`, `*.mov`, `*.mpg`, `*.mkv`

Use `@($files).Count` when reporting counts so a single result still counts correctly. Keep everything in one self-contained .ps1 file with section comments.