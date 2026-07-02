<?php

declare(strict_types=1);

final class AuthController
{
    public function __construct(private PDO $db)
    {
    }

    public function register(): void
    {
        $data = Request::json();
        Validator::require($data, ['name', 'email', 'password']);

        if (!filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
            Response::json(['message' => 'Email is invalid'], 422);
        }

        if (strlen((string) $data['password']) < 8) {
            Response::json(['message' => 'Password must be at least 8 characters'], 422);
        }

        $this->db->beginTransaction();

        try {
            $stmt = $this->db->prepare('INSERT INTO users (name, email, password_hash, subscription_plan, trial_started_at) VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP)');
            $stmt->execute([
                trim((string) $data['name']),
                strtolower(trim((string) $data['email'])),
                password_hash((string) $data['password'], PASSWORD_DEFAULT),
                'free',
            ]);

            $userId = (int) $this->db->lastInsertId();
            $this->createDefaults($userId);
            $this->db->commit();
        } catch (PDOException $exception) {
            $this->db->rollBack();
            Response::json(['message' => 'Email already exists'], 409);
        }

        Response::json([
            'message' => 'Registered',
            'token' => Auth::issueToken($userId),
        ], 201);
    }

    public function login(): void
    {
        $data = Request::json();
        Validator::require($data, ['email', 'password']);

        $stmt = $this->db->prepare('SELECT id, password_hash FROM users WHERE email = ?');
        $stmt->execute([strtolower(trim((string) $data['email']))]);
        $user = $stmt->fetch();

        if (!$user || !password_verify((string) $data['password'], $user['password_hash'])) {
            Response::json(['message' => 'Invalid email or password'], 401);
        }

        Response::json(['token' => Auth::issueToken((int) $user['id'])]);
    }

    public function me(array $params, array $user): void
    {
        Response::json(['data' => $user]);
    }

    public function changePassword(array $params, array $user): void
    {
        $data = Request::json();
        Validator::require($data, ['current_password', 'new_password']);

        if (strlen((string) $data['new_password']) < 8) {
            Response::json(['message' => 'New password must be at least 8 characters'], 422);
        }

        $stmt = $this->db->prepare('SELECT password_hash FROM users WHERE id = ?');
        $stmt->execute([$user['id']]);
        $record = $stmt->fetch();

        if (!$record || !password_verify((string) $data['current_password'], $record['password_hash'])) {
            Response::json(['message' => 'Current password is incorrect'], 422);
        }

        $stmt = $this->db->prepare('UPDATE users SET password_hash = ? WHERE id = ?');
        $stmt->execute([
            password_hash((string) $data['new_password'], PASSWORD_DEFAULT),
            $user['id'],
        ]);

        Response::json(['message' => 'Password updated']);
    }

    private function createDefaults(int $userId): void
    {
        $account = $this->db->prepare('INSERT INTO accounts (user_id, name, type, currency) VALUES (?, ?, ?, ?)');
        $account->execute([$userId, 'Cash', 'cash', 'THB']);

        $categories = [
            ['Salary', 'income', 'wallet', '#16a34a'],
            ['Bonus', 'income', 'sparkles', '#22c55e'],
            ['Food', 'expense', 'utensils', '#ef4444'],
            ['Transport', 'expense', 'car', '#f97316'],
            ['Shopping', 'expense', 'shopping-bag', '#8b5cf6'],
            ['Bills', 'expense', 'receipt', '#0ea5e9'],
            ['Health', 'expense', 'heart-pulse', '#ec4899'],
        ];

        $stmt = $this->db->prepare('INSERT INTO categories (user_id, name, type, icon, color) VALUES (?, ?, ?, ?, ?)');
        foreach ($categories as $category) {
            $stmt->execute([$userId, ...$category]);
        }
    }
}
