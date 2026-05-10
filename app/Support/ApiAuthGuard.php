<?php
declare(strict_types=1);

namespace App\Support;

final class ApiAuthGuard
{
    public static function requireLoginIfEnabled(?Config $config = null): void
    {
        $config = $config ?: new Config(dirname(__DIR__, 2) . '/config.ini');
        $auth = new AppAuth($config);

        if (!$auth->isEnabled() || $auth->isLoggedIn()) {
            return;
        }

        http_response_code(401);
        header('Content-Type: application/json; charset=UTF-8');
        echo json_encode([
            'ok' => false,
            'auth_required' => true,
            'message' => 'Login required.',
        ]);
        exit;
    }
}
