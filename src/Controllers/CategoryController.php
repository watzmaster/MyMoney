<?php

declare(strict_types=1);

final class CategoryController
{
    public function __construct(private PDO $db)
    {
    }

    public function index(array $params, array $user): void
    {
        $type = Request::query('type');
        $sql = 'SELECT * FROM categories WHERE user_id = ?';
        $bindings = [$user['id']];

        if ($type) {
            $sql .= ' AND type = ?';
            $bindings[] = $type;
        }

        $sql .= ' ORDER BY type ASC, name ASC';
        $stmt = $this->db->prepare($sql);
        $stmt->execute($bindings);

        Response::json(['data' => $stmt->fetchAll()]);
    }

    public function store(array $params, array $user): void
    {
        $data = Request::json();
        Validator::require($data, ['name', 'type']);

        if (!in_array($data['type'], ['income', 'expense'], true)) {
            Response::json(['message' => 'Category type must be income or expense'], 422);
        }

        $stmt = $this->db->prepare(
            'INSERT INTO categories (user_id, name, type, icon, color) VALUES (?, ?, ?, ?, ?)'
        );
        $stmt->execute([
            $user['id'],
            trim((string) $data['name']),
            $data['type'],
            $data['icon'] ?? null,
            $data['color'] ?? null,
        ]);

        Response::json(['message' => 'Category created', 'id' => (int) $this->db->lastInsertId()], 201);
    }

    public function update(array $params, array $user): void
    {
        $data = Request::json();
        $stmt = $this->db->prepare(
            'UPDATE categories SET name = COALESCE(?, name), icon = COALESCE(?, icon), color = COALESCE(?, color) WHERE id = ? AND user_id = ?'
        );
        $stmt->execute([
            $data['name'] ?? null,
            $data['icon'] ?? null,
            $data['color'] ?? null,
            $params['id'],
            $user['id'],
        ]);

        Response::json(['message' => 'Category updated']);
    }

    public function delete(array $params, array $user): void
    {
        $stmt = $this->db->prepare('DELETE FROM categories WHERE id = ? AND user_id = ?');
        $stmt->execute([$params['id'], $user['id']]);

        Response::json(['message' => 'Category deleted']);
    }
}

