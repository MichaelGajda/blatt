<p align="center">
  <a href="" rel="noopener">
    <img width=200px src="assets/logo.png" alt="blatt logo">
  </a>
</p>

<h3 align="center">blatt</h3>

<div align="center">

[![Status](https://img.shields.io/badge/status-active-success.svg)]()
[![GitHub Issues](https://img.shields.io/github/issues/MichaelGajda/blatt.svg)](https://github.com/MichaelGajda/blatt/issues)
[![GitHub Pull Requests](https://img.shields.io/github/issues-pr/MichaelGajda/blatt.svg)](https://github.com/MichaelGajda/blatt/pulls)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](/LICENSE)

</div>

---

<p align="center">PDF statistics for your terminal — page counts, document counts, file sizes.
    <br>
</p>

## Table of Contents

- [About](#about)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Running the Tests](#running-the-tests)
- [Built Using](#built-using)
- [Authors](#authors)
- [Contributing](CONTRIBUTING.md)

## About

Born from a one-liner, blatt gives you instant PDF statistics for any folder. How many pages across all your PDFs? How large are they? Which ones are the biggest? One command, instant answer.

macOS only — uses Spotlight metadata (`mdls`) for fast, reliable page counts without opening files.

## Getting Started

### Prerequisites

- macOS (uses built-in `mdls`, `stat`, `find`, `awk`)

### Installing

**Homebrew**:

```bash
brew tap michaelgajda/blatt
brew install blatt
```

**Manual**:

```bash
git clone https://github.com/MichaelGajda/blatt.git
cd blatt
ln -s "$(pwd)/src/blatt" /usr/local/bin/blatt
```

Verify the installation:

```bash
blatt --version
```

## Usage

```bash
blatt ~/Documents                       # Summary: pages, docs, size
blatt -v ~/Documents                    # Just the facts
blatt -r ~/Documents                    # Recursive: include subdirectories
blatt -v --sort pages ~/Documents       # Sort by pages (or: name, size)
blatt -v --sort size --top 5 ~/Documents  # Top 5 largest files
blatt --box ~/Documents                 # With manners
blatt --fancy ~/Documents               # Dressed to impress
blatt --ultrafancy ~/Documents          # You asked for this
blatt --json ~/Documents                # JSON output for scripting
```

**Summary output:**

```
347 pages in 12 documents, total size 45.2 MB
```

**Verbose output (`-v`):**

```
Name                          Pages       Size
──────────────────────────────────────────────
report-q1.pdf                    42    3.1 MB
handbook.pdf                    186   12.4 MB
invoice-march.pdf                 2   104.3 KB
──────────────────────────────────────────────
3 docs                          230   15.6 MB
```

**Box-drawing table (`--box`):**

```
┌───────────────────┬──────────┬────────────┐
│ Name              │    Pages │       Size │
├───────────────────┼──────────┼────────────┤
│ report-q1.pdf     │       42 │     3.1 MB │
│ handbook.pdf      │      186 │    12.4 MB │
│ invoice-march.pdf │        2 │   104.3 KB │
├───────────────────┼──────────┼────────────┤
│ 3 docs            │      230 │    15.6 MB │
└───────────────────┴──────────┴────────────┘
```

**`--fancy`** adds color-coded pages/sizes (green → yellow → red by magnitude), alternating row shading, and a background-highlighted header.

**`--ultrafancy`** goes full send: animated scanning intro, typing animation, sparkline size bars, a `¯\_(ツ)_/¯` in the totals row, and a random rainbow-animated sign-off. Try it.

**Top N (`--top`):**

Show only the N largest or longest files. Summary still shows full totals.

```bash
blatt -v --sort size --top 5 ~/Documents
```

**JSON output (`--json`):**

```json
{
  "directory": "~/Documents",
  "recursive": false,
  "total_pages": 230,
  "total_documents": 3,
  "total_bytes": 16357376,
  "files": [
    {"name": "report-q1.pdf", "path": "...", "pages": 42, "bytes": 3250585, "unreadable": false},
    {"name": "handbook.pdf", "path": "...", "pages": 186, "bytes": 13002342, "unreadable": false}
  ],
  "unreadable_count": 0
}
```

Pipe it into `jq` for quick queries:

```bash
blatt --json ~/Documents | jq '.files[] | select(.pages > 10)'
```

**Unreadable files:** PDFs that can't be read (not indexed, password-protected) are flagged with `?` in verbose output and `"unreadable": true` in JSON.

## Running the Tests

```bash
bash tests/test_blatt.sh
```

## Built Using

Pure Bash. macOS system tools only: `mdls`, `stat`, `find`, `awk`.

## Authors

- [@MichaelGajda](https://github.com/MichaelGajda) — Creator
- [Claude](https://claude.ai) — Rubber duck that talks back
