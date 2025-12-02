BEGIN;
ALTER TABLE wallet_transactions ADD COLUMN channel VARCHAR(32);
ALTER TABLE wallet_transactions ADD COLUMN initiator_ip VARCHAR(64);
ALTER TABLE wallet_transactions ADD COLUMN extra_data JSONB;

ALTER TABLE withdrawals ADD COLUMN channel VARCHAR(32);
ALTER TABLE withdrawals ADD COLUMN initiator_ip VARCHAR(64);
ALTER TABLE withdrawals ADD COLUMN extra_data JSONB;
ALTER TABLE withdrawals ALTER COLUMN details TYPE TEXT;

CREATE TABLE IF NOT EXISTS wallet_bridge_tokens (...);
CREATE TABLE IF NOT EXISTS wallet_device_codes (...);
CREATE TABLE IF NOT EXISTS payout_audit_logs (...);
CREATE TABLE IF NOT EXISTS admin_mfa_secrets (...);
CREATE TABLE IF NOT EXISTS kyc_snapshots (...);
COMMIT;
