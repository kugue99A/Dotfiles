# Local LLM for Herdr

The local coding stack is declared in
`macos/.config/home-manager/local-llm.nix` and applied with Home Manager.
It consists of:

- llama.cpp bound to `127.0.0.1:8080` as an OpenAI-compatible API;
- Muse Glimmer 30B Q4 as the coding/tool-use model;
- OpenCode as the Herdr-visible agent;
- a launchd service that loads the model on demand;
- the version-matched Herdr/OpenCode state integration.

The GGUF files are intentionally kept outside the Nix store because they are
large local artifacts. The expected paths are:

```text
~/models/muse-glimmer-30b/muse-glimmer-30B-kquant-dynamic.gguf
~/models/muse-glimmer-30b/dflash-kquant.gguf
```

## Use

```bash
local-llm doctor       # Check runtime, model, service, and client
local-llm start        # Load the model and wait until the API is ready
local-llm status       # Show API/model status
local-llm bench        # Run a deterministic chat-completion smoke benchmark
local-code             # Start OpenCode against the local model
local-llm logs         # Follow launchd logs
local-llm stop         # Release model memory
```

In a Herdr pane, run `local-code`. Herdr detects the OpenCode process and its
managed integration reports idle, working, and blocked states. The server uses
one inference slot: multiple local agents queue instead of competing for memory
bandwidth. Use cloud-backed agents for genuinely parallel inference.

## DFlash policy

DFlash remains available for controlled experiments with
`local-llm stop; local-llm serve-dflash`, but is not the launchd default. On
this M5 Max, a cold exact-answer sample measured about 20.7 generated tokens/s
with DFlash versus 25.5 without it. After warm-up on closely related prompts,
DFlash rose to roughly 49–62 tokens/s as draft acceptance improved, while the
normal path remained around 23–24 tokens/s. This high prompt- and warm-up
sensitivity is precisely why one headline number is insufficient. The default
favors predictable latency for diverse coding requests; re-test on a real
Herdr workload before making DFlash the default for repetitive batch work.

## Update and apply

```bash
nix-channel --update
mise upgrade --yes
home-manager switch
```

`mise` intentionally applies its configured release-age policy, so a just-published
release may be held briefly instead of being installed immediately.
