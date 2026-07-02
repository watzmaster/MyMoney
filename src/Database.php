<?php

declare(strict_types=1);

final class Database
{
    public static function connect(): PDO
    {
        $host = self::env('DB_HOST', '127.0.0.1');
        $port = self::env('DB_PORT', '3306');
        $database = self::env('DB_DATABASE', 'MyMoney_app');
        $username = self::env('DB_USERNAME', 'finance_user');
        $password = self::env('DB_PASSWORD', 'finance_password');
        $socket = self::env('DB_SOCKET', '');

        $dsn = $socket !== ''
            ? "mysql:unix_socket={$socket};dbname={$database};charset=utf8mb4"
            : "mysql:host={$host};port={$port};dbname={$database};charset=utf8mb4";

        return new PDO($dsn, $username, $password, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]);
    }

    private static function env(string $key, string $default): string
    {
        $value = $_ENV[$key] ?? getenv($key);
        return $value === false || $value === null || $value === '' ? $default : (string) $value;
    }
}
