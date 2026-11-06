# H3 Colab Studio

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Agent Skills](https://img.shields.io/badge/Spec-Agent%20Skills-green)](https://agentskills.io)
[![Antigravity](https://img.shields.io/badge/Antigravity-Skill%20%26%20Plugin-blue)](https://antigravity.google)

**English** | **[繁體中文](README.zh-TW.md)**

An agent skill and plugin for building and running a **MiniMax H3 Prompt-to-Video Workspace** bridged to **Google Colab G4 (ComfyUI)**.

A single MiniMax H3 generation renders one continuous take with no internal cuts. To produce cohesive multi-shot stories without watermarks, this workflow pairs three parts:

1. **Control-Surface Web App** ([`app-blueprint.md`](skills/h3-colab-studio/references/app-blueprint.md)): A persistent job queue and live prompt-draft preview. The UI is explicit that GPU generation runs on Colab rather than inside the browser app.
2. **Official H3 Multi-Shot Prompt Structure** ([`prompt-spec.md`](skills/h3-colab-studio/references/prompt-spec.md)): Converts user ideas in any language into structured English shot blocks with verbatim character/palette anchors and a shared fixed `noise_seed`.
3. **Verified Colab G4 Runbook & Stitching** ([`colab-runbook.md`](skills/h3-colab-studio/references/colab-runbook.md), [`stitch.sh`](skills/h3-colab-studio/scripts/stitch.sh)): Runs all shots in a single Colab G4 session (`RTX PRO 6000 Blackwell`, ~96 GB VRAM), applies two critical ComfyUI fixes before queueing, stitches MP4 clips locally via `ffmpeg`, verifies stream metadata with `ffprobe`, and tracks exact Colab compute-unit burn.

---

## Repository Layout

```text
.
├── skills/
│   └── h3-colab-studio/               # Universal Agent Skill (Antigravity, Claude Code, OpenSkills)
│       ├── SKILL.md                   # Entrypoint instructions with YAML frontmatter
│       ├── skill.yaml                 # Packaged skill manifest
│       ├── references/
│       │   ├── app-blueprint.md       # Persistent job-queue web app specification
│       │   ├── colab-runbook.md       # Verified Colab G4 + ComfyUI setup & failure fixes
│       │   └── prompt-spec.md         # Official MiniMax H3 prompt structure & multi-shot guide
│       └── scripts/
│           └── stitch.sh              # ffmpeg concat + ffprobe stream verification
├── plugins/
│   └── h3-colab-studio/               # Native Google Antigravity Plugin bundle
│       ├── plugin.json
│       ├── README.md
│       ├── assets/logo.svg
│       └── skills/h3-colab-studio/
├── dist/
│   └── h3-colab-studio.skill          # Ready-to-import .skill archive
├── .claude-plugin/                    # Claude Code plugin marketplace manifests
└── install.sh                         # One-click local installer
```

---

## Prerequisites

- **Google Colab Compute Units**: A Google account with Colab compute units (for example, Google AI Ultra or Colab Pro/Pro+) able to select the **G4** runtime (`NVIDIA RTX PRO 6000 Blackwell Server Edition`, ~96 GB VRAM).
- **Local FFmpeg**: `ffmpeg` and `ffprobe` installed locally for multi-shot concatenation and output verification (`brew install ffmpeg` on macOS, `apt install ffmpeg` on Ubuntu/Debian).

---

## Installation

### Option 1: One-Click Installer (Antigravity & Claude Code)

```bash
git clone https://github.com/Rea1Felix/H3-colab-studio.git
cd H3-colab-studio
chmod +x install.sh
./install.sh all
```

Available modes:
- `./install.sh all` — Installs both the Antigravity standalone skill (`~/.gemini/config/skills/`) and native plugin (`~/.gemini/config/plugins/`).
- `./install.sh skills` — Installs the standalone skill to `~/.gemini/config/skills/h3-colab-studio`.
- `./install.sh plugins` — Installs the native Antigravity plugin to `~/.gemini/config/plugins/h3-colab-studio`.
- `./install.sh claude` — Installs the skill to `~/.claude/skills/h3-colab-studio`.

### Option 2: OpenSkills / Agent Skills CLI

```bash
openskills install Rea1Felix/H3-colab-studio
```

Or with `npx skills`:

```bash
npx skills add Rea1Felix/H3-colab-studio
```

### Option 3: Packaged `.skill` Archive

Import [`dist/h3-colab-studio.skill`](dist/h3-colab-studio.skill) directly into platforms that accept `.skill` zip bundles.

---

## Key Verified Findings (Colab G4 + ComfyUI)

| Configuration | Duration | Measured Sampling Time (G4) | Notes |
| :--- | :--- | :--- | :--- |
| `864×480` (0.41 MP, 16:9) | 15 s | ~4–5 min | Fast draft / single-shot validation |
| `1376×768` (1.0 MP, 16:9) | 5 s / shot | ~2 min 55 s / shot | ~4.80 compute units total for a 3-shot (15 s) session incl. model download |
| `1920×1088` (2.0 MP, 16:9) | 15 s | ~69 min | ~17.59 compute units total; watch for Colab idle disconnect |

- **Measured G4 Burn Rate**: ~8.94 compute units/hour (~1.49 units per 10 minutes), slightly below the ~10.05 units/hour estimate shown in the Colab resource panel.
- **Two Mandatory Pre-Flight Fixes** (documented in [`colab-runbook.md`](skills/h3-colab-studio/references/colab-runbook.md)):
  1. **Missing Turbo LoRA**: Download `lightx2v/Minimax-h3-Turbo` (`minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors`, ~1.96 GB) into `/content/ComfyUI/models/loras` before queueing, even when Turbo is toggled off.
  2. **`SaveVideo` Format Check**: Verify the `SaveVideo` node's `format` field is explicitly set to `mp4` before every run so finished renders are not dropped at save time.
  3. **Avoid `keboqi/minimax-h3` Prism Studio UI**: Use the direct ComfyUI notebook (`dseditor/minimax-h3-colab`, `H3_Basic_ComfyUI.ipynb`) instead.

---

## Usage Examples

Once installed, ask your agent naturally:

- **Build the workspace app**:
  > "Use `h3-colab-studio` to build the local prompt-to-video job-queue web app following the blueprint."
- **Draft a multi-shot H3 prompt**:
  > "Optimize this idea into a 3-shot MiniMax H3 prompt (5s per shot, 1376×768, fixed seed): a deep-sea diver discovers an ancient bioluminescent clockwork cathedral."
- **Execute & stitch a queued job**:
  > "Run H3 job #1 on Google Colab G4 following the runbook, stitch the downloaded shots with `stitch.sh`, and backfill the output specs and compute units used."

---

## License

Released under the [MIT License](LICENSE).
