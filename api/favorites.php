<?php
declare(strict_types=1);

session_start();

header('Content-Type: application/json; charset=UTF-8');
header('Cache-Control: no-store');

$dataDir = dirname(__DIR__) . '/data';
$favoritesPath = $dataDir . '/favorites.txt';

function respond_json(array $payload, int $status = 200): void
{
    http_response_code($status);
    echo json_encode($payload, JSON_UNESCAPED_SLASHES);
    exit;
}

function normalize_mode(string $mode): string
{
    $value = strtoupper(trim($mode));

    if (in_array($value, ['ALLSTAR', 'ALLSTAR LINK', 'ALLSTARLINK'], true)) {
        return 'ASL';
    }

    if (in_array($value, ['ECHO', 'ECHO LINK', 'ECHOLINK', 'EL', 'E/L'], true)) {
        return 'ECHO';
    }

    if (in_array($value, ['D-STAR', 'D STAR', 'DSTAR'], true)) {
        return 'DSTAR';
    }

    if (in_array($value, ['P-25', 'P 25', 'P25'], true)) {
        return 'P25';
    }

    if (in_array($value, ['N-XDN', 'N XDN', 'NXDN'], true)) {
        return 'NXDN';
    }

    return match ($value) {
        'BM', 'TGIF', 'ASL', 'ECHO', 'YSF', 'DSTAR', 'P25', 'NXDN' => $value,
        default => 'BM',
    };
}

function clean_favorite_field(string $value, int $maxLength): string
{
    $value = trim(str_replace('|', ' ', $value));
    $value = preg_replace('/\s+/', ' ', $value) ?? '';

    if (function_exists('mb_substr')) {
        return mb_substr($value, 0, $maxLength);
    }

    return substr($value, 0, $maxLength);
}

function load_favorites_file(string $path): array
{
    if (!is_file($path)) {
        return [];
    }

    $lines = file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);

    if (!is_array($lines)) {
        return [];
    }

    $favorites = [];

    foreach ($lines as $index => $line) {
        $parts = explode('|', $line);

        $target = trim((string) ($parts[0] ?? ''));
        $name = trim((string) ($parts[1] ?? ''));
        $description = trim((string) ($parts[2] ?? ''));
        $mode = normalize_mode((string) ($parts[3] ?? 'BM'));

        if ($target === '') {
            continue;
        }

        $favorites[] = [
            'id' => (string) $index,
            'target' => $target,
            'name' => $name,
            'description' => $description,
            'mode' => $mode,
        ];
    }

    return array_values($favorites);
}

function save_favorites_file(string $path, array $favorites): bool
{
    $lines = [];

    foreach ($favorites as $favorite) {
        $target = clean_favorite_field((string) ($favorite['target'] ?? ''), 96);
        $name = clean_favorite_field((string) ($favorite['name'] ?? ''), 96);
        $description = clean_favorite_field((string) ($favorite['description'] ?? ''), 180);
        $mode = normalize_mode((string) ($favorite['mode'] ?? 'BM'));

        if ($target === '') {
            continue;
        }

        $lines[] = implode('|', [$target, $name, $description, $mode]);
    }

    $content = $lines === [] ? '' : implode(PHP_EOL, $lines) . PHP_EOL;

    return file_put_contents($path, $content, LOCK_EX) !== false;
}

if (!is_dir($dataDir) && !mkdir($dataDir, 0775, true) && !is_dir($dataDir)) {
    respond_json([
        'ok' => false,
        'message' => 'Unable to create AllTune2 data directory.',
    ], 500);
}

if (!is_file($favoritesPath) && file_put_contents($favoritesPath, '', LOCK_EX) === false) {
    respond_json([
        'ok' => false,
        'message' => 'Unable to create favorites.txt.',
    ], 500);
}

$favorites = load_favorites_file($favoritesPath);

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    respond_json([
        'ok' => true,
        'favorites' => $favorites,
        'favorites_count' => count($favorites),
    ]);
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    respond_json([
        'ok' => false,
        'message' => 'Unsupported request method.',
    ], 405);
}

$action = trim((string) ($_POST['action'] ?? 'save'));

if ($action !== 'save') {
    respond_json([
        'ok' => false,
        'message' => 'Unsupported favorites action.',
    ], 400);
}

$target = clean_favorite_field((string) ($_POST['target'] ?? ''), 96);
$mode = normalize_mode((string) ($_POST['mode'] ?? 'BM'));
$name = clean_favorite_field((string) ($_POST['name'] ?? ''), 96);
$description = clean_favorite_field((string) ($_POST['description'] ?? ''), 180);

if ($target === '') {
    respond_json([
        'ok' => false,
        'message' => 'Enter a TG / node / target before saving.',
    ], 400);
}

if ($name === '') {
    $name = $target;
}

$updated = false;
$savedFavorite = [
    'id' => '',
    'target' => $target,
    'name' => $name,
    'description' => $description,
    'mode' => $mode,
];

foreach ($favorites as $index => &$favorite) {
    if (
        trim((string) ($favorite['target'] ?? '')) === $target
        && normalize_mode((string) ($favorite['mode'] ?? 'BM')) === $mode
    ) {
        $favorite['target'] = $target;
        $favorite['name'] = $name;
        $favorite['description'] = $description;
        $favorite['mode'] = $mode;
        $favorite['id'] = (string) $index;
        $savedFavorite = $favorite;
        $updated = true;
        break;
    }
}
unset($favorite);

if (!$updated) {
    $savedFavorite['id'] = (string) count($favorites);
    $favorites[] = $savedFavorite;
}

if (!save_favorites_file($favoritesPath, $favorites)) {
    respond_json([
        'ok' => false,
        'message' => 'Unable to save favorites.txt.',
    ], 500);
}

$favorites = load_favorites_file($favoritesPath);

respond_json([
    'ok' => true,
    'message' => $updated ? 'Favorite updated.' : 'Favorite saved.',
    'updated' => $updated,
    'favorite' => $savedFavorite,
    'favorites' => $favorites,
    'favorites_count' => count($favorites),
]);
