// Destructive reset for this lab only. Run deliberately, not as an investigation.
// DETACH DELETE removes every marked lab node and its attached relationships.
// Use a dedicated learning database: relationships to outside nodes would also be deleted.
MATCH (n:FraudLab {lab: 'neo4j-fraud-investigation-lab'})
DETACH DELETE n;

// Remove only this lab's named amount index, preserving unrelated indexes.
DROP INDEX n4f_transaction_amount IF EXISTS;

// Dropping each lab constraint also removes its owned backing index.
DROP CONSTRAINT n4f_user_id IF EXISTS;

// Reset device ID enforcement created by setup.cypher.
DROP CONSTRAINT n4f_device_id IF EXISTS;

// Reset transaction ID enforcement created by setup.cypher.
DROP CONSTRAINT n4f_transaction_id IF EXISTS;

// Reset event ID enforcement created by setup.cypher.
DROP CONSTRAINT n4f_risk_event_id IF EXISTS;

// Verify that no nodes carrying this lab's marker remain; expect zero.
MATCH (n:FraudLab {lab: 'neo4j-fraud-investigation-lab'})
RETURN count(n) AS remaining_lab_nodes;
