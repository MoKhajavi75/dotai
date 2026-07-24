# MCP

| Name     | Link                                               | Command                                                                                                            |
| -------- | -------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| Context7 | [link](https://github.com/upstash/context7)        | `claude mcp add --scope user --header "CONTEXT7_API_KEY: YOUR_API_KEY" --transport http context7 https://mcp.context7.com/mcp` |
| GitMCP   | [link](https://github.com/idosal/git-mcp)          | `claude mcp add gitmcp -s user -- npx mcp-remote https://gitmcp.io/docs`                                          |
| Shadcn   | [link](https://ui.shadcn.com/docs/mcp#quick-start) | `pnpx shadcn@latest mcp init --client claude`                                                                     |

## Extras

### Canvas UI — shadcn registry

[Canvas UI](https://github.com/DavidHDev/canvas-ui) is a WebGL/canvas component library served as a shadcn registry. Not a replacement for the shadcn setup above — just an extra registry to pull components from.

```bash
pnpm dlx shadcn@latest add https://canvasui.dev/r/liquid-react.json
```

Pattern: `https://canvasui.dev/r/[component]-[framework].json` — framework is `react`, `vue`, `svelte`, or `vanilla`.

### GitMCP — per-repo endpoints

`https://gitmcp.io/docs` is the dynamic endpoint (any repo). To pin one repo instead, use `https://gitmcp.io/{owner}/{repo}`.
