# Neo4j Fraud Investigation Lab

## Overview

A beginner-to-intermediate **simulated enterprise transaction/data troubleshooting lab** using Neo4j and Cypher. Explore shared devices, linked accounts, high-value transactions, and risk flags using fictional records only.

This is a learning exercise, not a production fraud detector or evidence of professional Neo4j, financial crime, or enterprise support experience. Risk flags are manually supplied examples, not confirmed fraud or outputs from a trained model.

The graph investigation specialisation of the Technical Interview Foundation Portfolio, building on transaction-data and query reasoning.

## Language Notes

This repository uses English as the primary technical language.

Short Traditional Chinese and conversational Malaysian Malay notes are included to support learning and interview revision.

Technical terms are intentionally kept in English where commonly used in the industry.

Traditional Chinese:
繁中備註主要用來快速理解和複習技術概念，部分常用技術詞會保留英文。

Bahasa Melayu:
Nota BM guna gaya yang biasa ditutur di Malaysia supaya lebih senang faham dan explain masa interview. Istilah technical yang biasa digunakan akan kekal dalam English.

See [Neo4j and Cypher Learning Notes](LEARNING_NOTES.md) for concise revision of graph concepts, Cypher clauses, and investigation signals.

## Why This Project Exists

Practise explaining how connections between accounts, devices, transactions, and risk events can support an investigation. The goal is an understandable graph model and traceable queries, with explicit limits on what the links establish.

## Business / Technical Scenario

An investigator starts with a flagged synthetic account and asks whether other accounts share its devices, which transactions carry flags, and what evidence a relationship path actually provides. Shared infrastructure is an investigation lead, not a fraud verdict.

## Skills Demonstrated

- Property-graph modelling and relationship direction.
- MATCH/WHERE/RETURN, aggregation, WITH, and bounded traversal.
- Shared-device and linked-account investigation.
- Distinct event versus transaction counts, uniqueness constraints, and index concepts.
- Scoped write/cleanup examples and careful interpretation of risk signals.

## Architecture / Data Flow

```text
(User)-[:USES]->(Device)
(User)-[:INITIATED]->(Transaction)
(Transaction)-[:FLAGGED_AS]->(RiskEvent)
```

```text
setup.cypher -> constraints + amount index
sample_data.cypher -> fictional property graph
investigation_queries.cypher -> result sets and paths
cleanup.cypher -> optional, scoped reset
```

Queries 1-12 investigate the graph; queries 13-17 demonstrate writes on disposable nodes and then remove them. This is not an ingestion pipeline or real-time monitoring service.

## Dataset / Data Model

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

The baseline contains **22 nodes**: 5 users, 4 devices, 8 transactions, and 5 risk events. It has **19 relationships**: 6 `USES`, 8 `INITIATED`, and 5 `FLAGGED_AS`. Amounts are integer cents in USD; timestamps include UTC offsets.

| User | Transactions | Flagged transactions | Risk events |
| --- | ---: | ---: | ---: |
| `N4F_U001` | 3 | 2 | 3 |
| `N4F_U002` | 2 | 1 | 1 |
| `N4F_U003` | 1 | 1 | 1 |
| `N4F_U004` | 1 | 0 | 0 |
| `N4F_U005` | 1 | 0 | 0 |

## How It Works

A shared device can connect accounts that look unrelated in a transaction table. Following `User -> Device <- User` exposes the connection directly. Continuing through a second shared device can reveal a larger linked-account group.

A fraud ring is a group coordinating fraudulent activity. In real investigations, common infrastructure, coordinated timing, payment flows, and other evidence may support that hypothesis. This lab shows a small linked-account chain; it does not prove coordination or detect a confirmed ring. Shared family devices, public terminals, reused identifiers, and data errors can create innocent links.

Graph-based risk investigation starts with a lead, explores nearby accounts and flagged transactions, and checks supporting evidence. Document the path and confirm it against trusted source records. Relationship direction, data completeness, and the meaning of a device identifier all affect the conclusion.

### File map

| File | Purpose |
| --- | --- |
| [setup.cypher](setup.cypher) | Four uniqueness constraints, an amount index, and schema inspection. |
| [sample_data.cypher](sample_data.cypher) | One commented CREATE statement containing the fictional graph. |
| [investigation_queries.cypher](investigation_queries.cypher) | Twelve read queries followed by five disposable write demonstrations. |
| [cleanup.cypher](cleanup.cypher) | Deletes marked lab nodes and removes this lab's named schema objects. |
| [.gitignore](.gitignore) | Keeps local credentials, database files, exports, caches, and logs out of Git. |
| [LEARNING_NOTES.md](LEARNING_NOTES.md) | Short Traditional Chinese and Malaysian Malay revision notes with primary English explanations. |

> 繁中備註：沿著 user、device、transaction 和 risk event 的關係追查；找到連結只是線索，不代表已證實 fraud。
>
> ENG: Follow account, device, transaction, and event links as investigation leads rather than proof of fraud.
>
> BM: Ikut hubungan user, device, transaction dan risk event untuk cari petunjuk. Jumpa connection bukan bukti fraud.

## How to Run

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

> 繁中備註：在獨立練習 database 依序執行 setup、sample data、queries；13–17 是寫入示範，cleanup 只在確定要重設時執行。
>
> ENG: Use an isolated learning database: run setup, sample data, then queries; 13–17 demonstrate writes, and cleanup is an explicit reset.
>
> BM: Guna database latihan berasingan. Run setup, sample data, kemudian queries. Query 13–17 buat demo write; run cleanup hanya bila memang nak reset.

## Example Investigation

Use query 7 to connect `N4F_U001` and `N4F_U002` through `N4F_D001`. Query 11 then reaches user 3 through the second shared device. Query 6 traces user 1 to its risk events; query 9 counts two flagged transactions rather than the three individual events. These paths explain a lead, not confirmed coordination or a device used for a particular transaction.

> 繁中備註：從共用 device 找 linked accounts，再追查被標記的交易；user 1 有 2 筆 flagged transactions，但共有 3 個 risk events。
>
> ENG: Follow shared devices to linked accounts, then inspect flags; user 1 has two flagged transactions but three events.
>
> BM: Cari linked account melalui shared device, kemudian semak flag. User 1 ada dua transaction yang kena flag, tapi tiga risk event.

## Expected Results

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

> 繁中備註：預期結果以初始資料為準；目前只做過 static checks，還沒有在 live Neo4j database 驗證執行結果。
>
> ENG: Expected findings describe the baseline data; static checks do not replace execution against a live Neo4j database.
>
> BM: Expected result ikut data asal lab. Setakat ni static check sahaja; hasil sebenar belum verify dalam live Neo4j database.

## Troubleshooting / Root Cause Analysis

If results differ, first check the selected database and whether setup and the single data-loading statement completed. Inspect duplicate-ID errors before rerunning CREATE. Repeated write-example statements or an interrupted sequence can leave demo nodes; reset deliberately in the isolated learning database.

For suspicious links, distinguish a data-loading problem from an investigation hypothesis. Check the seed account, relationship types/directions, hop bounds, DISTINCT counts, and source-device reliability before interpreting a pattern as risk. Use independent evidence to validate any proposed cause.

> 繁中備註：先查 database、載入順序、ID constraint、關係方向和 hop 範圍；不要因為結果不同就直接重跑 CREATE。
>
> ENG: Check database selection, load order, constraints, relationship direction, and hop bounds before rerunning CREATE.
>
> BM: Check database yang dipilih, urutan load, constraint, arah relationship dan had hop dulu. Jangan terus run CREATE semula bila hasil tak sama.

## Limitations

Validated locally on 17 November 2026:

- All four Cypher files passed Neo4j's official JavaScript language-support linter (`@neo4j-cypher/language-support` version `2.0.0-next.6`) with **zero errors and zero warnings**. Negative controls confirmed that the linter reported deliberately malformed syntax and an undefined variable.
- An independent, temporary Python check read the fictional node/relationship definitions and checked the 22-node/19-relationship counts, unique IDs, endpoint types, shared devices, distinct event/transaction counts, high-value transactions, unflagged transactions, and two-/four-hop account links. It did not execute Cypher.
- All local README links resolved. The six repository files were reviewed for private information, credentials, and absolute local paths.

**No queries were executed against a live Neo4j database.** No Neo4j server was installed and the available Docker engine was not running. Parser and static data checks do not verify server permissions, actual query plans, schema creation, or runtime results. Run the scripts in an isolated Neo4j instance to confirm those behaviours. Expected findings above remain expected database results.

The parser and temporary checking tools are outside this repository and are not runtime dependencies. The lab implements no automatic risk scoring, fraud-ring algorithm, streaming ingestion, or identity verification.

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

> 繁中備註：共用 device 和 linked accounts 只是調查線索，不是 fraud 證明。面試時也要區分 RiskEvent 數量和被標記的 Transaction 數量。
>
> 🇲🇾 BM: Shared device dan linked account cuma petunjuk untuk siasat, bukan bukti fraud. Masa interview, bezakan bilangan RiskEvent dengan bilangan Transaction yang ada flag.

### Cypher versus SQL

| Task | SQL approach | Cypher approach |
| --- | --- | --- |
| Filter records | `SELECT ... WHERE ...` | `MATCH ... WHERE ... RETURN ...` |
| Connect entities | Foreign keys and JOIN conditions | Typed relationship patterns |
| Count related records | `GROUP BY` with `COUNT` | Non-aggregate expressions form grouping keys alongside `count()` |
| Filter aggregate results | `HAVING` | `WITH` followed by `WHERE` |
| Explore multiple hops | Repeated joins or a recursive CTE | Fixed or bounded variable-length path patterns |

SQL can also investigate connected data. Neo4j is useful when relationship exploration and changing traversal depth are central to the questions. Relational databases remain strong for tabular reporting, reconciliation, and established relational workloads. Neither model is automatically faster for every task.

## Quick Interview Revision

### What does a traversal explain?

English: Follow User → Transaction → RiskEvent to connect an account to the flags recorded against its transactions.

> 繁中備註：沿著 User → Transaction → RiskEvent，可以追查帳戶的哪些交易被加上哪些 flag。
>
> 🇲🇾 BM: Ikut User → Transaction → RiskEvent untuk tengok transaction akaun tu ada flag apa.

### What is a variable-length path?

English: `[:USES*2..4]` follows two to four relationships; the lab's undirected pattern can link accounts through shared devices.

> 繁中備註：`[:USES*2..4]` 走兩到四條 relationship；這裡忽略方向，透過 shared device 找 linked accounts。
>
> 🇲🇾 BM: `[:USES*2..4]` ikut dua hingga empat relationship. Pattern ni tak ikut arah arrow supaya boleh cari linked account melalui shared device.

### Does sharing a device prove fraud?

English: No. It is a risk signal requiring independent evidence and checks for innocent explanations.

> 繁中備註：不代表 fraud。共用裝置可能有合理原因，要用其他證據進一步確認。
>
> 🇲🇾 BM: Tak semestinya fraud. Mungkin ada sebab biasa untuk kongsi device; kena semak bukti lain dulu.

### Ten Cypher command families to memorize

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

## Role Relevance

The mapping describes transferable graph/query reasoning only. It does not demonstrate professional fraud, AML, identity-risk, or financial crime operations.

| Relevant area | Transferable practice demonstrated |
| --- | --- |
| Fraud Analytics | Explore shared infrastructure and distinguish leads from proven wrongdoing. |
| Financial Crime Technology | Trace connections and explain count/query assumptions; no compliance workflow exists. |
| AML Investigation Technology | Practise entity-link reasoning; no AML rules, case management, or reporting is implemented. |
| Graph Analytics | Model a small property graph and explain bounded traversal; no graph algorithms are implemented. |
| Digital Identity Risk | Investigate shared-device signals without treating them as identity proof. |
| Data Investigation | Preserve path evidence, check model assumptions, and explain uncertainty. |

## Future Improvements

Planned possibilities only; none of the following is implemented:

- A transaction monitoring graph with explicit event and time scope.
- Fraud-ring scoring with transparent rules and false-positive evaluation.
- Device/IP relationships with synthetic provenance and quality checks.
- Temporal relationships that distinguish current and historical associations.
- Graph algorithms applied to small, independently checkable examples.
- An analyst investigation workflow connecting leads, evidence, and review decisions.

Treat future scores as investigation prioritisation, not automated proof of fraud.

## Learning Notes

[LEARNING_NOTES.md](LEARNING_NOTES.md) retains concise English, Traditional Chinese, and conversational Malaysian Malay revision.

Read this model and dataset first, trace user 1's relationships in `sample_data.cypher`, then explain queries 7, 9, 10, and 11 aloud. Practise the disposable writes last.

Official references: [Cypher cheat sheet](https://neo4j.com/docs/cypher-manual/current/cheat-sheet/), [variable-length paths](https://neo4j.com/docs/cypher-manual/current/patterns/reference/variable-length-paths/), and [Neo4j language-support tooling](https://github.com/neo4j/cypher-language-support).
