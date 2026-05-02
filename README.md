# 🧠 Edge-Forge - Local AI Runtime + Agent Tooling Bootstrap

This repository provides a **modular, idempotent installer system** for setting up a local AI development environment, centered around **Ollama** and **LM Studio**, and integrating them with agent-oriented tools like **Aider**, **OpenCode**, and **Claude Code**.

The goal is to provide a **reproducible, scriptable, and composable setup** for running local models and connecting them to developer-facing AI workflows.

---

# 🎯 Purpose

* Standardize local AI environment setup
* Enable **agent-based coding workflows** with local models
* Support both **CLI-first (Ollama)** and **GUI-first (LM Studio)** runtimes
* Keep installs **idempotent and safe to re-run**
* Provide a foundation for **automation, experimentation, and performance tuning**

---

# ⚙️ Architecture Overview

The system is organized into three layers:

### 1. Entry Point

* `bin/install.sh`
  Central CLI dispatcher for all install operations

### 2. Shared Libraries (`lib/`)

Reusable primitives:

* system detection (OS, GPU)
* dependency checks (Node, CLI tools)
* runtime helpers (Ollama lifecycle)

### 3. Installers (`installers/`)

Discrete, composable modules:

* **runtime/** → installs model backends
* **coding-agents/** → installs agent/dev tools

This separation allows:

* independent installs (`runtime` vs `coding-agent`)
* easy extensibility (drop-in new installers)
* consistent behavior across tools

---

# 🤖 Supported Runtimes

## Ollama (default)

* Fully scriptable via CLI (`pull`, `list`, `serve`)
* Supports **idempotent model management**
* Ideal for:

  * automation
  * APIs
  * agent pipelines

## LM Studio

* GUI-based model management
* Loads raw GGUF files
* Better for:

  * experimentation
  * interactive tuning
  * quick local testing

⚠️ Models are **not shared** between runtimes → expect duplicated storage.

---

# 🧩 Supported Tooling

* Aider → agent-style coding workflows
* OpenCode → local model integration via OpenAI-compatible API
* Claude Code → local model integration via Ollama

All tools are installed in a consistent, repeatable way.

---

# 🔁 Idempotent Design

The system is safe to re-run:

* Existing binaries are detected and skipped
* Models are checked before download
* Configs are only written when needed

---

# 🧪 Usage

### Individual components

```bash
./bin/install.sh runtime ollama
./bin/install.sh runtime lmstudio

./bin/install.sh coding-agent aider
./bin/install.sh coding-agent opencode
./bin/install.sh coding-agent claude
```

# 🧠 Runtime Model Considerations

## Model Isolation

Each runtime uses a different format:

* Ollama → bundled model + runtime config
* LM Studio → raw GGUF weights

Even identical models:

* are stored separately
* are not interchangeable

# Repository Stracture

repo/
├── bin/
│   └── install              # main entrypoint
│
├── lib/
│   ├── core.sh              # shared utils (logging, checks)
│   ├── system.sh            # OS/GPU detection
│   ├── node.sh              # node/npm install logic
│   └── ollama.sh            # ollama helpers
│
├── installers/
│   ├── runtime/
│   │   ├── ollama.sh
│   │   └── lmstudio.sh
│   │
│   └── cli/
│       ├── claude.sh
│       ├── opencode.sh
│       └── aider.sh
│
├── config/
│   ├── opencode-lmstudio.json.tpl
│   └── config.env
│
└── README.md

# Notes & Design Decisions

* **Ollama chosen as default**: It exposes a CLI (`ollama pull`, `ollama list`) → supports true idempotent automation.
* **Model check strategy**:

  * Ollama: `ollama list | grep`
  * LM Studio: filesystem heuristic (no official CLI)
* **GPU detection** is advisory only (doesn’t block install).
* Script is **safe to re-run** (no duplicate installs or downloads).

## Models are not shared between `ollama` and `LM Studio`

Models are not shared between Ollama and LM Studio because they use different model packaging and runtimes. Ollama stores models in a bundled format that includes metadata, templates, and runtime configuration, while LM Studio loads raw GGUF files directly. They also keep models in separate directories and do not index or detect each other’s storage locations. As a result, even if the underlying weights are identical, each tool treats them as independent and incompatible installations.

If using the same model in both tools expect 2X disk space requirement

---

## Practical recommendation

Pick **one primary runtime**:

### Use Ollama if you:

* Want automation / scripting / APIs
* Are building pipelines or services
* Need reproducible installs (like your script)
* Understand its configuration to yield the most out of the tool

### Use LM Studio if you:

* Want GUI-based experimentation
* Compare models interactively
* Tweak parameters visually
* Faster out of the box setup and interaction with the model

---

## LM Studio vs Ollama performance reality

* LM Studio often feels **faster or more responsive**
* Ollama sometimes feels slower for the same model

### Why this happens:

Ollama:

* Optimized for **general server runtime + flexibility**
* May use more conservative defaults (context, scheduling, KV cache)
* Can incur overhead from model loading / serving pipeline

LM Studio:

* Optimized for **interactive inference (desktop UX)**
* Aggressive GPU/Metal optimizations (especially on Apple Silicon)
* Often better tuned kernels for supported models

---

## Context size = major speed factor (very important)

> **Larger context = slower responses**

Because transformer cost grows with:

* Attention over all previous tokens
* KV-cache memory usage
* Bandwidth pressure on GPU/CPU

### Practical behavior:

| Context size | Performance              |
| ------------ | ------------------------ |
| 4K           | fast                     |
| 8K           | normal                   |
| 16K          | noticeably slower        |
| 32K          | slow                     |
| 64K+         | very slow / memory heavy |


Even small models slow down significantly when context increases.

## “Minimum tokens” for agentic workflows

> agents need ~16K context or more to boot and operate normally

Agent loops require:

* system prompt (instructions)
* tool definitions
* conversation history
* code context
* intermediate reasoning traces

So even small tasks accumulate tokens fast.

### Typical breakdown:

* system prompt: ~1–2K
* tools schema: ~1–3K
* code context: ~2–8K
* conversation history: grows continuously

-----

#### Ollama Commands

* `ollama run <model>`
* `ollama stop <model>`
* `ollama rm <model>`
* `ollama ls`
* `ollama ps`
* `OLLAMA_NUM_PARALLEL=1 OLLAMA_FLASH_ATTENTION=true OLLAMA_MLX=1 ollama serve`
* `aider --model ollama/<model> --max-chat-history-tokens 16384 aider --map-tokens 8192`
* `ollama launch opencode --model <model>`

----
