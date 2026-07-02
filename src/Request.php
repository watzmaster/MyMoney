<?php

declare(strict_types=1);

final class Request
{
    public static function json(): array
    {
        $raw = file_get_contents('php://input') ?: '';
        $data = json_decode($raw, true);

        if ($raw !== '' && !is_array($data)) {
            Response::json(['message' => 'Invalid JSON body'], 422);
        }

        return $data ?? [];
    }

    public static function query(string $key, mixed $default = null): mixed
    {
        return $_GET[$key] ?? $default;
    }
}

