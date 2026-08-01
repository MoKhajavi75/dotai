# dotAI

My Claude Code setup — my own skills, plus the third-party skills, MCPs, plugins, and tools I install.

## Structure

| Path                                 | What's inside                                                            |
| ------------------------------------ | ------------------------------------------------------------------------ |
| [`skills/`](./skills/)               | My skills — one folder each. See [`skills/README.md`](./skills/).        |
| [`third-party.md`](./third-party.md) | Everything I install from elsewhere: skills, plugins, MCP servers, CLIs. |
| [`config/`](./config/)               | Loose config that isn't a skill (e.g. statusline).                       |

## Statusline

Not a skill — `settings.json` reads it from a fixed path, so it needs installing:

```bash
./config/install.sh   # from a clone: symlinks, edits stay live
```

```bash
curl -fsSL https://raw.githubusercontent.com/MoKhajavi75/dotai/main/config/install.sh | bash   # no clone: downloads a copy
```

Either way, anything already at `~/.claude/statusline-command.sh` is moved to `statusline-command.sh.bak` first. The script prints the `settings.json` snippet if `statusLine` isn't configured yet.
