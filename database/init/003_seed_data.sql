SET @demo_email := 'demo@example.com';
SET @demo_password_hash := '$2y$10$l1T0eV.Wap3GCNnRCz7g0.BfkQ7e5hvL6vLp7HQLHX2x82v9Z8X9W';

INSERT INTO users (name, email, password_hash, subscription_plan, trial_started_at)
SELECT 'Demo User', @demo_email, @demo_password_hash, 'premium', CURRENT_TIMESTAMP
WHERE NOT EXISTS (
  SELECT 1 FROM users WHERE email = @demo_email
);

SELECT id INTO @demo_user_id
FROM users
WHERE email = @demo_email
LIMIT 1;

UPDATE users
SET name = 'Demo User',
    password_hash = @demo_password_hash,
    subscription_plan = 'premium',
    premium_expires_at = DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 30 DAY)
WHERE id = @demo_user_id;

INSERT INTO accounts (user_id, name, type, currency, opening_balance)
SELECT @demo_user_id, 'Cash Wallet', 'cash', 'THB', 3500.00
WHERE NOT EXISTS (
  SELECT 1 FROM accounts WHERE user_id = @demo_user_id AND name = 'Cash Wallet'
);

INSERT INTO accounts (user_id, name, type, currency, opening_balance)
SELECT @demo_user_id, 'KBank Savings', 'bank', 'THB', 42500.00
WHERE NOT EXISTS (
  SELECT 1 FROM accounts WHERE user_id = @demo_user_id AND name = 'KBank Savings'
);

INSERT INTO accounts (user_id, name, type, currency, opening_balance)
SELECT @demo_user_id, 'Credit Card', 'credit_card', 'THB', 0.00
WHERE NOT EXISTS (
  SELECT 1 FROM accounts WHERE user_id = @demo_user_id AND name = 'Credit Card'
);

INSERT INTO accounts (user_id, name, type, currency, opening_balance)
SELECT @demo_user_id, 'TrueMoney Wallet', 'e_wallet', 'THB', 1200.00
WHERE NOT EXISTS (
  SELECT 1 FROM accounts WHERE user_id = @demo_user_id AND name = 'TrueMoney Wallet'
);

INSERT IGNORE INTO categories (user_id, name, type, icon, color) VALUES
  (@demo_user_id, 'Salary', 'income', 'wallet', '#16a34a'),
  (@demo_user_id, 'Bonus', 'income', 'sparkles', '#22c55e'),
  (@demo_user_id, 'Side Job', 'income', 'briefcase', '#0ea5e9'),
  (@demo_user_id, 'Food', 'expense', 'utensils', '#ef4444'),
  (@demo_user_id, 'Transport', 'expense', 'car', '#f97316'),
  (@demo_user_id, 'Shopping', 'expense', 'shopping-bag', '#8b5cf6'),
  (@demo_user_id, 'Bills', 'expense', 'receipt', '#0ea5e9'),
  (@demo_user_id, 'Health', 'expense', 'heart-pulse', '#ec4899'),
  (@demo_user_id, 'Entertainment', 'expense', 'film', '#6366f1'),
  (@demo_user_id, 'Travel', 'expense', 'plane', '#14b8a6');

SELECT id INTO @cash_account_id FROM accounts WHERE user_id = @demo_user_id AND name = 'Cash Wallet' LIMIT 1;
SELECT id INTO @bank_account_id FROM accounts WHERE user_id = @demo_user_id AND name = 'KBank Savings' LIMIT 1;
SELECT id INTO @card_account_id FROM accounts WHERE user_id = @demo_user_id AND name = 'Credit Card' LIMIT 1;
SELECT id INTO @wallet_account_id FROM accounts WHERE user_id = @demo_user_id AND name = 'TrueMoney Wallet' LIMIT 1;

SELECT id INTO @salary_category_id FROM categories WHERE user_id = @demo_user_id AND name = 'Salary' AND type = 'income' LIMIT 1;
SELECT id INTO @bonus_category_id FROM categories WHERE user_id = @demo_user_id AND name = 'Bonus' AND type = 'income' LIMIT 1;
SELECT id INTO @side_job_category_id FROM categories WHERE user_id = @demo_user_id AND name = 'Side Job' AND type = 'income' LIMIT 1;
SELECT id INTO @food_category_id FROM categories WHERE user_id = @demo_user_id AND name = 'Food' AND type = 'expense' LIMIT 1;
SELECT id INTO @transport_category_id FROM categories WHERE user_id = @demo_user_id AND name = 'Transport' AND type = 'expense' LIMIT 1;
SELECT id INTO @shopping_category_id FROM categories WHERE user_id = @demo_user_id AND name = 'Shopping' AND type = 'expense' LIMIT 1;
SELECT id INTO @bills_category_id FROM categories WHERE user_id = @demo_user_id AND name = 'Bills' AND type = 'expense' LIMIT 1;
SELECT id INTO @health_category_id FROM categories WHERE user_id = @demo_user_id AND name = 'Health' AND type = 'expense' LIMIT 1;
SELECT id INTO @entertainment_category_id FROM categories WHERE user_id = @demo_user_id AND name = 'Entertainment' AND type = 'expense' LIMIT 1;
SELECT id INTO @travel_category_id FROM categories WHERE user_id = @demo_user_id AND name = 'Travel' AND type = 'expense' LIMIT 1;

INSERT INTO transactions (user_id, account_id, category_id, type, amount, transaction_date, description, notes)
SELECT @demo_user_id, @bank_account_id, @salary_category_id, 'income', 55000.00, '2026-06-25', 'Monthly salary', 'Demo payroll income'
WHERE NOT EXISTS (
  SELECT 1 FROM transactions WHERE user_id = @demo_user_id AND transaction_date = '2026-06-25' AND description = 'Monthly salary'
);

INSERT INTO transactions (user_id, account_id, category_id, type, amount, transaction_date, description)
SELECT @demo_user_id, @bank_account_id, @bonus_category_id, 'income', 8000.00, '2026-06-28', 'Project bonus'
WHERE NOT EXISTS (
  SELECT 1 FROM transactions WHERE user_id = @demo_user_id AND transaction_date = '2026-06-28' AND description = 'Project bonus'
);

INSERT INTO transactions (user_id, account_id, category_id, type, amount, transaction_date, description)
SELECT @demo_user_id, @wallet_account_id, @side_job_category_id, 'income', 4500.00, '2026-07-01', 'Freelance design'
WHERE NOT EXISTS (
  SELECT 1 FROM transactions WHERE user_id = @demo_user_id AND transaction_date = '2026-07-01' AND description = 'Freelance design'
);

INSERT INTO transactions (user_id, account_id, to_account_id, category_id, type, amount, transaction_date, description)
SELECT @demo_user_id, @bank_account_id, @cash_account_id, NULL, 'transfer', 5000.00, '2026-06-26', 'ATM cash withdrawal'
WHERE NOT EXISTS (
  SELECT 1 FROM transactions WHERE user_id = @demo_user_id AND transaction_date = '2026-06-26' AND description = 'ATM cash withdrawal'
);

INSERT INTO transactions (user_id, account_id, category_id, type, amount, transaction_date, description) VALUES
  (@demo_user_id, @cash_account_id, @food_category_id, 'expense', 185.00, '2026-06-26', 'Lunch at office'),
  (@demo_user_id, @wallet_account_id, @transport_category_id, 'expense', 62.00, '2026-06-26', 'BTS fare'),
  (@demo_user_id, @card_account_id, @shopping_category_id, 'expense', 1290.00, '2026-06-27', 'Work shirt'),
  (@demo_user_id, @bank_account_id, @bills_category_id, 'expense', 1850.00, '2026-06-28', 'Electricity bill'),
  (@demo_user_id, @cash_account_id, @food_category_id, 'expense', 740.00, '2026-06-29', 'Groceries'),
  (@demo_user_id, @card_account_id, @entertainment_category_id, 'expense', 399.00, '2026-06-30', 'Streaming subscription'),
  (@demo_user_id, @wallet_account_id, @food_category_id, 'expense', 95.00, '2026-07-01', 'Coffee'),
  (@demo_user_id, @cash_account_id, @transport_category_id, 'expense', 320.00, '2026-07-01', 'Taxi'),
  (@demo_user_id, @bank_account_id, @health_category_id, 'expense', 1250.00, '2026-07-02', 'Pharmacy'),
  (@demo_user_id, @card_account_id, @travel_category_id, 'expense', 3200.00, '2026-07-02', 'Hotel booking')
ON DUPLICATE KEY UPDATE id = id;

DELETE duplicate_transactions
FROM transactions duplicate_transactions
JOIN transactions keep_transactions
  ON duplicate_transactions.user_id = keep_transactions.user_id
 AND duplicate_transactions.transaction_date = keep_transactions.transaction_date
 AND duplicate_transactions.description = keep_transactions.description
 AND duplicate_transactions.id > keep_transactions.id
WHERE duplicate_transactions.user_id = @demo_user_id;

INSERT INTO budgets (user_id, category_id, month, amount, alert_percent) VALUES
  (@demo_user_id, @food_category_id, '2026-07', 9000.00, 80),
  (@demo_user_id, @transport_category_id, '2026-07', 4500.00, 75),
  (@demo_user_id, @shopping_category_id, '2026-07', 7000.00, 85),
  (@demo_user_id, @bills_category_id, '2026-07', 6000.00, 80),
  (@demo_user_id, @entertainment_category_id, '2026-07', 2500.00, 80),
  (@demo_user_id, @travel_category_id, '2026-07', 12000.00, 90)
ON DUPLICATE KEY UPDATE
  amount = VALUES(amount),
  alert_percent = VALUES(alert_percent);

INSERT INTO recurring_transactions (user_id, account_id, category_id, type, amount, description, frequency, next_run_date)
SELECT @demo_user_id, @bank_account_id, @salary_category_id, 'income', 55000.00, 'Monthly salary', 'monthly', '2026-07-25'
WHERE NOT EXISTS (
  SELECT 1 FROM recurring_transactions WHERE user_id = @demo_user_id AND description = 'Monthly salary'
);

INSERT INTO recurring_transactions (user_id, account_id, category_id, type, amount, description, frequency, next_run_date)
SELECT @demo_user_id, @bank_account_id, @bills_category_id, 'expense', 12000.00, 'Condo rent', 'monthly', '2026-07-05'
WHERE NOT EXISTS (
  SELECT 1 FROM recurring_transactions WHERE user_id = @demo_user_id AND description = 'Condo rent'
);

INSERT INTO recurring_transactions (user_id, account_id, category_id, type, amount, description, frequency, next_run_date)
SELECT @demo_user_id, @card_account_id, @entertainment_category_id, 'expense', 399.00, 'Streaming subscription', 'monthly', '2026-07-30'
WHERE NOT EXISTS (
  SELECT 1 FROM recurring_transactions WHERE user_id = @demo_user_id AND description = 'Streaming subscription'
);
