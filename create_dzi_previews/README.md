# create_dzi_previews

Standalone tool to generate Deep Zoom (`.dzi` + JPG tile pyramids) from TIF files for the [Osprey Dashboard](https://github.com/Smithsonian/Osprey). It resolves dashboard `folder_id` and `file_id` values via the Osprey API so output names match what the zoom UI expects.

This folder is **self-contained** and can be copied elsewhere without the main Osprey Worker codebase.

## Requirements

- Python 3.7+
- An Osprey Dashboard server with API access
- Files and folders already registered in the dashboard (this tool only **reads** from the API)

Install dependencies:

```bash
pip install -r create_dzi_previews/requirements.txt
```

## Settings

Point the tool at the same `settings.py` used by Osprey Worker. Only these values are required:

```python
project_alias: str = "my_project"
api_url: str = "http://dashboard.example.com/api"
api_key: str = "your-api-key"
```

Set the path via `--settings`, the `OSPREY_SETTINGS` environment variable, or a `./settings.py` file in the current working directory.

## Usage

You must run the tool so Python can find the `create_dzi_previews` package. Use **one** of these methods:

### Option A — `run.py` (recommended, works from any directory)

```bash
python create_dzi_previews/run.py INPUT_FOLDER OUTPUT_FOLDER --settings /path/to/settings.py
```

From inside the package folder:

```bash
cd create_dzi_previews
python run.py /data/USNM_20260707/tifs /data/images --settings ../settings.py
```

### Option B — module mode (from the parent of `create_dzi_previews/`)

```bash
cd /path/to/Osprey_Worker    # directory that contains create_dzi_previews/
python -m create_dzi_previews INPUT_FOLDER OUTPUT_FOLDER --settings settings.py
```

### Common error

`ModuleNotFoundError: No module named 'create_dzi_previews'` means Python's working directory or path does not include the **parent** of the `create_dzi_previews` folder. Use Option A, or `cd` to the parent directory before Option B.

Do **not** run `python -m create_dzi_previews` from inside the `create_dzi_previews/` directory itself.

### Arguments

| Argument | Description |
|----------|-------------|
| `INPUT_FOLDER` | Folder containing `.tif` files (often a subfolder like `tifs/`) |
| `OUTPUT_FOLDER` | Root preview directory; files are written under `folder{folder_id}/` inside this path |

| Flag | Description |
|------|-------------|
| `--settings` | Path to `settings.py` (default: `$OSPREY_SETTINGS` or `./settings.py`) |
| `--force` | Regenerate even when `.dzi` and tile folders already exist |
| `--workers N` | Process N TIFs in parallel (default: 1; large images use a lot of memory) |
| `-v`, `--verbose` | Enable debug logging (includes API timing) |

### Example

```bash
python create_dzi_previews/run.py \
  /data/USNM_20260707/tifs \
  /data/images \
  --settings settings.py
```

If the dashboard folder name is `USNM_20260707` and `folder_id` is `123`, output is written to:

```
/data/images/folder123/
├── 12345.dzi
├── 12345_files/
│   ├── 0/
│   │   └── 0_0.jpg
│   └── ...
└── 67890.dzi
```

To regenerate existing previews:

```bash
python create_dzi_previews/run.py /data/USNM_20260707/tifs /data/images --settings settings.py --force
```

At the end of each run, the tool prints a summary line to stderr and stdout:

```text
SUMMARY | folder=USNM_20260707 folder_id=123 tifs=57 elapsed=0:12:20
```

## How folder and file IDs are resolved

1. **Folder name** — taken from the **parent** of `INPUT_FOLDER`, not the input folder itself.
   - Input: `/data/USNM_20260707/tifs` → dashboard folder name: `USNM_20260707`
2. **folder_id** — looked up in the project folder list via `POST /projects/{alias}` (read-only; no folder creation).
3. **file_id** — each TIF filename stem (without extension) is matched to `file_name` in the folder's file list from `POST /folders/{folder_id}`.

Files must already be registered in the dashboard. Unmatched TIFs are logged and skipped; the script exits with code **1** if any files fail generation or are unmatched.

## Output layout

For normal projects, previews go under `{OUTPUT_FOLDER}/folder{folder_id}/`. Transcription projects use `{OUTPUT_FOLDER}/{folder_id}/` instead (same rule as Osprey Worker).

At startup, the tool deletes any **top-level** legacy `*.jpg` / `*.tar*` files in the resolved preview folder (it does not scan or modify subfolders like `{file_id}_files/`).

Each image produces:

- `{file_id}.dzi` — Deep Zoom XML descriptor
- `{file_id}_files/` — tile pyramid (`0/`, `1/`, … with `{col}_{row}.jpg` tiles)

Tile settings match Osprey Worker: 254 px tiles, JPEG quality 100%, antialias resize.

## Portability

To use outside this repo, copy the entire `create_dzi_previews/` folder:

```
my_tools/
└── create_dzi_previews/
    ├── __main__.py
    ├── cli.py
    ├── registry.py
    ├── dzi.py
    ├── paths.py
    ├── api.py
    ├── settings_loader.py
    ├── requirements.txt
    └── openzoom/
```

Then from `my_tools/`:

```bash
pip install -r create_dzi_previews/requirements.txt
python create_dzi_previews/run.py INPUT OUTPUT --settings settings.py
```

## Troubleshooting

| Problem | Likely cause |
|---------|----------------|
| `Folder '…' not found in project` | Parent folder name does not match a dashboard folder, or wrong `project_alias` |
| `No API file_id for …` | TIF stem does not match any `file_name` in the dashboard for that folder |
| `settings missing required values` | `api_url`, `api_key`, or `project_alias` not set in settings |
| Out of memory with `--workers` | Reduce `--workers`; each process loads a full TIF into memory |

## What this tool does not do

- Image validation (JHOVE, MD5, etc.)
- Thumbnail or full-size JPG generation
- API writes (lookup only)
- Tar packaging of tile folders

## Package layout

| File | Purpose |
|------|---------|
| `cli.py` | Command-line entry and orchestration |
| `registry.py` | API lookups for `folder_id` and `file_id` |
| `dzi.py` | Deep Zoom tile generation |
| `paths.py` | Output path helpers |
| `api.py` | HTTP helpers for dashboard API |
| `settings_loader.py` | Load and validate `settings.py` |
| `openzoom/` | Vendored Deep Zoom tile library |
