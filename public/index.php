<?php

declare(strict_types=1);

if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'GET') {
    $path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) ?: '/';

    if ($path === '/' || $path === '/app') {
        require __DIR__ . '/app.php';
        exit;
    }
}

require __DIR__ . '/../src/bootstrap.php';

$router = new Router();

$router->get('/health', fn() => Response::json(['status' => 'ok']));

$authController = new AuthController($db);
$router->post('/auth/register', [$authController, 'register']);
$router->post('/auth/login', [$authController, 'login']);
$router->get('/me', [$authController, 'me'], true);
$router->put('/me/password', [$authController, 'changePassword'], true);

$accountController = new AccountController($db);
$router->get('/accounts', [$accountController, 'index'], true);
$router->post('/accounts', [$accountController, 'store'], true);
$router->put('/accounts/{id}', [$accountController, 'update'], true);
$router->delete('/accounts/{id}', [$accountController, 'delete'], true);

$categoryController = new CategoryController($db);
$router->get('/categories', [$categoryController, 'index'], true);
$router->post('/categories', [$categoryController, 'store'], true);
$router->put('/categories/{id}', [$categoryController, 'update'], true);
$router->delete('/categories/{id}', [$categoryController, 'delete'], true);

$transactionController = new TransactionController($db);
$router->get('/transactions', [$transactionController, 'index'], true);
$router->post('/transactions', [$transactionController, 'store'], true);
$router->get('/transactions/{id}', [$transactionController, 'show'], true);
$router->put('/transactions/{id}', [$transactionController, 'update'], true);
$router->delete('/transactions/{id}', [$transactionController, 'delete'], true);

$budgetController = new BudgetController($db);
$router->get('/budgets', [$budgetController, 'index'], true);
$router->post('/budgets', [$budgetController, 'store'], true);
$router->put('/budgets/{id}', [$budgetController, 'update'], true);
$router->delete('/budgets/{id}', [$budgetController, 'delete'], true);

$recurringController = new RecurringController($db);
$router->get('/recurring-transactions', [$recurringController, 'index'], true);
$router->post('/recurring-transactions', [$recurringController, 'store'], true);
$router->put('/recurring-transactions/{id}', [$recurringController, 'update'], true);
$router->delete('/recurring-transactions/{id}', [$recurringController, 'delete'], true);

$reportController = new ReportController($db);
$router->get('/reports/summary', [$reportController, 'summary'], true);
$router->get('/reports/cashflow', [$reportController, 'cashflow'], true);
$router->get('/reports/category-breakdown', [$reportController, 'categoryBreakdown'], true);
$router->get('/reports/budget-usage', [$reportController, 'budgetUsage'], true);

$router->dispatch($_SERVER['REQUEST_METHOD'], parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) ?: '/');
