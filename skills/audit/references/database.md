# Database audit

Review the schema against how the code actually queries it. A schema is only good or bad relative to its queries.

## 1. Collect the inputs

- **Engine and version:** Postgres, MySQL/MariaDB, SQLite, MongoDB, Redis, etc. Check compose files, connection strings in env examples, driver packages. Advice differs per engine; say which you assumed.
- **Schema source of truth:** migrations folder, ORM models (Prisma `schema.prisma`, Drizzle, TypeORM entities, Sequelize, SQLAlchemy/Alembic, Django models, ActiveRecord `schema.rb`, GORM, Ent, Mongoose schemas), or raw `.sql` files.
- **Query inventory:** grep every data access path: ORM calls (`findMany`, `where`, `filter`, `.objects.`, `Find(`), query builders, raw SQL strings. For each hot path from the system map, list the columns used in `WHERE`, `JOIN`, `ORDER BY`, `GROUP BY`, and the expected row counts.

If migrations and models disagree, report the drift as its own finding.

## 2. Schema design

- **Primary keys:** every table has one. Random UUIDv4 PKs on large, write-heavy B-tree tables fragment the index; suggest UUIDv7 or ULID when ordering matters. `int` PKs on tables that can pass 2 billion rows must be `bigint`.
- **Foreign keys:** relations enforced with FK constraints, with deliberate `ON DELETE` behavior. Missing FKs mean orphan rows sooner or later.
- **Constraints over app checks:** uniqueness that the app checks with "select then insert" needs a `UNIQUE` constraint (race condition otherwise). Required columns are `NOT NULL`. Value ranges and enums use `CHECK` or enum types.
- **Types:**
  - Money in `numeric`/`decimal` or integer minor units, never `float`/`double`.
  - Timestamps are timezone-aware (`timestamptz` in Postgres) and stored in UTC.
  - `text`/`varchar` with sane limits where input is user-controlled.
  - Booleans are not strings, IDs are not strings unless they must be, IPs use `inet` where available.
- **JSON columns:** fine for truly schemaless data. A red flag when the code filters or joins on keys inside them; propose real columns or expression/GIN indexes.
- **Soft delete:** `deleted_at` columns need unique constraints and indexes to be partial (`WHERE deleted_at IS NULL`), and every query must filter them. Check that it does.
- **Multi-tenancy:** every tenant-scoped table has `tenant_id` (or `org_id`), it is `NOT NULL`, it leads the relevant composite indexes, and every query filters by it. Consider row-level security for Postgres.
- **Audit columns:** `created_at`, `updated_at` on mutable business tables. `updated_at` actually updated.
- **Naming:** consistent casing and pluralization. Only flag when inconsistency is causing real bugs or confusion.

## 3. Indexes

Derive needed indexes from the query inventory, not from intuition.

- **Missing index on a filtered or joined column** of a table that grows. Most common and most valuable finding.
- **FK columns without an index** (Postgres and SQLite do not create them automatically). Causes slow joins and slow parent deletes.
- **Composite index order:** equality columns first, then range, then sort. `WHERE tenant_id = ? AND status = ? ORDER BY created_at DESC` wants `(tenant_id, status, created_at DESC)`.
- **Covering indexes** (`INCLUDE` in Postgres) for hot read-only queries that fetch a few columns.
- **Partial indexes** for queries that always filter the same predicate (`WHERE status = 'pending'`, `WHERE deleted_at IS NULL`).
- **Index killers in queries:** functions on the column (`LOWER(email) = ?` needs an expression index or `citext`), leading wildcards (`LIKE '%foo'` needs trigram/full text), implicit casts, `OR` across different columns.
- **Redundant indexes:** an index that is a left prefix of another, exact duplicates, indexes no query uses. Each costs write throughput and storage; propose dropping them.
- **Low-selectivity single-column indexes** (boolean, small enum) that the planner will ignore. Better as part of a composite or partial index.
- **Full text search** implemented with `LIKE` on large tables: propose the engine's full text index or an external search service.

## 4. Query patterns

- N+1: a query per item in a loop, or lazy relations accessed in serializers. Propose eager loading, `IN (...)` batching, or a join.
- `SELECT *` on wide tables in hot paths, especially with large text or JSON columns.
- Unbounded reads: no `LIMIT`, loading full tables for in-app filtering, counting with `SELECT *` then `.length`.
- `OFFSET` pagination on large tables: propose keyset (cursor) pagination on an indexed column.
- `COUNT(*)` on large tables per request: propose approximate counts, cached counters, or dropping exact totals.
- Transactions: too wide (external HTTP calls inside a transaction hold locks), or missing where multiple writes must be atomic.
- Locking: read-modify-write without `SELECT ... FOR UPDATE` or an atomic `UPDATE ... SET x = x - 1 WHERE x >= 1`. Inconsistent lock order across code paths (deadlocks).
- Raw SQL built with string concatenation or template literals: injection. Must be parameterized.
- Connection handling: pool size times instance count versus DB `max_connections`; connections opened per request; missing pooler (PgBouncer) for serverless.

## 5. Scale and lifecycle

- Tables that grow forever (logs, events, notifications, sessions, audit): propose retention jobs, archiving, or time-based partitioning.
- Hot rows (single counter row updated by every request): propose sharded counters or async aggregation.
- Large blobs in the DB that belong in object storage.
- Read-heavy workloads that can use a read replica, and whether the code tolerates replica lag.
- Backups and restore: mention if nothing in the repo or docs covers them (mark `needs-confirmation`).
- PII columns: identify them, check encryption at rest where required, and check that deletion requests can actually delete them.

## 6. Migration safety

Every proposed change must include how to ship it without downtime. Also review existing migrations for these hazards.

Postgres:

- `CREATE INDEX` locks writes; use `CREATE INDEX CONCURRENTLY` (outside a transaction; many migration tools need a flag for this).
- Adding a `NOT NULL` column: add nullable, backfill in batches, then add a `CHECK ... NOT VALID`, `VALIDATE CONSTRAINT`, then `SET NOT NULL`.
- Adding a FK: `ADD CONSTRAINT ... NOT VALID`, then `VALIDATE CONSTRAINT` separately.
- Changing a column type usually rewrites the table; use expand and contract (new column, dual write, backfill, switch reads, drop old).
- Renaming or dropping a column in use breaks running app versions; deploy code first, then the schema change.
- Set `lock_timeout` in migrations so a blocked DDL fails fast instead of queueing every query behind it.

MySQL: prefer `ALGORITHM=INPLACE, LOCK=NONE` where supported; large tables may need `gh-ost` or `pt-online-schema-change`.

SQLite: many `ALTER TABLE` operations require a table rebuild; note the lock and file size impact.

MongoDB: build indexes with awareness of replica set rolling builds; validate schemas with `$jsonSchema` where the app assumes structure.

## 7. Proposal format

For each schema or index proposal, include:

1. **Problem:** what is slow, unsafe, or inconsistent, with the query or code at `file:line`.
2. **Change:** exact DDL (or ORM schema diff if the project uses one).
3. **Migration safety:** locks, rewrite, backfill steps, order relative to code deploy.
4. **Expected impact:** what gets faster or safer, and the write cost it adds.
5. **Verify:** the `EXPLAIN (ANALYZE, BUFFERS)` (or engine equivalent) the user can run before and after.

Example:

```sql
-- Problem: orders list filters by customer and status, sorts by date (src/orders/repo.ts:88).
-- Only a single-column index on customer_id exists, so Postgres sorts every customer order in memory.
CREATE INDEX CONCURRENTLY idx_orders_customer_status_created
  ON orders (customer_id, status, created_at DESC);

-- Redundant after the index above: left prefix of the new composite index.
DROP INDEX CONCURRENTLY idx_orders_customer_id;

-- Verify:
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, total, created_at FROM orders
WHERE customer_id = $1 AND status = 'paid'
ORDER BY created_at DESC LIMIT 20;
```
