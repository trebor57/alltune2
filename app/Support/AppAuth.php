<?php
declare(strict_types=1);

namespace App\Support;

final class AppAuth
{
    private Config $config;

    public function __construct(?Config $config = null)
    {
        $this->config = $config ?: new Config(dirname(__DIR__, 2) . '/config.ini');
    }

    public function isEnabled(): bool
    {
        $enabled = strtolower(trim($this->config->getString('ALLTUNE2_AUTH_ENABLED', '0')));
        $hash = trim($this->config->getString('ALLTUNE2_ADMIN_PASSWORD_HASH', ''));

        return in_array($enabled, ['1', 'true', 'yes', 'on'], true) && $hash !== '';
    }

    public function isLoggedIn(): bool
    {
        return !empty($_SESSION['alltune2_authenticated']);
    }

    public function login(string $password): bool
    {
        if (!$this->isEnabled()) {
            return false;
        }

        $hash = trim($this->config->getString('ALLTUNE2_ADMIN_PASSWORD_HASH', ''));

        if ($hash === '' || !password_verify($password, $hash)) {
            return false;
        }

        session_regenerate_id(true);
        $_SESSION['alltune2_authenticated'] = true;
        $_SESSION['alltune2_login_time'] = time();

        return true;
    }

    public function logout(): void
    {
        unset($_SESSION['alltune2_authenticated'], $_SESSION['alltune2_login_time']);
        session_regenerate_id(true);
    }
}
