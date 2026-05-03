# 🧠 Edge-Forge - Trusted Execution Environment for Local AI Agents

This repository provides a **modular, idempotent installer system** for creating a **trusted execution environment** where internal files are never exposed to external APIs. It uses **Ollama** and **LM Studio** as local-only model runtimes, integrated with agent-oriented tools like **Aider**, **OpenCode**, and **Claude Code**.

The goal is to provide a **reproducible, scriptable, and composable setup** that enforces data access boundaries — either by limiting filesystem exposure through curated workspaces, or by running models entirely offline/locally so no data leaves the machine.

---

# 🎯 Purpose

* Create a **trusted execution environment** for AI agents
* Prevent accidental host data exposure (files, credentials, browser data) to LLM workloads
* Enable **agent-based coding workflows** with **local-only** models (Ollama, LM Studio)
* Enforce **default-deny data access** — applies exclusively to Docker configuration (uses OpenCode online default settings, and trusted via Docker configuration) to ensure zero host filesystem access unless explicitly provided
* Support both **CLI-first (Ollama)** and **GUI-first (LM Studio)** runtimes
* Keep installs **idempotent and safe to re-run**
* Provide a foundation for **secure automation and experimentation**

---

# ⚙️ Architecture Overview

The system supports three execution mechanisms: Ollama and LM Studio (local runtimes, trusted by locality — run offline on host, no external API calls) and Docker (uses OpenCode online default settings, and trusted via Docker configuration). The four layers are organized as follows, with Docker-specific components enforcing a **default-deny data exposure model**:

### 1. Entry Points

* `bin/install.sh` — Central CLI dispatcher for all install operations
* `bin/activate.sh` — Dispatcher for environment activation

### 2. Shared Libraries (`lib/`)

Reusable primitives:

* dependency checks (Node, CLI tools)
* runtime helpers (Ollama lifecycle)
* security checks (filesystem mount validation)

### 3. Installers (`installers/`)

Discrete, composable modules:

* **runtime/** → installs model backends (local-only, no external API calls)
* **coding-agents/** → installs agent/dev tools with controlled data access

### 4. Activators (`activators/`)

Interactive launchers:

* **docker.sh** → standalone Docker container
* **ollama.sh** → interactive model management + agent selection

This separation allows:

* independent installs (`runtime` vs `coding-agent`)
* easy extensibility (drop-in new installers)
* consistent behavior across tools

---

# 🤖 Supported Runtimes (Local-Only)

## Ollama (default)

* Fully scriptable via CLI (`pull`, `list`, `serve`)
* Supports **idempotent model management**
* **Runs offline/locally** — no external API calls
* Ideal for:

  * secure automation
  * local agent pipelines
  * air-gapped environments

## LM Studio

* GUI-based model management
* Loads raw GGUF files
* **Runs offline/locally** — no external API calls
* Better for:

  * secure experimentation
  * interactive tuning
  * quick local testing without cloud dependencies

⚠️ Models are **not shared** between runtimes → expect duplicated storage.
⚠️ **Both runtimes enforce local-only execution** — your data never leaves the machine.

# 🔐 Security Model (Trusted Execution Environment)

This repository uses **two trust models** for agent execution:

**Ollama / LM Studio (local, trusted by locality)**: Run offline on the host, no external API calls. Data stays on the local machine — trust comes from locality.

**Docker (trusted via configuration, container data untrusted)**: Uses **uses OpenCode online default settings* (no local LLM). Trust comes from Docker's **default-deny data exposure model**, not the container's contents. Core principles for Docker:

1. **Zero ambient host access**: Containers start with no access to `$HOME`, system configs, or sensitive files unless explicitly provided via curated mounts.
2. **No local LLM in Docker**: Docker uses OpenCode online default settings to maintain trusted agentic abilities even when host resources can not support local LLM. Trust relies on Docker configuration, not container data.
3. **No environment leakage**: Containers block inherited host variables (`HOME`, `USER`, `XDG_*`, credentials) to prevent ambient discovery.
4. **Defense-in-depth**: Sensitive paths (`~/.ssh`, `~/.aws`, `~/.config`, browser profiles) are never mounted and blocked from discovery.
5. **Prevent agent escalation**: Minimal filesystem surfaces stop agents from recursively exploring or scraping host state.

# 🧩 Supported Tooling

* Aider → agent-style coding workflows with **local model backend** (Ollama/LM Studio)
* OpenCode → local model integration via OpenAI-compatible API (served locally for Ollama/LM Studio); Docker activator uses OpenCode online default settings to maintain trusted agentic abilities even when host resources can not support local LLM.
* Claude Code → local model integration via Ollama

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
./bin/activate.sh docker <workspace>          # Launch Docker container (uses generic OpenCode, no local LLM; trusted via Docker config, container data untrusted)
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
│   ├── docker.sh            # Online LLM, Docker container trusted execution environment when LLM can not run locally
│   └── ollama.sh            # Local LLM, Interactive: list models, build from config, pick agent
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
│   ├── docker-images/       # Docker image definitions for trusted execution environment
│   │   └── Dockerfile
│   └── ollama-models/       # Modelfiles for custom model configs
│       └── gemma3-4b-16k
│
└── README.md
```

---

## Model Knowledge Guide

For detailed information on context sizing, memory impact, Ollama vs LM Studio performance differences, and model tuning, see [MODEL_GUIDE.md](MODEL_GUIDE.md).
