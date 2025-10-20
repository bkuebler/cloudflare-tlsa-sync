# Cloudflare TLSA Sync

This script automates the creation and updating of TLSA (DANE) DNS records for domains managed by Cloudflare. Certificates are checked, TLSA-compliant certificate hashes are generated, and DNS TLSA records are set for any (sub)domain/port combination as declared in your JSON configuration. In case of errors, (optional) alert hooks for monitoring or notification systems are triggered.

## Features

- Reads a structured JSON configuration (multiple domains, any number of hosts/ports per domain)
- Automatically discovers the Cloudflare Zone ID
- Calculates certificate hashes from local PEM files (default: 3 1 1 / SHA256)
- Creates or updates corresponding TLSA records via the Cloudflare API
- Systemd-compatible logging (or falls back to stdout)
- Flexible "alert hooks" – supports multiple scripts for mail, messengers, monitoring, etc.
- CLI interface with `-h` and `-c <config>` and more

## Requirements

- Bash ≥ 4
- curl, jq, openssl, xxd
- Valid Cloudflare API token with DNS write permission
- Read access to all referenced certificate files
- (Optional) systemd for journal logging
- (Optional) Monitoring or notification hook scripts of your choice

## Installation

1. **Clone** or copy this repository to your system.
2. Copy the included example JSON configuration to `cloudflare_tlsa_sync.json`.
3. Place the script and config in the same directory (or specify a config path).
4. Make the script executable:  
   `chmod +x cloudflare_tlsa_sync.sh`
5. If the script should use alert hooks place them where the config file is available.
6. For an systemd service file example see extras directory

## Usage

By default, the script looks for `cloudflare_tlsa_sync.json` in its own directory. You can override this path with the `-c` option:

```bash
./cloudflare_tlsa_sync.sh
./cloudflare_tlsa_sync.sh -c /etc/cloudflare_tlsa_sync/config.json
```

Show help at any time with:

```bash
./cloudflare_tlsa_sync.sh -h
```

## Configuration

`cloudflare_tlsa_sync.json` defines your domains, hosts, ports, certificate files and (optionally) any number of alert hooks or the ttl value for the TLSA entry from the given domain. See the example config provided in this repository.

### Entry Configuration Object

| Parameter      | Type          | Description                                                  | Mandatory | Beispiel                              |
| -------------- | ------------- | -------------------------------------------------------------| --------- | ------------------------------------- |
| `cf_api_token` | String        | Cloudflare API Token with DNS Zone edit rights               | ✅        | `"cf_api_token": "YOUR_API_TOKEN"`    |
| `alert_hooks`  | Array[String] | A list of hook scripts, which will be executed on failures   | ❌        | `["alert-mail.sh", "alert-slack.sh"]` |
| `domains`      | Array[Object] | A list with the domains to maintain TLSA records             | ✅        | see below                             |

#### Domain Object

| Parameter | Type          | Description                                                     | Mandatory | Example         |
| --------- | ------------- | --------------------------------------------------------------- | --------- | --------------- |
| `domain`  | String        | The TLD domain name / zone for you want to define the records   | ✅        | `"example.com"` |
| `records` | Array[Object] | A list of DNS-/TLS-Records for the zone to maintain             | ✅        | see below n     |

#### Record Object

| Parameter          | Type           | Description                                                                           | Mandatory | Example                     |
| ------------------ | -------------- | ------------------------------------------------------------------------------------- | --------- | --------------------------- |
| `host`             | String         | Hostname of the DNS-Record (`mail` or `mx`). Used for FQDN creation (`host.domain`)   | ✅        | `"mail"`                    |
| `ports`            | Array[Integer] | A list of TCP-Ports, which should get a TLSA record (SMTP 25, Submission 587)         | ✅        | `[25, 587]`                 |
| `ttl`              | Integer        | The TTL value which the record should get (default 3600 if unset)                     | ❌        | `7200`                      |
| `verify_type`      | String         | TLSA verification type `TLS`(default if unset),`STARTTLS:{STARTTLSTYPE}`,`NONE`       | ❌        | `"STARTTLS:smtp"`           |
| `certificate_file` | String         | Location of your certificate file, a fullchain file works as well                     | ✅        | `"/etc/ssl/certs/mail.pem"` |

For `STARTTLSTYPE` see available values in your openssl command `openssl s_client -starttls -help`.

## Alert Hooks

The `alert_hooks` array in the config may contain any number of executable scripts triggered on various error (or event) conditions, each receiving parameters with error type and details. Example hook templates for e-mail, Slack, Matrix, Telegram, Icinga2 REST, and Google Chat are provided.

## Systemd Integration

You can run the script via a systemd “OneShot” service and/or scheduled timer unit for unattended, regular execution.  
See examples in the documentation.

## Security

- It is recommended to use a dedicated system user for this script (with read access to certs and config only).
- Use a Cloudflare API Token with the minimum required permissions only.
- (Optional) Secure API traffic by restricting the source IP address, or only run on trusted infrastructure.

## Support & Contribution

See [CONTRIBUTE.md](CONTRIBUTE.md) for details on reporting issues or contributing code or hook scripts.

---

## License & Authors

This project is free software, licensed under the GNU General Public License, version 3 or later (GPLv3+).
See the LICENSE file for details.

Main author: Benjamin Kübler <b.kuebler@kuebler-it.de>
Contributors: see Git log.
