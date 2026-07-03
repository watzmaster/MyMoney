<?php

declare(strict_types=1);

final class ReportController
{
    public function __construct(private PDO $db)
    {
    }

    public function summary(array $params, array $user): void
    {
        [$from, $to] = $this->dateRange();
        [$accountSql, $accountBindings] = $this->accountFilter();

        $stmt = $this->db->prepare(
            "SELECT
                COALESCE(SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END), 0) AS income,
                COALESCE(SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END), 0) AS expense,
                COALESCE(SUM(CASE WHEN type = 'income' THEN amount WHEN type = 'expense' THEN -amount ELSE 0 END), 0) AS net
             FROM transactions
             WHERE user_id = ? AND transaction_date BETWEEN ? AND ?{$accountSql}"
        );
        $stmt->execute([$user['id'], $from, $to, ...$accountBindings]);

        Response::json(['data' => ['from' => $from, 'to' => $to] + $stmt->fetch()]);
    }

    public function cashflow(array $params, array $user): void
    {
        [$from, $to] = $this->dateRange();
        [$accountSql, $accountBindings] = $this->accountFilter();
        $stmt = $this->db->prepare(
            "SELECT transaction_date,
                COALESCE(SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END), 0) AS income,
                COALESCE(SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END), 0) AS expense
             FROM transactions
             WHERE user_id = ? AND transaction_date BETWEEN ? AND ?{$accountSql}
             GROUP BY transaction_date
             ORDER BY transaction_date ASC"
        );
        $stmt->execute([$user['id'], $from, $to, ...$accountBindings]);

        Response::json(['data' => $stmt->fetchAll()]);
    }

    public function categoryBreakdown(array $params, array $user): void
    {
        [$from, $to] = $this->dateRange();
        $type = Request::query('type', 'expense');
        [$accountSql, $accountBindings] = $this->accountFilter('t.');

        $stmt = $this->db->prepare(
            "SELECT c.id, c.name, c.icon, c.color, COALESCE(SUM(t.amount), 0) AS total
             FROM transactions t
             JOIN categories c ON c.id = t.category_id
             WHERE t.user_id = ? AND t.type = ? AND t.transaction_date BETWEEN ? AND ?{$accountSql}
             GROUP BY c.id
             ORDER BY total DESC"
        );
        $stmt->execute([$user['id'], $type, $from, $to, ...$accountBindings]);

        Response::json(['data' => $stmt->fetchAll()]);
    }

    public function budgetUsage(array $params, array $user): void
    {
        $month = Request::query('month', date('Y-m'));
        [$accountJoinSql, $accountBindings] = $this->accountFilter('t.');
        $stmt = $this->db->prepare(
            "SELECT b.id, b.month, b.amount AS budget_amount, b.alert_percent, c.name AS category_name,
                COALESCE(SUM(t.amount), 0) AS spent,
                b.amount - COALESCE(SUM(t.amount), 0) AS remaining,
                COALESCE(ROUND((SUM(t.amount) / b.amount) * 100, 2), 0) AS used_percent,
                COALESCE(ROUND((SUM(t.amount) / b.amount) * 100, 2), 0) >= b.alert_percent AS should_alert
             FROM budgets b
             JOIN categories c ON c.id = b.category_id
             LEFT JOIN transactions t ON t.category_id = b.category_id
                AND t.user_id = b.user_id
                AND t.type = 'expense'
                AND DATE_FORMAT(t.transaction_date, '%Y-%m') = b.month
                {$accountJoinSql}
             WHERE b.user_id = ? AND b.month = ?
             GROUP BY b.id
             ORDER BY used_percent DESC"
        );
        $stmt->execute([...$accountBindings, $user['id'], $month]);

        Response::json(['data' => $stmt->fetchAll()]);
    }

    private function dateRange(): array
    {
        $from = (string) Request::query('from', date('Y-m-01'));
        $to = (string) Request::query('to', date('Y-m-t'));

        Validator::date($from);
        Validator::date($to);

        return [$from, $to];
    }

    private function accountFilter(string $prefix = ''): array
    {
        $accountId = Request::query('account_id');
        if ($accountId === null || $accountId === '') {
            return ['', []];
        }

        return [" AND {$prefix}account_id = ?", [$accountId]];
    }
}
