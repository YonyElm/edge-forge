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

The system is organized into four layers:

### 1. Entry Points

* `bin/install.sh` — Central CLI dispatcher for all install operations
* `bin/activate.sh` — Dispatcher for environment activation

### 2. Shared Libraries (`lib/`)

Reusable primitives:

* dependency checks (Node, CLI tools)
* runtime helpers (Ollama lifecycle)

### 3. Installers (`installers/`)

Discrete, composable modules:

* **runtime/** → installs model backends
* **coding-agents/** → installs agent/dev tools

### 4. Activators (`activators/`)

Interactive launchers:

* **docker.sh** → standalone Docker container
* **ollama.sh** → interactive model management + agent selection

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

### Install components

```bash
./bin/install.sh runtime ollama
./bin/install.sh runtime lmstudio

./bin/install.sh coding-agent aider
./bin/install.sh coding-agent opencode
./bin/install.sh coding-agent claude
```

### Activate environments

```bash
./bin/activate.sh docker           # Launch Docker container
./bin/activate.sh ollama           # Interactive: list models, build from config, pick agent
```

#### Interactive Ollama Activator

`./bin/activate.sh ollama` provides an interactive workflow:

1. **Lists existing models** currently installed
2. **Detects unbuilt Modelfiles** in `config/ollama-models/` and offers to build them
3. **Model selection** — choose from installed models
4. **Agent selection** — pick `aider`, `opencode`, or `claude`
5. **Launches the agent** with the selected model (installs it if missing)

---

# Repository Structure

```
repo/
├── bin/
│   ├── install.sh           # main entrypoint (installs runtimes & agents)
│   └── activate.sh          # activator dispatcher (launches environments)
│
├── activators/              # environment launchers (interactive)
│   ├── docker.sh            # Docker container launcher
│   └── ollama.sh            # Interactive: list models, build from config, pick agent
│
├── lib/
│   ├── core.sh              # shared utils (logging, checks)
│   ├── node.sh              # node/npm install logic (requires core.sh)
│   └── ollama.sh            # ollama helpers (requires core.sh)
│
├── installers/
│   ├── runtime/
│   │   ├── ollama.sh        # idempotent: install ollama + pull model
│   │   └── lmstudio.sh      # idempotent: check LM Studio + model
│   │
│   └── coding-agents/
│       ├── claude.sh
│       ├── opencode.sh
│       └── aider.sh
│
├── config/
│   ├── config.env           # environment variables
│   ├── models.local.env     # per-machine override (gitignored)
│   ├── opencode-lmstudio.json.tpl
│   └── ollama-models/       # Modelfiles for custom model configs
│       └── gemma3-4b-16k
│
└── README.md
```

---

# Notes & Design Decisions

* **Ollama chosen as default**: It exposes a CLI (`ollama pull`, `ollama list`) → supports true idempotent automation.
* **Model check strategy**:

  * Ollama: `ollama list | grep`
  * LM Studio: filesystem heuristic (no official CLI)
* Script is **safe to re-run** (no duplicate installs or downloads).
* **Installers** are idempotent setup routines. **Activators** are interactive launchers.

---

## Model Knowledge Guide

For detailed information on context sizing, memory impact, Ollama vs LM Studio performance differences, and model tuning, see [MODEL_GUIDE.md](MODEL_GUIDE.md).
