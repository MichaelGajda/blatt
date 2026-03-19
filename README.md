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

**Homebrew** (coming soon):

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
blatt ~/Documents              # Summary: pages, docs, size
blatt -v ~/Documents           # Verbose: table with per-file breakdown
blatt -r ~/Documents           # Recursive: include subdirectories
blatt -rv ~/Documents          # Both
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
230 pages in 3 documents, total size 15.6 MB
```

## Running the Tests

```bash
bash tests/test_blatt.sh
```

## Built Using

Pure Bash. macOS system tools only: `mdls`, `stat`, `find`, `awk`.

## Authors

- [@MichaelGajda](https://github.com/MichaelGajda) — Creator
- [Claude](https://claude.ai) — Rubber duck that talks back
