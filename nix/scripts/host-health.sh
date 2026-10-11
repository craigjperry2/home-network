#!/usr/bin/env bash
set -uo pipefail

section() { printf '\n\n===== %s =====\n' "$1"; }
unit_report() {
  local unit=$1 state
  state=$(systemctl is-active "$unit" 2>/dev/null || true)
  printf '\n--- %s: %s ---\n' "$unit" "${state:-unknown}"
  systemctl status "$unit" --no-pager --full 2>&1 | sed -n '1,18p' || true
  printf 'Recent journal:\n'
  journalctl -u "$unit" -n 8 --no-pager -o short-iso 2>&1 || true
}

section 'Host'
printf 'Hostname: %s\n' "$(hostname --fqdn 2>/dev/null || hostname)"
printf 'Date: %s\n' "$(date --iso-8601=seconds)"
printf 'Kernel: %s\n' "$(uname -srmo)"
printf 'Uptime: %s\n' "$(uptime -p)"
printf 'Load: %s\n' "$(cat /proc/loadavg)"
printf 'Failed systemd units: '
systemctl --failed --no-legend --plain | sed -n '1,30p'

section 'Memory and swap'
free -h
grep -E '^(MemAvailable|MemTotal|SwapFree|SwapTotal):' /proc/meminfo

section 'Filesystems'
df -hT -x tmpfs -x devtmpfs -x squashfs
printf '\nInode usage:\n'
df -ih -x tmpfs -x devtmpfs -x squashfs

section 'Storage pools'
if command -v zpool >/dev/null 2>&1; then
  zpool status -xv 2>&1 || true
  zpool list -o name,size,alloc,free,cap,health 2>&1 || true
else
  echo 'zpool command unavailable'
fi

section 'GPU'
if command -v nvidia-smi >/dev/null 2>&1; then
  nvidia-smi --query-gpu=name,temperature.gpu,utilization.gpu,memory.total,memory.used,memory.free,power.draw --format=csv 2>&1 || nvidia-smi 2>&1 || true
  printf '\nGPU processes:\n'
  nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv 2>&1 || true
else
  echo 'NVIDIA GPU metrics unavailable (nvidia-smi not found)'
fi

section 'Configured application services'
for unit in plex immich-server immich-machine-learning postgresql tsssrstack nginx; do
  unit_report "$unit.service"
done

section 'Core host services'
for unit in sshd tailscaled zfs-mount zfs-zed sanoid.timer; do
  unit_report "$unit.service"
done

section 'HTTP application probes'
probe() {
  local name=$1 url=$2
  printf '\n%s (%s): ' "$name" "$url"
  curl --silent --show-error --location --max-time 8 --output /dev/null \
    --write-out 'HTTP %{http_code}; connect %{time_connect}s; total %{time_total}s\n' "$url" \
    || echo 'request failed'
}
probe 'Immich API' 'http://127.0.0.1:2283/api/server/ping'
probe 'Tsssrstack HTTPS' 'https://127.0.0.1:8443/'
probe 'Plex local' 'http://127.0.0.1:32400/identity'
printf '\nPostgreSQL readiness: '
if command -v pg_isready >/dev/null 2>&1; then
  pg_isready --host 127.0.0.1 2>&1 || true
else
  echo 'pg_isready unavailable'
fi

section 'Listening sockets'
ss -H -lntup 2>&1 || true

section 'Active systemd service units'
systemctl list-units --type=service --state=running --no-legend --plain 2>&1

section 'Recent system errors (last hour)'
journalctl -p err --since '1 hour ago' -n 60 --no-pager -o short-iso 2>&1 || true
