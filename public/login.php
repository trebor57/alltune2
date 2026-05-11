<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/app/Support/AppSession.php';
\App\Support\AppSession::start();

require_once dirname(__DIR__) . '/app/Support/Config.php';
require_once dirname(__DIR__) . '/app/Support/AppAuth.php';
require_once dirname(__DIR__) . '/app/Support/AppCsrf.php';

use App\Support\AppAuth;
use App\Support\Config;

$config = new Config(dirname(__DIR__) . '/config.ini');
$auth = new AppAuth($config);
$authHttpsWarning = $auth->isEnabled() && !\App\Support\AppSession::isHttps();
$adminUser = $auth->adminUser();

function e(mixed $value): string
{
    return htmlspecialchars((string) $value, ENT_QUOTES, 'UTF-8');
}

$message = '';
$error = '';

if (!$auth->isEnabled()) {
    $message = 'Web login is disabled. AllTune2 is running in normal mode. To enable login, run sudo php /var/www/html/alltune2/tools/alltune2_set_admin_password.php on the node.';
} elseif ($auth->isLoggedIn()) {
    $message = 'You are already signed in.';
} elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = $auth->adminUser();
    $password = (string) ($_POST['password'] ?? '');

    if (!\App\Support\AppCsrf::validateRequest()) {
        $error = 'Security check failed. Refresh the page and try again.';
    } elseif ($auth->login($username, $password)) {
        header('Location: /alltune2/public/');
        exit;
    }

    $error = 'Login failed. Check the password and try again.';
}
?>
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>AllTune2 Login</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body {
            min-height: 100vh;
            margin: 0;
            display: grid;
            place-items: center;
            background:
                radial-gradient(circle at top, rgba(122, 44, 191, 0.26), transparent 42%),
                linear-gradient(180deg, #16091f, #06040a);
            color: #f4eaff;
            font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
        }
        .card {
            width: min(430px, calc(100vw - 32px));
            padding: 30px;
            border: 1px solid rgba(216, 108, 242, 0.34);
            border-radius: 24px;
            background:
                linear-gradient(180deg, rgba(36, 20, 54, 0.97), rgba(10, 7, 18, 0.98));
            box-shadow:
                0 22px 70px rgba(0, 0, 0, 0.46),
                0 0 34px rgba(122, 44, 191, 0.18);
        }
        h1 {
            margin: 0;
            font-size: 1.65rem;
            letter-spacing: 0.01em;
        }
        .login-subtitle {
            margin: 4px 0 18px;
            color: #d9c2e6;
            font-size: 0.95rem;
            font-weight: 750;
            text-transform: uppercase;
            letter-spacing: 0.08em;
        }
        p {
            color: #d9c2e6;
            line-height: 1.45;
        }
        label {
            display: block;
            margin: 18px 0 8px;
            font-weight: 700;
        }
        input {
            width: 100%;
            box-sizing: border-box;
            padding: 12px 13px;
            border-radius: 12px;
            border: 1px solid rgba(216, 108, 242, 0.28);
            background: rgba(0, 0, 0, 0.22);
            color: #fff;
            font-size: 1rem;
        }
        button, a.button {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            margin-top: 16px;
            min-height: 42px;
            padding: 0 18px;
            border: 1px solid rgba(216, 108, 242, 0.42);
            border-radius: 14px;
            background: linear-gradient(180deg, rgba(130, 62, 191, 0.95), rgba(84, 36, 128, 0.96));
            color: #fff;
            font-weight: 850;
            text-decoration: none;
            cursor: pointer;
            box-shadow: 0 0 18px rgba(122, 44, 191, 0.16);
        }
        button:hover, a.button:hover {
            border-color: rgba(255, 125, 242, 0.74);
            box-shadow: 0 0 0 3px rgba(216, 108, 242, 0.12);
        }
        .error {
            color: #ffb3b3;
            font-weight: 700;
        }
        .message {
            color: #c7f7d4;
            font-weight: 700;
        }
        .warning {
            color: #ffd9a8;
            font-weight: 800;
        }
        .links {
            margin-top: 16px;
        }
    
        /* login-cleanup-polish */
        body {
            background:
                radial-gradient(circle at top, rgba(122, 44, 191, 0.26), transparent 42%),
                linear-gradient(180deg, #16091f, #06040a);
        }
        .card {
            border-color: rgba(216, 108, 242, 0.34);
            box-shadow:
                0 22px 70px rgba(0, 0, 0, 0.46),
                0 0 34px rgba(122, 44, 191, 0.18);
        }
        h1 {
            margin-bottom: 2px;
            font-size: 1.65rem;
        }
        .login-subtitle {
            margin: 0 0 18px;
            color: #d9c2e6;
            font-size: 0.88rem;
            font-weight: 800;
            letter-spacing: 0.08em;
            text-transform: uppercase;
        }
        button,
        a.button {
            border: 1px solid rgba(216, 108, 242, 0.42);
            background: linear-gradient(180deg, rgba(130, 62, 191, 0.95), rgba(84, 36, 128, 0.96));
            box-shadow: 0 0 18px rgba(122, 44, 191, 0.16);
        }
        button:hover,
        a.button:hover {
            border-color: rgba(255, 125, 242, 0.74);
            box-shadow: 0 0 0 3px rgba(216, 108, 242, 0.12);
        }
        
        .single-admin-note {
            margin: -8px 0 18px;
            color: #bda2ce;
            font-size: 0.82rem;
            font-weight: 700;
        }
        </style>
</head>
<body>
    <main class="card">
        <h1>AllTune2</h1>
        <p class="login-subtitle">Operator Login</p>
        <p class="single-admin-note">Single administrator access</p>

        <?php if ($authHttpsWarning): ?>
            <p class="warning">Web login is enabled, but this page is not using HTTPS. Use HTTPS or a VPN before allowing outside access.</p>
        <?php endif; ?>

        <?php if ($message !== ''): ?>
            <p class="message"><?= e($message) ?></p>
        <?php endif; ?>

        <?php if ($error !== ''): ?>
            <p class="error"><?= e($error) ?></p>
        <?php endif; ?>

        <?php if ($auth->isEnabled() && !$auth->isLoggedIn()): ?>
            <form method="post" action="/alltune2/public/login.php">
                <?= \App\Support\AppCsrf::inputHtml() ?>
<label for="password">Admin password</label>
                <input id="password" name="password" type="password" autocomplete="current-password" required autofocus>
                <button type="submit">Sign In</button>
            </form>
        <?php endif; ?>

        <div class="links">
            <a class="button" href="/alltune2/public/">Back to Dashboard</a>
        </div>
    </main>
</body>
</html>
