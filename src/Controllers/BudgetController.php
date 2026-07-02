<?php

declare(strict_types=1);

final class BudgetController
{
    public function __construct(private PDO $db)
    {
    }

    public function index(array $params, array $user): void
    {
        $month = Request::query('month', date('Y-m'));
        $stmt = $this->db->prepare(
            "SELECT b.*, c.name AS category_name,
                COALESCE(SUM(t.amount), 0) AS spent,
                ROUND((COALESCE(SUM(t.amount), 0) / b.amount) * 100, 2) AS used_percent
             FROM budgets b
             JOIN categories c ON c.id = b.category_id
             LEFT JOIN transactions t ON t.category_id = b.category_id
                AND t.user_id = b.user_id
                AND t.type = 'expense'
                AND DATE_FORMAT(t.transaction_date, '%Y-%m') = b.month
             WHERE b.user_id = ? AND b.month = ?
             GROUP BY b.id
             ORDER BY c.name ASC"
        );
        $stmt->execute([$user['id'], $month]);

        Response::json(['data' => $stmt->fetchAll()]);
    }

    public function store(array $params, array $user): void
    {
        $data = Request::json();
        Validator::require($data, ['category_id', 'month', 'amount']);
        $this->ensureExpenseCategory((int) $data['category_id'], (int) $user['id']);

        $stmt = $this->db->prepare(
            'INSERT INTO budgets (user_id, category_id, month, amount, alert_percent) VALUES (?, ?, ?, ?, ?)'
        );
        $stmt->execute([
            $user['id'],
            $data['category_id'],
            $data['month'],
            (float) $data['amount'],
            (int) ($data['alert_percent'] ?? 80),
        ]);

        Response::json(['message' => 'Budget created', 'id' => (int) $this->db->lastInsertId()], 201);
    }

    public function update(array $params, array $user): void
    {
        $data = Request::json();
        $stmt = $this->db->prepare(
            'UPDATE budgets SET amount = COALESCE(?, amount), alert_percent = COALESCE(?, alert_percent) WHERE id = ? AND user_id = ?'
        );
        $stmt->execute([
            $data['amount'] ?? null,
            $data['alert_percent'] ?? null,
            $params['id'],
            $user['id'],
        ]);

        Response::json(['message' => 'Budget updated']);
    }

    public function delete(array $params, array $user): void
    {
        $stmt = $this->db->prepare('DELETE FROM budgets WHERE id = ? AND user_id = ?');
        $stmt->execute([$params['id'], $user['id']]);

        Response::json(['message' => 'Budget deleted']);
    }

    private function ensureExpenseCategory(int $categoryId, int $userId): void
    {
        $stmt = $this->db->prepare("SELECT id FROM categories WHERE id = ? AND user_id = ? AND type = 'expense'");
        $stmt->execute([$categoryId, $userId]);

        if (!$stmt->fetch()) {
            Response::json(['message' => 'Expense category not found'], 404);
        }
    }
}

