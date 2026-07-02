<?php

declare(strict_types=1);

final class TransactionController
{
    public function __construct(private PDO $db)
    {
    }

    public function index(array $params, array $user): void
    {
        $sql = "SELECT t.*, a.name AS account_name, ta.name AS to_account_name, c.name AS category_name
                FROM transactions t
                JOIN accounts a ON a.id = t.account_id
                LEFT JOIN accounts ta ON ta.id = t.to_account_id
                LEFT JOIN categories c ON c.id = t.category_id
                WHERE t.user_id = ?";
        $bindings = [$user['id']];

        foreach (['type', 'account_id', 'category_id'] as $filter) {
            $value = Request::query($filter);
            if ($value !== null && $value !== '') {
                $sql .= " AND t.{$filter} = ?";
                $bindings[] = $value;
            }
        }

        if ($from = Request::query('from')) {
            $sql .= ' AND t.transaction_date >= ?';
            $bindings[] = $from;
        }

        if ($to = Request::query('to')) {
            $sql .= ' AND t.transaction_date <= ?';
            $bindings[] = $to;
        }

        $sql .= ' ORDER BY t.transaction_date DESC, t.id DESC LIMIT ? OFFSET ?';
        $bindings[] = min((int) Request::query('limit', 50), 200);
        $bindings[] = max((int) Request::query('offset', 0), 0);

        $stmt = $this->db->prepare($sql);
        $stmt->execute($bindings);

        Response::json(['data' => $stmt->fetchAll()]);
    }

    public function show(array $params, array $user): void
    {
        $stmt = $this->db->prepare('SELECT * FROM transactions WHERE id = ? AND user_id = ?');
        $stmt->execute([$params['id'], $user['id']]);
        $transaction = $stmt->fetch();

        if (!$transaction) {
            Response::json(['message' => 'Transaction not found'], 404);
        }

        Response::json(['data' => $transaction]);
    }

    public function store(array $params, array $user): void
    {
        $data = Request::json();
        Validator::require($data, ['account_id', 'type', 'amount', 'transaction_date']);
        Validator::type((string) $data['type']);
        Validator::date((string) $data['transaction_date']);
        $this->ensureOwnsAccount((int) $data['account_id'], (int) $user['id']);

        if (($data['type'] ?? '') === 'transfer') {
            Validator::require($data, ['to_account_id']);
            $this->ensureOwnsAccount((int) $data['to_account_id'], (int) $user['id']);
        } elseif (!empty($data['category_id'])) {
            $this->ensureOwnsCategory((int) $data['category_id'], (int) $user['id']);
        }

        $stmt = $this->db->prepare(
            'INSERT INTO transactions (user_id, account_id, to_account_id, category_id, type, amount, transaction_date, description, notes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)'
        );
        $stmt->execute([
            $user['id'],
            $data['account_id'],
            $data['to_account_id'] ?? null,
            $data['category_id'] ?? null,
            $data['type'],
            (float) $data['amount'],
            $data['transaction_date'],
            $data['description'] ?? null,
            $data['notes'] ?? null,
        ]);

        Response::json(['message' => 'Transaction created', 'id' => (int) $this->db->lastInsertId()], 201);
    }

    public function update(array $params, array $user): void
    {
        $data = Request::json();

        if (isset($data['type'])) {
            Validator::type((string) $data['type']);
        }

        if (isset($data['transaction_date'])) {
            Validator::date((string) $data['transaction_date']);
        }

        if (isset($data['account_id'])) {
            $this->ensureOwnsAccount((int) $data['account_id'], (int) $user['id']);
        }

        if (isset($data['to_account_id'])) {
            $this->ensureOwnsAccount((int) $data['to_account_id'], (int) $user['id']);
        }

        if (isset($data['category_id']) && $data['category_id'] !== null) {
            $this->ensureOwnsCategory((int) $data['category_id'], (int) $user['id']);
        }

        $stmt = $this->db->prepare(
            'UPDATE transactions SET account_id = COALESCE(?, account_id), to_account_id = ?, category_id = ?, type = COALESCE(?, type), amount = COALESCE(?, amount), transaction_date = COALESCE(?, transaction_date), description = ?, notes = ? WHERE id = ? AND user_id = ?'
        );
        $stmt->execute([
            $data['account_id'] ?? null,
            $data['to_account_id'] ?? null,
            $data['category_id'] ?? null,
            $data['type'] ?? null,
            $data['amount'] ?? null,
            $data['transaction_date'] ?? null,
            $data['description'] ?? null,
            $data['notes'] ?? null,
            $params['id'],
            $user['id'],
        ]);

        Response::json(['message' => 'Transaction updated']);
    }

    public function delete(array $params, array $user): void
    {
        $stmt = $this->db->prepare('DELETE FROM transactions WHERE id = ? AND user_id = ?');
        $stmt->execute([$params['id'], $user['id']]);

        Response::json(['message' => 'Transaction deleted']);
    }

    private function ensureOwnsAccount(int $accountId, int $userId): void
    {
        $stmt = $this->db->prepare('SELECT id FROM accounts WHERE id = ? AND user_id = ?');
        $stmt->execute([$accountId, $userId]);
        if (!$stmt->fetch()) {
            Response::json(['message' => 'Account not found'], 404);
        }
    }

    private function ensureOwnsCategory(int $categoryId, int $userId): void
    {
        $stmt = $this->db->prepare('SELECT id FROM categories WHERE id = ? AND user_id = ?');
        $stmt->execute([$categoryId, $userId]);
        if (!$stmt->fetch()) {
            Response::json(['message' => 'Category not found'], 404);
        }
    }
}

