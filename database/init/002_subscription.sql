SET @column_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'users'
    AND column_name = 'subscription_plan'
);
SET @sql := IF(
  @column_exists = 0,
  "ALTER TABLE users ADD COLUMN subscription_plan ENUM('free','premium') NOT NULL DEFAULT 'free' AFTER password_hash",
  "SELECT 1"
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @column_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'users'
    AND column_name = 'trial_started_at'
);
SET @sql := IF(
  @column_exists = 0,
  "ALTER TABLE users ADD COLUMN trial_started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP AFTER subscription_plan",
  "SELECT 1"
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @column_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'users'
    AND column_name = 'premium_expires_at'
);
SET @sql := IF(
  @column_exists = 0,
  "ALTER TABLE users ADD COLUMN premium_expires_at TIMESTAMP NULL AFTER trial_started_at",
  "SELECT 1"
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

UPDATE users
SET trial_started_at = COALESCE(trial_started_at, created_at, CURRENT_TIMESTAMP),
    subscription_plan = COALESCE(subscription_plan, 'free');
