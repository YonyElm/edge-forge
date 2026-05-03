# Docker-based “Agent Sandbox” (Current Design Summary)

## What we have built

We now have a Docker-based execution environment designed to run Node.js tooling (including `opencode-ai`), Git, npm, and general development workflows inside an isolated container.

### Core properties of the setup

* Runs a **Node.js 18 Debian-based container**
* Provides:

  * `git` (for GitHub clone/push workflows)
  * `npm` (for installing global tooling)
  * `curl` (for API and internet interaction)
* Executes in a **separate Docker network**
* Does **not mount host filesystem**
* Does **not use privileged Docker mode**
* Uses **resource limits (CPU, memory, PID cap)**

### Intended behavior

* Access to the public internet (GitHub, npm registry, APIs)
* No direct visibility into host files
* Ephemeral runtime (container is destroyed after exit)
* Controlled execution environment for agentic or automation workflows

---

## Key tradeoffs we had to make

During hardening, we encountered a fundamental constraint:

> Strong container isolation and full developer tooling compatibility are in tension.

### 1. Security vs usability

We had to relax several strict security controls:

| Control                      | Why it was removed                             |
| ---------------------------- | ---------------------------------------------- |
| `--user 1000`                | Broke apt and npm global installs              |
| `--cap-drop ALL`             | Broke package installation system              |
| read-only filesystem         | Prevented normal tooling (apt/npm/git)         |
| tmpfs strict ownership rules | Caused permission failures in package managers |

### Result:

We prioritized **functional usability over maximal syscall restriction**.

---

### 2. Root inside container

We allow root inside the container because:

* Debian package system (APT) expects root privileges
* npm global installs require writable system paths or root-equivalent prefix handling
* Git workflows are simpler and more predictable

This increases risk inside the container, but does not directly affect the host when properly isolated.

---

### 3. Network access is intentionally open

We allow:

* outbound HTTPS (GitHub, npm, APIs)

We do NOT enforce strict outbound filtering because:

* it breaks package ecosystems
* it complicates development workflows significantly

---

## Security model (what is actually protected)

### Strong protections in place

* No host filesystem mounts (`-v` removed)
* No privileged container mode
* No direct access to host process space
* Isolated Docker bridge network (no container-to-container trust assumed)
* Resource limits (CPU/memory/PID)
* Ephemeral container lifecycle

### What this effectively prevents

* Direct reading or modification of host files
* Simple privilege escalation into host via Docker APIs (if socket not mounted)
* Accidental host environment modification
* Persistent infection via container filesystem (container is destroyed on exit)

---

## Remaining security risks (important)

Even in this setup, several risks remain:

### 1. Network exfiltration (HIGH)

Any code running inside the container can:

* Send data to external servers
* Leak API keys, tokens, or sensitive prompts
* Establish outbound connections freely

> This is the most significant remaining risk.

---

### 2. Supply chain risk (HIGH)

Because the container installs:

* npm packages (`opencode-ai`)
* system packages (`apt-get`)

These steps can execute arbitrary remote code.

---

### 3. Kernel-level escape (LOW but non-zero)

Docker shares the host kernel:

* A kernel vulnerability could allow escape
* This is rare but historically real

---

### 4. Local network exposure (depends on host configuration)

If host firewall rules are NOT applied:

* Container may access LAN devices
* Can scan internal services (NAS, routers, IoT devices)

---

### 5. Insider / malicious workload risk

If the container runs:

* untrusted AI-generated code
* compromised dependencies

It can behave maliciously within its network access scope.

---

## Benefits of running this on an isolated home network machine

Running this setup on a dedicated machine in a home LAN provides a meaningful security boundary upgrade:

### 1. Host isolation becomes meaningful

If the machine:

* is not your primary workstation
* has no sensitive personal data

Then compromise impact is reduced.

---

### 2. Network segmentation improves safety

On a home network:

* You can isolate the machine behind firewall rules
* You can block LAN access entirely
* You can restrict inbound traffic to SSH or none

This reduces lateral movement risk.

---

### 3. Disposable execution environment

You gain:

* repeatable sandbox environment
* safe experimentation space for automation/agents
* no long-term persistence of container state

---

## Remaining risks even on an isolated home machine

Even in this improved deployment model, risks remain:

### 1. Router / LAN pivot risk

If LAN access is not explicitly blocked:

* container can probe internal services
* may attack vulnerable IoT devices
* may attempt lateral movement within home network

---

### 2. Internet-based exfiltration still fully possible

Even on a home-isolated machine:

* outbound traffic is unrestricted by default
* data can be sent anywhere on the internet
* no visibility unless you add network monitoring

---

### 3. Host compromise still possible (rare but real)

If a Docker escape vulnerability is exploited:

* attacker gains control of the sandbox host
* then may pivot to entire home network depending on segmentation

---

## Final assessment

This system is best described as:

> A **practical, developer-friendly container sandbox with moderate isolation guarantees**

It is NOT:

* a high-assurance security sandbox
* a hardened adversarial execution environment
* a VM-level isolation boundary

---

## Practical takeaway

This design is a **deliberate engineering compromise**:

* ✔ Strong enough for agent workflows, development, automation
* ✔ Safe when used on a non-critical isolated machine
* ❌ Not suitable for running fully untrusted or adversarial code without additional network controls (firewall/VPN/VM layer)
