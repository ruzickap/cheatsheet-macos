# AI Agent Guidelines

## Project Overview

This is a LaTeX-based macOS keyboard shortcuts cheatsheet
(`macos_cheatsheet.tex`). It compiles to PDF, JPG, PNG, and SVG via
a Docker-based build pipeline using `makefile4latex`.

## Build Commands

```bash
# Full build (PDF + JPG + PNG + SVG) via Docker
./run.sh

# Build specific format only
./run.sh pdf
./run.sh jpg png

# Verbose build
./run.sh --verbose pdf

# Direct make targets (requires local TeXLive installation)
make pdf         # Build PDF
make jpg png svg # Build image formats
make mostlyclean # Remove intermediate files only
make clean       # Remove all generated files
make pretty      # Format LaTeX with latexindent
make lint        # Lint LaTeX with chktex
make help        # Show all available targets
```

## Lint and Validation Commands

CI uses MegaLinter (`.mega-linter.yml`). Run individual linters
locally:

```bash
# Markdown linting (Rust-based, replaces markdownlint)
rumdl .

# Shell script linting and formatting
shellcheck --exclude=SC2317 run.sh
shfmt --case-indent --indent 2 --space-redirects --diff run.sh

# Link checking
lychee --config lychee.toml .

# JSON validation (with comment support)
jsonlint --comments .github/renovate.json5

# LaTeX linting and formatting (via Makefile)
make lint   # Runs chktex
make pretty # Runs latexindent

# Makefile linting
checkmake Makefile

# GitHub Actions validation
actionlint

# Security scanning
checkov --quiet -d .
trivy fs --severity HIGH,CRITICAL --ignore-unfixed .
```

## Code Style Guidelines

### Markdown

- Wrap lines at 80 characters for readability
- Use proper heading hierarchy (no skipped levels)
- Include language identifiers in code fences (`bash`, `json`)
- Prefer code fences over inline code for multi-line examples
- Must pass `rumdl` checks (config: `.rumdl.toml`)
- Shell code blocks (`bash`/`shell`/`sh`) are extracted and
  validated with `shellcheck` + `shfmt` during CI
- `CHANGELOG.md` is auto-generated and excluded from linting

### Shell Scripts

- Start with `set -euo pipefail` for strict error handling
- Format with `shfmt`: 2-space indent, case-indent,
  space-redirects
- Use **uppercase** for variables: `${MY_VARIABLE}`
- Always use braces in variable expansion: `${VAR}` not `$VAR`
- Functions use `snake_case`: `print_info()`, `show_usage()`
- `shellcheck` exclusion: SC2317 (unreachable command warning)

### LaTeX

- Use `booktabs` commands (`\toprule`, `\midrule`, `\bottomrule`)
  for table formatting -- never use `\hline`
- Use `% chktex <number>` inline comments to suppress false
  positives from `chktex`
- Consistent table column specification: `{*{2}{l}}`

### JSON / YAML

- JSON files may contain comments (`jsonlint --comments`)
- `.devcontainer/devcontainer.json` is excluded from JSON linting
- YAML files start with `---` document separator
- Use `# keep-sorted` annotations for sections that must stay
  sorted

### GitHub Actions Workflows

- **Pin all actions to full SHA** with version comment:
  `actions/checkout@<sha> # v6.0.2`
- Use `permissions: read-all` (minimal permissions)
- Set `timeout-minutes` on every job
- Validate changes with `actionlint`

### General Formatting

- Use **two spaces** for indentation (no tabs) in all file types
  except LaTeX (which uses tabs for `\begin`/`\end` nesting)
- Insert final newline at end of files
- Trim trailing whitespace
- Rulers at column 80

## Version Control

### Commit Messages

Use conventional commit format with these rules:

- **Types**: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`,
  `style`, `perf`, `ci`, `build`, `revert`
- **Format**: `<type>: <description>` (max 72 chars)
- Imperative mood, lowercase (except proper nouns)
- No trailing period on subject line
- Body: wrap at 72 chars, explain what and why
- Reference issues: `Fixes #123`, `Closes #456`

```text
docs: update keyboard shortcuts for macOS Sequoia

- Add new Stage Manager shortcuts
- Remove deprecated Dashboard shortcuts

Resolves: #42
```

### Branching

Follow [Conventional Branch](https://conventional-branch.github.io/)
format: `<type>/<description>`

- `feature/` or `feat/`: new features
- `bugfix/` or `fix/`: bug fixes
- `hotfix/`: urgent fixes
- `release/`: release prep (e.g., `release/v1.2.0`)
- `chore/`: non-code tasks

Use lowercase, hyphens, no consecutive/leading/trailing hyphens.

### Pull Requests

- Always create as **draft** initially
- Title must follow conventional commit format
- Include clear description of changes and motivation
- Link related issues with `Fixes`, `Closes`, `Resolves`

## Security

- Checkov: skip `CKV_GHA_7` (workflow_dispatch inputs)
- DevSkim: ignore DS162092 (debug code), DS137138 (insecure URL);
  exclude `CHANGELOG.md`
- KICS: fail only on HIGH severity
- Trivy: HIGH/CRITICAL only, ignore unfixed vulnerabilities

## Link Checking

- Tool: `lychee` (config: `lychee.toml`)
- Valid status codes: 200, 429
- Caching enabled; 403/429 responses are re-checked
- Excluded: template variables, shell variables, private IPs
- Excluded files: `CHANGELOG.md`, `package-lock.json`
