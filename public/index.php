<?php
declare(strict_types=1);

session_start();

require_once dirname(__DIR__) . '/app/Support/Config.php';

use App\Support\Config;

$config = new Config(dirname(__DIR__) . '/config.ini');

function e(mixed $value): string
{
    return htmlspecialchars((string) $value, ENT_QUOTES, 'UTF-8');
}

function is_placeholder_config_value(mixed $value): bool
{
    $normalized = strtoupper(trim((string) $value));

    if ($normalized === '') {
        return true;
    }

    return in_array($normalized, [
        'CHANGE_ME',
        'YOUR NODE',
        'YOUR DVSWITCH NODE',
        'YOUR_REAL_PASSWORD',
        'YOUR_REAL_KEY',
        'YOUR PASSWORD',
        'YOUR KEY',
    ], true);
}

function config_flag_enabled(Config $config, string $key): bool
{
    $value = strtolower(trim((string) $config->get($key, '0')));
    return in_array($value, ['1', 'true', 'yes', 'on'], true);
}

$appName = 'AllTune2';
$repoUrl = 'https://github.com/TerryClaiborne/alltune2';
$remoteVersionUrl = 'https://raw.githubusercontent.com/TerryClaiborne/alltune2/main/VERSION';
$versionFile = dirname(__DIR__) . '/VERSION';
$localVersion = '0.0.0';

if (is_readable($versionFile)) {
    $versionText = trim((string) @file_get_contents($versionFile));
    if ($versionText !== '') {
        $localVersion = $versionText;
    }
}

$dvswitchNode = trim((string) $config->get('DVSWITCH_NODE', ''));
$myNode = trim((string) $config->get('MYNODE', ''));
$bmPassword = trim((string) $config->get('BM_SelfcarePassword', ''));
$tgifKey = trim((string) $config->get('TGIF_HotspotSecurityKey', ''));
$dstarEnabled = config_flag_enabled($config, 'DSTAR_ENABLED');
$p25Enabled = config_flag_enabled($config, 'P25_ENABLED');
$nxdnEnabled = config_flag_enabled($config, 'NXDN_ENABLED');
$dvswitchScriptAvailable = is_file('/opt/MMDVM_Bridge/dvswitch.sh');

$hasRealMyNode = !is_placeholder_config_value($myNode);
$hasRealDvSwitchNode = !is_placeholder_config_value($dvswitchNode);
$hasRealBmPassword = !is_placeholder_config_value($bmPassword);
$hasRealTgifKey = !is_placeholder_config_value($tgifKey);

$displayMyNode = $hasRealMyNode ? $myNode : 'Not Set';
$displayDvSwitchNode = $hasRealDvSwitchNode ? $dvswitchNode : '';

$modeAvailability = [
    'ASL'  => $hasRealMyNode,
    'ECHO' => $hasRealMyNode,
    'BM'   => $hasRealMyNode && $hasRealDvSwitchNode && $hasRealBmPassword,
    'TGIF'  => $hasRealMyNode && $hasRealDvSwitchNode && $hasRealTgifKey,
    'YSF'   => $hasRealMyNode && $hasRealDvSwitchNode,
    'DSTAR' => $hasRealMyNode && $hasRealDvSwitchNode && $dstarEnabled && $dvswitchScriptAvailable,
    'P25'   => $hasRealMyNode && $hasRealDvSwitchNode && $p25Enabled && $dvswitchScriptAvailable,
    'NXDN'  => $hasRealMyNode && $hasRealDvSwitchNode && $nxdnEnabled && $dvswitchScriptAvailable,
];

$autoloadDvSwitch = isset($_SESSION['autoload_dvswitch'])
    ? (bool) $_SESSION['autoload_dvswitch']
    : true;

$autoloadDvSwitchMode = strtolower(trim((string) ($_SESSION['autoload_dvswitch_mode'] ?? 'transceive')));
if ($autoloadDvSwitchMode !== 'local_monitor') {
    $autoloadDvSwitchMode = 'transceive';
}

$rawDvSwitchActiveMode = strtolower(trim((string) ($_SESSION['dvswitch_active_mode'] ?? '')));
$dvswitchActiveMode = in_array($rawDvSwitchActiveMode, ['local_monitor', 'transceive'], true)
    ? $rawDvSwitchActiveMode
    : '';

$disconnectBeforeConnect = isset($_SESSION['disconnect_before_connect'])
    ? (bool) $_SESSION['disconnect_before_connect']
    : false;

$selectedMode = strtoupper((string) ($_SESSION['selected_mode'] ?? 'BM'));
if (in_array($selectedMode, ['ALLSTAR', 'ALLSTAR LINK', 'ALLSTARLINK'], true)) {
    $selectedMode = 'ASL';
}
if (in_array($selectedMode, ['ECHO', 'ECHO LINK', 'ECHOLINK', 'EL', 'E/L'], true)) {
    $selectedMode = 'ECHO';
}

$targetValue = (string) ($_SESSION['pending_target'] ?? $_SESSION['last_target'] ?? '');
$lastStatus = (string) ($_SESSION['last_status'] ?? 'IDLE - NO CONNECTIONS');
$lastMode = strtoupper((string) ($_SESSION['last_mode'] ?? ''));
$lastTarget = (string) ($_SESSION['last_target'] ?? '');
$pendingTarget = (string) ($_SESSION['pending_target'] ?? $_SESSION['pending_tg'] ?? '');
$dmrNetwork = strtoupper((string) ($_SESSION['dmr_network'] ?? ''));
$dmrReady = !empty($_SESSION['dmr_ready']);
$dvswitchLinkActive = !empty($_SESSION['dvswitch_autoloaded']) || $dmrReady || in_array($lastMode, ['YSF', 'DSTAR', 'P25', 'NXDN'], true);

$nodeStatsUrl = $hasRealMyNode
    ? 'https://stats.allstarlink.org/stats/' . rawurlencode($myNode)
    : 'https://stats.allstarlink.org/';

$dvswitchCockpitDir = dirname(__DIR__, 2) . '/dvswitch_cockpit';
$dvswitchHref = is_dir($dvswitchCockpitDir)
    ? '/dvswitch_cockpit/'
    : '/dvswitch/';

$navItems = [
    ['label' => 'Dashboard', 'href' => '/alltune2/public/index.php', 'active' => true],
    ['label' => 'Favorites', 'href' => '/alltune2/public/favorites.php', 'active' => false],
    ['label' => 'Node Stats', 'href' => $nodeStatsUrl, 'active' => false, 'target' => '_blank'],
    ['label' => 'DVSwitch', 'href' => $dvswitchHref, 'active' => false, 'target' => '_blank'],
];

$modeOptions = [
    'BM'   => 'BrandMeister (DMR)',
    'TGIF' => 'TGIF Network',
    'ASL'  => 'AllStarLink',
    'ECHO' => 'EchoLink',
    'YSF'  => 'System Fusion (YSF)',
];

if ($modeAvailability['DSTAR']) {
    $modeOptions['DSTAR'] = 'D-Star';
}

if ($modeAvailability['P25']) {
    $modeOptions['P25'] = 'P25';
}

if ($modeAvailability['NXDN']) {
    $modeOptions['NXDN'] = 'NXDN';
}

if (!array_key_exists($selectedMode, $modeOptions)) {
    $selectedMode = 'BM';
}

$activityLines = [];

$activityLines[] = [
    'label' => 'DVSwitch Auto-Load',
    'value' => $autoloadDvSwitch
        ? 'Enabled' . ($displayDvSwitchNode !== '' ? ' (' . $displayDvSwitchNode . ')' : '')
        : 'Disabled',
];
$activityLines[] = [
    'label' => 'Link Mode',
    'value' => $autoloadDvSwitchMode === 'local_monitor' ? 'Local Monitor' : 'Transceive',
];
$activityLines[] = [
    'label' => 'DVSwitch Link Active',
    'value' => $dvswitchLinkActive ? 'Yes' : 'No',
];
$activityLines[] = [
    'label' => 'Disconnect Before Connect',
    'value' => $disconnectBeforeConnect ? 'Enabled' : 'Disabled',
];
$activityLines[] = [
    'label' => 'Current Status',
    'value' => $lastStatus,
];
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= e($appName) ?></title>
    <link rel="stylesheet" href="/alltune2/public/assets/css/style.css">
</head>
<body>
<div class="page">
    <header class="topbar">
        <div class="branding">
            <a
                class="branding-link"
                href="<?= e($repoUrl) ?>"
                target="_blank"
                rel="noopener noreferrer"
                aria-label="Open AllTune2 GitHub repository"
            >
                <h1
                    class="branding-title"
                    id="branding-title"
                    data-local-version="<?= e($localVersion) ?>"
                    data-version-url="<?= e($remoteVersionUrl) ?>"
                    title="AllTune2 v<?= e($localVersion) ?>"
                >
                    <span class="branding-title-text"><?= e($appName) ?></span>
                    <span
                        class="branding-title-bolt"
                        id="update-indicator"
                        aria-hidden="true"
                        title="Installed version: v<?= e($localVersion) ?>"
                    >&#9889;</span>
                </h1>
            </a>
            <div class="branding-subtitle">
                Modernized control flow with backend-first switching
            </div>
        </div>

        <nav class="nav" aria-label="Primary">
            <?php foreach ($navItems as $item): ?>
                <a
                    class="nav-button<?= !empty($item['active']) ? ' active' : '' ?>"
                    href="<?= e($item['href']) ?>"
                    <?= isset($item['target']) ? ' target="' . e((string) $item['target']) . '"' : '' ?>
                >
                    <?= e($item['label']) ?>
                </a>
            <?php endforeach; ?>
        </nav>
    </header>

    <?php require __DIR__ . '/alltune2_ribbon_bar.php'; ?>

    <main class="dashboard-grid">
        <section class="left-stack">
            <article class="card">
                <div class="card-header">
                    <span>Control Center</span>
                    <a
                        class="badge control-node-badge"
                        href="<?= e($nodeStatsUrl) ?>"
                        target="_blank"
                        rel="noopener"
                        title="Open AllStar stats for node <?= e($displayMyNode) ?>"
                    >Node <?= e($displayMyNode) ?></a>
                </div>

                <div class="card-body">
                    <form
                        id="control-form"
                        autocomplete="off"
                        data-config-path="/var/www/html/alltune2/config.ini"
                        data-has-real-mynode="<?= $hasRealMyNode ? '1' : '0' ?>"
                        data-has-real-dvswitch-node="<?= $hasRealDvSwitchNode ? '1' : '0' ?>"
                        data-dvswitch-node="<?= e($displayDvSwitchNode) ?>"
                        data-has-real-bm-password="<?= $hasRealBmPassword ? '1' : '0' ?>"
                        data-has-real-tgif-key="<?= $hasRealTgifKey ? '1' : '0' ?>"
                        data-asl-configured="<?= $modeAvailability['ASL'] ? '1' : '0' ?>"
                        data-echo-configured="<?= $modeAvailability['ECHO'] ? '1' : '0' ?>"
                        data-bm-configured="<?= $modeAvailability['BM'] ? '1' : '0' ?>"
                        data-tgif-configured="<?= $modeAvailability['TGIF'] ? '1' : '0' ?>"
                        data-ysf-configured="<?= $modeAvailability['YSF'] ? '1' : '0' ?>"
                        data-dstar-configured="<?= $modeAvailability['DSTAR'] ? '1' : '0' ?>"
                        data-p25-configured="<?= $modeAvailability['P25'] ? '1' : '0' ?>"
                        data-nxdn-configured="<?= $modeAvailability['NXDN'] ? '1' : '0' ?>"
                    >
                        <div class="control-grid">
                            <label class="sr-only" for="target">TG / Node #</label>
                            <input
                                id="target"
                                name="target"
                                class="control"
                                type="text"
                                placeholder="TG / Node #"
                                value="<?= e($targetValue) ?>"
                            >

                            <label class="sr-only" for="mode">Mode</label>
                            <select id="mode" name="mode" class="control">
                                <?php foreach ($modeOptions as $value => $label): ?>
                                    <option value="<?= e($value) ?>" <?= $selectedMode === $value ? 'selected' : '' ?>>
                                        <?= e($label) ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>

                            <button type="button" class="btn btn-primary" id="connect-button">
                                Connect
                            </button>

                            <button type="button" class="btn btn-danger" id="disconnect-button">
                                Disconnect
                            </button>
                        </div>

                        <div class="control-settings-grid">
                            <div class="control-settings-left">
                                <div class="private-link-managed">
                                    <input
                                        type="checkbox"
                                        id="autoload_dvswitch"
                                        name="autoload_dvswitch"
                                        value="1"
                                        class="private-link-managed-input"
                                        <?= $autoloadDvSwitch ? 'checked' : '' ?>
                                        aria-hidden="true"
                                        tabindex="-1"
                                    >

                                    <div class="private-link-managed-card">
                                        <span class="private-link-managed-label">
                                            DVSwitch Private Link<?= $displayDvSwitchNode !== '' ? ' ' . e($displayDvSwitchNode) : '' ?>
                                        </span>
                                        <span class="private-link-managed-value">
                                            Auto-managed
                                        </span>
                                    </div>
                                </div>

                                <label class="checkbox-inline" for="disconnect_before_connect">
                                    <input
                                        type="checkbox"
                                        id="disconnect_before_connect"
                                        name="disconnect_before_connect"
                                        value="1"
                                        <?= $disconnectBeforeConnect ? 'checked' : '' ?>
                                    >
                                    <span>Disconnect before Connect</span>
                                </label>

                                <label class="checkbox-inline" for="audio_alerts">
                                    <input
                                        type="checkbox"
                                        id="audio_alerts"
                                        name="audio_alerts"
                                        value="1"
                                        checked
                                    >
                                    <span>Audio Alerts</span>
                                </label>
                            </div>

                            <div class="control-settings-right">
                                <div style="display:flex; flex-direction:column; align-items:flex-end; gap:6px;">
                                    <div style="display:flex; align-items:center; gap:10px; justify-content:flex-end;">
                                        <button
                                            type="button"
                                            class="btn btn-warning"
                                            id="disconnect-dvswitch-button"
                                        >
                                            Disconnect DVSwitch
                                        </button>

                                        <button
                                            type="button"
                                            class="btn btn-danger"
                                            id="disconnect-all-button"
                                        >
                                            Disconnect All
                                        </button>
                                    </div>

                                    <div style="display:flex; align-items:center; gap:6px; justify-content:flex-end;">
                                        <label
                                            for="dtmf-code"
                                            style="font-size:0.68rem; font-weight:700; letter-spacing:0.06em; text-transform:uppercase; color:#f4a6ff;"
                                        >
                                            DTMF
                                        </label>

                                        <input
                                            id="dtmf-code"
                                            name="dtmf_code"
                                            type="text"
                                            value=""
                                            placeholder="*70 or 1234#"
                                            maxlength="14"
                                            aria-label="DTMF Command"
                                            style="
                                                width:118px;
                                                min-width:118px;
                                                max-width:118px;
                                                height:32px;
                                                padding:0 10px;
                                                border-radius:10px;
                                                border:1px solid rgba(193, 107, 255, 0.70);
                                                background:#05030a;
                                                color:#ffffff;
                                                font-size:0.88rem;
                                                font-weight:700;
                                                box-sizing:border-box;
                                            "
                                        >

                                        <button
                                            type="button"
                                            class="btn btn-primary"
                                            id="send-dtmf-button"
                                            disabled
                                            style="
                                                min-width:78px;
                                                height:32px;
                                                padding:0 14px;
                                                border-radius:10px;
                                                font-size:0.88rem;
                                                font-weight:700;
                                                opacity:0.38;
                                                cursor:not-allowed;
                                                filter:saturate(0.45) brightness(0.88);
                                            "
                                        >
                                            Send
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="control-mode-row">
                            <label class="control-mode-label" for="autoload_dvswitch_mode">
                                Link Mode
                            </label>

                            <select
                                id="autoload_dvswitch_mode"
                                name="autoload_dvswitch_mode"
                                class="control control-compact"
                                aria-label="Link Mode"
                            >
                                <option value="transceive" <?= $autoloadDvSwitchMode === 'transceive' ? 'selected' : '' ?>>
                                    Transceive
                                </option>
                                <option value="local_monitor" <?= $autoloadDvSwitchMode === 'local_monitor' ? 'selected' : '' ?>>
                                    Local Monitor
                                </option>
                            </select>

                            <div class="inline-status-wrap" aria-live="polite">
                                <span class="inline-status-label">Status</span>
                                <span
                                    class="inline-status-value<?= str_starts_with(strtoupper($lastStatus), 'WAITING') ? ' waiting' : '' ?>"
                                    id="system-status"
                                >
                                    <?= e($lastStatus) ?>
                                </span>
                            </div>
                        </div>
                    </form>
                </div>
            </article>

            <article class="card" id="network-center-section">
                <div class="card-header">
                    <span>Network Center</span>
                    <span class="meta-line">Flow and guidance</span>
                </div>
                <div class="card-body">
                    <div class="helper-panel helper-panel-standalone" id="helper-panel">
                        <div class="helper-title">Network Flow</div>
                        <p class="helper-text" id="helper-text">
                            BrandMeister, TGIF, YSF, AllStarLink, and EchoLink are all one-step connects. Enter or load the target and press Connect once. BrandMeister private calls are supported with a single trailing #. Disconnect removes the current managed connection. Disconnect DVSwitch removes only the configured DVSwitch link and stops BM receive mode if it is active. Disconnect All performs a full reset. With Disconnect before Connect off, BM, TGIF, YSF, D-Star, P25, or NXDN can stay up while you add direct AllStarLink or EchoLink connections. When Disconnect before Connect is on, a new managed connect clears the earlier managed session first. When DVSwitch auto-load is enabled, the configured DVSwitch link is loaded using the selected link mode.
                        </p>
                    </div>
                </div>
            </article>
        </section>

        <aside class="right-stack">
            <article class="card">
                <div class="card-header">
                    <span>Live Status</span>
                    <span class="meta-line">Read only</span>
                </div>
                <div class="card-body">
                    <div class="status-grid">
                        <div class="status-box">
                            <div class="status-box-label">BrandMeister</div>
                            <div class="status-box-value" id="status-bm">Idle</div>
                        </div>
                        <div class="status-box">
                            <div class="status-box-label">TGIF</div>
                            <div class="status-box-value" id="status-tgif">Idle</div>
                        </div>
                        <div class="status-box">
                            <div class="status-box-label">YSF</div>
                            <div class="status-box-value" id="status-ysf">Idle</div>
                        </div>
                        <div class="status-box">
                            <div class="status-box-label">D-Star</div>
                            <div class="status-box-value" id="status-dstar">Idle</div>
                        </div>
                        <div class="status-box">
                            <div class="status-box-label">P25</div>
                            <div class="status-box-value" id="status-p25">Idle</div>
                        </div>
                        <div class="status-box">
                            <div class="status-box-label">NXDN</div>
                            <div class="status-box-value" id="status-nxdn">Idle</div>
                        </div>
                        <div class="status-box status-box-wide">
                            <div class="status-box-label">AllStarLink / EchoLink</div>
                            <div class="status-box-value" id="status-allstar">No links</div>
                            <div id="status-allstar-links">
                                <div>No links</div>
                            </div>
                        </div>
                    </div>
                </div>
            </article>

            <article class="card activity-card">
                <div class="card-header">
                    <span>Activity</span>
                    <span class="meta-line">Read only</span>
                </div>
                <div class="card-body">
                    <div class="activity-list">
                        <?php foreach ($activityLines as $line): ?>
                            <div class="activity-row">
                                <div class="activity-label"><?= e($line['label']) ?></div>
                                <div class="activity-value"><?= e($line['value']) ?></div>
                            </div>
                        <?php endforeach; ?>
                    </div>
                </div>
            </article>
        </aside>
    </main>

    <section class="favorites-section" id="favorites-section">
        <article class="card favorites-card">
            <div class="card-header">
                <span>Saved Favorites</span>
                <span class="meta-line favorites-network-line">
                    <span class="shared-label">Shared —</span>
                    <span class="net-bm">BM</span>
                    <span class="separator">/</span>
                    <span class="net-tgif">TGIF</span>
                    <span class="separator">/</span>
                    <span class="net-ysf">YSF</span>
                    <span class="separator">/</span>
                    <span class="net-dstar">D-Star</span>
                    <span class="separator">/</span>
                    <span class="net-p25">P25</span>
                    <span class="separator">/</span>
                    <span class="net-nxdn">NXDN</span>
                    <span class="separator">/</span>
                    <span class="net-asl">AllStar</span>
                    <span class="separator">/</span>
                    <span class="net-echo">EchoLink</span>
                </span>
            </div>
            <div class="card-body card-body-tight">
                <div class="favorites-table-wrap">
                    <table class="favorites-table" id="favorites-table">
                        <thead>
                        <tr>
                            <th>
                                <button type="button" class="favorites-sort-button" data-sort-key="target" data-sort-type="mixed" title="Sort by TG / Node #">
                                    <span class="favorites-sort-label">TG / Node #</span>
                                    <span class="favorites-sort-hint">sort target</span>
                                    <span class="favorites-sort-indicator" aria-hidden="true"></span>
                                </button>
                            </th>
                            <th>
                                <button type="button" class="favorites-sort-button" data-sort-key="name" data-sort-type="text" title="Sort by Station Name">
                                    <span class="favorites-sort-label">Station Name</span>
                                    <span class="favorites-sort-hint">sort name</span>
                                    <span class="favorites-sort-indicator" aria-hidden="true"></span>
                                </button>
                            </th>
                            <th>
                                <button type="button" class="favorites-sort-button" data-sort-key="description" data-sort-type="text" title="Sort by Description">
                                    <span class="favorites-sort-label">Description</span>
                                    <span class="favorites-sort-hint">sort notes</span>
                                    <span class="favorites-sort-indicator" aria-hidden="true"></span>
                                </button>
                            </th>
                            <th>
                                <button type="button" class="favorites-sort-button" data-sort-key="mode" data-sort-type="text" title="Sort by Mode">
                                    <span class="favorites-sort-label">Mode</span>
                                    <span class="favorites-sort-hint">sort network</span>
                                    <span class="favorites-sort-indicator" aria-hidden="true"></span>
                                </button>
                            </th>
                            <th>Action</th>
                        </tr>
                        </thead>
                        <tbody id="favorites-body">
                        <tr>
                            <td colspan="5">Loading favorites...</td>
                        </tr>
                        </tbody>
                    </table>
                </div>
                <div class="favorites-note">
                    Shared favorites for BM, TGIF, YSF, D-Star, P25, NXDN, AllStar, and EchoLink.
                </div>
            </div>
        </article>
    </section>
</div>

<script>
(function () {
    const dtmfInput = document.getElementById('dtmf-code');
    const sendButton = document.getElementById('send-dtmf-button');

    if (!dtmfInput || !sendButton) {
        return;
    }

    const syncDtmfUi = () => {
        const hasValue = String(dtmfInput.value || '').trim() !== '';
        sendButton.disabled = !hasValue;
        sendButton.style.opacity = hasValue ? '1' : '0.45';
        sendButton.style.cursor = hasValue ? 'pointer' : 'not-allowed';
    };

    dtmfInput.addEventListener('input', syncDtmfUi);
    syncDtmfUi();
}());
</script>

<script src="/alltune2/public/assets/js/app.js"></script>
<script>
(function () {
    const dtmfInput = document.getElementById('dtmf-code');
    const sendButton = document.getElementById('send-dtmf-button');

    if (!dtmfInput || !sendButton) {
        return;
    }

    function syncDtmfUi() {
        const hasValue = String(dtmfInput.value || '').trim() !== '';

        sendButton.disabled = !hasValue;
        sendButton.style.opacity = hasValue ? '1' : '0.38';
        sendButton.style.cursor = hasValue ? 'pointer' : 'not-allowed';
        sendButton.style.filter = hasValue ? 'none' : 'saturate(0.45) brightness(0.88)';
    }

    dtmfInput.addEventListener('input', syncDtmfUi);
    syncDtmfUi();
}());
</script>
</body>
</html>
