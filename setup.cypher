// Run in a dedicated learning database before loading sample_data.cypher.
// These named uniqueness constraints reject duplicate business identifiers.
// IF NOT EXISTS makes setup repeatable. Uniqueness does not require a value.
CREATE CONSTRAINT n4f_user_id IF NOT EXISTS
FOR (u:User) REQUIRE u.user_id IS UNIQUE;

// Each device has one unique identifier, even when several users use it.
CREATE CONSTRAINT n4f_device_id IF NOT EXISTS
FOR (d:Device) REQUIRE d.device_id IS UNIQUE;

// A transaction identifier should identify one transaction node.
CREATE CONSTRAINT n4f_transaction_id IF NOT EXISTS
FOR (t:Transaction) REQUIRE t.transaction_id IS UNIQUE;

// Each RiskEvent represents one flag occurrence, not a reusable category node.
CREATE CONSTRAINT n4f_risk_event_id IF NOT EXISTS
FOR (r:RiskEvent) REQUIRE r.event_id IS UNIQUE;

// A range index can support selective amount filters, such as high-value searches.
// Do not add a redundant ID index: uniqueness constraints already back IDs with indexes.
CREATE INDEX n4f_transaction_amount IF NOT EXISTS
FOR (t:Transaction) ON (t.amount_cents);

// Inspect the named constraints to confirm that setup was applied.
SHOW CONSTRAINTS YIELD name, type
WHERE name STARTS WITH 'n4f_'
RETURN name, type ORDER BY name;

// Indexes may initially be POPULATING. Wait for ONLINE before inspecting plans.
SHOW INDEXES YIELD name, type, state
WHERE name STARTS WITH 'n4f_'
RETURN name, type, state ORDER BY name;
