<?php

declare(strict_types=1);

final class AccountController
{
    public function __construct(private PDO $db)
    {
    }

    public function index(array $params, array $user): void
    {
        $stmt = $this->db->prepare(
            "SELECT a.*,
                a.opening_balance
                + COALESCE(SUM(CASE
                    WHEN t.type = 'income' AND t.account_id = a.id THEN t.amount
                    WHEN t.type = 'expense' AND t.account_id = a.id THEN -t.amount
                    WHEN t.type = 'transfer' AND t.account_id = a.id THEN -t.amount
                    WHEN t.type = 'transfer' AND t.to_account_id = a.id THEN t.amount
                    ELSE 0
                END), 0) AS current_balance
             FROM accounts a
             LEFT JOIN transactions t ON t.user_id = a.user_id AND (t.account_id = a.id OR t.to_account_id = a.id)
             WHERE a.user_id = ?
             GROUP BY a.id
             ORDER BY a.is_archived ASC, a.name ASC"
        );
        $stmt->execute([$user['id']]);

        Response::json(['data' => $stmt->fetchAll()]);
    }

    public function store(array $params, array $user): void
    {
        $data = Request::json();
        Validator::require($data, ['name']);

        $stmt = $this->db->prepare(
            'INSERT INTO accounts (user_id, name, type, currency, opening_balance) VALUES (?, ?, ?, ?, ?)'
        );
        $stmt->execute([
            $user['id'],
            trim((string) $data['name']),
            $data['type'] ?? 'cash',
            strtoupper((string) ($data['currency'] ?? 'THB')),
            (float) ($data['opening_balance'] ?? 0),
        ]);

        Response::json(['message' => 'Account created', 'id' => (int) $this->db->lastInsertId()], 201);
    }

    public function update(array $params, array $user): void
    {
        $data = Request::json();
        $stmt = $this->db->prepare(
            'UPDATE accounts SET name = COALESCE(?, name), type = COALESCE(?, type), currency = COALESCE(?, currency), opening_balance = COALESCE(?, opening_balance), is_archived = COALESCE(?, is_archived) WHERE id = ? AND user_id = ?'
        );
        $stmt->execute([
            $data['name'] ?? null,
            $data['type'] ?? null,
            isset($data['currency']) ? strtoupper((string) $data['currency']) : null,
            $data['opening_balance'] ?? null,
            $data['is_archived'] ?? null,
            $params['id'],
            $user['id'],
        ]);

        Response::json(['message' => 'Account updated']);
    }

    public function delete(array $params, array $user): void
    {
        $stmt = $this->db->prepare('DELETE FROM accounts WHERE id = ? AND user_id = ?');
        $stmt->execute([$params['id'], $user['id']]);

        Response::json(['message' => 'Account deleted']);
    }
}

