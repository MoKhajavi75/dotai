# Third-party

Everything I install from elsewhere — skills, plugins, MCP servers, standalone CLIs.
My own stuff lives in [`skills/`](./skills/) — see the [README](./README.md#my-skills).

## Skills

| Name          | Link                                                                            | Command                                                                                                |
| ------------- | ------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| Agent Browser | [link](https://agent-browser.dev/installation#ai-coding-assistants-recommended) | `pnpx skills add vercel-labs/agent-browser -a claude-code -y`                                          |
| ElysiaJS      | [link](https://elysiajs.com/table-of-content.html#ai-skills-for-llms)           | `pnpx skills add elysiajs/skills -a claude-code -y`                                                    |
| Humanizer     | [link](https://github.com/blader/humanizer)                                     | `pnpx skills add https://github.com/blader/humanizer -a claude-code -y`                                |
| No AI Slop    | [link](https://github.com/petergyang/no-ai-slop)                                | `pnpx skills add https://github.com/petergyang/no-ai-slop -a claude-code -y`                           |
| Playwright    | [link](https://github.com/microsoft/playwright-cli)                             | `pnpx skills add https://github.com/microsoft/playwright-cli --skill playwright-cli -a claude-code -y` |

### Collections

Multi-skill repos — installing pulls every skill in the repo.

| Name          | Link                                           | About                                                 | Command                                                 |
| ------------- | ---------------------------------------------- | ----------------------------------------------------- | ------------------------------------------------------- |
| Emil Kowalski | [link](https://github.com/emilkowalski/skills) | Design engineering — animation, motion, UI taste.     | `pnpx skills add emilkowalski/skills -a claude-code -y` |
| Matt Pocock   | [link](https://github.com/mattpocock/skills)   | Engineering workflow — TDD, review, specs, debugging. | `pnpx skills add mattpocock/skills -a claude-code -y`   |

> Matt Pocock's repo also ships as a plugin (`/plugin marketplace add mattpocock/skills` → `/plugin install mattpocock-skills@mattpocock`). Run `/setup-matt-pocock-skills` once after install.

## Plugins

| Name                | Link                                                          | Command                                                                                        |
| ------------------- | ------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| Caveman             | [link](https://github.com/JuliusBrussee/caveman)              | `/plugin marketplace add JuliusBrussee/caveman`<br>`/plugin install caveman@caveman`           |
| Figma               | [link](https://github.com/figma/mcp-server-guide)             | `/plugin install figma@claude-plugins-official`                                                |
| Frontend            | [link](https://github.com/anthropics/claude-plugins-official) | `/plugin install frontend-design@claude-plugins-official`                                      |
| I have ADHD         | [link](https://github.com/ayghri/i-have-adhd)                 | `/plugin marketplace add ayghri/i-have-adhd`<br>`/plugin install i-have-adhd@i-have-adhd`      |
| Impeccable          | [link](https://github.com/pbakaus/impeccable)                 | `/plugin marketplace add pbakaus/impeccable`<br>`/plugin install impeccable@impeccable`        |
| Last 30 Days        | [link](https://github.com/mvanhorn/last30days-skill)          | `/plugin marketplace add mvanhorn/last30days-skill`<br>`/plugin install last30days`            |
| Understand Anything | [link](https://github.com/Lum1104/Understand-Anything)        | `/plugin marketplace add Lum1104/Understand-Anything`<br>`/plugin install understand-anything` |

## MCP

| Name     | Link                                               | Command                                                                                                                        |
| -------- | -------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| Context7 | [link](https://github.com/upstash/context7)        | `claude mcp add --scope user --header "CONTEXT7_API_KEY: YOUR_API_KEY" --transport http context7 https://mcp.context7.com/mcp` |
| GitMCP   | [link](https://github.com/idosal/git-mcp)          | `claude mcp add gitmcp -s user -- npx mcp-remote https://gitmcp.io/docs`                                                       |
| Shadcn   | [link](https://ui.shadcn.com/docs/mcp#quick-start) | `pnpx shadcn@latest mcp init --client claude`                                                                                  |

### Canvas UI — shadcn registry

[Canvas UI](https://github.com/DavidHDev/canvas-ui) is a WebGL/canvas component library served as a shadcn registry. Not a replacement for the shadcn setup above — just an extra registry to pull components from.

```bash
pnpm dlx shadcn@latest add https://canvasui.dev/r/liquid-react.json
```

Pattern: `https://canvasui.dev/r/[component]-[framework].json` — framework is `react`, `vue`, `svelte`, or `vanilla`.

### GitMCP — per-repo endpoints

`https://gitmcp.io/docs` is the dynamic endpoint (any repo). To pin one repo instead, use `https://gitmcp.io/{owner}/{repo}`.

## Tools

| Name         | Link                                              | Command                                                                                                                                       |
| ------------ | ------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| Graphify     | [link](https://github.com/Graphify-Labs/graphify) | `uv tool install graphifyy`<br>`graphify install`<br>`/graphify .`                                                                            |
| RTK          | [link](https://github.com/rtk-ai/rtk)             | `brew install rtk-ai/tap/rtk`<br>`rtk init --global`                                                                                          |
| SkillSpector | [link](https://github.com/NVIDIA/SkillSpector)    | `git clone https://github.com/NVIDIA/skillspector.git`<br>`cd skillspector`<br>`uv venv .venv && source .venv/bin/activate`<br>`make install` |
