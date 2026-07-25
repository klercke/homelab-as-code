# SOPS in homelab-as-code

Secrets in this repo are encrypted with [SOPS](https://github.com/getsops/sops) using
[age](https://github.com/FiloSottile/age) keys. Encrypted files are committed to git.
Plaintext never is.

SOPS encrypts *values* and leaves *keys* readable, so `git diff` still shows you which
secret changed even though you cannot see what it changed to.

## Contents

- [Model](#model)
- [Prerequisites](#prerequisites)
- [File layout](#file-layout)
- [Normal operations](#normal-operations)
- [Re-encryption: three different operations](#re-encryption-three-different-operations)
- [Adding or removing a recipient](#adding-or-removing-a-recipient)
- [How consumers read secrets](#how-consumers-read-secrets)
- [Generating new secrets](#generating-new-secrets)
- [Guardrails](#guardrails)
- [Gotchas](#gotchas)
- [Disaster recovery](#disaster-recovery)

## Model

Every secrets file is encrypted to three age recipients, declared in `.sops.yaml`:

| Recipient | Private key lives | Purpose |
|---|---|---|
| `d0c` | workstation, `~/.config/sops/age/keys.txt` | day to day work |
| `ci` | GitLab CI variable (File type, protected) | pipeline runs |
| `bg` | offline, not on any machine | recovery |

Three keys rather than one means losing the workstation does not lose the secrets, and rotating CI credentials does not require touching the admin key.

Any one of the three can decrypt any file.
There is no threshold scheme.

## Prerequisites

```bash
nix develop          # provides sops, age
```

SOPS finds the admin key automatically at `~/.config/sops/age/keys.txt`.
If it lives elsewhere, set `SOPS_AGE_KEY_FILE`.

Verify you can decrypt:

```bash
sops -d --extract '["TF_HTTP_USERNAME"]' secrets/substrate.sops.yaml
```

## File layout

```
.sops.yaml                      creation rules, recipient list
secrets/
  substrate.sops.yaml           PVE API token, GitLab state creds, state passphrase
  platform.sops.yaml            Postgres roles, NetBox, PowerDNS, Kea
scripts/
  generate_secrets.sh           generates platform secrets from scratch
```

The split follows the OpenTofu state layers.
A compromise of the platform key should not hand over cluster access, so PVE credentials live only in `substrate.sops.yaml`.

`.sops.yaml` matches files by path.
Adding a new secrets file means adding a creation rule for it first, or SOPS will refuse to encrypt (and refuse to decrypt, see Gotchas).

## Normal operations

**Read one value** (does not open an editor, does not write plaintext to disk):

```bash
sops -d --extract '["pdns_api_key"]' secrets/platform.sops.yaml
```

**Read everything, redacted** (useful for confirming structure):

```bash
sops -d secrets/platform.sops.yaml | sed -E 's/: .*/: <redacted>/'
```

**Edit values:**

```bash
TMPDIR="$XDG_RUNTIME_DIR" sops secrets/platform.sops.yaml
```

Opens `$EDITOR` with the decrypted content and re-encrypts on save.
The `TMPDIR` override keeps the decrypted scratch file in tmpfs.
See Gotchas for why that matters on btrfs or zfs.

**Run a command with secrets in the environment:**

```bash
sops exec-env secrets/substrate.sops.yaml 'tofu plan'
```

Environment variables are named after the YAML keys, which is why keys in `substrate.sops.yaml` are already uppercase (`PROXMOX_VE_API_TOKEN`, `TF_HTTP_PASSWORD`).
In practice direnv does this automatically, see below.

## Re-encryption: three different operations

These get conflated.
They are not the same thing and they fix different problems.

### 1. Recipients changed

You edited the recipient list in `.sops.yaml` (added a key, removed a key).
The files themselves still carry the old recipient set until you sync them:

```bash
sops updatekeys secrets/substrate.sops.yaml
sops updatekeys secrets/platform.sops.yaml
```

Editing `.sops.yaml` without running this is the single most common mistake.
The new key looks configured but cannot actually decrypt anything, and you will not find out until you need it.

`updatekeys` is also a useful no-op check: if the recipients already match, it reports no changes, which confirms the creation rule matches the file's path.

### 2. Data key compromised

An age private key leaked, so the data key it protects must be considered compromised:

```bash
sops rotate -i secrets/platform.sops.yaml
```

This generates a fresh data key and re-encrypts the values under it.
It does **not** change the secret values.
If the plaintext itself leaked, you still have to rotate the actual credentials in Postgres, PVE, GitLab, and so on.

### 3. Secret values changed

Just edit the file:

```bash
TMPDIR="$XDG_RUNTIME_DIR" sops secrets/platform.sops.yaml
```

Then re-run whatever consumes it (`tofu apply`, the relevant Ansible play).

## Adding or removing a recipient

Full procedure, in order.
Skipping step 3 is the failure mode described above.

1. Get the new public key (`age-keygen` prints it, or read the `# public key:` line of an existing key file).
2. Add it to the `keys:` anchors and every relevant `key_groups` in `.sops.yaml`.
3. `sops updatekeys secrets/*.sops.yaml`
4. Update the recipient count in the `check-sops` hook in `flake.nix` if the total changed.
5. `prek run --all-files` to confirm the hook agrees.
6. Commit `.sops.yaml` and the re-encrypted files together.

For a **removal**, the same steps apply, but understand what it does and does not achieve.
Removing a recipient prevents future decryption.
It does not un-see anything that key already had access to.
Treat a removed key as a compromise and rotate the underlying credentials.

## How consumers read secrets

### direnv (interactive work)

`terraform/substrate/.envrc` decrypts into the environment on `cd`:

```bash
source_up
watch_file ../../secrets/substrate.sops.yaml
eval "$(sops -d --output-type dotenv ../../secrets/substrate.sops.yaml \
  | direnv dotenv bash /dev/stdin)"

export TF_ENCRYPTION="key_provider \"pbkdf2\" \"main\" { passphrase = \"$TOFU_STATE_PASSPHRASE\" }"
```

Loading is scoped to that directory.
Leaving it unsets the variables.
`watch_file` makes direnv reload after a rotation rather than serving a stale cached value.

After editing any `.envrc`, direnv revokes its approval.
Run `direnv allow` again or the variables will not load.

Note the tradeoff: while you are inside that directory the token is in the environment of every process you launch, readable via `/proc/<pid>/environ`.
Do not run untrusted tooling from there.

### OpenTofu

The `proxmox` provider reads `PROXMOX_VE_ENDPOINT` and `PROXMOX_VE_API_TOKEN` from the environment.
Provider configuration is not written to state, so the PVE token never lands in state or in a saved plan file.

The `http` backend reads `TF_HTTP_USERNAME` and `TF_HTTP_PASSWORD` the same way.

This does **not** hold for secrets passed as resource arguments.
Anything read via a `sops_file` data source or fed into a resource attribute (Postgres passwords, the NetBox API token) is stored in state in plaintext.
That is what the OpenTofu `encryption` block is for.
Assume state is sensitive regardless.

### Ansible

```yaml
- name: Load platform secrets
  community.sops.load_vars:
    file: "{{ playbook_dir }}/../../secrets/platform.sops.yaml"
```

Requires `ansible-galaxy collection install community.sops` and the `sops` binary on `PATH`.
It shells out to `sops`, so the creation rule must match the path *as invoked*.
Run playbooks from the repo root.

## Generating new secrets

`scripts/generate_secrets.sh` writes a fresh `platform.sops.yaml`.
It generates hex values with `openssl rand`, builds the file in tmpfs, validates the shape, and encrypts.

Hex, not base64, deliberately: these values end up in `pdns.conf`, Kea JSON, and Postgres connection strings, and `+` and `/` cause escaping problems in all three.
Also, `openssl rand -base64` wraps output at 64 columns, which silently produces invalid YAML for anything over 48 bytes.

Running it again **overwrites** the file.
It is for bootstrapping, not for adding a single key.
To add one key, edit the file.

## Guardrails

Enforced by `prek` (configured in `flake.nix`):

- `sops-encrypted` rejects any file under `secrets/` lacking a `sops:` metadata block, or carrying the wrong number of recipients.
- `no-age-private-keys` rejects any staged text file containing something shaped like an age secret key.
- `end-of-file-fixer`, `trim-trailing-whitespace`, and `check-yaml` all exclude `^secrets/`.
  Nothing should rewrite a SOPS file automatically.

These catch accidents, not intent.
`git commit --no-verify` bypasses all of it, and so does any commit made outside this shell.

## Gotchas

**Creation rules gate decryption, not just encryption.**
`sops -d` fails with `no matching creation rules found` when the file's path does not match a rule, even though the file carries valid metadata and you hold a valid key.
The option is named `creation_rules` but it controls reads too.
If you move or rename a secrets file, update `.sops.yaml` in the same commit.

**Rules are matched relative to `.sops.yaml`.
** Since SOPS 3.7.2, `path_regex` is compared against the path relative to the config file's directory, not an absolute path.
Run SOPS from the repo root.

**SOPS searches upward for `.sops.yaml` from the file it is operating on.**
Encrypting a file in `/tmp` or `$XDG_RUNTIME_DIR` finds no config at all.
Use `--filename-override` to tell SOPS what path to pretend it is at:

```bash
sops -e --filename-override secrets/platform.sops.yaml "$tmp" > secrets/platform.sops.yaml
```

**Never write plaintext into the working tree.**
The root filesystem is btrfs.
Deleted blocks survive in snapshots and `shred` does not work on copy-on-write filesystems.
Keep plaintext in `$XDG_RUNTIME_DIR` (tmpfs) and set `TMPDIR` when SOPS needs scratch space.

**Never `git add` a decrypted file, even briefly.**
`nix flake check` copies git-tracked files into `/nix/store`, which is world-readable, and store paths persist until garbage collection.
Unlike a file, you cannot simply delete it back out.

**Do not redirect `sops -d` to a file.**
Pipe it, extract from it, or use `exec-env`.

## Disaster recovery

**Lost the workstation key.**
Restore it from the password manager backup, or decrypt with the break-glass key and `updatekeys` to a newly generated admin key.

**Lost all three keys.**
The secrets are gone.
There is no recovery path and no vendor to call.
This is why the break-glass key is offline and why the admin key is backed up independently.

**Lost `TOFU_STATE_PASSPHRASE`.**
The encrypted OpenTofu state is unreadable, which is worse than it sounds: the infrastructure keeps running but you can no longer manage it, and rebuilding state means importing every resource by hand.
It lives in `secrets/substrate.sops.yaml` and is therefore covered by the three-recipient scheme, but it deserves its own mention because the failure is silent until the day you need it.

**Verify recovery works before you need it.**
Periodically confirm the break-glass key still decrypts:

```bash
SOPS_AGE_KEY_FILE=/path/to/breakglass.key sops -d secrets/platform.sops.yaml >/dev/null && echo OK
```

An untested recovery path is a guess.

## See also

- SOPS: https://github.com/getsops/sops
- age: https://github.com/FiloSottile/age
- `community.sops`: https://galaxy.ansible.com/ui/repo/published/community/sops/
