# Security and data leak audit

Think like an attacker who has a normal user account and read access to the frontend bundle. Start from each trust boundary in the system map and follow untrusted input to where it is used.

## 1. Authorization (highest yield)

- **IDOR:** every endpoint that takes an ID (`/orders/:id`, `?userId=`) must check the caller owns or may access that record. Look for lookups by ID alone: `findById(req.params.id)` with no owner or tenant filter.
- **Tenant isolation:** every query on tenant data filters by the caller's tenant, derived from the session, never from the request body or query string.
- **Role checks:** admin routes guarded server side, not only hidden in the UI. Check middleware ordering; a route registered before the auth middleware is public.
- **Mass assignment:** request bodies spread straight into create or update calls (`User.update(req.body)`) let callers set `role`, `isAdmin`, `tenantId`, `balance`. Needs an allowlist or DTO.
- **Function-level gaps:** GraphQL resolvers, RPC handlers, websocket events, server actions, and background job triggers often skip the checks REST routes have.

## 2. Authentication and sessions

- Passwords hashed with argon2id, bcrypt, or scrypt. Never MD5, SHA-*, or reversible encryption.
- JWT: signature always verified, algorithm pinned (no `none`, no HS/RS confusion), expiry enforced, secret not a default or short string. Revocation story for logout and password change.
- Session cookies: `HttpOnly`, `Secure`, `SameSite`. Tokens not stored in `localStorage` when avoidable.
- Login, signup, reset, and OTP endpoints are rate limited. Reset tokens are single use, expire, and are compared in constant time.
- Account enumeration through different error messages or timings on login and reset.
- OAuth: `state` checked, redirect URIs exact match, no open redirect in the callback.

## 3. Injection

- **SQL/NoSQL:** string-built queries, `$where`, raw operators from user JSON (`{"$gt": ""}`) passed into Mongo filters.
- **Command:** `exec`, `spawn` with `shell: true`, `os.system`, `subprocess` with `shell=True` on user input.
- **Path traversal:** user input in file paths without normalization and a base directory check. Zip extraction ("zip slip").
- **SSRF:** server fetches a user-supplied URL (webhooks, image import, link previews) without blocking internal ranges and cloud metadata (`169.254.169.254`), and without re-checking after redirects.
- **Template and XSS:** unescaped output, `dangerouslySetInnerHTML`, `v-html`, `innerHTML`, markdown rendered without sanitizing.
- **Deserialization:** `pickle`, `yaml.load`, Java/PHP native deserialization, `eval`/`new Function` on input.
- **XXE** in XML parsers with external entities enabled.
- **Header and log injection:** user input in headers or unescaped into log lines.

## 4. Secrets

- Hardcoded keys, tokens, passwords, private keys in source, tests, fixtures, docs, or CI files.
- Secrets in git history even if removed: search with `git log -p -S '<pattern>'` for likely prefixes (`sk_`, `AKIA`, `ghp_`, `xox`, `-----BEGIN`). A secret ever committed must be rotated, not only deleted.
- `.env` files tracked in git; missing `.gitignore` entries.
- Secrets exposed to the client: env vars with public prefixes (`NEXT_PUBLIC_`, `VITE_`, `REACT_APP_`, `EXPO_PUBLIC_`) holding server keys.
- Secrets baked into Docker images or printed in CI logs.

## 5. Data exposure and leaks

- API responses returning whole ORM objects: password hashes, tokens, internal flags, other users' emails. Needs explicit response shapes.
- PII, tokens, or full request bodies in logs, error trackers, or analytics events.
- Verbose errors: stack traces, SQL errors, or internal paths returned to clients in production.
- Debug endpoints, admin panels, Swagger, GraphQL introspection, or source maps exposed in production.
- Signed URLs or share links that never expire or are guessable (sequential IDs, short tokens).
- Caching of personalized responses by a shared cache or CDN (missing `Cache-Control: private`).

## 6. Web and transport

- CORS: `*` or reflected origin combined with credentials.
- CSRF protection on cookie-authenticated state-changing requests.
- Security headers: CSP, `X-Content-Type-Options`, `frame-ancestors`, HSTS.
- File uploads: type checked by content not extension, size limits, stored outside the web root or on object storage, served with safe `Content-Type` and `Content-Disposition`.
- Webhooks: signature verified over the raw body, timestamp checked to prevent replay, handler idempotent.

## 7. Business logic

- Race conditions on money, credits, coupons, inventory, and invites (double spend by sending two requests at once).
- Negative quantities, integer overflow, rounding abuse on prices.
- Client-trusted values: price, discount, role, or user ID taken from the request instead of the server.
- Workflow skipping: calling step 3 of a flow without steps 1 and 2.

## 8. Infrastructure in the repo

- Containers running as root, `privileged`, host network or docker socket mounts.
- Databases, caches, or admin ports exposed publicly in compose or IaC.
- Debug mode or dev settings reachable by production env values.
- Dependencies with known vulnerabilities visible in lockfiles, and unpinned GitHub Actions (`uses: foo@main`).

## 9. AI and LLM features (if present)

- Prompt injection from user or retrieved content leading to tool calls with the user's or system's privileges.
- LLM output rendered as HTML or executed as code or SQL.
- API keys for model providers exposed client side; no per-user spend or rate limits.

## Reporting

Each security finding states: the entry point, the exact vulnerable line, a concrete attack (request or sequence), the impact (what data or action the attacker gains), and the fix. If exploitability depends on config not in the repo, mark it `needs-confirmation`.
