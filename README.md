# prod-tools

Production tools and monitoring plugins by RDEM Systems.

Bash-based, zero external dependencies, compatible with **Nagios/NRPE/MRPE** and **CheckMK local check**.

Target: Debian 12/13 and derivatives.

## Tools

### Corosync

| Tool | Description |
|---|---|
| [check_cluster_time_sync](corosync/check_cluster_time_sync/) | Verify time synchronization across a Corosync cluster (Proxmox VE, generic HA, etc.) — inter-node drift, NTP source consistency, chrony health |

### Monitoring

| Tool | Description |
|---|---|
| [check_ntp_sync](monitoring/check_ntp_sync/) | Verify local NTP synchronization — supports chrony, ntpd, systemd-timesyncd, ntpdate |

## Quick start

```bash
# Cluster time sync (run on any Corosync node, e.g. Proxmox)
./corosync/check_cluster_time_sync/check_cluster_time_sync -w 1 -c 2

# Local NTP sync (run on any server)
./monitoring/check_ntp_sync/check_ntp_sync -w 50 -c 200
```

## Quick install (one-liners)

### check_ntp_sync (any server)

```bash
# CheckMK (900s cache)
sudo mkdir -p /usr/lib/check_mk_agent/local/900 && sudo curl -fsSL https://raw.githubusercontent.com/rdemsystems/prod-tools/main/monitoring/check_ntp_sync/check_ntp_sync -o /usr/lib/check_mk_agent/local/900/check_ntp_sync && sudo chmod +x /usr/lib/check_mk_agent/local/900/check_ntp_sync

# Nagios / NRPE
sudo curl -fsSL https://raw.githubusercontent.com/rdemsystems/prod-tools/main/monitoring/check_ntp_sync/check_ntp_sync -o /usr/lib/nagios/plugins/check_ntp_sync && sudo chmod +x /usr/lib/nagios/plugins/check_ntp_sync
```

### check_cluster_time_sync (Corosync / Proxmox nodes)

```bash
# CheckMK (900s cache)
sudo mkdir -p /usr/lib/check_mk_agent/local/900 && sudo curl -fsSL https://raw.githubusercontent.com/rdemsystems/prod-tools/main/corosync/check_cluster_time_sync/check_cluster_time_sync -o /usr/lib/check_mk_agent/local/900/check_cluster_time_sync && sudo chmod +x /usr/lib/check_mk_agent/local/900/check_cluster_time_sync

# Nagios / NRPE
sudo curl -fsSL https://raw.githubusercontent.com/rdemsystems/prod-tools/main/corosync/check_cluster_time_sync/check_cluster_time_sync -o /usr/lib/nagios/plugins/check_cluster_time_sync && sudo chmod +x /usr/lib/nagios/plugins/check_cluster_time_sync
```

## Installation (from clone)

```bash
git clone https://github.com/rdemsystems/prod-tools.git
sudo prod-tools/monitoring/check_ntp_sync/install.sh
sudo prod-tools/corosync/check_cluster_time_sync/install.sh
```

Each install script auto-detects CheckMK or Nagios and copies to the right location (CheckMK: `/usr/lib/check_mk_agent/local/900/`, Nagios: `/usr/lib/nagios/plugins/`).

Both scripts auto-detect CheckMK context and adjust their output format accordingly. Use `--checkmk` or `--nagios` to override.

## License

MIT — see [LICENSE](LICENSE).
