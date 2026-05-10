<?php
declare(strict_types=1);

session_start();

require_once dirname(__DIR__) . '/app/Support/Config.php';
require_once dirname(__DIR__) . '/app/Support/AppAuth.php';

use App\Support\AppAuth;
use App\Support\Config;

$config = new Config(dirname(__DIR__) . '/config.ini');
$auth = new AppAuth($config);

function e(mixed $value): string
{
    return htmlspecialchars((string) $value, ENT_QUOTES, 'UTF-8');
}

$message = '';
$error = '';

if (!$auth->isEnabled()) {
    $message = 'Web login is not enabled. AllTune2 is running in normal mode.';
} elseif ($auth->isLoggedIn()) {
    $message = 'You are already signed in.';
} elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $password = (string) ($_POST['password'] ?? '');

    if ($auth->login($password)) {
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
            background: #100719;
            color: #f4eaff;
            font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
        }
        .card {
            width: min(420px, calc(100vw - 32px));
            padding: 28px;
            border: 1px solid rgba(216, 108, 242, 0.28);
            border-radius: 22px;
            background: linear-gradient(180deg, rgba(35, 20, 52, 0.96), rgba(13, 8, 22, 0.98));
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.42);
        }
        h1 {
            margin: 0 0 10px;
            font-size: 1.4rem;
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
            min-height: 40px;
            padding: 0 16px;
            border: 0;
            border-radius: 13px;
            background: #7b2cbf;
            color: #fff;
            font-weight: 800;
            text-decoration: none;
            cursor: pointer;
        }
        .error {
            color: #ffb3b3;
            font-weight: 700;
        }
        .message {
            color: #c7f7d4;
            font-weight: 700;
        }
        .links {
            margin-top: 16px;
        }
    </style>
</head>
<body>
    <main class="card">
        <h1>AllTune2 Login</h1>

        <?php if ($message !== ''): ?>
            <p class="message"><?= e($message) ?></p>
        <?php endif; ?>

        <?php if ($error !== ''): ?>
            <p class="error"><?= e($error) ?></p>
        <?php endif; ?>

        <?php if ($auth->isEnabled() && !$auth->isLoggedIn()): ?>
            <form method="post" action="/alltune2/public/login.php">
                <label for="password">Admin password</label>
                <input id="password" name="password" type="password" autocomplete="current-password" required>
                <button type="submit">Sign In</button>
            </form>
        <?php endif; ?>

        <div class="links">
            <a class="button" href="/alltune2/public/">Back to Dashboard</a>
        </div>
    </main>
</body>
</html>
