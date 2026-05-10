<?php
declare(strict_types=1);

namespace App\Support;

require_once __DIR__ . '/AppCsrf.php';

final class ApiAuthGuard
{
    private static function isUnsafeRequest(): bool
    {
        $method = strtoupper((string) ($_SERVER['REQUEST_METHOD'] ?? 'GET'));
        return in_array($method, ['POST', 'PUT', 'PATCH', 'DELETE'], true);
    }

    public static function requireLoginIfEnabled(?Config $config = null): void
    {
        $config = $config ?: new Config(dirname(__DIR__, 2) . '/config.ini');
        $auth = new AppAuth($config);

        if (!$auth->isEnabled()) {
            return;
        }

        if (!$auth->isLoggedIn()) {
            http_response_code(401);
            header('Content-Type: application/json; charset=UTF-8');
            echo json_encode([
                'ok' => false,
                'auth_required' => true,
                'message' => 'Login required.',
            ]);
            exit;
        }

        if (self::isUnsafeRequest() && !AppCsrf::validateRequest()) {
            http_response_code(403);
            header('Content-Type: application/json; charset=UTF-8');
            echo json_encode([
                'ok' => false,
                'csrf_failed' => true,
                'message' => 'Security check failed. Refresh the page and try again.',
            ]);
            exit;
        }

        return;
    }
}
