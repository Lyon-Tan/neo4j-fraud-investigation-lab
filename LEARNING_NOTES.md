# Neo4j and Cypher Learning Notes

Concise revision for this simulated graph investigation lab. Keep the [README](README.md) and unchanged Cypher files as the primary technical references.

## Graph database, node, label, and property

A graph database stores connected entities. A `node` is one entity; a `label` categorizes it; a `property` stores a value. For example, a `User` node has a `user_id` property and can also carry the `FraudLab` label.

> 繁中備註：graph database 強調資料之間的連結。node 是實體，label 是分類，property 是屬性；例如 `User` node 有 `user_id`，也能同時帶有 `FraudLab` label。
>
> 🇲🇾 BM: Graph database simpan entiti dan hubungan antara entiti. Node ialah satu entiti, label bagi kategori, property simpan value. Contohnya node `User` ada `user_id` dan boleh ada label `FraudLab` sekali.

## Relationship and graph traversal

A relationship connects nodes with a type and direction. `(User)-[:USES]->(Device)` records device use. Graph traversal follows relationships, such as User → Transaction → RiskEvent, to explain which events flag a user's transactions.

> 繁中備註：relationship 表示 node 之間有方向和類型的關係。traversal 就是沿著關係走，例如從 User 找 Transaction，再找到 RiskEvent。
>
> 🇲🇾 BM: Relationship tunjuk hubungan, type dan arah antara node. Traversal maksudnya ikut hubungan tu, contohnya dari User ke Transaction, kemudian ke RiskEvent.

## MATCH, WHERE, and RETURN

`MATCH` finds a pattern, `WHERE` filters matches, and `RETURN` selects the output. Matching a pattern does not create nodes or prove a fraud hypothesis.

> 繁中備註：`MATCH` 找 pattern，`WHERE` 篩選，`RETURN` 決定輸出。找到關聯不等於證明 fraud，也不會建立新 node。
>
> 🇲🇾 BM: `MATCH` cari pattern, `WHERE` tapis hasil, `RETURN` pilih apa yang nak dipaparkan. Jumpa connection bukan bukti fraud dan tak create node baru.

## WITH, COUNT, and ORDER BY

`WITH` carries selected variables and aggregate results to the next stage. `count(DISTINCT r)` counts events, while `count(DISTINCT t)` counts transactions. `ORDER BY ... DESC` ranks results from highest to lowest.

> 繁中備註：`WITH` 把需要的變數和彙總結果傳到下一步。算 RiskEvent 和算 Transaction 不一樣；`ORDER BY ... DESC` 是由大到小排序。
>
> 🇲🇾 BM: `WITH` bawa variable dan hasil aggregate ke langkah seterusnya. Count event tak sama dengan count transaction. Guna `ORDER BY ... DESC` untuk susun yang paling tinggi dulu.

## CREATE and SET

`CREATE` creates nodes or relationships; it is not an upsert. `SET` adds or replaces properties. The write examples use disposable demo nodes so the investigation dataset remains intact after the full sequence.

> 繁中備註：`CREATE` 建立資料，不會自動判斷是否已存在；`SET` 新增或更新 property。先用可刪除的 demo node 練習寫入。
>
> 🇲🇾 BM: `CREATE` tambah node atau relationship, bukan automatik update rekod sedia ada. `SET` tambah atau ubah property. Praktis guna demo node yang boleh dibuang.

## REMOVE and DETACH DELETE

`REMOVE` can remove a property without deleting the node. `DETACH DELETE` deletes a node and its attached relationships. Scope deletion carefully and use only the isolated learning database.

> 繁中備註：`REMOVE` 可以只移除 property；`DETACH DELETE` 會刪除 node 和相連的 relationships。要確認刪除範圍，只在隔離的練習 database 操作。
>
> 🇲🇾 BM: `REMOVE` boleh buang property tanpa padam node. `DETACH DELETE` padam node sekali dengan relationship yang bersambung. Check skop dulu dan guna database latihan yang berasingan.

## Constraints and indexes

Uniqueness constraints reject duplicate IDs but do not require an ID to be present. Indexes can speed selective lookups; unique constraints already have backing indexes. Neither feature proves data is trustworthy or a query will always be faster.

> 繁中備註：uniqueness constraint 擋重複 ID，但不保證 ID 必填。index 有助於特定查詢；unique constraint 已有 backing index，不需要再建相同的 ID index。
>
> 🇲🇾 BM: Uniqueness constraint halang ID duplicate, tapi tak wajibkan ID mesti ada. Index boleh bantu lookup tertentu. Unique constraint dah ada backing index, jadi tak perlu tambah index ID yang sama.

## Variable-length paths and linked accounts

`[:USES*2..4]` follows two to four relationships. In this lab's undirected pattern, User → Device ← User takes two hops; another shared device can link a third account in four. Bound the depth because path expansion can grow quickly.

> 繁中備註：`[:USES*2..4]` 表示走兩到四條 relationship，不是兩到四個 node。這裡忽略方向，經過共用 device 就能連到其他帳戶；要限制深度，避免路徑數快速增加。
>
> 🇲🇾 BM: `[:USES*2..4]` ikut dua hingga empat relationship, bukan bilangan node. Pattern ni tak ikut arah arrow, jadi boleh cari linked account melalui shared device. Hadkan depth sebab jumlah path boleh cepat bertambah.

## Shared-device detection and fraud rings

Multiple accounts sharing a device are a risk signal, not proof of fraud. A fraud ring involves coordinated wrongdoing; a linked-account group alone does not establish that. Check timing, device reliability, and independent evidence, including innocent explanations such as a family device.

> 繁中備註：共用 device 是 risk signal，不是 fraud 證據。fraud ring 還需要協同行為等證據；家人共用裝置也可能產生相同連結，要進一步查證。
>
> 🇲🇾 BM: Beberapa akaun guna device yang sama tak semestinya fraud. Fraud ring perlukan bukti aktiviti yang diselaraskan, bukan connection sahaja. Semak timing dan bukti lain; mungkin satu keluarga kongsi device.

## SQL vs Neo4j

SQL commonly connects tables with JOINs; Cypher expresses node/relationship patterns. Neo4j can make multi-hop investigations easier to express, while SQL remains useful for tabular reporting and reconciliation. Choose by workload, not an assumption that graphs are always faster.

> 繁中備註：SQL 常用 JOIN 連接資料表，Cypher 用 graph pattern 表達關係。多層關聯調查適合考慮 Neo4j；報表和 reconciliation 仍很適合 SQL，沒有一種永遠比較快。
>
> 🇲🇾 BM: SQL biasa guna JOIN antara table, Cypher guna pattern node dan relationship. Neo4j senang untuk siasat banyak hop, tapi SQL masih sesuai untuk report dan reconciliation. Pilih ikut kerja, bukan anggap graph sentiasa lebih laju.
