# s1 NVIDIA resume / llama-cpp handoff

## Resume note

- Resume copilot session on s1 with identifier: `3986f185-4eb9-446b-9f4d-e47baf904d39`

## Goal

Understand why `llama-cpp` loses CUDA access on `s1` after suspend/resume, and identify a practical recovery or configuration change.

## Current host/config context

- Host: `s1`
- GPU: NVIDIA GeForce GTX 1080 Ti (Pascal)
- Driver in use: `hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_580;`
- `hardware.nvidia.open = false`
- Experimental NVIDIA systemd power-management flow was deliberately not used because it previously caused suspend hangs on this host.
- `llama-cpp` is configured with CUDA support and `--n-gpu-layers 99`.
- `llama-cpp.service` is already stopped before sleep via:
  - `before = ["sleep.target"];`
  - `conflicts = ["sleep.target"];`

Relevant file:

- `nix/hosts/s1/configuration.nix`
  - `services.llama-cpp` config around lines 157-177
  - sleep-related `systemd.services.llama-cpp` wiring around lines 182-190
  - NVIDIA config around lines 243-251

## What was observed live on s1 after resume

- The host had already resumed from suspend.
- `llama-cpp` had previously crashed with:
  - `CUDA-capable device(s) is/are busy or unavailable`
  - `status=6/ABRT`
- Kernel logs showed:
  - `Xid 31`
  - `Xid 154, GPU recovery action changed ... to ... Node Reboot Required`
- After that, `nvidia-smi` still worked and reported the card normally, but `llama-cpp` could no longer initialize CUDA.

Important implication:

- The failure mode is **not** “GPU missing from PCI completely”.
- The failure mode is “driver/card looks partially alive to `nvidia-smi`, but CUDA init for `llama-cpp` is broken after resume”.

## Commands tried and outcome

### 1. Plain service restart

Tried:

- `systemctl restart llama-cpp.service`

Outcome:

- `llama-cpp` restarted, but still logged:
  - `ggml_cuda_init: failed to initialize CUDA: unknown error`
  - `warning: no usable GPU found, --gpu-layers option will be ignored`
- Service stayed up in CPU-only mode.

Conclusion:

- Simple restart is not enough once the GPU is in the bad post-resume state.

### 2. NVIDIA user-space reset

Tried:

- `nvidia-smi --gpu-reset -i 0`

Outcome:

- Failed with:
  - `GPU Reset couldn't run because GPU 00000000:01:00.0 is the primary GPU.`

Conclusion:

- This path is blocked while the NVIDIA card is the primary GPU.

### 3. Full NVIDIA module unload/reload

Tried, after stopping `llama-cpp`:

- `modprobe -r nvidia_uvm nvidia_drm nvidia_modeset nvidia`

Outcome:

- Failed immediately:
  - `modprobe: FATAL: Module nvidia_uvm is in use.`

Additional checks:

- No obvious holders via `lsof /dev/nvidia* /dev/dri/*`
- No obvious holders via `fuser -v /dev/nvidia* /dev/dri/*`
- `/proc/driver/nvidia/clients` was empty

Conclusion:

- Full driver unload is not currently clean/practical on this host in the bad state.

### 4. Partial display-side module unload

Tried:

- `modprobe -r nvidia_drm nvidia_modeset`
- then restarted `llama-cpp`

Outcome:

- Unloading `nvidia_drm` / `nvidia_modeset` succeeded.
- CUDA still failed exactly the same way in `llama-cpp`.

Conclusion:

- The problem is not limited to the DRM/modeset layer.

### 5. PCI driver unbind/rebind

Tried:

- stop `llama-cpp`
- write `0000:01:00.0` to `/sys/bus/pci/drivers/nvidia/unbind`

Outcome:

- Operation stalled/hung.
- Kernel log showed:
  - `NVRM: Attempting to remove device 0000:01:00.0 with non-zero usage count!`

Conclusion:

- PCI unbind/rebind is not clean in the bad state while NVIDIA is primary.

### 6. sysfs PCI reset

Discovered:

- `/sys/bus/pci/devices/0000:01:00.0/reset` exists
- `/sys/bus/pci/devices/0000:01:00.0/reset_method` reports `bus`

Tried:

- stop `llama-cpp`
- `echo 1 > /sys/bus/pci/devices/0000:01:00.0/reset`

Outcome:

- Write stalled/hung.
- No helpful kernel output appeared during the stall.

Conclusion:

- Even though a bus reset hook exists, it did not complete cleanly in the bad state.

## Other useful live facts

- `nvidia-smi` continued to show the GTX 1080 Ti and no running GPU processes.
- The card stayed bound at `/sys/bus/pci/drivers/nvidia`.
- PCI power state was `D0`, runtime status `active`, and power control `on`.
- There was no active display manager/X/Wayland service visible during checks.

## Best current hypothesis

The strongest working hypothesis is:

1. Suspend/resume leaves the Pascal GPU or NVIDIA driver in a broken CUDA state.
2. Because the NVIDIA card is the **primary GPU**, the stronger reset paths are blocked or unsafe:
   - `nvidia-smi --gpu-reset` is explicitly refused
   - unbind/rebind is blocked by non-zero usage
   - sysfs PCI reset does not complete cleanly
3. As long as NVIDIA is primary, a reliable in-place recovery may not be possible.

## Why the next experiment makes sense

You plan to:

1. reboot
2. make Intel iGPU primary in BIOS
3. boot the host
4. verify `llama-cpp` can use NVIDIA normally
5. suspend
6. resume
7. verify whether `llama-cpp` again loses CUDA access

This is the right next step because if Intel becomes primary:

- `nvidia-smi --gpu-reset` may become available
- PCI unbind/rebind may become safer/more realistic
- the NVIDIA card may no longer be pinned by primary-console responsibilities during resume

## What the next agent should do first

After the BIOS change and reproduction attempt:

1. Confirm whether `llama-cpp` uses GPU before suspend:
   - inspect `journalctl -u llama-cpp.service -n 80 --no-pager`
   - look for successful CUDA/device initialization rather than `no usable GPU found`
2. Suspend and resume.
3. Re-check whether CUDA fails again.
4. If it still fails and NVIDIA is no longer primary, retry these in order:
   - `nvidia-smi --gpu-reset -i 0`
   - stop `llama-cpp`, then full NVIDIA module reload
   - PCI unbind/rebind
   - sysfs `reset`
5. If one of those works, turn it into a controlled post-resume recovery hook in `nix/hosts/s1/configuration.nix`.

## Configuration guidance for the next agent

- Do **not** re-enable the experimental NVIDIA power-management feature on this Pascal/legacy_580 setup unless there is new evidence it behaves differently now.
- Prefer a targeted post-resume recovery path over broad speculative changes.
- If Intel-primary makes reset workable, the most promising persistent fix is likely:
  - stop `llama-cpp` before sleep
  - on resume, wait briefly for the GPU/driver to settle
  - perform the minimal successful recovery action
  - restart `llama-cpp`

## Current live state when this handoff was written

- `llama-cpp.service` is running again.
- Last observed state of `llama-cpp` was still **CPU-only**, with:
  - `ggml_cuda_init: failed to initialize CUDA: unknown error`
  - `warning: no usable GPU found, --gpu-layers option will be ignored`

## Update after follow-up resume test

The server was later booted again at `2026-05-31 10:45` and this was verified:

1. Before suspend, `llama-cpp` used CUDA normally.
   - `journalctl -u llama-cpp.service` showed:
     - `CUDA0   : NVIDIA GeForce GTX 1080 Ti`
   - This successful run started at `10:49` and was stopped cleanly at `10:56:14` by the sleep-related systemd wiring.
2. The host then suspended at `10:56:18` and resumed at `10:56:59`.
3. After resume, manually starting `llama-cpp.service` at `11:01:13` reproduced the failure immediately:
   - first start:
     - `CUDA-capable device(s) is/are busy or unavailable`
     - service aborted with `status=6/ABRT`
   - kernel again reported:
     - `Xid 31`
     - `Xid 154, ... Node Reboot Required`
   - systemd restarted the service, after which it came up CPU-only with:
     - `ggml_cuda_init: failed to initialize CUDA: unknown error`
     - `warning: no usable GPU found, --gpu-layers option will be ignored`
4. `nvidia-smi` still looked normal after the failure and showed no running GPU processes.

### Important new topology finding

- The machine is still in the old topology where NVIDIA is primary.
- `/sys/bus/pci/devices/0000:01:00.0/boot_vga` is `1`.
- A scan of `/sys/bus/pci/devices/*` showed only the NVIDIA VGA device (`0000:01:00.0`, class `0x030000`); no Intel VGA device was visible on PCI during this test.
- `nvidia-smi --gpu-reset -i 0` still failed with:
  - `GPU Reset couldn't run because GPU 00000000:01:00.0 is the primary GPU.`

### Updated conclusion

- The original failure mode is now re-confirmed on a fresh boot:
  - CUDA works before suspend
  - the first post-resume CUDA initialization triggers `Xid 31` / `Xid 154`
  - `llama-cpp` then falls back to CPU-only
- The planned "make Intel primary, then retry recovery methods" experiment has **not** actually been reached yet on the tested system state.
- Before that experiment can happen, the next agent should first verify whether:
  - the CPU/platform actually exposes an Intel iGPU, and
  - BIOS settings can make it visible and primary on this host.
- If no Intel/iGPU path is available, the likely practical choices narrow to:
  - accepting reboot as the only reliable recovery, or
  - changing hardware/topology so the NVIDIA card is not the primary GPU during resume.

## Short version

What was ruled out:

- plain `llama-cpp` restart
- `nvidia-smi --gpu-reset` while NVIDIA is primary
- full module unload/reload in the current topology
- unloading only DRM/modeset
- PCI unbind/rebind in the bad state
- sysfs PCI reset in the bad state

Most likely next leverage point:

- make Intel the primary GPU, then retry recovery methods and see whether post-resume reset becomes possible.

## Update after Intel-primary topology test

The BIOS/topology experiment was finally reached on a later boot, and the result is important:

1. The host **does** expose an Intel iGPU, and it can be made primary.
   - CPU: `Intel(R) Core(TM) i7-6700K CPU @ 4.00GHz`
   - Intel GPU: `0000:00:02.0`, vendor `0x8086`, device `0x1912`, driver `i915`
   - NVIDIA GPU: `0000:01:00.0`, vendor `0x10de`, device `0x1b06`, driver `nvidia`
   - Boot VGA flags after the BIOS change:
     - Intel: `boot_vga=1`
     - NVIDIA: `boot_vga=0`
2. On this boot, `llama-cpp` used CUDA normally before suspend.
   - At `11:33:10`, `journalctl -u llama-cpp.service` again showed:
     - `CUDA0   : NVIDIA GeForce GTX 1080 Ti`
3. The host then suspended and resumed on the same boot:
   - suspend entry around `11:33:50`
   - resume completed at `11:49:22`
4. After resume, manually starting `llama-cpp.service` at `11:53:41` reproduced the same failure **even with Intel primary**:
   - `CUDA-capable device(s) is/are busy or unavailable`
   - kernel:
     - `Xid 31`
     - `Xid 154, ... Node Reboot Required`
   - after the restart attempt, `llama-cpp` again came up CPU-only with:
     - `ggml_cuda_init: failed to initialize CUDA: unknown error`
     - `warning: no usable GPU found, --gpu-layers option will be ignored`

### Recovery experiments in Intel-primary topology

What changed:

- `nvidia-smi --gpu-reset -i 0` is no longer rejected because NVIDIA is primary.

What still failed:

1. `sudo nvidia-smi --gpu-reset -i 0`
   - failed with:
     - `GPU 00000000:01:00.0 is currently in use by another process.`
   - this still happened after stopping `llama-cpp`
   - no obvious users were visible via:
     - `/proc/driver/nvidia/clients`
     - `fuser -v /dev/nvidia* /dev/dri/*`
     - `lsof /dev/nvidia* /dev/dri/*`
2. Full module unload/reload still did not become clean.
   - `modprobe -r nvidia_uvm nvidia_drm nvidia_modeset nvidia`
   - still failed immediately at:
     - `modprobe: FATAL: Module nvidia_uvm is in use.`
   - `nvidia_uvm` still reported refcount `2` even with no visible user-space holders
3. Unloading only display-side modules still worked:
   - `modprobe -r nvidia_drm nvidia_modeset`
   - but that did not make `nvidia-smi --gpu-reset` succeed
4. PCI unbind still hung.
   - unbind attempt did not complete cleanly
   - kernel again logged:
     - `NVRM: Attempting to remove device 0000:01:00.0 with non-zero usage count!`
   - after aborting the stuck command, the live state had changed to:
     - `/sys/bus/pci/devices/0000:01:00.0/driver` missing
     - `nvidia-smi` -> `No devices were found`
5. Re-bind and sysfs reset also hung in that detached state.
   - bind to `/sys/bus/pci/drivers/nvidia/bind` stalled
   - `echo 1 > /sys/bus/pci/devices/0000:01:00.0/reset` stalled

### Updated conclusion after Intel-primary test

- Making Intel primary did **not** prevent the suspend/resume CUDA failure.
- The first post-resume CUDA initialization still triggers `Xid 31` / `Xid 154` and poisons the NVIDIA stack.
- Intel-primary only changed one thing:
  - `nvidia-smi --gpu-reset` is no longer blocked by the "primary GPU" restriction
- But even in this topology, practical in-place recovery still was not achieved:
  - GPU reset remains blocked by a hidden "in use" state
  - module unload is still blocked by `nvidia_uvm`
  - unbind/bind/reset paths still hang

### Current live state at end of this investigation

- `llama-cpp.service` has been started again and is running **CPU-only**
- the NVIDIA PCI device is currently detached from the driver
  - `/sys/bus/pci/devices/0000:01:00.0/driver` is missing
  - `nvidia-smi` reports `No devices were found`
- the failed live recovery attempts have also left the kernel with stuck tasks in the NVIDIA remove/reset paths
  - hung-task logs show blocked processes in:
    - `nv_pci_remove` after unbind/remove attempts
    - `pci_reset_function` after sysfs reset attempts
  - additional PCI recovery operations on this same boot are therefore not trustworthy anymore
- practical implication:
  - a reboot is now very likely required to restore normal NVIDIA visibility on this boot

### What the next agent should do first now

1. If GPU access is needed again on this boot, reboot first.
2. Treat the old hypothesis "Intel-primary may make recovery possible" as **tested and not sufficient**.
3. Any next investigation should start from the new reality:
   - Intel-primary is achievable on this host
   - but the suspend/resume CUDA failure still reproduces
   - and no reliable in-place recovery method has been found yet
4. Avoid drawing new conclusions from any further live PCI reset/unbind behavior on this same boot once the kernel has reported hung tasks in `nv_pci_remove` / `pci_reset_function`; reboot before retrying lower-level recovery experiments.
