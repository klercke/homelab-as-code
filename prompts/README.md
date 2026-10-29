# Muninn's prompts

The persona every client gets, injected by LiteLLM on llm01.
It is the same in Open WebUI, OpenCode, voice, or anything else that talks to the gateway.

Each client is identified by its LiteLLM key alias.
`llm_persona_surfaces` in `ansible/roles/llm/defaults/main.yml` maps an alias to the files below, concatenated in order.
Keys with no mapping get no persona, so scripts and benchmarks see the raw models.

- `system` files go to every model.
- `personal` entries are not files here.
  They name secrets in `secrets/platform.sops.yaml`, and go to local models only.
  Personal context stays encrypted in this repo and never reaches a cloud model.

`{{USER_NAME}}` is replaced with the Open WebUI user's name for local models, and with "the user" for cloud models.
The gateway appends the current date and time to every prompt.

Write one sentence per line.
Change a file, run `just role llm`, and every client picks it up.
