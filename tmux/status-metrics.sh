#!/bin/sh

# Print short host-wide CPU, memory, and disk-I/O readings for tmux's status
# line. Use only utilities already shipped with macOS or Linux.

export LC_ALL=C

case "$(uname -s)" in
Darwin)
  top_output=$(top -l 2 -n 0 -s 1 2>/dev/null) || top_output=
  cpu=$(printf '%s\n' "$top_output" | awk '
	/CPU usage:/ {
		for (i = 1; i <= NF; i++) {
			if ($i ~ /^idle/) {
				idle = $(i - 1)
				gsub(/[^0-9.]/, "", idle)
				cpu = 100 - idle
			}
		}
	}
	END { if (cpu == "") print "--"; else printf "%.0f%%", cpu }
	')
  # top's PhysMem includes reclaimable cache. Use the same page accounting
  # as Stats' RAM reader: app + wired + physical compressor, excluding cache.
  # https://github.com/exelban/stats/blob/master/Modules/RAM/readers.swift
  memory_total=$(sysctl -n hw.memsize 2>/dev/null) || memory_total=0
  ram=$(vm_stat 2>/dev/null | awk -F ':' -v total="$memory_total" '
	NR == 1 && /page size of/ {
		size = $0
		sub(/.*page size of /, "", size)
		sub(/ bytes.*/, "", size)
		page_size = size + 0
		next
	}
	NF == 2 {
		value = $2
		gsub(/[^0-9]/, "", value)
		pages[$1] = value + 0
	}
	END {
		if (total <= 0 || page_size <= 0 ||
			!("Pages active" in pages) || !("Pages inactive" in pages) ||
			!("Pages speculative" in pages) || !("Pages wired down" in pages) ||
			!("Pages occupied by compressor" in pages) ||
			!("Pages purgeable" in pages) || !("File-backed pages" in pages)) {
			print "--"
			exit
		}
		used = pages["Pages active"] + pages["Pages inactive"] + \
			pages["Pages speculative"] + pages["Pages wired down"] + \
			pages["Pages occupied by compressor"] - pages["Pages purgeable"] - \
			pages["File-backed pages"]
		percent = 100 * used * page_size / total
		if (percent < 0) percent = 0
		if (percent > 100) percent = 100
		printf "%.0f%%", percent
	}') || ram=--
  io=$(iostat -d -n 20 -w 1 -c 2 2>/dev/null | awk '
	$1 ~ /^[0-9]/ {
		line = 0
		for (i = 3; i <= NF; i += 3) {
			if ($i ~ /^[0-9]+([.][0-9]+)?$/) line += $i
		}
		if (NF >= 3) rate = line
	}
	END { if (rate == "") print "--"; else printf "%.1f", rate }
	')
  ;;
Linux)
  # Guest CPU time is already included in user/nice, so only sum the first
  # eight counters. Whole leaf disks avoid counting partitions and LVM/RAID
  # layers twice; loop and RAM-backed devices are not physical disk I/O.
  cpu_counters() {
    awk 'NR == 1 { total = 0; for (i = 2; i <= 9; i++) total += $i; print total, $5 + $6 }' /proc/stat
  }
  disk_sectors() {
    for disk in /sys/block/*; do
      [ -r "$disk/stat" ] || continue
      case "${disk##*/}" in loop* | ram* | zram*) continue ;; esac
      for slave in "$disk"/slaves/*; do
        [ ! -e "$slave" ] || continue 2
      done
      cat "$disk/stat"
    done | awk '{ sectors += $3 + $7 } END { print sectors + 0 }'
  }
  cpu_before=$(cpu_counters)
  disk_before=$(disk_sectors)
  sleep 1
  cpu_after=$(cpu_counters)
  disk_after=$(disk_sectors)
  read -r cpu_total_before cpu_idle_before <<EOF
$cpu_before
EOF
  read -r cpu_total_after cpu_idle_after <<EOF
$cpu_after
EOF
  cpu=$(awk -v tb="$cpu_total_before" -v ib="$cpu_idle_before" \
    -v ta="$cpu_total_after" -v ia="$cpu_idle_after" \
    'BEGIN { d = ta - tb; if (d <= 0) print "--"; else printf "%.0f%%", 100 * (d - (ia - ib)) / d }')
  ram=$(awk '
	/^MemTotal:/ { total = $2 }
	/^MemAvailable:/ { available = $2 }
	END { if (total > 0) printf "%.0f%%", 100 * (total - available) / total; else print "--" }
	' /proc/meminfo)
  io=$(awk -v before="$disk_before" -v after="$disk_after" \
    'BEGIN { rate = (after - before) * 512 / 1024 / 1024; if (rate < 0) rate = 0; printf "%.1f", rate }')
  ;;
*)
  printf 'CPU -- MEM -- IO --\n'
  exit 0
  ;;
esac

[ -n "$io" ] || io=--
printf 'CPU %s MEM %s IO %s MB/s\n' "$cpu" "$ram" "$io"
