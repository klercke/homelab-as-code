# Secrets

Secrets live in `secrets/`, encrypted with [SOPS](https://github.com/getsops/sops) and [age](https://age-encryption.org/).
SOPS only encrypts values so keys stay readable and `git diff` shows which secret changed without showing the secret.

## Recipients

Every file is encrypted to the same three age keys, defined in `.sops.yaml`.
Any one of them can decrypt any file.

| Key | Where the private key lives | Used for |
|---|---|---|
| `d0c` | My workstation, `~/.config/sops/age/keys.txt` | Day-to-day work |
| `ci` | CI secret store | Automated runs |
| `bg` | Offline | Break-glass recovery |

## Files

| File | Holds | Read by |
|---|---|---|
| `substrate.sops.yaml` | Proxmox and Linode API tokens, state backend credentials, the state passphrase | `terraform/substrate` |
| `platform.sops.yaml` | Service credentials (Postgres, NetBox, PowerDNS, Kea, Valkey, LiteLLM, ...), API tokens, and the other Terraform layers' credentials | The other Terraform layers, most playbooks |
| `infra.sops.yaml` | Physical infrastructure: PBS encryption key and tokens, offsite backup credentials, installer and firewall values | `hypervisors` and `pbs` playbooks |

Keys that a Terraform layer reads from its environment are uppercase (`PROXMOX_VE_API_TOKEN`, `TOFU_STATE_PASSPHRASE`), because they become environment variables as-is.
Everything Ansible reads is lowercase.

Every file needs a creation rule in `.sops.yaml`.
SOPS checks the rules on decrypt too, so a file without a matching rule can't be read even with a valid key.

## Everyday use

Everything comes from the dev shell (`nix develop`).
SOPS finds my key at `~/.config/sops/age/keys.txt`; set `SOPS_AGE_KEY_FILE` if it lives somewhere else.
Run these from the repo root, since creation rules match paths relative to `.sops.yaml`.

| Task | Command |
|---|---|
| Read one value | `sops -d --extract '["pdns_api_key"]' secrets/platform.sops.yaml` |
| See which keys a file has | `sops -d secrets/platform.sops.yaml \| sed -E 's/: .*/: <redacted>/'` |
| Edit a file | `TMPDIR="$XDG_RUNTIME_DIR" sops secrets/platform.sops.yaml` |
| Run a command with a file's secrets in its environment | `sops exec-env secrets/substrate.sops.yaml 'tofu plan'` |

`TMPDIR` keeps SOPS's decrypted scratch file in tmpfs instead of on disk (see [Plaintext](#plaintext)).

After changing a value, rerun whatever consumes it: the Terraform layer or the playbook.

## How secrets are consumed

### OpenTofu

Each layer's `.envrc` decrypts its file into the environment when I `cd` into the directory, and unloads it when I leave.
The `.envrc` files aren't committed; this is the pattern:

```bash
source_up
watch_file ../../secrets/substrate.sops.yaml
eval "$(sops -d --output-type dotenv ../../secrets/substrate.sops.yaml | direnv dotenv bash /dev/stdin)"
export TF_ENCRYPTION="key_provider \"pbkdf2\" \"main\" { passphrase = \"$TOFU_STATE_PASSPHRASE\" }"
```

`watch_file` reloads it after a secret changes.
Every `just` recipe runs through `direnv exec`, so recipes get the same environment.

Providers read their credentials from the environment, so those never end up in state.
Anything passed into a resource does end up in state, which is why state is encrypted: every layer has an `encryption` block with `enforced = true`, and the passphrase comes in through `TF_ENCRYPTION`.

### Ansible

Playbooks load their secrets as variables in `pre_tasks`:

```yaml
- name: Load platform secrets
  community.sops.load_vars:
    file: "{{ playbook_dir }}/../../secrets/platform.sops.yaml"
```

## Changing recipients

Editing `.sops.yaml` doesn't re-encrypt anything.
The files keep their old recipients until `updatekeys` runs, so a new key looks configured but can't decrypt anything.

1. Add or remove the public key in `keys:` and in every creation rule in `.sops.yaml`.
2. `sops updatekeys secrets/*.sops.yaml`
3. If the number of recipients changed, update the count in the `check-sops` hook in `flake.nix`.
4. `prek run --all-files`
5. Commit `.sops.yaml` and the re-encrypted files together.

Removing a key stops it from decrypting future versions, not the ones it could already read.
Treat a removed key as compromised and rotate the secrets it protected.

## Rotation

| Situation | What to do |
|---|---|
| A secret value needs to change | Edit the file, then rerun its consumers |
| An age private key leaked | `sops rotate -i <file>` for every file, which replaces the data key, then rotate the actual credentials too: `rotate` doesn't change any secret values |
| A plaintext secret leaked | Rotate that credential at its source, then edit the file |

## Plaintext

My root filesystem is btrfs: deleted files survive in snapshots, and `shred` doesn't work on copy-on-write filesystems.
So plaintext only ever goes to `$XDG_RUNTIME_DIR` (tmpfs), never the working tree, and `sops -d` is piped or extracted, never redirected to a file.

Never `git add` a decrypted file, even briefly.
`nix develop` and `nix flake check` copy tracked files into the world-readable Nix store, where they stay until garbage collection.

When encrypting a file that lives in tmpfs, SOPS can't find `.sops.yaml` from there.
Tell it where the file will end up:

```bash
sops -e --filename-override secrets/platform.sops.yaml "$tmp" > secrets/platform.sops.yaml
```

## Guardrails

The pre-commit hooks (in `flake.nix`) check that:

- every file in `secrets/` is SOPS-encrypted to exactly three recipients;
- no text file contains an age private key;
- nothing reformats files in `secrets/` (the YAML, whitespace, and end-of-file hooks all skip it).

They catch mistakes, not intent: `git commit --no-verify` skips them.

## Recovery

| Lost | Recovery |
|---|---|
| My workstation key | Restore it from my password manager, or decrypt with the break-glass key and `updatekeys` to a new key |
| All three keys | The secrets are gone. Every credential has to be regenerated at its source |
| `TOFU_STATE_PASSPHRASE` | State can't be read. Infrastructure keeps running, but managing it again means re-importing every resource. It's in `substrate.sops.yaml` and `platform.sops.yaml`, so it's covered by all three keys |

Check the break-glass key still works now and then:

```bash
SOPS_AGE_KEY_FILE=/path/to/breakglass.key sops -d secrets/platform.sops.yaml > /dev/null && echo OK
```
