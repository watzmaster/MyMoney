<?php

declare(strict_types=1);

final class Auth
{
    public static function user(PDO $db): array
    {
        $header = self::authorizationHeader();

        if (!str_starts_with($header, 'Bearer ')) {
            Response::json(['message' => 'Unauthenticated'], 401);
        }

        $payload = self::decodeToken(substr($header, 7));
        $stmt = $db->prepare(
            "SELECT id, name, email, subscription_plan, trial_started_at, premium_expires_at, created_at,
                DATEDIFF(CURRENT_DATE, DATE(COALESCE(trial_started_at, created_at))) AS trial_days_used,
                GREATEST(0, 7 - DATEDIFF(CURRENT_DATE, DATE(COALESCE(trial_started_at, created_at)))) AS trial_days_remaining,
                CASE
                    WHEN subscription_plan = 'premium' AND (premium_expires_at IS NULL OR premium_expires_at > CURRENT_TIMESTAMP) THEN 'premium'
                    WHEN DATEDIFF(CURRENT_DATE, DATE(COALESCE(trial_started_at, created_at))) < 7 THEN 'trial'
                    ELSE 'free_with_ads'
                END AS access_tier
             FROM users
             WHERE id = ?"
        );
        $stmt->execute([$payload['sub'] ?? 0]);
        $user = $stmt->fetch();

        if (!$user) {
            Response::json(['message' => 'Unauthenticated'], 401);
        }

        return $user;
    }

    public static function issueToken(int $userId): string
    {
        $payload = [
            'sub' => $userId,
            'iat' => time(),
            'exp' => time() + (60 * 60 * 24 * 30),
        ];

        $body = self::base64UrlEncode(json_encode($payload, JSON_THROW_ON_ERROR));
        $signature = hash_hmac('sha256', $body, self::secret());

        return "{$body}.{$signature}";
    }

    private static function decodeToken(string $token): array
    {
        $parts = explode('.', $token);

        if (count($parts) !== 2) {
            Response::json(['message' => 'Unauthenticated'], 401);
        }

        [$body, $signature] = $parts;
        $expected = hash_hmac('sha256', $body, self::secret());

        if (!hash_equals($expected, $signature)) {
            Response::json(['message' => 'Unauthenticated'], 401);
        }

        $payload = json_decode(self::base64UrlDecode($body), true);

        if (!is_array($payload) || ($payload['exp'] ?? 0) < time()) {
            Response::json(['message' => 'Token expired'], 401);
        }

        return $payload;
    }

    private static function secret(): string
    {
        $secret = $_ENV['APP_SECRET'] ?? getenv('APP_SECRET') ?: '';
        return $secret !== '' ? (string) $secret : 'change-this-secret-before-production';
    }

    private static function authorizationHeader(): string
    {
        $header = $_SERVER['HTTP_AUTHORIZATION'] ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] ?? '';

        if ($header !== '') {
            return (string) $header;
        }

        if (function_exists('getallheaders')) {
            foreach (getallheaders() as $key => $value) {
                if (strtolower((string) $key) === 'authorization') {
                    return (string) $value;
                }
            }
        }

        return '';
    }

    private static function base64UrlEncode(string $value): string
    {
        return rtrim(strtr(base64_encode($value), '+/', '-_'), '=');
    }

    private static function base64UrlDecode(string $value): string
    {
        return base64_decode(strtr($value, '-_', '+/')) ?: '';
    }
}
