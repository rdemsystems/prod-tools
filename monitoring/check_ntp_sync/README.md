# check_ntp_sync

Monitoring plugin to verify local NTP synchronization on any server.

Compatible with **Nagios/NRPE/MRPE** and **CheckMK local check**.

## What it checks

- **NTP offset** from the reference clock
- **Stratum** level
- **Leap status** (chrony)
- **Synchronization state**

## Detection chain

The script tries multiple NTP clients in order, using the first one that works:

1. **chronyc tracking** — offset, stratum, leap status, source
2. **ntpq -c peers** — offset and stratum from the active peer (`*`)
3. **timedatectl show** — systemd-timesyncd synchronization state
4. **ntpdate -q** — query-only (does not modify the clock), last resort

If none are available → UNKNOWN.

## Requirements

- Bash (no external dependencies beyond standard coreutils + awk)
- At least one NTP client: chrony, ntpd, systemd-timesyncd, or ntpdate

## Quick install (one-liner)

### CheckMK local check (900s cache)

```bash
sudo mkdir -p /usr/lib/check_mk_agent/local/900 && sudo curl -fsSL https://raw.githubusercontent.com/rdemsystems/prod-tools/main/monitoring/check_ntp_sync/check_ntp_sync -o /usr/lib/check_mk_agent/local/900/check_ntp_sync && sudo chmod +x /usr/lib/check_mk_agent/local/900/check_ntp_sync
```

### Nagios / NRPE

```bash
sudo curl -fsSL https://raw.githubusercontent.com/rdemsystems/prod-tools/main/monitoring/check_ntp_sync/check_ntp_sync -o /usr/lib/nagios/plugins/check_ntp_sync && sudo chmod +x /usr/lib/nagios/plugins/check_ntp_sync
```

## Installation (from clone)

```bash
git clone https://github.com/rdemsystems/prod-tools.git
sudo prod-tools/monitoring/check_ntp_sync/install.sh
```

The install script auto-detects CheckMK or Nagios and copies to the right location.

### MRPE

Add to `/etc/check_mk/mrpe.cfg`:

```
NTP_Sync /path/to/check_ntp_sync -w 50 -c 200
```

## Usage

```
check_ntp_sync [OPTIONS]

Options:
  -w, --warning <ms>     Offset warning threshold in ms (default: 50)
  -c, --critical <ms>    Offset critical threshold in ms (default: 200)
  -s, --ntp-server <srv> NTP server for fallback query (default: pool.ntp.org)
  --checkmk              Force CheckMK output
  --nagios               Force Nagios output
  -v, --verbose          Show details
  -h, --help             Show help
```

## Output examples

### Nagios (default)

```
OK - NTP offset 2.3ms (source: pool.ntp.org, stratum 2) | ntp_offset=0.002300s;0.050000;0.200000 stratum=2
```

### CheckMK

```
P "NTP Sync" ntp_offset=0.002300;0.050000;0.200000 stratum=2 OK - NTP offset 2.3ms (source: pool.ntp.org, stratum 2)
```

## Alert conditions

| Condition | WARNING | CRITICAL |
|---|---|---|
| NTP offset | > 50ms (default) | > 200ms (default) |
| Chrony leap status != Normal | WARNING | — |
| Stratum > 10 | WARNING | > 15 |
| No NTP client detected | — | UNKNOWN |

## License

MIT
