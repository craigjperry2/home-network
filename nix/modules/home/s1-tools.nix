# Helpers for inspecting s1's suspend/resume behaviour from any host. Built
# with writeShellApplication so shellcheck runs on them at build time; the
# heredoc bodies run on s1.
{pkgs, ...}: {
  home.packages = [
    # Print each suspend on s1 and how long it slept.
    (pkgs.writeShellApplication {
      name = "srp";
      text = ''
      ssh s1.home.craigjperry.com bash -s <<'REMOTE'
      journalctl -u systemd-suspend.service | awk '
        /Performing sleep/ { sm = $1; sd = $2; st = $3; cmd = "date -d \"" $1 " " $2 " " $3 "\" +%s"; cmd | getline ss; close(cmd) }
        /System returned/ { cmd = "date -d \"" $1 " " $2 " " $3 "\" +%s"; cmd | getline es; close(cmd); d = es - ss; printf "Suspended on %s %s at %s, slept for %02d:%02d:%02d, woke on %s %s at %s\n", sm, sd, st, d / 3600, d % 3600 / 60, d % 60, $1, $2, $3 }
      '
      REMOTE
      '';
    })

    # Show how long s1 has been awake and which autosuspend checks keep it up.
    (pkgs.writeShellApplication {
      name = "why-awake";
      text = ''
      ssh s1.home.craigjperry.com bash -s <<'REMOTE'
      last_wake=$(sudo journalctl -u systemd-suspend.service --since "1 week ago" --no-pager | awk '/System returned from sleep/ {last=$1" "$2" "$3} END {print last}')
      if [ -n "$last_wake" ]; then
        wake_ts=$(date -d "$last_wake" +%s)
        now_ts=$(date +%s)
        diff=$((now_ts - wake_ts))
        hours=$((diff / 3600))
        mins=$(( (diff % 3600) / 60 ))
        [ $hours -gt 0 ] && printf "Awake for %dh %dm\n" $hours $mins || printf "Awake for %dm\n" $mins
      else
        up=$(awk '{print int($1)}' /proc/uptime)
        days=$((up / 86400))
        hours=$(( (up % 86400) / 3600 ))
        mins=$(( (up % 3600) / 60 ))
        [ $days -gt 0 ] && printf "Awake for %dd %dh %dm\n" $days $hours $mins || ([ $hours -gt 0 ] && printf "Awake for %dh %dm\n" $hours $mins || printf "Awake for %dm\n" $mins)
      fi
      sudo journalctl -u autosuspend.service -n 1 --no-pager | awk '{print "Last check at: " $1 " " $2 " " $3}'
      echo "Active checks (last 50 mins):"
      sudo journalctl -u autosuspend.service -n 50 --no-pager | awk '/Check .* matched/ { ts=$1" "$2" "$3; check=gensub(/.*Check (.*) matched.*/, "\\1", "g", $0); if (!(check in start)) start[check]=ts; } END { for (c in start) { print "  - " c " (active since " start[c] ")"; } }'
      REMOTE
      '';
    })
  ];
}
