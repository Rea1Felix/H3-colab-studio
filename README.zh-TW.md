# H3 Colab Studio

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Agent Skills](https://img.shields.io/badge/Spec-Agent%20Skills-green)](https://agentskills.io)
[![Antigravity](https://img.shields.io/badge/Antigravity-Skill%20%26%20Plugin-blue)](https://antigravity.google)

**[English](README.md)** | **繁體中文**

專為 **MiniMax H3** 打造的開源 Agent Skill 與 Plugin：結合「任務佇列與分鏡提示詞工作台 Web App」與「Google Colab G4 (ComfyUI) 代理執行橋接流程」，穩定產出無浮水印、帶音軌的多鏡頭連貫影片。

由於 MiniMax H3 單次生成只會輸出一鏡到底的連續畫面（不會在單支影片內自動切鏡），本工作流透過三個模組協作來完成多鏡敘事：

1. **任務佇列控制介面**（[`app-blueprint.md`](skills/h3-colab-studio/references/app-blueprint.md)）：建立本地端或持久化的任務佇列 Web App，提供即時結構化 Prompt 預覽與編修。介面明確區分「控制面」與「算力面」，實際 GPU 推論皆在 Colab 執行。
2. **官方結構化多鏡 Prompt 規範**（[`prompt-spec.md`](skills/h3-colab-studio/references/prompt-spec.md)）：將任意語言的故事構想轉為符合官方 `h3-prompt-writing` 結構的英文分鏡腳本，透過逐字固定角色／色調錨點與共享 `noise_seed` 維持跨鏡頭一致性。
3. **實測驗證的 Colab G4 操作手冊與合成腳本**（[`colab-runbook.md`](skills/h3-colab-studio/references/colab-runbook.md)、[`stitch.sh`](skills/h3-colab-studio/scripts/stitch.sh)）：在單一 Colab G4 執行階段（`RTX PRO 6000 Blackwell`，約 96 GB VRAM）跑完所有分鏡，預先修補兩個實測必踩的 ComfyUI 錯誤，下載後以 `ffmpeg` 無縫接片、`ffprobe` 驗證影音規格，並精確記錄前後消耗的 Compute Units。

---

## 專案結構

```text
.
├── skills/
│   └── h3-colab-studio/               # 通用 Agent Skill（支援 Antigravity、Claude Code、OpenSkills）
│       ├── SKILL.md                   # 主說明檔（含標準 YAML frontmatter）
│       ├── skill.yaml                 # 封裝設定檔
│       ├── references/
│       │   ├── app-blueprint.md       # 任務佇列 Web App 規格藍圖
│       │   ├── colab-runbook.md       # Colab G4 + ComfyUI 實測操作步驟與除錯指南
│       │   └── prompt-spec.md         # MiniMax H3 官方提示詞結構與多鏡連貫技巧
│       └── scripts/
│           └── stitch.sh              # ffmpeg 多鏡合併與 ffprobe 串流驗證腳本
├── plugins/
│   └── h3-colab-studio/               # Google Antigravity 原生 Plugin 封裝
│       ├── plugin.json
│       ├── README.md
│       ├── assets/logo.svg
│       └── skills/h3-colab-studio/
├── dist/
│   └── h3-colab-studio.skill          # 可直接匯入之 .skill 封裝檔
├── .claude-plugin/                    # Claude Code Plugin Marketplace 設定檔
└── install.sh                         # 一鍵安裝腳本
```

---

## 環境需求

- **Google Colab 運算單元（Compute Units）**：具備可用運算單元且能選用 **G4** 執行階段（`NVIDIA RTX PRO 6000 Blackwell Server Edition`，約 96 GB VRAM）的 Google 帳號（如 Google AI Ultra 或 Colab 付費方案）。
- **本機 FFmpeg**：用於合併分鏡片段與檢查輸出規格（macOS 可執行 `brew install ffmpeg`，Ubuntu/Debian 可執行 `apt install ffmpeg`）。

---

## 安裝方式

### 方式一：一鍵安裝腳本（支援 Antigravity 與 Claude Code）

```bash
git clone https://github.com/Rea1Felix/H3-colab-studio.git
cd H3-colab-studio
chmod +x install.sh
./install.sh all
```

可用參數：
- `./install.sh all` — 同時安裝 Antigravity 獨立 Skill（`~/.gemini/config/skills/`）與原生 Plugin（`~/.gemini/config/plugins/`）。
- `./install.sh skills` — 僅安裝至 `~/.gemini/config/skills/h3-colab-studio`。
- `./install.sh plugins` — 僅安裝原生 Plugin 至 `~/.gemini/config/plugins/h3-colab-studio`。
- `./install.sh claude` — 安裝至 Claude Code 全域技能目錄 `~/.claude/skills/h3-colab-studio`。

### 方式二：透過 OpenSkills / Agent Skills CLI 安裝

```bash
openskills install Rea1Felix/H3-colab-studio
```

或使用 `npx skills`：

```bash
npx skills add Rea1Felix/H3-colab-studio
```

### 方式三：匯入 `.skill` 封裝包

若使用支援 `.skill` 壓縮封裝的平台，可直接匯入 [`dist/h3-colab-studio.skill`](dist/h3-colab-studio.skill)。

---

## Colab G4 實測數據與避坑重點

| 解析度設定 | 單鏡秒數 | G4 實測取樣時間 | 備註 |
| :--- | :--- | :--- | :--- |
| `864×480` (0.41 MP, 16:9) | 15 秒 | 約 4–5 分鐘 | 適合快速草稿測試與構圖確認 |
| `1376×768` (1.0 MP, 16:9) | 5 秒 / 鏡 | 約 2 分 55 秒 / 鏡 | 3 鏡共 15 秒（含模型下載）整場約消耗 4.80 運算單元 |
| `1920×1088` (2.0 MP, 16:9) | 15 秒 | 約 69 分鐘 | 整場約消耗 17.59 運算單元；長時取樣需留意閒置斷線 |

- **G4 實測扣點速率**：每小時約消耗 **8.94** 運算單元（每 10 分鐘約 1.49 單元），略低於 Colab 面板預估顯示的 10.05 單元／小時。執行完畢務必「中斷連線並刪除執行階段」才會停止計費。
- **排隊前必做的兩項關鍵修正**（詳見 [`colab-runbook.md`](skills/h3-colab-studio/references/colab-runbook.md)）：
  1. **補齊缺失的 Turbo LoRA**：即使關閉 Turbo 模式，工作流模板仍會載入 LoRA 節點。首次排隊前需先透過 Hugging Face 下載 `lightx2v/Minimax-h3-Turbo`（`minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors`，約 1.96 GB）至 `/content/ComfyUI/models/loras`。
  2. **確認 `SaveVideo` 格式欄位**：每次送出佇列前，確認 `SaveVideo` 節點的 `format` 欄位明確填為 `mp4`，避免算完後因欄位空白導致存檔失敗。
  3. **避開 `keboqi/minimax-h3` 的 Prism Studio UI**：實測會在輸入綁定階段拋出 `IndexError`，請改用 `dseditor/minimax-h3-colab` 的 `H3_Basic_ComfyUI.ipynb` 直接操作 ComfyUI。

---

## 使用範例

安裝完成後，可直接在對話中請 Agent 執行：

- **建立工作台 Web App**：
  > 「請依照 `h3-colab-studio` 的藍圖幫我建立本地端任務佇列與分鏡提示詞預覽 Web App。」
- **撰寫多鏡連貫提示詞**：
  > 「請用 `h3-colab-studio` 幫我把這個構想寫成 3 鏡、每鏡 5 秒、1376×768、固定 Seed 的 MiniMax H3 結構化英文分鏡腳本：一位深海潛水員在海溝發現發光的古代齒輪大教堂。」
- **執行任務並合成影片**：
  > 「請依照 Colab Runbook 在 G4 執行佇列中的第 1 號任務，下載各鏡 MP4 後用 `stitch.sh` 合併驗證，並將實際規格與消耗點數回填到任務紀錄。」

---

## 授權條款

本專案採用 [MIT License](LICENSE) 開源授權。
