<?php

declare(strict_types=1);

spl_autoload_register(function (string $class): void {
    $paths = [
        __DIR__ . '/' . $class . '.php',
        __DIR__ . '/Controllers/' . $class . '.php',
    ];

    foreach ($paths as $path) {
        if (is_file($path)) {
            require $path;
            return;
        }
    }
});

set_exception_handler(function (Throwable $exception): void {
    $isLocal = ($_ENV['APP_ENV'] ?? getenv('APP_ENV') ?: 'production') === 'local';

    Response::json([
        'message' => 'Server error',
        'error' => $isLocal ? $exception->getMessage() : null,
    ], 500);
});

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS');

if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'OPTIONS') {
    http_response_code(204);
    exit;
}

$db = Database::connect();

