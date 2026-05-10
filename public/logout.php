<?php
declare(strict_types=1);

session_start();

require_once dirname(__DIR__) . '/app/Support/Config.php';
require_once dirname(__DIR__) . '/app/Support/AppAuth.php';

use App\Support\AppAuth;
use App\Support\Config;

$config = new Config(dirname(__DIR__) . '/config.ini');
$auth = new AppAuth($config);
$auth->logout();

header('Location: /alltune2/public/');
exit;
