USE MyMoney_app;

INSERT INTO users (
  name,
  email,
  password_hash,
  subscription_plan,
  trial_started_at,
  premium_expires_at
) VALUES (
  'Demo User',
  'demo@example.com',
  '$2y$10$W0MjxCZtC4hO4vtHDniTTu39s0aG78v1yLIj.e5rloxz7Mwi.Yd62',
  'premium',
  '2026-06-01 09:00:00',
  '2026-12-31 23:59:59'
) ON DUPLICATE KEY UPDATE
  id = LAST_INSERT_ID(id),
  name = VALUES(name),
  password_hash = VALUES(password_hash),
  subscription_plan = VALUES(subscription_plan),
  trial_started_at = VALUES(trial_started_at),
  premium_expires_at = VALUES(premium_expires_at);

SET @user_id := LAST_INSERT_ID();

INSERT INTO accounts (user_id, name, type, currency, opening_balance)
SELECT @user_id, 'Cash Wallet', 'cash', 'THB', 3500.00
WHERE NOT EXISTS (
  SELECT 1 FROM accounts WHERE user_id = @user_id AND name = 'Cash Wallet'
);

INSERT INTO accounts (user_id, name, type, currency, opening_balance)
SELECT @user_id, 'Main Bank', 'bank', 'THB', 42500.00
WHERE NOT EXISTS (
  SELECT 1 FROM accounts WHERE user_id = @user_id AND name = 'Main Bank'
);

INSERT INTO accounts (user_id, name, type, currency, opening_balance)
SELECT @user_id, 'Travel Card', 'credit_card', 'THB', 0.00
WHERE NOT EXISTS (
  SELECT 1 FROM accounts WHERE user_id = @user_id AND name = 'Travel Card'
);

INSERT INTO accounts (user_id, name, type, currency, opening_balance)
SELECT @user_id, 'E-Wallet', 'e_wallet', 'THB', 1250.00
WHERE NOT EXISTS (
  SELECT 1 FROM accounts WHERE user_id = @user_id AND name = 'E-Wallet'
);

INSERT INTO categories (user_id, name, type, icon, color) VALUES
  (@user_id, 'Salary', 'income', 'briefcase', '#16A34A'),
  (@user_id, 'Freelance', 'income', 'laptop', '#0EA5E9'),
  (@user_id, 'Food', 'expense', 'utensils', '#F97316'),
  (@user_id, 'Transport', 'expense', 'bus', '#6366F1'),
  (@user_id, 'Shopping', 'expense', 'shopping-bag', '#EC4899'),
  (@user_id, 'Housing', 'expense', 'home', '#8B5CF6'),
  (@user_id, 'Utilities', 'expense', 'zap', '#EAB308'),
  (@user_id, 'Health', 'expense', 'heart-pulse', '#EF4444'),
  (@user_id, 'Entertainment', 'expense', 'film', '#14B8A6')
ON DUPLICATE KEY UPDATE
  icon = VALUES(icon),
  color = VALUES(color);

SET @cash_id := (SELECT id FROM accounts WHERE user_id = @user_id AND name = 'Cash Wallet' LIMIT 1);
SET @bank_id := (SELECT id FROM accounts WHERE user_id = @user_id AND name = 'Main Bank' LIMIT 1);
SET @card_id := (SELECT id FROM accounts WHERE user_id = @user_id AND name = 'Travel Card' LIMIT 1);
SET @wallet_id := (SELECT id FROM accounts WHERE user_id = @user_id AND name = 'E-Wallet' LIMIT 1);

SET @salary_id := (SELECT id FROM categories WHERE user_id = @user_id AND name = 'Salary' AND type = 'income' LIMIT 1);
SET @freelance_id := (SELECT id FROM categories WHERE user_id = @user_id AND name = 'Freelance' AND type = 'income' LIMIT 1);
SET @food_id := (SELECT id FROM categories WHERE user_id = @user_id AND name = 'Food' AND type = 'expense' LIMIT 1);
SET @transport_id := (SELECT id FROM categories WHERE user_id = @user_id AND name = 'Transport' AND type = 'expense' LIMIT 1);
SET @shopping_id := (SELECT id FROM categories WHERE user_id = @user_id AND name = 'Shopping' AND type = 'expense' LIMIT 1);
SET @housing_id := (SELECT id FROM categories WHERE user_id = @user_id AND name = 'Housing' AND type = 'expense' LIMIT 1);
SET @utilities_id := (SELECT id FROM categories WHERE user_id = @user_id AND name = 'Utilities' AND type = 'expense' LIMIT 1);
SET @health_id := (SELECT id FROM categories WHERE user_id = @user_id AND name = 'Health' AND type = 'expense' LIMIT 1);
SET @entertainment_id := (SELECT id FROM categories WHERE user_id = @user_id AND name = 'Entertainment' AND type = 'expense' LIMIT 1);

INSERT INTO transactions (
  user_id,
  account_id,
  to_account_id,
  category_id,
  type,
  amount,
  transaction_date,
  description,
  notes
)
SELECT * FROM (
  SELECT @user_id, @bank_id, NULL, @salary_id, 'income', 65000.00, '2026-06-01', 'Monthly salary', 'Seed data' UNION ALL
  SELECT @user_id, @bank_id, NULL, @freelance_id, 'income', 8500.00, '2026-06-07', 'Website maintenance project', 'Seed data' UNION ALL
  SELECT @user_id, @cash_id, NULL, @food_id, 'expense', 185.00, '2026-06-02', 'Lunch with team', 'Seed data' UNION ALL
  SELECT @user_id, @wallet_id, NULL, @transport_id, 'expense', 72.00, '2026-06-03', 'BTS and taxi', 'Seed data' UNION ALL
  SELECT @user_id, @card_id, NULL, @shopping_id, 'expense', 2490.00, '2026-06-05', 'Work shoes', 'Seed data' UNION ALL
  SELECT @user_id, @bank_id, NULL, @housing_id, 'expense', 14500.00, '2026-06-05', 'Monthly rent', 'Seed data' UNION ALL
  SELECT @user_id, @bank_id, NULL, @utilities_id, 'expense', 2180.50, '2026-06-10', 'Electric and internet bills', 'Seed data' UNION ALL
  SELECT @user_id, @cash_id, NULL, @health_id, 'expense', 950.00, '2026-06-12', 'Clinic visit', 'Seed data' UNION ALL
  SELECT @user_id, @wallet_id, NULL, @entertainment_id, 'expense', 399.00, '2026-06-14', 'Streaming subscription', 'Seed data' UNION ALL
  SELECT @user_id, @bank_id, @wallet_id, NULL, 'transfer', 3000.00, '2026-06-15', 'Top up e-wallet', 'Seed data' UNION ALL
  SELECT @user_id, @cash_id, NULL, @food_id, 'expense', 420.00, '2026-06-18', 'Groceries', 'Seed data' UNION ALL
  SELECT @user_id, @card_id, NULL, @transport_id, 'expense', 1250.00, '2026-06-20', 'Fuel and parking', 'Seed data' UNION ALL
  SELECT @user_id, @bank_id, NULL, @food_id, 'expense', 1290.00, '2026-06-22', 'Family dinner', 'Seed data' UNION ALL
  SELECT @user_id, @wallet_id, NULL, @entertainment_id, 'expense', 760.00, '2026-06-24', 'Cinema night', 'Seed data'
) AS seed_transactions
WHERE NOT EXISTS (
  SELECT 1 FROM transactions WHERE user_id = @user_id AND notes = 'Seed data'
);

INSERT INTO budgets (user_id, category_id, month, amount, alert_percent) VALUES
  (@user_id, @food_id, '2026-06', 9000.00, 80),
  (@user_id, @transport_id, '2026-06', 5000.00, 75),
  (@user_id, @shopping_id, '2026-06', 6000.00, 85),
  (@user_id, @housing_id, '2026-06', 15000.00, 90),
  (@user_id, @entertainment_id, '2026-06', 3000.00, 80)
ON DUPLICATE KEY UPDATE
  amount = VALUES(amount),
  alert_percent = VALUES(alert_percent);

INSERT INTO recurring_transactions (
  user_id,
  account_id,
  category_id,
  type,
  amount,
  description,
  frequency,
  next_run_date,
  is_active
)
SELECT @user_id, @bank_id, @salary_id, 'income', 65000.00, 'Monthly salary', 'monthly', '2026-07-01', TRUE
WHERE NOT EXISTS (
  SELECT 1 FROM recurring_transactions
  WHERE user_id = @user_id AND description = 'Monthly salary'
);

INSERT INTO recurring_transactions (
  user_id,
  account_id,
  category_id,
  type,
  amount,
  description,
  frequency,
  next_run_date,
  is_active
)
SELECT @user_id, @bank_id, @housing_id, 'expense', 14500.00, 'Monthly rent', 'monthly', '2026-07-05', TRUE
WHERE NOT EXISTS (
  SELECT 1 FROM recurring_transactions
  WHERE user_id = @user_id AND description = 'Monthly rent'
);
