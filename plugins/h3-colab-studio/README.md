# H3 Colab Studio (`h3-colab-studio`)

Native Google Antigravity plugin for building and running a **MiniMax H3 Prompt-to-Video Workspace** bridged to **Google Colab G4 (ComfyUI)**.

安裝於 `~/.gemini/config/plugins/h3-colab-studio/`，即使 Antigravity 更新也會永久保留。

---

## Core Capabilities / 核心功能

1. **Workspace Control App (`references/app-blueprint.md`)**
   - 建立本地端持久化任務佇列 Web App（支援 T2V 分鏡設定、即時 H3 結構化 Prompt 預覽與編輯、任務狀態追蹤與結果回填）。
   - 誠實分離控制介面與算力後端：Web App 負責排程與 Prompt 編修，實際 GPU 生成由 Agent 橋接至 Google Colab G4 執行。

2. **Official MiniMax H3 Multi-Shot Prompting (`references/prompt-spec.md`)**
   - 遵循官方 `h3-prompt-writing` 結構（主體場景定義 + 分鏡鏡頭標籤 + 環境音 `overall_soundscape` + 配樂 `non_diegetic_music`）。
   - 透過逐字重複主體／色調描述＋固定共享 `noise_seed`，讓多個獨立單鏡（5 秒 × 3 鏡等）剪接後具備一致角色服裝與電影級連貫感。

3. **Verified Colab G4 Runbook & Stitching (`references/colab-runbook.md`, `scripts/stitch.sh`)**
   - 內建實測驗證的 `dseditor/minimax-h3-colab` (`H3_Basic_ComfyUI.ipynb`) G4 操作流程。
   - 自動避開兩大實測踩坑點：補齊缺失的 `minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors` Turbo LoRA，以及每次排隊前檢查 `SaveVideo` 的 `mp4` 格式欄位。
   - 使用 `scripts/stitch.sh` 呼叫 `ffmpeg` 合成多鏡影片並以 `ffprobe` 驗證解析度、影格率、時長與音軌，最後記錄前後 Compute Units 消耗並刪除 Runtime 停止計費。
