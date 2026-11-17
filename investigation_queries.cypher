// Run queries 1-12 for read-only investigation.
// Queries 13-17 demonstrate writes on disposable demo nodes, then remove them.
// Run the write examples in order. All examples use this lab's marker label.

// 1. MATCH finds user nodes; RETURN selects the properties to display.
MATCH (u:User:FraudLab {lab: 'neo4j-fraud-investigation-lab'})
RETURN u.user_id AS user_id, u.display_name AS display_name;

// 2. WHERE filters matching transactions by a property value.
// A completed status alone does not imply that a transaction is low risk.
MATCH (t:Transaction:FraudLab {lab: 'neo4j-fraud-investigation-lab'})
WHERE t.status = 'COMPLETED'
RETURN t.transaction_id AS transaction_id, t.status AS status;

// 3. ORDER BY ranks all transactions by value, with an ID tie-breaker.
// Integer cents avoid binary floating-point rounding for this single-currency lab.
MATCH (t:Transaction:FraudLab {lab: 'neo4j-fraud-investigation-lab'})
RETURN t.transaction_id AS transaction_id, t.amount_cents AS amount_cents
ORDER BY amount_cents DESC, transaction_id;

// 4. COUNT counts each user's initiated transactions.
// OPTIONAL MATCH also preserves users with no transactions; count(t) is then zero.
MATCH (u:User:FraudLab {lab: 'neo4j-fraud-investigation-lab'})
OPTIONAL MATCH (u)-[:INITIATED]->(t:Transaction:FraudLab {lab: 'neo4j-fraud-investigation-lab'})
RETURN u.user_id AS user_id, count(DISTINCT t) AS transaction_count
ORDER BY user_id;

// 5. WITH groups and carries results into a later WHERE filter.
// Count DISTINCT events: two events on one transaction are still two events.
MATCH (u:User:FraudLab {lab: 'neo4j-fraud-investigation-lab'})-[:INITIATED]->
      (t:Transaction:FraudLab {lab: 'neo4j-fraud-investigation-lab'})-[:FLAGGED_AS]->
      (r:RiskEvent:FraudLab {lab: 'neo4j-fraud-investigation-lab'})
WITH u, count(DISTINCT r) AS risk_event_count
WHERE risk_event_count >= 2
RETURN u.user_id AS user_id, risk_event_count
ORDER BY risk_event_count DESC, user_id;

// 6. Trace User -> Transaction -> RiskEvent; returning a path supports graph views.
// The risk event is a preloaded investigation signal, not a calculated fraud verdict.
MATCH path = (u:User:FraudLab {user_id: 'N4F_U001', lab: 'neo4j-fraud-investigation-lab'})
             -[:INITIATED]->(t:Transaction:FraudLab {lab: 'neo4j-fraud-investigation-lab'})
             -[:FLAGGED_AS]->(r:RiskEvent:FraudLab {lab: 'neo4j-fraud-investigation-lab'})
RETURN path;

// 7. Two users using the same device form a shared-device investigation lead.
// Ordering the IDs removes self-pairs and mirrored copies of the same pair.
MATCH (a:User:FraudLab {lab: 'neo4j-fraud-investigation-lab'})-[:USES]->
      (d:Device:FraudLab {lab: 'neo4j-fraud-investigation-lab'})<-[:USES]-
      (b:User:FraudLab {lab: 'neo4j-fraud-investigation-lab'})
WHERE a.user_id < b.user_id
RETURN DISTINCT d.device_id AS device_id, a.user_id AS first_user, b.user_id AS second_user
ORDER BY device_id, first_user, second_user;

// 8. Aggregate users per device to find devices linked to more than one account.
// DISTINCT protects the count from repeated USES relationships.
MATCH (u:User:FraudLab {lab: 'neo4j-fraud-investigation-lab'})-[:USES]->
      (d:Device:FraudLab {lab: 'neo4j-fraud-investigation-lab'})
WITH d, count(DISTINCT u) AS user_count
WHERE user_count > 1
RETURN d.device_id AS device_id, user_count ORDER BY device_id;

// 9. Count flagged transactions separately from risk events.
// DISTINCT t prevents a transaction with two flags from being counted twice.
MATCH (u:User:FraudLab {lab: 'neo4j-fraud-investigation-lab'})-[:INITIATED]->
      (t:Transaction:FraudLab {lab: 'neo4j-fraud-investigation-lab'})-[:FLAGGED_AS]->
      (:RiskEvent:FraudLab {lab: 'neo4j-fraud-investigation-lab'})
WITH u, count(DISTINCT t) AS flagged_transaction_count
WHERE flagged_transaction_count >= 2
RETURN u.user_id AS user_id, flagged_transaction_count;

// 10. High-value means at least USD 2,000 in this lab, not a universal fraud rule.
// Filter currency too: values from different currencies cannot be compared directly.
MATCH (u:User:FraudLab {lab: 'neo4j-fraud-investigation-lab'})-[:INITIATED]->
      (t:Transaction:FraudLab {lab: 'neo4j-fraud-investigation-lab'})
WHERE t.currency = 'USD' AND t.amount_cents >= 200000
RETURN u.user_id AS user_id, t.transaction_id AS transaction_id, t.amount_cents AS amount_cents
ORDER BY amount_cents DESC, transaction_id;

// 11. A bounded, variable-length path follows two to four USES relationships.
// Direction is ignored here to move User -> Device <- User and onward.
// Scope every intermediate node to this lab; exclude the starting account.
// These links suggest accounts to review, not a proven fraud ring.
MATCH path = (start:User:FraudLab {user_id: 'N4F_U001', lab: 'neo4j-fraud-investigation-lab'})
             -[:USES*2..4]-(linked:User:FraudLab {lab: 'neo4j-fraud-investigation-lab'})
WHERE start <> linked
  AND all(n IN nodes(path) WHERE n:FraudLab AND n.lab = 'neo4j-fraud-investigation-lab')
RETURN DISTINCT linked.user_id AS linked_user_id, length(path) AS hops
ORDER BY hops, linked_user_id;

// 12. Find transactions without flags, using OPTIONAL MATCH and a NULL check.
// Absence of a recorded flag does not prove a transaction is legitimate.
MATCH (t:Transaction:FraudLab {lab: 'neo4j-fraud-investigation-lab'})
OPTIONAL MATCH (t)-[:FLAGGED_AS]->(r:RiskEvent:FraudLab {lab: 'neo4j-fraud-investigation-lab'})
WITH t, r WHERE r IS NULL
RETURN t.transaction_id AS transaction_id ORDER BY transaction_id;

// 13. CREATE makes a disposable user node for the write demonstrations.
// Run once before queries 14-17. Its ID is covered by setup's uniqueness constraint.
CREATE (u:User:FraudLab {user_id: 'N4F_U_DEMO', display_name: 'Disposable Demo User', demo: true, lab: 'neo4j-fraud-investigation-lab'})
RETURN u.user_id AS user_id;

// 14. MATCH finds that user; CREATE adds a new device and a directed USES relationship.
// CREATE is not an upsert: repeating this statement fails on the unique device ID.
MATCH (u:User:FraudLab {user_id: 'N4F_U_DEMO', demo: true, lab: 'neo4j-fraud-investigation-lab'})
CREATE (u)-[:USES]->(d:Device:FraudLab {device_id: 'N4F_D_DEMO', demo: true, lab: 'neo4j-fraud-investigation-lab'})
RETURN u.user_id AS user_id, d.device_id AS device_id;

// 15. SET adds or replaces a property on the disposable user.
MATCH (u:User:FraudLab {user_id: 'N4F_U_DEMO', demo: true, lab: 'neo4j-fraud-investigation-lab'})
SET u.review_note = 'Training example only'
RETURN u.user_id AS user_id, u.review_note AS review_note;

// 16. REMOVE removes a property; subsequent reads of that property return NULL.
MATCH (u:User:FraudLab {user_id: 'N4F_U_DEMO', demo: true, lab: 'neo4j-fraud-investigation-lab'})
REMOVE u.review_note
RETURN u.user_id AS user_id, u.review_note AS removed_note;

// 17. DETACH DELETE deletes the disposable nodes and their attached relationships.
// The marker and demo flag leave the 22 baseline nodes intact.
MATCH (n:FraudLab {lab: 'neo4j-fraud-investigation-lab', demo: true})
DETACH DELETE n;
