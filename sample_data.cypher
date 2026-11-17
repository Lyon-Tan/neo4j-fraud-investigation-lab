// Fictional records only. Run once after setup in a dedicated learning database.
// Every node has a FraudLab marker label and a lab property for scoped cleanup.
// One CREATE statement keeps the initial dataset in a single transaction.
// Re-running without cleanup fails on the uniqueness constraints rather than duplicating IDs.
CREATE
  (u1:User:FraudLab {user_id: 'N4F_U001', display_name: 'Demo User 1', lab: 'neo4j-fraud-investigation-lab'}),
  (u2:User:FraudLab {user_id: 'N4F_U002', display_name: 'Demo User 2', lab: 'neo4j-fraud-investigation-lab'}),
  (u3:User:FraudLab {user_id: 'N4F_U003', display_name: 'Demo User 3', lab: 'neo4j-fraud-investigation-lab'}),
  (u4:User:FraudLab {user_id: 'N4F_U004', display_name: 'Demo User 4', lab: 'neo4j-fraud-investigation-lab'}),
  (u5:User:FraudLab {user_id: 'N4F_U005', display_name: 'Demo User 5', lab: 'neo4j-fraud-investigation-lab'}),
  (d1:Device:FraudLab {device_id: 'N4F_D001', device_type: 'mobile', lab: 'neo4j-fraud-investigation-lab'}),
  (d2:Device:FraudLab {device_id: 'N4F_D002', device_type: 'browser', lab: 'neo4j-fraud-investigation-lab'}),
  (d3:Device:FraudLab {device_id: 'N4F_D003', device_type: 'mobile', lab: 'neo4j-fraud-investigation-lab'}),
  (d4:Device:FraudLab {device_id: 'N4F_D004', device_type: 'browser', lab: 'neo4j-fraud-investigation-lab'}),
  (t1:Transaction:FraudLab {transaction_id: 'N4F_T001', amount_cents: 4500, currency: 'USD', status: 'COMPLETED', timestamp: datetime('2026-11-16T09:00:00Z'), lab: 'neo4j-fraud-investigation-lab'}),
  (t2:Transaction:FraudLab {transaction_id: 'N4F_T002', amount_cents: 250000, currency: 'USD', status: 'COMPLETED', timestamp: datetime('2026-11-16T09:01:00Z'), lab: 'neo4j-fraud-investigation-lab'}),
  (t3:Transaction:FraudLab {transaction_id: 'N4F_T003', amount_cents: 900000, currency: 'USD', status: 'PENDING', timestamp: datetime('2026-11-16T09:02:00Z'), lab: 'neo4j-fraud-investigation-lab'}),
  (t4:Transaction:FraudLab {transaction_id: 'N4F_T004', amount_cents: 300000, currency: 'USD', status: 'COMPLETED', timestamp: datetime('2026-11-16T09:03:00Z'), lab: 'neo4j-fraud-investigation-lab'}),
  (t5:Transaction:FraudLab {transaction_id: 'N4F_T005', amount_cents: 120000, currency: 'USD', status: 'FAILED', timestamp: datetime('2026-11-16T09:04:00Z'), lab: 'neo4j-fraud-investigation-lab'}),
  (t6:Transaction:FraudLab {transaction_id: 'N4F_T006', amount_cents: 2500, currency: 'USD', status: 'COMPLETED', timestamp: datetime('2026-11-16T10:00:00Z'), lab: 'neo4j-fraud-investigation-lab'}),
  (t7:Transaction:FraudLab {transaction_id: 'N4F_T007', amount_cents: 8000, currency: 'USD', status: 'COMPLETED', timestamp: datetime('2026-11-16T10:05:00Z'), lab: 'neo4j-fraud-investigation-lab'}),
  (t8:Transaction:FraudLab {transaction_id: 'N4F_T008', amount_cents: 7000, currency: 'USD', status: 'COMPLETED', timestamp: datetime('2026-11-16T10:10:00Z'), lab: 'neo4j-fraud-investigation-lab'}),
  (r1:RiskEvent:FraudLab {event_id: 'N4F_R001', category: 'HIGH_VALUE', severity: 'MEDIUM', lab: 'neo4j-fraud-investigation-lab'}),
  (r2:RiskEvent:FraudLab {event_id: 'N4F_R002', category: 'HIGH_VALUE', severity: 'HIGH', lab: 'neo4j-fraud-investigation-lab'}),
  (r3:RiskEvent:FraudLab {event_id: 'N4F_R003', category: 'VELOCITY_REVIEW', severity: 'HIGH', lab: 'neo4j-fraud-investigation-lab'}),
  (r4:RiskEvent:FraudLab {event_id: 'N4F_R004', category: 'DEVICE_LINK_REVIEW', severity: 'MEDIUM', lab: 'neo4j-fraud-investigation-lab'}),
  (r5:RiskEvent:FraudLab {event_id: 'N4F_R005', category: 'VELOCITY_REVIEW', severity: 'MEDIUM', lab: 'neo4j-fraud-investigation-lab'}),
  // D001 connects users 1 and 2; D002 connects users 2 and 3.
  (u1)-[:USES]->(d1),
  (u2)-[:USES]->(d1),
  (u2)-[:USES]->(d2),
  (u3)-[:USES]->(d2),
  (u4)-[:USES]->(d3),
  (u5)-[:USES]->(d4),
  // Every transaction has one initiator in this small dataset.
  (u1)-[:INITIATED]->(t1),
  (u1)-[:INITIATED]->(t2),
  (u1)-[:INITIATED]->(t3),
  (u2)-[:INITIATED]->(t4),
  (u3)-[:INITIATED]->(t5),
  (u4)-[:INITIATED]->(t6),
  (u5)-[:INITIATED]->(t7),
  (u2)-[:INITIATED]->(t8),
  // User 1 has two flagged transactions but three distinct flag events.
  (t2)-[:FLAGGED_AS]->(r1),
  (t3)-[:FLAGGED_AS]->(r2),
  (t3)-[:FLAGGED_AS]->(r3),
  (t4)-[:FLAGGED_AS]->(r4),
  (t5)-[:FLAGGED_AS]->(r5);
