# Brew Tools That Make Claude Code Better

Tools that Claude Code actually uses — either directly via shell commands or as the engine behind its built-in tools. These aren't cosmetic; they make searches faster, output more useful, and workflows more capable.

## Core — Powers Built-in Tools

| Tool | Package | What It Does | How Claude Code Uses It |
|------|---------|--------------|------------------------|
| **ripgrep** | `ripgrep` | Fast recursive text search | Powers the Grep tool directly. Every code search Claude runs goes through `rg`. Respects `.gitignore`, handles regex, and returns results in milliseconds even on large repos. |
| **fd** | `fd` | Fast file finder | Used for file discovery via Bash. Finds files by name or extension far faster than `find`. Its `.gitignore` awareness keeps results clean. |

## Essential — Used Directly via Shell

| Tool | Package | What It Does | How Claude Code Uses It |
|------|---------|--------------|------------------------|
| **gh** | `gh` | GitHub CLI | Claude's primary interface to GitHub. Creates PRs, reads issues, checks CI status, posts comments, and manages releases — all without needing a browser. |
| **jq** | `jq` | JSON processor | Parses and transforms JSON output from APIs, config files, and other CLI tools. Lets Claude extract exactly the data it needs from structured output. |
| **tokei** | `tokei` | Code statistics | Gives Claude a fast project overview — languages used, lines of code, comment density. Helps scope work and understand unfamiliar codebases quickly. |
| **shellcheck** | `shellcheck` | Shell script linter | Catches bugs and portability issues in shell scripts Claude writes or edits. Validates correctness before committing. |

## Useful — Available When Needed

| Tool | Package | What It Does | How Claude Code Uses It |
|------|---------|--------------|------------------------|
| **hyperfine** | `hyperfine` | Command benchmarking | When Claude needs to prove a performance improvement, `hyperfine` provides statistically rigorous before/after comparisons. |
| **difftastic** | `difftastic` | Structural diff | Understands syntax, so it diffs by AST rather than raw text. Helps Claude produce more meaningful change analysis. |
| **wget/curl** | `wget` / `curl` | HTTP client | Fetches remote files, tests API endpoints, downloads assets. `curl` is usually pre-installed; `wget` adds resume and recursive download. |

## Installation

```sh
# Core
brew install ripgrep fd

# Essential
brew install gh jq tokei shellcheck

# Useful
brew install hyperfine difftastic wget
```

## Not on This List

Tools like `bat`, `eza`, `fzf`, `zoxide`, and `delta` are excellent but they improve **your** terminal experience, not Claude's. Claude can't use interactive tools (fzf, zoxide) and doesn't benefit from syntax highlighting or color output (bat, eza, delta). See `brew-cli-tools.md` for those.
