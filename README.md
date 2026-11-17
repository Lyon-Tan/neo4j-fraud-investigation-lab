# Neo4j Fraud Investigation Lab

A beginner-to-intermediate **simulated enterprise transaction/data troubleshooting lab** using Neo4j and Cypher. Explore shared devices, linked accounts, high-value transactions, and risk flags using fictional records only.

This is a learning exercise, not a production fraud detector or evidence of professional Neo4j, financial crime, or enterprise support experience. Risk flags are manually supplied examples, not confirmed fraud or outputs from a trained model.

## Language Notes

This repository uses English as the primary technical language.

Short Traditional Chinese and conversational Malaysian Malay notes are included to support learning and interview revision.

Technical terms are intentionally kept in English where commonly used in the industry.

Traditional Chinese:
繁中備註主要用來快速理解和複習技術概念，部分常用技術詞會保留英文。

Bahasa Melayu:
Nota BM guna gaya yang biasa ditutur di Malaysia supaya lebih senang faham dan explain masa interview. Istilah technical yang biasa digunakan akan kekal dalam English.

See [Neo4j and Cypher Learning Notes](LEARNING_NOTES.md) for concise revision of graph concepts, Cypher clauses, and investigation signals.

## Graph model

```text
(User)-[:USES]->(Device)
(User)-[:INITIATED]->(Transaction)
(Transaction)-[:FLAGGED_AS]->(RiskEvent)
```

| Concept | Meaning in this lab |
| --- | --- |
| Node | An individual entity, such as one user or transaction. |
| Label | A category on a node, such as `User`, `Device`, `Transaction`, or `RiskEvent`. A node can have multiple labels. |
| Property | A key/value attribute, such as `user_id`, `amount_cents`, or `severity`. |
| Relationship | A directed, typed connection between nodes, such as `INITIATED`. Relationships can also have properties, although these examples do not need them. |
| Pattern | A shape describing nodes and connections to find or create. |
| MATCH | Finds data matching a graph pattern. It does not create data. |
| Traversal | Follows relationships through the graph, for example from a user to transactions and then risk events. |

Every node also has the `FraudLab` marker label and a `lab` property for scoped queries and cleanup. IDs begin with `N4F_`. Use a **dedicated learning database**: the uniqueness constraints apply to all nodes with their primary label in that database, not just marked lab nodes.

Each `RiskEvent` is one flag occurrence. Two events may have the same category, but different `event_id` values. Each transaction has one initiating user in this sample; the schema does not enforce that relationship cardinality. `USES` links users to devices; it does **not** identify which device executed a particular transaction.

## Files

| File | Purpose |
| --- | --- |
| [setup.cypher](setup.cypher) | Four uniqueness constraints, an amount index, and schema inspection. |
| [sample_data.cypher](sample_data.cypher) | One commented CREATE statement containing the fictional graph. |
| [investigation_queries.cypher](investigation_queries.cypher) | Twelve read queries followed by five disposable write demonstrations. |
| [cleanup.cypher](cleanup.cypher) | Deletes marked lab nodes and removes this lab's named schema objects. |
| [.gitignore](.gitignore) | Keeps local credentials, database files, exports, caches, and logs out of Git. |
| [LEARNING_NOTES.md](LEARNING_NOTES.md) | Short Traditional Chinese and Malaysian Malay revision notes with primary English explanations. |

## Run the lab

Use Neo4j 5 or a later version that supports Cypher 5 syntax. No APOC, Graph Data Science plugin, Python package, or paid edition feature is required by these queries.

1. Start a dedicated local learning instance, or use an existing isolated learning database. Connect using your own credentials; do not put them in the repository.
2. Open Neo4j Browser or the query editor for your instance.
3. Run the statements in `setup.cypher` in order, one statement at a time. Check the named index states and allow them to become `ONLINE` before examining query plans.
4. Run the complete CREATE statement in `sample_data.cypher` once.
5. Run investigation queries 1-12 individually and compare with the expectations below. Query 6 returns paths suitable for a graph view.
6. Optionally run write demonstrations 13-17 in order. They create two disposable nodes, connect them, update/remove a property, then delete the nodes and relationship. Running them all restores the baseline dataset.
7. To reset, deliberately run `cleanup.cypher`, then repeat setup and data loading. Cleanup also removes the named constraints and index.

If `cypher-shell` is installed, these commands run from this repository folder against a dedicated local instance. Omit the password argument so the shell prompts for it:

```powershell
cypher-shell -a bolt://localhost:7687 -u neo4j -d neo4j -f setup.cypher
cypher-shell -a bolt://localhost:7687 -u neo4j -d neo4j -f sample_data.cypher
cypher-shell -a bolt://localhost:7687 -u neo4j -d neo4j -f investigation_queries.cypher
```

Use the database name configured for your instance if it differs. The final command includes the optional write demonstrations. Do not run cleanup automatically. Run it explicitly when you want to remove the lab:

```powershell
cypher-shell -a bolt://localhost:7687 -u neo4j -d neo4j -f cleanup.cypher
```

Setup is repeatable through `IF NOT EXISTS`. Data loading uses `CREATE`, so it is not repeatable without a reset; uniqueness constraints reject existing IDs. If a write demonstration is interrupted, its disposable nodes may remain. Reset before starting again. Cleanup removes relationships attached to marked lab nodes, including any connections you manually added to outside nodes; keep the exercise isolated.

## Dataset and expected findings

The baseline contains **22 nodes**: 5 users, 4 devices, 8 transactions, and 5 risk events. It has **19 relationships**: 6 `USES`, 8 `INITIATED`, and 5 `FLAGGED_AS`. Amounts are integer cents in USD; timestamps include UTC offsets.

| User | Transactions | Flagged transactions | Risk events |
| --- | ---: | ---: | ---: |
| `N4F_U001` | 3 | 2 | 3 |
| `N4F_U002` | 2 | 1 | 1 |
| `N4F_U003` | 1 | 1 | 1 |
| `N4F_U004` | 1 | 0 | 0 |
| `N4F_U005` | 1 | 0 | 0 |

Expected results after setup/data loading, before disposable write examples:

- Query 2: six completed transactions. A completed transaction can still have a risk flag.
- Query 3: `N4F_T003` ranks highest at 900,000 cents.
- Query 5: user `N4F_U001` has three distinct risk events.
- Query 6: three paths connect user 1 to the three risk events through two transactions.
- Queries 7-8: `N4F_D001` is shared by users 1 and 2; `N4F_D002` is shared by users 2 and 3.
- Query 9: user `N4F_U001` has two distinct flagged transactions, even though one has two events.
- Query 10: `N4F_T003`, `N4F_T004`, and `N4F_T002` meet the illustrative USD 2,000 threshold, in descending value order.
- Query 11: starting at user 1 reaches user 2 in two relationships and user 3 in four.
- Query 12: transactions `N4F_T001`, `N4F_T006`, `N4F_T007`, and `N4F_T008` have no flags recorded.
- Query 16: the removed demo property reads as `NULL`. After query 17, the baseline counts are restored.

The velocity and device-link event categories are preloaded to practise investigation. This lab does not implement time-window detection or automatically generate flags. Unflagged records are normal-looking examples, not verified legitimate transactions.

## Why graphs help an investigation

A shared device can connect accounts that look unrelated in a transaction table. Following `User -> Device <- User` exposes the connection directly. Continuing through a second shared device can reveal a larger linked-account group.

A fraud ring is a group coordinating fraudulent activity. In real investigations, common infrastructure, coordinated timing, payment flows, and other evidence may support that hypothesis. This lab shows a small linked-account chain; it does not prove coordination or detect a confirmed ring. Shared family devices, public terminals, reused identifiers, and data errors can create innocent links.

Graph-based risk investigation starts with a lead, explores nearby accounts and flagged transactions, and checks supporting evidence. Document the path and confirm it against trusted source records. Relationship direction, data completeness, and the meaning of a device identifier all affect the conclusion.

## Cypher versus SQL

| Task | SQL approach | Cypher approach |
| --- | --- | --- |
| Filter records | `SELECT ... WHERE ...` | `MATCH ... WHERE ... RETURN ...` |
| Connect entities | Foreign keys and JOIN conditions | Typed relationship patterns |
| Count related records | `GROUP BY` with `COUNT` | Non-aggregate expressions form grouping keys alongside `count()` |
| Filter aggregate results | `HAVING` | `WITH` followed by `WHERE` |
| Explore multiple hops | Repeated joins or a recursive CTE | Fixed or bounded variable-length path patterns |

SQL can also investigate connected data. Neo4j is useful when relationship exploration and changing traversal depth are central to the questions. Relational databases remain strong for tabular reporting, reconciliation, and established relational workloads. Neither model is automatically faster for every task.

## Interview Talking Points

- **SQL vs Neo4j:** describe rows and joins versus nodes and relationships. Both support declarative queries; choose based on the workload and data model.
- **When Neo4j helps:** multi-hop account/device exploration can be expressed naturally as patterns. It does not replace every relational database.
- **Why shared devices matter:** they provide an investigation lead between accounts. A shared device alone is insufficient to conclude fraud.
- **Fraud-ring investigation:** expand from an account to connected accounts, then correlate events and other evidence. This lab demonstrates traversal, not a production detection pipeline.
- **Variable-length paths:** `[:USES*2..4]` traverses between two and four relationships. A shared device requires two hops between users. The undirected pattern permits travel against stored arrow directions. Bounded lengths limit expansion, but do not guarantee cheap execution on a large graph.
- **Counting correctly:** `count(DISTINCT r)` counts events; `count(DISTINCT t)` counts flagged transactions. One transaction can have multiple flags.
- **Constraints:** unique IDs prevent duplicate identifiers. Uniqueness alone allows missing IDs and does not enforce valid amounts or relationship cardinality. Neo4j creates backing indexes for these constraints. See the [constraint documentation](https://neo4j.com/docs/cypher-manual/current/schema/constraints/create-constraints/).
- **Indexes:** an amount index can help selective range searches. The planner may prefer a scan for a tiny dataset. Use `EXPLAIN` to inspect a plan without running the statement; `PROFILE` executes the statement, including writes. See the [index documentation](https://neo4j.com/docs/cypher-manual/current/indexes/performance-indexes/create-indexes/).
- **Financial crime technology:** connecting entities and recording explainable investigation paths are transferable skills. This repository demonstrates synthetic query practice, not regulatory compliance, fraud adjudication, or professional experience.

> 🇹🇼 繁中備註：共用 device 和 linked accounts 只是調查線索，不是 fraud 證明。面試時也要區分 RiskEvent 數量和被標記的 Transaction 數量。
>
> 🇲🇾 BM: Shared device dan linked account cuma petunjuk untuk siasat, bukan bukti fraud. Masa interview, bezakan bilangan RiskEvent dengan bilangan Transaction yang ada flag.

## Quick Interview Revision

### What does a traversal explain?

English: Follow User → Transaction → RiskEvent to connect an account to the flags recorded against its transactions.

> 🇹🇼 繁中備註：沿著 User → Transaction → RiskEvent，可以追查帳戶的哪些交易被加上哪些 flag。
>
> 🇲🇾 BM: Ikut User → Transaction → RiskEvent untuk tengok transaction akaun tu ada flag apa.

### What is a variable-length path?

English: `[:USES*2..4]` follows two to four relationships; the lab's undirected pattern can link accounts through shared devices.

> 🇹🇼 繁中備註：`[:USES*2..4]` 走兩到四條 relationship；這裡忽略方向，透過 shared device 找 linked accounts。
>
> 🇲🇾 BM: `[:USES*2..4]` ikut dua hingga empat relationship. Pattern ni tak ikut arah arrow supaya boleh cari linked account melalui shared device.

### Does sharing a device prove fraud?

English: No. It is a risk signal requiring independent evidence and checks for innocent explanations.

> 🇹🇼 繁中備註：不代表 fraud。共用裝置可能有合理原因，要用其他證據進一步確認。
>
> 🇲🇾 BM: Tak semestinya fraud. Mungkin ada sebab biasa untuk kongsi device; kena semak bukti lain dulu.

## Ten Cypher command families to memorize

| Command or clause | Remember |
| --- | --- |
| `MATCH ... RETURN` | Find a pattern and choose the output. |
| `WHERE` | Filter matched rows. |
| `ORDER BY` | Sort results; use `DESC` for largest first. |
| `CREATE` | Create nodes or relationships; repeated execution can duplicate data. |
| `SET` | Add or replace properties. |
| `REMOVE` | Remove a property or label. |
| `DETACH DELETE` | Delete nodes and their attached relationships. |
| `count()` | Aggregate rows or entities; consider `DISTINCT`. |
| `WITH` | Carry variables, aggregate, and filter between query stages. |
| `CREATE CONSTRAINT` / `CREATE INDEX` | Enforce identifier uniqueness / support lookup performance. |

## Validation and limitations

Validated locally on 17 November 2026:

- All four Cypher files passed Neo4j's official JavaScript language-support linter (`@neo4j-cypher/language-support` version `2.0.0-next.6`) with **zero errors and zero warnings**. Negative controls confirmed that the linter reported deliberately malformed syntax and an undefined variable.
- An independent, temporary Python check read the fictional node/relationship definitions and checked the 22-node/19-relationship counts, unique IDs, endpoint types, shared devices, distinct event/transaction counts, high-value transactions, unflagged transactions, and two-/four-hop account links. It did not execute Cypher.
- All local README links resolved. The six repository files were reviewed for private information, credentials, and absolute local paths.

**No queries were executed against a live Neo4j database.** No Neo4j server was installed and the available Docker engine was not running. Parser and static data checks do not verify server permissions, actual query plans, schema creation, or runtime results. Run the scripts in an isolated Neo4j instance to confirm those behaviours. Expected findings above remain expected database results.

The parser and temporary checking tools are outside this repository and are not runtime dependencies. The lab implements no automatic risk scoring, fraud-ring algorithm, streaming ingestion, or identity verification.

## Reference and study order

Read this model and dataset first, trace user 1's relationships in `sample_data.cypher`, then explain queries 7, 9, 10, and 11 aloud. Practise the disposable writes last.

Official references: [Cypher cheat sheet](https://neo4j.com/docs/cypher-manual/current/cheat-sheet/), [variable-length paths](https://neo4j.com/docs/cypher-manual/current/patterns/reference/variable-length-paths/), and [Neo4j language-support tooling](https://github.com/neo4j/cypher-language-support).
