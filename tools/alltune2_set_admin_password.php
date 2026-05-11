#!/usr/bin/env php
<?php
declare(strict_types=1);

$configPath = dirname(__DIR__) . '/config.ini';

if (PHP_SAPI !== 'cli') {
    fwrite(STDERR, "This tool must be run from the command line.\n");
    exit(1);
}

if (!is_file($configPath)) {
    fwrite(STDERR, "Missing config.ini at {$configPath}\n");
    exit(1);
}

function promptHidden(string $message): string
{
    fwrite(STDOUT, $message);
    system('stty -echo');
    $value = rtrim((string) fgets(STDIN), "\r\n");
    system('stty echo');
    fwrite(STDOUT, "\n");
    return $value;
}

function setConfigKey(string $text, string $key, string $value): string
{
    $lines = preg_split('/\R/', $text) ?: [];
    $found = false;
    $out = [];

    foreach ($lines as $line) {
        if (preg_match('/^\s*' . preg_quote($key, '/') . '\s*=/', $line)) {
            $out[] = $key . '=' . $value;
            $found = true;
        } else {
            $out[] = $line;
        }
    }

    if (!$found) {
        $out[] = $key . '=' . $value;
    }

    return rtrim(implode("\n", $out)) . "\n";
}

echo "AllTune2 Web Login Setup\n";
echo "========================\n\n";
echo "AllTune2 uses one administrator login.\n";
echo "Press Enter with no password to disable web login but keep the saved hash.\n";
echo "Enter a password to enable or change web login.\n\n";

$text = file_get_contents($configPath);
if ($text === false) {
    fwrite(STDERR, "Unable to read config.ini\n");
    exit(1);
}

$password = promptHidden("Admin password: ");

// Always keep the single internal admin username.
$text = setConfigKey($text, 'ALLTUNE2_ADMIN_USER', '"admin"');

if ($password === '') {
    $text = setConfigKey($text, 'ALLTUNE2_AUTH_ENABLED', '0');

    if (file_put_contents($configPath, $text, LOCK_EX) === false) {
        fwrite(STDERR, "Unable to update config.ini\n");
        exit(1);
    }

    echo "\nWeb login disabled. Existing password hash was kept.\n";
    exit(0);
}

$confirm = promptHidden("Confirm admin password: ");

if (!hash_equals($password, $confirm)) {
    fwrite(STDERR, "\nPasswords did not match. No changes made.\n");
    exit(1);
}

$hash = password_hash($password, PASSWORD_DEFAULT);

$text = setConfigKey($text, 'ALLTUNE2_AUTH_ENABLED', '1');
$text = setConfigKey($text, 'ALLTUNE2_ADMIN_PASSWORD_HASH', '"' . $hash . '"');

if (file_put_contents($configPath, $text, LOCK_EX) === false) {
    fwrite(STDERR, "Unable to update config.ini\n");
    exit(1);
}

echo "\nWeb login enabled for the single admin account.\n";
echo "The password hash was saved to config.ini. The plain password was not stored.\n";
