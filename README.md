# Photo & Video Sorter

A small PowerShell script that tidies a pile of photos and videos into dated folders. It scans a source folder recursively, then **moves** each file into a `Year\Year-Month-Day\` folder based on the file's last-modified date — separating images from videos into two destination trees.

It's a single `.ps1` file with no dependencies beyond Windows PowerShell.

---

## What it does

- Recursively searches a source folder for media files.
- For each file, reads its **last-write time** and builds a destination path like `2024\2024-08-17\`.
- Moves photos into a `Photos` tree and videos into a `Videos` tree.
- Creates the dated folders as needed.
- Handles name collisions safely (see below).

### File types

| Category | Extensions |
|----------|-----------|
| Photos | `.jpg`, `.jpeg` |
| Videos | `.mp4`, `.3gp`, `.avi`, `.mov`, `.mpg`, `.mkv` |

### Folder layout

By default the script works relative to its own location (`$PSScriptRoot`, falling back to the current directory). With the script in a folder `D:\Media\`, it expects:

```
D:\Media\
  _sort\                         <- source: put files to be sorted here (scanned recursively)
  _test\
    Photos\
      2024\2024-08-17\photo.jpg  <- sorted output
    Videos\
      2023\2023-12-01\clip.mp4
```

- **Source:** `_sort\`
- **Photo output:** `_test\Photos\`
- **Video output:** `_test\Videos\`

### Duplicate / collision handling

When a file with the same name already exists at the destination:

- **Same size** — the file is treated as a duplicate and **left untouched** in the source. (The script contains a `Remove-Item` line to delete such duplicates, but it is **commented out**, so nothing is deleted by default — un-comment it to enable automatic removal.)
- **Different size** — the incoming file is renamed with a numeric suffix (`name.1.jpg`, `name.2.jpg`, …) so the existing file is never overwritten, then moved.

---

## Usage

1. Place the script in a working folder (e.g. `D:\Media\`).
2. Put the files you want to sort into a `_sort` subfolder beside it.
3. Run it in PowerShell:

   ```powershell
   .\Sort-Media.ps1
   ```

   If your environment blocks unsigned scripts, you can run it for the current session with:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\Sort-Media.ps1
   ```

The console reports progress per type ("Found N *.jpg files…") and prints each `source -> destination` move.

---

## Configuration

The paths are set near the middle of the script and can be edited to taste:

```powershell
$SrcPath = $BasePath + "_sort\"          # where files are read from
$DstPath = $BasePath + "_test\Photos\"   # photo destination (reassigned to _test\Videos\ before videos)
```

Change `_sort`, `_test\Photos`, and `_test\Videos` to point anywhere you like. To sort additional file types, add another `$ext = "*.<ext>"` / `Get-ChildItem` / `Process-Photo-Files` block following the existing pattern.

---

## Notes & cautions

- **It moves, not copies.** Files are relocated out of the source folder. Back up your media before a first run, and try it against a copy or a small test set.
- **Sorting is by modification date, not EXIF "date taken."** It uses each file's `LastWriteTime`. If your files were copied or edited in a way that changed that timestamp, the dated folders may not match when the photo was actually shot.
- **Dates are formatted with US English culture** (`en-US`) for consistent `yyyy-MM-dd` folder names regardless of system locale.
- Windows-only (uses Windows path conventions and PowerShell).

---

## Requirements

Windows with PowerShell (Windows PowerShell 5.x or PowerShell 7+). No modules or external tools required.
