<?php

declare(strict_types=1);

final class Validator
{
    public static function require(array $data, array $fields): void
    {
        $missing = [];

        foreach ($fields as $field) {
            if (!array_key_exists($field, $data) || $data[$field] === '' || $data[$field] === null) {
                $missing[] = $field;
            }
        }

        if ($missing !== []) {
            Response::json(['message' => 'Validation failed', 'missing' => $missing], 422);
        }
    }

    public static function type(string $value): void
    {
        if (!in_array($value, ['income', 'expense', 'transfer'], true)) {
            Response::json(['message' => 'Type must be income, expense, or transfer'], 422);
        }
    }

    public static function date(string $value): void
    {
        $date = DateTime::createFromFormat('Y-m-d', $value);
        if (!$date || $date->format('Y-m-d') !== $value) {
            Response::json(['message' => 'Date must use YYYY-MM-DD format'], 422);
        }
    }
}

