# check_cluster_time_sync

Monitoring plugin to verify time synchronization across a Corosync cluster (Proxmox VE, generic HA, etc.).

Compatible with **Nagios/NRPE/MRPE** and **CheckMK local check**.

## What it checks

1. **Inter-node clock drift** — measures time difference between all cluster nodes using SSH (midpoint method to compensate RTT)
2. **NTP source consistency** — verifies all nodes use the same NTP servers
3. **Chrony health** — checks leap status, stratum, and system time offset on each node

## Requirements

- Bash (no external dependencies beyond standard coreutils + awk)
- `/etc/corosync/corosync.conf` accessible on the local node
- SSH root access between cluster nodes (standard in Corosync clusters)
- `chronyc` available on all nodes (recommended)

## Quick install (one-liner)

### CheckMK local check (900s cache)

```bash
sudo mkdir -p /usr/lib/check_mk_agent/local/900 && sudo curl -fsSL https://raw.githubusercontent.com/rdemsystems/prod-tools/main/corosync/check_cluster_time_sync/check_cluster_time_sync -o /usr/lib/check_mk_agent/local/900/check_cluster_time_sync && sudo chmod +x /usr/lib/check_mk_agent/local/900/check_cluster_time_sync
```

### Nagios / NRPE

```bash
sudo curl -fsSL https://raw.githubusercontent.com/rdemsystems/prod-tools/main/corosync/check_cluster_time_sync/check_cluster_time_sync -o /usr/lib/nagios/plugins/check_cluster_time_sync && sudo chmod +x /usr/lib/nagios/plugins/check_cluster_time_sync
```

## Installation (from clone)

```bash
git clone https://github.com/rdemsystems/prod-tools.git
sudo prod-tools/corosync/check_cluster_time_sync/install.sh
```

The install script auto-detects CheckMK or Nagios and copies to the right location.

### MRPE

Add to `/etc/check_mk/mrpe.cfg`:

```
Cluster_Time_Sync /path/to/check_cluster_time_sync -w 1 -c 2
```

The script auto-detects CheckMK context (via `MK_LIBDIR`/`MK_CONFDIR` or script path).

## Usage

```
check_cluster_time_sync [OPTIONS]

Options:
  -w, --warning <ms>     Drift warning threshold in ms (default: 1)
  -c, --critical <ms>    Drift critical threshold in ms (default: 2)
  -f, --config <path>    Corosync config path (default: /etc/corosync/corosync.conf)
  --checkmk              Force CheckMK local check output
  --nagios               Force Nagios output
  -t, --timeout <s>      SSH timeout in seconds (default: 5)
  -v, --verbose          Show per-node details
  -h, --help             Show help
```

## Output examples

### Nagios (default)

```
OK - Cluster time sync: max drift 0.3ms across 3 nodes, NTP sources consistent | max_drift=0.0003s;0.001000;0.002000 node1_drift=0.0002s node2_drift=0.0003s node1_chrony_offset=0.0001s node2_chrony_offset=0.0003s
```

### CheckMK

```
P "Cluster Time Sync" max_drift=0.0003;0.001000;0.002000|node1_drift=0.0002|node2_drift=0.0003 OK - max drift 0.3ms across 3 nodes, NTP sources consistent
```

## Alert conditions

| Condition | WARNING | CRITICAL |
|---|---|---|
| Inter-node drift | > 1ms (default) | > 2ms (default) |
| NTP sources differ between nodes | WARNING | — |
| Chrony leap status != Normal | WARNING | — |
| Chrony stratum > 10 | WARNING | > 15 |
| Node unreachable via SSH | — | CRITICAL |
| Chrony unavailable on a node | WARNING | — |

Final status = worst status encountered (standard Nagios escalation).

## How drift is measured

The script uses the **midpoint method** to compensate for SSH round-trip time:

1. Record local time `t1`
2. Execute `date +%s.%N` on the remote node via SSH
3. Record local time `t2`
4. Estimated drift = `|remote_time - (t1 + t2) / 2|`

This gives sub-millisecond accuracy on a LAN.

## License

MIT
