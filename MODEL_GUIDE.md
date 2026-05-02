# 🧠 Model Guide — Runtime Considerations & Performance Tuning

This guide covers how to match models to your local hardware, understand memory and context tradeoffs, and choose between runtimes.

---

## Model Isolation

Each runtime uses a different format:

* **Ollama** → bundled model + runtime config
* **LM Studio** → raw GGUF weights

Even identical models:

* are stored separately
* are not interchangeable

If using the same model in both tools, expect **2x disk space requirement**.

---

## Practical Recommendation

Pick **one primary runtime**:

### Use Ollama if you:

* Want automation / scripting / APIs
* Are building pipelines or services
* Need reproducible installs
* Understand its configuration to yield the most out of the tool

### Use LM Studio if you:

* Want GUI-based experimentation
* Compare models interactively
* Tweak parameters visually
* Prefer faster out-of-the-box setup and interaction

---

## LM Studio vs Ollama Performance Reality

* LM Studio often feels **faster or more responsive**
* Ollama sometimes feels slower for the same model

### Why this happens:

**Ollama:**

* Optimized for **general server runtime + flexibility**
* May use more conservative defaults (context, scheduling, KV cache)
* Can incur overhead from model loading / serving pipeline

**LM Studio:**

* Optimized for **interactive inference (desktop UX)**
* Aggressive GPU/Metal optimizations (especially on Apple Silicon)
* Often better tuned kernels for supported models

---

## Context Size = Major Speed Factor

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

### KV Cache Compression

In `config/ollama-models/` Modelfiles you can control KV cache size:

* `q8_0` — ~2GB RAM for 8K context (recommended balance)
* `q4_0` — ~1GB RAM for 8K context (aggressive, may affect quality)
* uncompressed (f16) — ~4GB RAM for 8K context

This frees up massive amounts of RAM for larger context windows.

---

## Minimum Tokens for Agentic Workflows

> Agents need ~16K context or more to boot and operate normally

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

---

## Ollama Quick Reference

### Commands

* `ollama run <model>`
* `ollama stop <model>`
* `ollama rm <model>`
* `ollama ls`
* `ollama ps`

### Serve with optimized settings

```bash
OLLAMA_NUM_PARALLEL=1 OLLAMA_FLASH_ATTENTION=true OLLAMA_MLX=1 ollama serve
```

### Aider with Ollama

```bash
aider --model ollama/<model> --max-chat-history-tokens 16384 --map-tokens 8192
```

### OpenCode with Ollama

```bash
ollama launch opencode --model <model>
```
