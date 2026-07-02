<?php

declare(strict_types=1);

final class Router
{
    private array $routes = [];

    public function get(string $path, callable $handler, bool $auth = false): void
    {
        $this->add('GET', $path, $handler, $auth);
    }

    public function post(string $path, callable $handler, bool $auth = false): void
    {
        $this->add('POST', $path, $handler, $auth);
    }

    public function put(string $path, callable $handler, bool $auth = false): void
    {
        $this->add('PUT', $path, $handler, $auth);
    }

    public function delete(string $path, callable $handler, bool $auth = false): void
    {
        $this->add('DELETE', $path, $handler, $auth);
    }

    public function dispatch(string $method, string $path): void
    {
        foreach ($this->routes as $route) {
            if ($route['method'] !== $method) {
                continue;
            }

            $params = $this->match($route['path'], $path);

            if ($params === null) {
                continue;
            }

            $user = $route['auth'] ? Auth::user($GLOBALS['db']) : null;
            call_user_func($route['handler'], $params, $user);
            return;
        }

        Response::json(['message' => 'Route not found'], 404);
    }

    private function add(string $method, string $path, callable $handler, bool $auth): void
    {
        $this->routes[] = compact('method', 'path', 'handler', 'auth');
    }

    private function match(string $routePath, string $requestPath): ?array
    {
        $pattern = preg_replace('#\{([a-zA-Z_][a-zA-Z0-9_]*)\}#', '(?P<$1>[^/]+)', $routePath);
        $pattern = '#^' . $pattern . '$#';

        if (!preg_match($pattern, $requestPath, $matches)) {
            return null;
        }

        return array_filter($matches, 'is_string', ARRAY_FILTER_USE_KEY);
    }
}

