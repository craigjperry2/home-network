# GPU & CUDA Health on Host `s1`

Assessment date: 2026-10-25

## Hardware & Driver Health

* **Host**: `s1`
* **GPU**: NVIDIA GeForce GTX 1080 Ti (11,264 MiB VRAM)
* **Driver Version**: `580.178.04` (Legacy 580 branch)
* **CUDA Version**: 13.0 (Driver) / 12.9 (Nixpkgs unstable toolkit)
* **Thermals & Power**:
  * Idle: ~32°C at 8W
  * Under load: ~38°C–43°C at 57W–73W
* **Kernel & Driver Status**:
  * Clean post-reboot kernel buffer without `Xid` errors.
  * Prior issue: A pre-reboot MMU fault (`Xid 31: Host Memory MMU Fault`, followed by `Xid 154: Node Reboot Required`) was causing `/dev/nvidia-uvm` to fail with `EIO` (`failed to initialize CUDA: unknown error`). Rebooting resolved the fault and restored normal `/dev/nvidia-uvm` access.

## Mutually Exclusive CUDA Systemd Services

Host `s1` defines three mutually exclusive LLaMA C++ systemd services configured in `nix/hosts/s1/configuration.nix`. Each was started individually, verified for GPU offloading, and exercised against its HTTP endpoints:

| Service | Model | VRAM Usage | `/health` Endpoint | Functional Verification |
| :--- | :--- | :--- | :--- | :--- |
| `llama-cpp-qwen.service` | `/srv/ai/Qwen3.5-9B-Q8_0.gguf` | 10,625 MiB | `{"status":"ok"}` | Chat completion: **30.9 tokens/sec** |
| `llama-cpp-gemma.service` | `/srv/ai/gemma-4-e4b-8bit.gguf` + mmproj | 8,889 MiB | `{"status":"ok"}` | Multimodal chat completion: **38.9 tokens/sec** |
| `llama-cpp-qwen-embed.service` | `/srv/ai/Qwen3-Embedding-4B-Q8_0.gguf` | 10,135 MiB | `{"status":"ok"}` | Vector embedding generation (`/v1/embeddings`) |

## Current Default State

* **Active Unit**: `llama-cpp-qwen.service`
* **Port**: `127.0.0.1:11434`
* **VRAM Allocated**: ~10,620 MiB to `llama-server`
