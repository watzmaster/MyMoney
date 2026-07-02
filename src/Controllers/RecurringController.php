<?php

declare(strict_types=1);

final class RecurringController
{
    public function __construct(private PDO $db)
    {
    }

    public function index(array $params, array $user): void
    {
        $stmt = $this->db->prepare(
            "SELECT r.*, a.name AS account_name, c.name AS category_name
             FROM recurring_transactions r
             JOIN accounts a ON a.id = r.account_id
             LEFT JOIN categories c ON c.id = r.category_id
             WHERE r.user_id = ?
             ORDER BY r.is_active DESC, r.next_run_date ASC"
        );
        $stmt->execute([$user['id']]);

        Response::json(['data' => $stmt->fetchAll()]);
    }

    public function store(array $params, array $user): void
    {
        $data = Request::json();
        Validator::require($data, ['account_id', 'type', 'amount', 'description', 'next_run_date']);

        if (!in_array($data['type'], ['income', 'expense'], true)) {
            Response::json(['message' => 'Recurring type must be income or expense'], 422);
        }

        Validator::date((string) $data['next_run_date']);
        $this->ensureOwnsAccount((int) $data['account_id'], (int) $user['id']);

        $stmt = $this->db->prepare(
            'INSERT INTO recurring_transactions (user_id, account_id, category_id, type, amount, description, frequency, next_run_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?)'
        );
        $stmt->execute([
            $user['id'],
            $data['account_id'],
            $data['category_id'] ?? null,
            $data['type'],
            (float) $data['amount'],
            trim((string) $data['description']),
            $data['frequency'] ?? 'monthly',
            $data['next_run_date'],
        ]);

        Response::json(['message' => 'Recurring transaction created', 'id' => (int) $this->db->lastInsertId()], 201);
    }

    public function update(array $params, array $user): void
    {
        $data = Request::json();
        $stmt = $this->db->prepare(
            'UPDATE recurring_transactions SET amount = COALESCE(?, amount), description = COALESCE(?, description), frequency = COALESCE(?, frequency), next_run_date = COALESCE(?, next_run_date), is_active = COALESCE(?, is_active) WHERE id = ? AND user_id = ?'
        );
        $stmt->execute([
            $data['amount'] ?? null,
            $data['description'] ?? null,
            $data['frequency'] ?? null,
            $data['next_run_date'] ?? null,
            $data['is_active'] ?? null,
            $params['id'],
            $user['id'],
        ]);

        Response::json(['message' => 'Recurring transaction updated']);
    }

    public function delete(array $params, array $user): void
    {
        $stmt = $this->db->prepare('DELETE FROM recurring_transactions WHERE id = ? AND user_id = ?');
        $stmt->execute([$params['id'], $user['id']]);

        Response::json(['message' => 'Recurring transaction deleted']);
    }

    private function ensureOwnsAccount(int $accountId, int $userId): void
    {
        $stmt = $this->db->prepare('SELECT id FROM accounts WHERE id = ? AND user_id = ?');
        $stmt->execute([$accountId, $userId]);

        if (!$stmt->fetch()) {
            Response::json(['message' => 'Account not found'], 404);
        }
    }
}

