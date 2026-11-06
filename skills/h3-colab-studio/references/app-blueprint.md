# Workspace app blueprint

Build this as a persistent web app—for example, a lightweight local full-stack
app backed by a JSON or SQLite store in local coding workspaces (Antigravity,
Claude Code, Cursor, etc.), or a hosted full-stack web app—so job records
survive across restarts and the agent can read and update them via API routes,
CLI helpers, or workspace actions. Dark theme, mobile first. All UI copy should
be honest about the bridge: the app never generates video itself.

## New job form

Fields, in order:

- Idea (textarea, any language)
- Mode: T2V enabled and default. I2V, FL2VA, Ref2VA selectable but labeled
  "coming soon" (jobs may still be queued)
- Per-shot duration chips: 5, 8, 10, 15 seconds
- Resolution tier chips (16:9 base): standard 864×480, high 1120×640,
  max 1376×768
- Aspect ratio: 16:9, 9:16, 1:1
- Shot count: auto, 1, 3, 5
- Seed: random toggle or fixed number input
- Turbo toggle: on or off
- Style: dropdown (none, cinematic, horror, anime, realistic, sci-fi) plus
  a free-text custom style field

## Optimized prompt preview

Beside or below the form, assemble a draft live as the user types, from the
template in [prompt-spec.md](prompt-spec.md):

- A subject and scene block merging idea and style
- One block per shot. For shot count 1, a single block. For 3, 5 or auto,
  propose three blocks with shot-type labels (wide, close-up, cutaway) and
  template-derived descriptions the user can edit
- Soundscape and music lines chosen from the style

Label the panel as a draft that the agent refines before execution. Make
the whole draft editable text, and store per-shot blocks separately in the
job record so the executor can queue them one by one.

## Job record

Store at minimum:

- id, created_at
- status: queued, optimizing, running, done, failed
- All form inputs
- prompt_draft full text and shot_blocks array (label, shot type, text)
- Result fields, empty until the agent backfills: output_specs,
  output_file, colab_cu_used, result_note, status_note, started_at,
  finished_at

## Actions / endpoints the app must expose

- createJob: saves a submission with status queued
- listJobs: newest first
- getJob or job detail view data
- updateJobResult: agent bridge interface (API route, CLI helper, or workspace
  action) that sets status and backfills the result fields
- deleteJob: two-step confirm in the UI

## Job list and detail

- List shows status chip, idea summary, parameter summary, created time
- Detail shows every input, the full prompt with per-shot blocks, a status
  timeline, and the result section once filled
- After a successful submit, show the hint: tell the agent in chat
  "run job #N" and the agent will execute it on Colab and backfill the
  result here

## Bridge status panel

Small panel, values labeled with their measurement date:

- Backend: Google Colab G4 (RTX PRO 6000, 96 GB)
- Compute-unit balance, last measured value and date, with expiry note
- Bridge: the agent, via chat instruction
- Three-step how-it-works: submit here, ask the agent to run it, agent
  generates on Colab, stitches, and backfills the finished record

## Seeding

After the first real run completes, seed exactly one example job from it,
marked as a real example, with the actual prompts, seed, specs and units.
Never seed invented results.
